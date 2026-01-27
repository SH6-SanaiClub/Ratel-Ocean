package com.sanaiclub.payment.service.impl;

import com.fasterxml.jackson.databind.JsonNode;
import com.sanaiclub.contract.dao.ContractMapper;
import com.sanaiclub.contract.dao.ContractMilestoneMapper;
import com.sanaiclub.contract.model.vo.ContractStatus;
import com.sanaiclub.contract.model.vo.MilestoneStatus;
import com.sanaiclub.contract.model.vo.ContractMilestoneVO;
import com.sanaiclub.contract.model.vo.ContractVO;
import com.sanaiclub.payment.dao.PaymentMapper;
import com.sanaiclub.payment.dao.RefundMapper;
import com.sanaiclub.payment.model.dto.RefundRequestDTO;
import com.sanaiclub.payment.model.dto.RefundResponseDTO;
import com.sanaiclub.payment.model.vo.RefundStatus;
import com.sanaiclub.payment.model.vo.PaymentVO;
import com.sanaiclub.payment.model.vo.RefundVO;
import com.sanaiclub.payment.service.RefundService;
import com.sanaiclub.payment.util.PortoneApiClient;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;


@Service
@RequiredArgsConstructor
public class RefundServiceImpl implements RefundService {

    private static final Logger logger = LoggerFactory.getLogger(RefundServiceImpl.class);

    private final RefundMapper refundMapper;
    private final PaymentMapper paymentMapper;
    private final ContractMapper contractMapper;
    private final ContractMilestoneMapper milestoneMapper;
    private final PortoneApiClient portoneApiClient;

    /**
     * 환불 요청
     */
    @Override
    @Transactional
    public RefundResponseDTO requestRefund(RefundRequestDTO request) {
        logger.info("환불 요청 시작: contractId={}, reason={}",
                request.getContractId(), request.getReason());

        try {
            // 1. 계약 정보 조회
            ContractVO contract = contractMapper.selectContractById(request.getContractId());
            if (contract == null) {
                throw new IllegalArgumentException("계약을 찾을 수 없습니다: " + request.getContractId());
            }

            // 2. 결제 정보 조회
            List<PaymentVO> payments = paymentMapper.selectPaymentsByContractId(request.getContractId());
            if (payments.isEmpty()) {
                throw new IllegalStateException("결제 정보를 찾을 수 없습니다.");
            }

            PaymentVO payment = payments.get(0); // 최신 결제

            // 3. 환불 가능 금액 계산 (DEPOSITED 또는 REQUESTED 상태의 마일스톤 합계)
            List<ContractMilestoneVO> milestones = milestoneMapper
                    .selectMilestonesByContractId(request.getContractId());

            Long refundableAmount = milestones.stream()
                    .filter(m -> MilestoneStatus.DEPOSITED.equals(m.getStatus()) ||
                            MilestoneStatus.REQUESTED.equals(m.getStatus()))
                    .mapToLong(ContractMilestoneVO::getAmount)
                    .sum();

            if (refundableAmount <= 0) {
                throw new IllegalStateException("환불 가능한 금액이 없습니다.");
            }

            // 4. 요청된 환불 금액 검증
            Long actualRefundAmount = request.getRefundAmount() != null
                    ? request.getRefundAmount()
                    : refundableAmount;

            if (actualRefundAmount > refundableAmount) {
                throw new IllegalArgumentException("환불 가능 금액을 초과했습니다: " + refundableAmount);
            }

            // 5. 포트원 API로 환불 요청
            JsonNode refundInfo = portoneApiClient.cancelPayment(
                    payment.getImpUid(),
                    actualRefundAmount,
                    refundableAmount, // checksum
                    request.getReason()
            );

            // 6. 환불 정보 저장
            RefundVO refund = RefundVO.builder()
                    .paymentId(payment.getPaymentId())
                    .contractId(request.getContractId())
                    .refundAmount(actualRefundAmount)
                    .reason(request.getReason())
                    .requestedBy(request.getRequestedBy())
                    .refundStatus(RefundStatus.COMPLETED)
                    .impRefundUid(refundInfo.get("imp_uid").asText())
                    .refundedAt(LocalDateTime.now())
                    .build();

            refundMapper.insertRefund(refund);

            // 7. 계약 상태 업데이트 (PAID/SIGNED → TERMINATED)
            contractMapper.updateContractStatus(
                    request.getContractId(),
                    ContractStatus.TERMINATED.name(),
                    request.getReason()
            );

            // 8. 계약 결제 상태 업데이트
            // Note: PaymentStatus는 별도 테이블이 없으므로 contract_status로 관리
            // 환불 시에는 이미 updateContractStatus로 TERMINATED 상태로 변경됨
            // Long totalPayment = payment.getAmount();
            // boolean isFullRefund = actualRefundAmount.equals(totalPayment);
            // PaymentStatus는 contract_status로 관리되므로 별도 업데이트 불필요

            // 9. 미지급 마일스톤 취소 처리
            for (ContractMilestoneVO milestone : milestones) {
                if (MilestoneStatus.DEPOSITED.equals(milestone.getStatus()) ||
                        MilestoneStatus.REQUESTED.equals(milestone.getStatus()) ||
                        MilestoneStatus.WAITING.equals(milestone.getStatus())) {
                    milestoneMapper.updateMilestoneStatus(
                            request.getContractId(),
                            milestone.getStep(),
                            MilestoneStatus.CANCELED.name()
                    );
                }
            }

            logger.info("환불 완료: refundId={}, amount={}", refund.getRefundId(), actualRefundAmount);

            // 10. 응답 DTO 생성
            return RefundResponseDTO.builder()
                    .refundId(refund.getRefundId())
                    .contractId(request.getContractId())
                    .refundAmount(actualRefundAmount)
                    .refundStatus(RefundStatus.COMPLETED)
                    .impRefundUid(refund.getImpRefundUid())
                    .refundedAt(refund.getRefundedAt())
                    .success(true)
                    .message("환불이 완료되었습니다.")
                    .build();

        } catch (Exception e) {
            logger.error("환불 처리 실패: contractId={}", request.getContractId(), e);

            // 실패 정보 저장
            RefundVO failedRefund = RefundVO.builder()
                    .contractId(request.getContractId())
                    .refundAmount(request.getRefundAmount())
                    .reason(request.getReason())
                    .requestedBy(request.getRequestedBy())
                    .refundStatus(RefundStatus.FAILED)
                    .failedReason(e.getMessage())
                    .build();

            refundMapper.insertRefund(failedRefund);

            throw new RuntimeException("환불 처리 중 오류가 발생했습니다: " + e.getMessage(), e);
        }
    }

    /**
     * 환불 가능 금액 조회
     */
    @Override
    @Transactional(readOnly = true)
    public Long getRefundableAmount(Integer contractId) {
        // 마일스톤 기반 계산으로 변경
        List<ContractMilestoneVO> milestones = milestoneMapper
                .selectMilestonesByContractId(contractId);

        Long refundableAmount = milestones.stream()
                .filter(m -> MilestoneStatus.DEPOSITED.equals(m.getStatus()) ||
                        MilestoneStatus.REQUESTED.equals(m.getStatus()))
                .mapToLong(ContractMilestoneVO::getAmount)
                .sum();

        return refundableAmount;
    }

    /**
     * 환불 상태 조회
     */
    @Override
    @Transactional(readOnly = true)
    public RefundResponseDTO getRefundStatus(Integer refundId) {
        RefundVO refund = refundMapper.selectRefundById(refundId);

        if (refund == null) {
            throw new IllegalArgumentException("환불 정보를 찾을 수 없습니다: " + refundId);
        }

        return RefundResponseDTO.builder()
                .refundId(refund.getRefundId())
                .contractId(refund.getContractId())
                .refundAmount(refund.getRefundAmount())
                .refundStatus(refund.getRefundStatus())
                .impRefundUid(refund.getImpRefundUid())
                .refundedAt(refund.getRefundedAt())
                .success(RefundStatus.COMPLETED.equals(refund.getRefundStatus()))
                .message(refund.getFailedReason())
                .build();
    }
}