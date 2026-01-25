package com.sanaiclub.payment.service.impl;

import com.sanaiclub.contract.dao.ContractMapper;
import com.sanaiclub.contract.model.vo.ContractVO;
import com.sanaiclub.payment.dao.EscrowMapper;
import com.sanaiclub.payment.model.vo.EscrowStatus;
import com.sanaiclub.payment.model.vo.EscrowVO;
import com.sanaiclub.payment.service.EscrowService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * ============================================================================
 * EscrowServiceImpl - 에스크로 서비스 구현체
 * ============================================================================
 */
@Service
@RequiredArgsConstructor
public class EscrowServiceImpl implements EscrowService {

    private static final Logger logger = LoggerFactory.getLogger(EscrowServiceImpl.class);

    private final EscrowMapper escrowMapper;
    private final ContractMapper contractMapper;

    /**
     * 에스크로 생성
     */
    @Override
    @Transactional
    public EscrowVO createEscrow(Integer paymentId, Integer contractId, Long totalAmount) {
        logger.info("에스크로 생성: paymentId={}, contractId={}, amount={}",
                paymentId, contractId, totalAmount);

        // 1. 계약 정보 조회
        ContractVO contract = contractMapper.selectContractById(contractId);
        if (contract == null) {
            throw new IllegalArgumentException("계약을 찾을 수 없습니다: " + contractId);
        }

        // 2. 에스크로 VO 생성
        EscrowVO escrow = EscrowVO.builder()
                .paymentId(paymentId)
                .contractId(contractId)
                .totalAmount(totalAmount)
                .heldAmount(totalAmount)      // 초기에는 전액 보유
                .releasedAmount(0L)
                .refundedAmount(0L)
                .escrowStatus(EscrowStatus.HOLDING)
                .build();

        // 3. DB 저장
        escrowMapper.insertEscrow(escrow);

        logger.info("에스크로 생성 완료: escrowId={}", escrow.getEscrowId());

        return escrow;
    }

    /**
     * 마일스톤 지급 처리
     */
    @Override
    @Transactional
    public void releaseFunds(Integer escrowId, Long releaseAmount) {
        logger.info("마일스톤 지급: escrowId={}, amount={}", escrowId, releaseAmount);

        // 1. 에스크로 조회
        EscrowVO escrow = escrowMapper.selectEscrowById(escrowId);
        if (escrow == null) {
            throw new IllegalArgumentException("에스크로를 찾을 수 없습니다: " + escrowId);
        }

        // 2. 잔액 확인
        if (escrow.getHeldAmount() < releaseAmount) {
            throw new IllegalStateException("에스크로 잔액 부족: held=" + escrow.getHeldAmount() +
                    ", release=" + releaseAmount);
        }

        // 3. 지급 처리 (held_amount 차감, released_amount 증가)
        int updated = escrowMapper.updateEscrowRelease(escrowId, releaseAmount);

        if (updated == 0) {
            throw new IllegalStateException("에스크로 업데이트 실패");
        }

        logger.info("마일스톤 지급 완료: escrowId={}, released={}", escrowId, releaseAmount);
    }

    /**
     * 환불 처리
     */
    @Override
    @Transactional
    public void refundFunds(Integer escrowId, Long refundAmount) {
        logger.info("환불 처리: escrowId={}, amount={}", escrowId, refundAmount);

        // 1. 에스크로 조회
        EscrowVO escrow = escrowMapper.selectEscrowById(escrowId);
        if (escrow == null) {
            throw new IllegalArgumentException("에스크로를 찾을 수 없습니다: " + escrowId);
        }

        // 2. 잔액 확인
        if (escrow.getHeldAmount() < refundAmount) {
            throw new IllegalStateException("에스크로 잔액 부족: held=" + escrow.getHeldAmount() +
                    ", refund=" + refundAmount);
        }

        // 3. 환불 처리 (held_amount 차감, refunded_amount 증가)
        int updated = escrowMapper.updateEscrowRefund(escrowId, refundAmount);

        if (updated == 0) {
            throw new IllegalStateException("에스크로 업데이트 실패");
        }

        logger.info("환불 처리 완료: escrowId={}, refunded={}", escrowId, refundAmount);
    }

    /**
     * 계약별 에스크로 조회
     */
    @Override
    @Transactional(readOnly = true)
    public EscrowVO getEscrowByContractId(Integer contractId) {
        EscrowVO escrow = escrowMapper.selectEscrowByContractId(contractId);

        if (escrow == null) {
            throw new IllegalArgumentException("에스크로를 찾을 수 없습니다: contractId=" + contractId);
        }

        return escrow;
    }

    /**
     * 환불 가능 금액 조회
     */
    @Override
    @Transactional(readOnly = true)
    public Long getRefundableAmount(Integer contractId) {
        EscrowVO escrow = escrowMapper.selectEscrowByContractId(contractId);

        if (escrow == null) {
            return 0L;
        }

        // 환불 가능 금액 = 현재 보유 금액 (아직 지급 안 된 금액)
        return escrow.getHeldAmount();
    }
}