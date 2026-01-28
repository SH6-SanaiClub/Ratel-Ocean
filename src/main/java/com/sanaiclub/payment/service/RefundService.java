package com.sanaiclub.payment.service;

import com.sanaiclub.payment.model.dto.RefundRequestDTO;
import com.sanaiclub.payment.model.dto.RefundResponseDTO;


public interface RefundService {

    /**
     * 환불 요청 (계약 취소 시)
     */
    RefundResponseDTO requestRefund(RefundRequestDTO request);

    /**
     * 환불 가능 금액 조회
     */
    Long getRefundableAmount(Integer contractId);

    /**
     * 환불 상태 조회
     */
    RefundResponseDTO getRefundStatus(Integer refundId);
}