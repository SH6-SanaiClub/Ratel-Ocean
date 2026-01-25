package com.sanaiclub.contract.service;


public interface ContractAIService {

    /**
     * 계약서 초안 생성을 요청
     */
    String requestContractDraft(String prompt);

    /**
     * AI 서비스 상태 확인
     */
    String getServiceStatus();
}
