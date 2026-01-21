package com.sanaiclub.contract.service;

/**
 * 계약서 자동 작성을 위한 AI 호출 서비스
 *
 * [역할]
 * - 프롬프트를 AI에 전달
 * - 계약서 초안(JSON 또는 텍스트)을 반환
 *
 * [설계 원칙]
 * - 이 서비스는 PDF를 모른다
 * - 이 서비스는 DB를 모른다
 * - 이 서비스는 계약 저장을 모른다
 */
public interface ContractAIService {

    /**
     * 계약서 초안 생성을 요청한다.
     *
     * @param prompt
     *  - AI에게 전달할 최종 프롬프트
     *
     * @return
     *  - AI가 생성한 계약서 초안 (JSON 또는 텍스트)
     */
    String requestContractDraft(String prompt);

    String getServiceStatus();
}
