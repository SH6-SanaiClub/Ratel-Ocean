// src/main/java/com/sanaiclub/payment/service/impl/PaymentServiceImpl.java
package com.sanaiclub.payment.service.impl;

import com.fasterxml.jackson.databind.JsonNode;
import com.sanaiclub.contract.dao.ContractMapper;
import com.sanaiclub.contract.dao.ContractMilestoneMapper;
import com.sanaiclub.contract.model.dto.ContractDetailDTO;
import com.sanaiclub.contract.model.vo.*;
import com.sanaiclub.payment.dao.PaymentMapper;
import com.sanaiclub.payment.model.dto.*;
import com.sanaiclub.payment.model.vo.PaymentTransactionStatus;
import com.sanaiclub.payment.model.vo.PaymentVO;
import com.sanaiclub.payment.service.PaymentService;
import com.sanaiclub.payment.util.*;
import com.sanaiclub.project.model.vo.ProjectStatus;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PaymentServiceImpl implements PaymentService {

    private static final Logger logger = LoggerFactory.getLogger(PaymentServiceImpl.class);

    private final PaymentMapper paymentMapper;
    private final ContractMapper contractMapper;
    private final ContractMilestoneMapper contractMilestoneMapper;
    private final PortoneApiClient portoneApiClient;

    @Value("${portone.imp.code}")
    private String impCode;

    /**
     * 결제 준비
     */
    @Override
    @Transactional(readOnly = true)
    public PaymentPrepareDTO preparePayment(PaymentRequestDTO request) {
        logger.info("결제 준비 시작: contractId={}", request.getContractId());

        // 1. 계약 정보 조회
        ContractVO contract = contractMapper.selectContractById(request.getContractId());
        if (contract == null) {
            throw new IllegalArgumentException("계약을 찾을 수 없습니다: " + request.getContractId());
        }

        // 2. 계약 상태 검증 (SIGNED 상태여야 함)
        if (!ContractStatus.SIGNED.equals(contract.getContractStatus())) {
            throw new IllegalStateException("결제 가능한 상태가 아닙니다. 현재 상태: " + contract.getContractStatus());
        }

        // 3. 결제 상태 검증 (UNPAID 상태여야 함)
        // Note: PaymentStatus는 별도 컬럼이 없으므로 계약 상태로 판단
        if (ContractStatus.PAID.equals(contract.getContractStatus()) || 
            ContractStatus.COMPLETED.equals(contract.getContractStatus())) {
            throw new IllegalStateException("이미 결제된 계약입니다.");
        }

        // 4. 금액 검증
        if (!request.getAmount().equals(contract.getTotalBudget())) {
            throw new IllegalArgumentException("결제 금액이 계약 금액과 일치하지 않습니다.");
        }

        // 5. merchant_uid 생성
        String merchantUid = MerchantUidGenerator.generate(request.getContractId());

        // 6. 결제 준비 DTO 생성
        PaymentPrepareDTO prepareDTO = PaymentPrepareDTO.builder()
                .merchantUid(merchantUid)
                .contractId(request.getContractId())
                .amount(request.getAmount())
                .name(request.getName())
                .buyerName(request.getBuyerName())
                .buyerEmail(request.getBuyerEmail())
                .buyerTel(request.getBuyerTel())
                .impCode(impCode)
                .build();

        logger.info("결제 준비 완료: merchantUid={}", merchantUid);

        return prepareDTO;
    }

    /**
     * 결제 완료 검증 및 처리
     * 
     * [DB 상태 변화 흐름]
     * 1. 결제 정보 저장 (payments 테이블 INSERT)
     * 2. 모든 마일스톤 상태 변경: WAITING → DEPOSITED (에스크로 입금 완료)
     * 3. 계약 상태 변경: SIGNED → PAID
     * 4. 프로젝트 상태 변경: READY → IN_PROGRESS
     * 
     * [트랜잭션]
     * - @Transactional로 모든 DB 작업이 원자적으로 처리됨
     * - 중간에 실패 시 전체 롤백
     */
    @Override
    @Transactional
    public PaymentResponseDTO completePayment(PaymentCompleteDTO request) {
        logger.info("=== 결제 완료 처리 시작: impUid={} ===", request.getImpUid());

        try {
            // ====================================================================
            // 1단계: 포트원 API로 결제 정보 조회 및 검증
            // ====================================================================
            logger.info("[1단계] 포트원 API 결제 정보 조회 시작");
            JsonNode paymentInfo = portoneApiClient.getPaymentInfo(request.getImpUid());
            logger.info("[1단계] 포트원 API 결제 정보 조회 완료");

            // 2. merchant_uid에서 계약 ID 추출
            String merchantUid = paymentInfo.get("merchant_uid").asText();
            Integer contractId = MerchantUidGenerator.extractContractId(merchantUid);

            if (contractId == null) {
                throw new IllegalArgumentException("잘못된 merchant_uid 형식: " + merchantUid);
            }
            logger.info("[2단계] 계약 ID 추출 완료: contractId={}, merchantUid={}", contractId, merchantUid);

            // ====================================================================
            // 2단계: 계약 정보 조회 및 검증
            // ====================================================================
            logger.info("[3단계] 계약 정보 조회 시작: contractId={}", contractId);
            ContractVO contract = contractMapper.selectContractById(contractId);
            if (contract == null) {
                throw new IllegalArgumentException("계약을 찾을 수 없습니다: " + contractId);
            }
            logger.info("[3단계] 계약 정보 조회 완료: contractId={}, 현재 상태={}, 총 예산={}",
                    contractId, contract.getContractStatus(), contract.getTotalBudget());

            // 계약 상태 검증 (SIGNED 상태여야 결제 가능)
            if (!ContractStatus.SIGNED.equals(contract.getContractStatus())) {
                throw new IllegalStateException(
                        String.format("결제 가능한 상태가 아닙니다. 현재 상태: %s (예상: SIGNED)", contract.getContractStatus()));
            }

            // ====================================================================
            // 3단계: 결제 정보 검증
            // ====================================================================
            logger.info("[4단계] 결제 정보 검증 시작");
            Long actualAmount = paymentInfo.get("amount").asLong();
            if (!PaymentValidator.validate(paymentInfo, merchantUid, contract.getTotalBudget())) {
                throw new IllegalStateException("결제 정보 검증 실패");
            }
            logger.info("[4단계] 결제 정보 검증 완료: 실제 결제 금액={}, 계약 금액={}", actualAmount, contract.getTotalBudget());

            // ====================================================================
            // 4단계: 결제 정보 저장 (DB INSERT)
            // ====================================================================
            logger.info("[5단계] 결제 정보 저장 시작: contractId={}, amount={}", contractId, actualAmount);
            PaymentVO payment = buildPaymentVO(paymentInfo, contractId);
            paymentMapper.insertPayment(payment);
            logger.info("[5단계] 결제 정보 저장 완료: paymentId={}", payment.getPaymentId());

            // ====================================================================
            // 5단계: 모든 마일스톤 상태 변경 (WAITING → DEPOSITED)
            // 에스크로 시스템 특성: 총 예산이 한 번에 입금되므로 모든 마일스톤이 DEPOSITED 상태가 됨
            // ====================================================================
            logger.info("[6단계] 마일스톤 상태 변경 시작: contractId={}", contractId);
            List<ContractMilestoneVO> milestones = contractMilestoneMapper
                    .selectMilestonesByContractId(contractId);

            if (milestones == null || milestones.isEmpty()) {
                logger.warn("[6단계] 마일스톤이 없습니다: contractId={}", contractId);
            } else {
                logger.info("[6단계] 마일스톤 개수: {}개, 상태 변경 시작 (WAITING → DEPOSITED)", milestones.size());
                int updatedCount = 0;
                for (ContractMilestoneVO milestone : milestones) {
                    logger.debug("[6단계] 마일스톤 상태 변경: step={}, milestoneId={}, 현재 상태={} → DEPOSITED",
                            milestone.getStep(), milestone.getMilestoneId(), milestone.getStatus());
                    
                    contractMilestoneMapper.updateMilestoneStatus(
                            contractId,
                            milestone.getStep(),
                            MilestoneStatus.DEPOSITED.name()
                    );
                    updatedCount++;
                }
                logger.info("[6단계] 마일스톤 상태 변경 완료: {}개 마일스톤이 DEPOSITED 상태로 변경됨", updatedCount);
            }

            // ====================================================================
            // 6단계: 계약 상태 변경 (SIGNED → PAID)
            // ====================================================================
            logger.info("[7단계] 계약 상태 변경 시작: contractId={}, SIGNED → PAID", contractId);
            int contractUpdated = contractMapper.updateContractStatus(contractId, ContractStatus.PAID.name(), null);
            if (contractUpdated > 0) {
                logger.info("[7단계] 계약 상태 변경 완료: contractId={}, 상태=PAID", contractId);
            } else {
                logger.warn("[7단계] 계약 상태 변경 실패: contractId={}, 업데이트된 행이 없습니다.", contractId);
            }

            // ====================================================================
            // 7단계: 프로젝트 상태 변경 (READY → IN_PROGRESS)
            // ====================================================================
            logger.info("[8단계] 프로젝트 상태 변경 시작: contractId={}", contractId);
            ContractDetailDTO contractDetail = contractMapper.selectContractDetailWithJoin(contractId);
            if (contractDetail != null && contractDetail.getProjectId() != null) {
                int projectUpdated = contractMapper.updateProjectStatus(
                        contractDetail.getProjectId(),
                        ProjectStatus.IN_PROGRESS.name()
                );
                
                if (projectUpdated > 0) {
                    logger.info("[8단계] 프로젝트 상태 변경 완료: projectId={}, 상태=IN_PROGRESS",
                            contractDetail.getProjectId());
                } else {
                    logger.warn("[8단계] 프로젝트 상태 변경 실패: projectId={}, 업데이트된 행이 없습니다.",
                            contractDetail.getProjectId());
                }
            } else {
                logger.warn("[8단계] 프로젝트 상태 변경 건너뜀: contractId={}, projectId를 찾을 수 없습니다.", contractId);
            }

            // ====================================================================
            // 최종 로깅 및 응답 생성
            // ====================================================================
            logger.info("=== 결제 완료 처리 성공: paymentId={}, contractId={}, amount={} ===",
                    payment.getPaymentId(), contractId, actualAmount);
            logger.info("=== DB 상태 변화 요약 ===");
            logger.info("  - 결제 정보: INSERT 완료 (paymentId={})", payment.getPaymentId());
            logger.info("  - 마일스톤 상태: {}개 마일스톤 WAITING → DEPOSITED",
                    milestones != null ? milestones.size() : 0);
            logger.info("  - 계약 상태: SIGNED → PAID");
            logger.info("  - 프로젝트 상태: READY → IN_PROGRESS");

            // 9. 응답 DTO 생성
            return buildPaymentResponseDTO(payment, true, "결제가 완료되었습니다.");

        } catch (Exception e) {
            logger.error("=== 결제 완료 처리 실패: impUid={} ===", request.getImpUid(), e);
            logger.error("트랜잭션 롤백 예정: 모든 DB 변경사항이 취소됩니다.");
            throw new RuntimeException("결제 처리 중 오류가 발생했습니다: " + e.getMessage(), e);
        }
    }

    /**
     * 포트원 웹훅 처리
     */
    @Override
    @Transactional
    public void handleWebhook(PaymentWebhookDTO webhook) {
        logger.info("웹훅 수신: impUid={}, status={}", webhook.getImpUid(), webhook.getStatus());

        try {
            // 1. 결제 정보 조회
            PaymentVO payment = paymentMapper.selectPaymentByImpUid(webhook.getImpUid());

            if (payment == null) {
                logger.warn("웹훅 처리 실패: 결제 정보 없음 - impUid={}", webhook.getImpUid());
                return;
            }

            // 2. 포트원 상태에 따른 처리
            PaymentTransactionStatus newStatus = PaymentStatusConverter.fromPortone(webhook.getStatus());

            // 3. 결제 상태 업데이트
            paymentMapper.updatePaymentStatus(payment.getPaymentId(), newStatus.name());

            logger.info("웹훅 처리 완료: paymentId={}, status={}", payment.getPaymentId(), newStatus);

        } catch (Exception e) {
            logger.error("웹훅 처리 실패: impUid={}", webhook.getImpUid(), e);
        }
    }

    /**
     * 결제 정보 조회 (imp_uid 기준)
     */
    @Override
    @Transactional(readOnly = true)
    public PaymentResponseDTO getPaymentByImpUid(String impUid) {
        PaymentVO payment = paymentMapper.selectPaymentByImpUid(impUid);

        if (payment == null) {
            throw new IllegalArgumentException("결제 정보를 찾을 수 없습니다: " + impUid);
        }

        return buildPaymentResponseDTO(payment, true, null);
    }

    /**
     * 계약별 결제 정보 조회
     */
    @Override
    @Transactional(readOnly = true)
    public PaymentResponseDTO getPaymentByContractId(Integer contractId) {
        PaymentVO payment = paymentMapper.selectPaymentsByContractId(contractId)
                .stream()
                .findFirst()
                .orElse(null);

        if (payment == null) {
            throw new IllegalArgumentException("결제 정보를 찾을 수 없습니다: contractId=" + contractId);
        }

        return buildPaymentResponseDTO(payment, true, null);
    }

    /**
     * 결제 페이지용 계약 정보 조회 및 검증
     */
    @Override
    @Transactional(readOnly = true)
    public ContractVO getContractForPayment(Integer contractId) {
        logger.info("결제 페이지용 계약 조회: contractId={}", contractId);

        // 1. 계약 정보 조회
        ContractVO contract = contractMapper.selectContractById(contractId);
        if (contract == null) {
            throw new IllegalArgumentException("계약을 찾을 수 없습니다: " + contractId);
        }

        // 2. 계약 상태 검증 (SIGNED 상태여야 결제 가능)
        if (!ContractStatus.SIGNED.equals(contract.getContractStatus())) {
            throw new IllegalStateException("결제 가능한 상태가 아닙니다. 현재 상태: " + contract.getContractStatus());
        }

        // 3. 결제 상태 검증 (PAID 상태가 아니어야 함)
        // Note: PaymentStatus는 별도 컬럼이 없으므로 계약 상태로 판단
        if (ContractStatus.PAID.equals(contract.getContractStatus()) || 
            ContractStatus.COMPLETED.equals(contract.getContractStatus())) {
            throw new IllegalStateException("이미 결제된 계약입니다.");
        }

        return contract;
    }

    /**
     * 결제 완료된 계약 정보 조회 (성공 페이지용)
     */
    @Override
    @Transactional(readOnly = true)
    public ContractVO getContractById(Integer contractId) {
        logger.info("계약 정보 조회: contractId={}", contractId);

        ContractVO contract = contractMapper.selectContractById(contractId);
        if (contract == null) {
            throw new IllegalArgumentException("계약을 찾을 수 없습니다: " + contractId);
        }

        return contract;
    }

    // ========================================================================
    // Private Helper Methods
    // ========================================================================

    /**
     * 포트원 응답 → PaymentVO 변환
     */
    private PaymentVO buildPaymentVO(JsonNode paymentInfo, Integer contractId) {
        Long paidAtTimestamp = paymentInfo.get("paid_at").asLong();
        LocalDateTime paidAt = LocalDateTime.ofInstant(
                Instant.ofEpochSecond(paidAtTimestamp),
                ZoneId.systemDefault()
        );

        return PaymentVO.builder()
                .contractId(contractId)
                .impUid(paymentInfo.get("imp_uid").asText())
                .merchantUid(paymentInfo.get("merchant_uid").asText())
                .amount(paymentInfo.get("amount").asLong())
                .paymentMethod(paymentInfo.get("pay_method").asText())
                .paymentStatus(PaymentTransactionStatus.PAID)
                .paidAt(paidAt)
                .buyerName(paymentInfo.has("buyer_name") ? paymentInfo.get("buyer_name").asText() : null)
                .buyerEmail(paymentInfo.has("buyer_email") ? paymentInfo.get("buyer_email").asText() : null)
                .buyerTel(paymentInfo.has("buyer_tel") ? paymentInfo.get("buyer_tel").asText() : null)
                .pgProvider(paymentInfo.has("pg_provider") ? paymentInfo.get("pg_provider").asText() : null)
                .pgTid(paymentInfo.has("pg_tid") ? paymentInfo.get("pg_tid").asText() : null)
                .cardName(paymentInfo.has("card_name") ? paymentInfo.get("card_name").asText() : null)
                .cardNumber(paymentInfo.has("card_number") ? paymentInfo.get("card_number").asText() : null)
                .receiptUrl(paymentInfo.has("receipt_url") ? paymentInfo.get("receipt_url").asText() : null)
                .build();
    }

    /**
     * PaymentVO → PaymentResponseDTO 변환
     */
    private PaymentResponseDTO buildPaymentResponseDTO(PaymentVO payment, Boolean success, String message) {
        return PaymentResponseDTO.builder()
                .paymentId(payment.getPaymentId())
                .contractId(payment.getContractId())
                .impUid(payment.getImpUid())
                .merchantUid(payment.getMerchantUid())
                .amount(payment.getAmount())
                .paymentMethod(payment.getPaymentMethod())
                .paymentStatus(PaymentStatus.PAID) // contract의 payment_status
                .paidAt(payment.getPaidAt())
                .receiptUrl(payment.getReceiptUrl())
                .success(success)
                .message(message)
                .build();
    }
}