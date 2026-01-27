package com.sanaiclub.contract.service;

/** 계약서 자동 작성을 위한 AI 호출 서비스 인터페이스. AI API 호출만 담당. */
public interface ContractAIService {

    /** 계약서 초안 생성 요청. 프롬프트를 AI API에 전달하고 JSON 응답 반환. */
    String requestContractDraft(String prompt);

    /** AI 서비스 상태 확인. */
    String getServiceStatus();
}
