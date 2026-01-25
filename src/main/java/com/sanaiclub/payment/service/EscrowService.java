package com.sanaiclub.payment.service;

import com.sanaiclub.payment.model.vo.EscrowVO;


public interface EscrowService {

    /**
     * 에스크로 생성 (결제 완료 시)
     */
    EscrowVO createEscrow(Integer paymentId, Integer contractId, Long totalAmount);

    /**
     * 마일스톤 지급 처리 (held_amount 차감)
     */
    void releaseFunds(Integer escrowId, Long releaseAmount);

    /**
     * 환불 처리 (held_amount 차감, refunded_amount 증가)
     */
    void refundFunds(Integer escrowId, Long refundAmount);

    /**
     * 계약별 에스크로 조회
     */
    EscrowVO getEscrowByContractId(Integer contractId);

    /**
     * 환불 가능 금액 조회
     */
    Long getRefundableAmount(Integer contractId);
}