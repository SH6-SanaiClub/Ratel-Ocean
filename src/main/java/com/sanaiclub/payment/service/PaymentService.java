package com.sanaiclub.payment.service;

import com.sanaiclub.contract.model.vo.ContractVO;
import com.sanaiclub.payment.model.dto.*;


public interface PaymentService {

    /**
     * 결제 준비 (merchant_uid 생성 및 검증)
     */
    PaymentPrepareDTO preparePayment(PaymentRequestDTO request);

    /**
     * 결제 완료 검증 및 처리
     */
    PaymentResponseDTO completePayment(PaymentCompleteDTO request);

    /**
     * 포트원 웹훅 처리
     */
    void handleWebhook(PaymentWebhookDTO webhook);

    /**
     * 결제 정보 조회 (imp_uid 기준)
     */
    PaymentResponseDTO getPaymentByImpUid(String impUid);

    /**
     * 계약별 결제 정보 조회
     */
    PaymentResponseDTO getPaymentByContractId(Integer contractId);

    /**
     * 결제 페이지용 계약 정보 조회 및 검증
     */
    ContractVO getContractForPayment(Integer contractId);

    /**
     * 결제 완료된 계약 정보 조회 (성공 페이지용)
     */
    ContractVO getContractById(Integer contractId);
}