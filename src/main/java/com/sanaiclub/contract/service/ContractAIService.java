package com.sanaiclub.contract.service;

/**
 * ============================================================================
 * ContractAIService - 계약서 자동 작성을 위한 AI 호출 서비스 인터페이스
 * ============================================================================
 * 
 * [역할]
 * - 프롬프트를 AI API에 전달하고 응답을 받는 서비스
 * - 계약서 초안 생성에 필요한 AI 호출 기능 제공
 * - AI 서비스 구현체와의 추상화 계층
 * 
 * [설계 원칙]
 * - 단일 책임: AI API 호출만 담당
 * - 이 서비스는 PDF를 모른다 (PDF 처리는 PDFProcessingService)
 * - 이 서비스는 DB를 모른다 (DB 접근은 Mapper)
 * - 이 서비스는 계약 저장을 모른다 (계약 저장은 ContractService)
 * 
 * [구현체]
 * - DeepSeekContractAIServiceImpl: DeepSeek AI API 구현
 * - 다른 AI 서비스로 교체 가능 (인터페이스 기반 설계)
 * 
 * [사용 위치]
 * - ContractAutoFillServiceImpl: AI 초안 생성 시 호출
 * 
 * ============================================================================
 */
public interface ContractAIService {

    /**
     * 계약서 초안 생성을 요청
     * 
     * [기능]
     * - 완성된 프롬프트를 AI API에 전달
     * - AI가 생성한 계약서 초안(JSON)을 반환
     * 
     * [프롬프트]
     * - ContractAutoFillServiceImpl에서 생성한 최종 프롬프트
     * - 프로젝트 정보, 프리랜서 정보, PDF 텍스트, 사용자 입력 내용 포함
     * 
     * [응답 형식]
     * - JSON 문자열 (ContractAutoFillDTO 형식)
     * - 마크다운 코드블록으로 감싸진 경우도 있음 (```json ... ```)
     * 
     * [에러 처리]
     * - AI API 호출 실패 시 예외 발생
     * - 네트워크 오류, API 키 오류 등 처리 필요
     * 
     * @param prompt AI에게 전달할 최종 프롬프트
     *               - 프로젝트 정보, 프리랜서 정보, PDF 텍스트, 사용자 입력 포함
     * @return AI가 생성한 계약서 초안 (JSON 문자열)
     *         - ContractAutoFillDTO 형식의 JSON
     *         - 마크다운 코드블록 포함 가능
     */
    String requestContractDraft(String prompt);

    /**
     * AI 서비스 상태 확인
     * 
     * [기능]
     * - AI 서비스의 현재 상태를 확인
     * - API 키 유효성, 서비스 가용성 등 확인
     * 
     * @return 서비스 상태 문자열
     */
    String getServiceStatus();
}
