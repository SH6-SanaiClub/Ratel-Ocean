package com.sanaiclub.payment.service.impl;

import com.sanaiclub.contract.dao.ContractMapper;
import com.sanaiclub.contract.dao.ContractMilestoneMapper;
import com.sanaiclub.contract.model.vo.ContractStatus;
import com.sanaiclub.contract.model.vo.MilestoneStatus;
import com.sanaiclub.contract.model.vo.ContractMilestoneVO;
import com.sanaiclub.contract.model.vo.ContractVO;
import com.sanaiclub.payment.dao.EscrowMapper;
import com.sanaiclub.payment.dao.WalletMapper;
import com.sanaiclub.payment.model.dto.PayoutRequestDTO;
import com.sanaiclub.payment.model.dto.PayoutResponseDTO;
import com.sanaiclub.payment.model.vo.WalletIoType;
import com.sanaiclub.payment.model.vo.EscrowVO;
import com.sanaiclub.payment.model.vo.FreelancerWalletVO;
import com.sanaiclub.payment.model.vo.WalletHistoryVO;
import com.sanaiclub.payment.service.PayoutService;
import com.sanaiclub.payment.service.EscrowService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;


@Service
@RequiredArgsConstructor
public class PayoutServiceImpl implements PayoutService {

    private static final Logger logger = LoggerFactory.getLogger(PayoutServiceImpl.class);

    private final ContractMapper contractMapper;
    private final ContractMilestoneMapper milestoneMapper;
    private final EscrowMapper escrowMapper;
    private final WalletMapper walletMapper;
    private final EscrowService escrowService;

    /**
     * 마일스톤 지급 (클라이언트가 직접 지급)
     */
    @Override
    @Transactional
    public PayoutResponseDTO releaseMilestone(Integer contractId, Integer milestoneId, Integer userId) {
        logger.info("마일스톤 지급 시작: contractId={}, milestoneId={}, userId={}",
                contractId, milestoneId, userId);

        // 1. 계약 정보 조회
        ContractVO contract = contractMapper.selectContractById(contractId);
        if (contract == null) {
            throw new IllegalArgumentException("계약을 찾을 수 없습니다: " + contractId);
        }

        // 2. 계약 상태 검증 (PAID 상태여야 함)
        if (!ContractStatus.PAID.name().equals(contract.getContractStatus())) {
            throw new IllegalStateException("지급 가능한 상태가 아닙니다: " + contract.getContractStatus());
        }

        // 3. 마일스톤 정보 조회
        ContractMilestoneVO milestone = milestoneMapper.selectMilestoneById(milestoneId);
        if (milestone == null) {
            throw new IllegalArgumentException("마일스톤을 찾을 수 없습니다: " + milestoneId);
        }

        // 4. 마일스톤 상태 검증 (DEPOSITED 상태여야 함)
        if (!MilestoneStatus.DEPOSITED.name().equals(milestone.getStatus())) {
            throw new IllegalStateException("지급 가능한 마일스톤 상태가 아닙니다: " + milestone.getStatus());
        }

        // 5. 에스크로 조회
        EscrowVO escrow = escrowMapper.selectEscrowByContractId(contractId);
        if (escrow == null) {
            throw new IllegalStateException("에스크로를 찾을 수 없습니다: contractId=" + contractId);
        }

        // 6. 프리랜서 ID 추출 (origin_contract_url에서)
        Integer freelancerId = extractFreelancerIdFromContract(contract);

        // 7. 프리랜서 지갑 조회
        FreelancerWalletVO wallet = walletMapper.selectWalletByUserId(freelancerId);
        if (wallet == null) {
            throw new IllegalArgumentException("프리랜서 지갑을 찾을 수 없습니다: userId=" + freelancerId);
        }

        // 8. 에스크로에서 지급 (held_amount 차감)
        escrowService.releaseFunds(escrow.getEscrowId(), milestone.getAmount());

        // 9. 프리랜서 지갑에 입금 (트리거가 자동으로 잔액 업데이트)
        WalletHistoryVO history = WalletHistoryVO.builder()
                .walletId(wallet.getWalletId())
                .ioType(WalletIoType.PAYMENT)
                .amount(milestone.getAmount())
                .summary(String.format("마일스톤 %d단계 지급: %s",
                        milestone.getStep(), milestone.getTitle()))
                .build();

        walletMapper.insertWalletHistory(history);

        // 10. 마일스톤 상태 업데이트 (DEPOSITED → PAID)
        milestoneMapper.updateMilestoneStatus(milestoneId, MilestoneStatus.PAID);

        // 11. 모든 마일스톤이 지급되었는지 확인
        List<ContractMilestoneVO> allMilestones = milestoneMapper.selectMilestonesByContractId(contractId);
        boolean allPaid = allMilestones.stream()
                .allMatch(m -> MilestoneStatus.PAID.equals(m.getStatus()));

        if (allPaid) {
            // 모든 마일스톤 지급 완료 → 계약 완료
            contractMapper.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);
            logger.info("모든 마일스톤 지급 완료, 계약 종료: contractId={}", contractId);
        }

        // 12. 지갑 잔액 다시 조회 (업데이트된 값)
        wallet = walletMapper.selectWalletByUserId(freelancerId);

        // 13. 에스크로 잔액 다시 조회
        escrow = escrowMapper.selectEscrowById(escrow.getEscrowId());

        logger.info("마일스톤 지급 완료: milestoneId={}, amount={}", milestoneId, milestone.getAmount());

        // 14. 응답 DTO 생성
        return PayoutResponseDTO.builder()
                .milestoneId(milestoneId)
                .contractId(contractId)
                .amount(milestone.getAmount())
                .milestoneStatus(MilestoneStatus.PAID)
                .walletBalance(wallet.getBalance())
                .escrowHeldAmount(escrow.getHeldAmount())
                .paidAt(LocalDateTime.now())
                .success(true)
                .message("마일스톤 지급이 완료되었습니다.")
                .build();
    }

    /**
     * 마일스톤 지급 요청 (프리랜서가 승인 요청)
     */
    @Override
    @Transactional
    public void requestPayout(PayoutRequestDTO request) {
        logger.info("마일스톤 지급 요청: milestoneId={}, userId={}",
                request.getMilestoneId(), request.getRequestedBy());

        // 1. 마일스톤 정보 조회
        ContractMilestoneVO milestone = milestoneMapper.selectMilestoneById(request.getMilestoneId());
        if (milestone == null) {
            throw new IllegalArgumentException("마일스톤을 찾을 수 없습니다: " + request.getMilestoneId());
        }

        // 2. 마일스톤 상태 검증 (DEPOSITED 상태여야 함)
        if (!MilestoneStatus.DEPOSITED.name().equals(milestone.getStatus())) {
            throw new IllegalStateException("요청 가능한 마일스톤 상태가 아닙니다: " + milestone.getStatus());
        }

        // 3. 마일스톤 상태 업데이트 (DEPOSITED → REQUESTED)
        milestoneMapper.updateMilestoneStatus(request.getMilestoneId(), MilestoneStatus.REQUESTED);

        logger.info("마일스톤 지급 요청 완료: milestoneId={}", request.getMilestoneId());

        // TODO: 클라이언트에게 알림 전송
    }

    /**
     * 마일스톤 지급 승인 (클라이언트가 승인)
     */
    @Override
    @Transactional
    public PayoutResponseDTO approvePayout(Integer milestoneId, Integer userId) {
        logger.info("마일스톤 지급 승인: milestoneId={}, userId={}", milestoneId, userId);

        // 1. 마일스톤 정보 조회
        ContractMilestoneVO milestone = milestoneMapper.selectMilestoneById(milestoneId);
        if (milestone == null) {
            throw new IllegalArgumentException("마일스톤을 찾을 수 없습니다: " + milestoneId);
        }

        // 2. 마일스톤 상태 검증 (REQUESTED 상태여야 함)
        if (!MilestoneStatus.REQUESTED.name().equals(milestone.getStatus())) {
            throw new IllegalStateException("승인 가능한 마일스톤 상태가 아닙니다: " + milestone.getStatus());
        }

        // 3. 지급 처리 (releaseMilestone과 동일한 로직)
        return releaseMilestone(milestone.getContractId(), milestoneId, userId);
    }

    /**
     * FIXED 방식 전액 지급
     */
    @Override
    @Transactional
    public PayoutResponseDTO releaseFullAmount(Integer contractId, Integer userId) {
        logger.info("전액 지급 시작: contractId={}, userId={}", contractId, userId);

        // 1. 계약 정보 조회
        ContractVO contract = contractMapper.selectContractById(contractId);
        if (contract == null) {
            throw new IllegalArgumentException("계약을 찾을 수 없습니다: " + contractId);
        }

        // 2. 결제 방식 검증 (FIXED여야 함)
        if (!"FIXED".equals(contract.getPaymentMethod()) && !"FULL".equals(contract.getPaymentMethod())) {
            throw new IllegalStateException("FIXED 방식이 아닙니다: " + contract.getPaymentMethod());
        }

        // 3. 계약 상태 검증 (PAID 상태여야 함)
        if (!ContractStatus.PAID.name().equals(contract.getContractStatus())) {
            throw new IllegalStateException("지급 가능한 상태가 아닙니다: " + contract.getContractStatus());
        }

        // 4. 에스크로 조회
        EscrowVO escrow = escrowMapper.selectEscrowByContractId(contractId);
        if (escrow == null) {
            throw new IllegalStateException("에스크로를 찾을 수 없습니다: contractId=" + contractId);
        }

        // 5. 프리랜서 ID 추출
        Integer freelancerId = extractFreelancerIdFromContract(contract);

        // 6. 프리랜서 지갑 조회
        FreelancerWalletVO wallet = walletMapper.selectWalletByUserId(freelancerId);
        if (wallet == null) {
            throw new IllegalArgumentException("프리랜서 지갑을 찾을 수 없습니다: userId=" + freelancerId);
        }

        // 7. 에스크로에서 전액 지급
        Long totalAmount = escrow.getHeldAmount();
        escrowService.releaseFunds(escrow.getEscrowId(), totalAmount);

        // 8. 프리랜서 지갑에 입금
        WalletHistoryVO history = WalletHistoryVO.builder()
                .walletId(wallet.getWalletId())
                .ioType(WalletIoType.PAYMENT)
                .amount(totalAmount)
                .summary(String.format("계약 %d 전액 지급", contractId))
                .build();

        walletMapper.insertWalletHistory(history);

        // 9. 계약 상태 업데이트 (PAID → COMPLETED)
        contractMapper.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);

        // 10. 지갑 잔액 다시 조회
        wallet = walletMapper.selectWalletByUserId(freelancerId);

        logger.info("전액 지급 완료: contractId={}, amount={}", contractId, totalAmount);

        // 11. 응답 DTO 생성
        return PayoutResponseDTO.builder()
                .contractId(contractId)
                .amount(totalAmount)
                .walletBalance(wallet.getBalance())
                .escrowHeldAmount(0L)
                .paidAt(LocalDateTime.now())
                .success(true)
                .message("전액 지급이 완료되었습니다.")
                .build();
    }

    // ========================================================================
    // Private Helper Methods
    // ========================================================================

    /**
     * origin_contract_url에서 프리랜서 ID 추출
     * 형식: contracts/{clientId}/{projectId}/{freelancerId}/{filename}
     */
    private Integer extractFreelancerIdFromContract(ContractVO contract) {
        String url = contract.getOriginContractUrl();
        if (url == null || url.isEmpty()) {
            throw new IllegalStateException("계약서 URL이 없습니다.");
        }

        try {
            String[] parts = url.split("/");
            if (parts.length >= 4) {
                return Integer.parseInt(parts[3]); // freelancerId
            }
        } catch (Exception e) {
            logger.error("프리랜서 ID 추출 실패: url={}", url, e);
        }

        throw new IllegalStateException("프리랜서 ID를 추출할 수 없습니다: " + url);
    }
}