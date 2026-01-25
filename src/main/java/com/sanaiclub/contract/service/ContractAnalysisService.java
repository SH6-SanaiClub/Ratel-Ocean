package com.sanaiclub.contract.service;

import com.sanaiclub.contract.model.dto.ContractAnalysisDTO;
import com.sanaiclub.contract.model.dto.ContractDetailDTO;
import com.sanaiclub.contract.model.dto.ContractResponseDTO;

/**
 * ============================================================================
 * ContractAnalysisService - 계약서 AI 분석 서비스 인터페이스
 * ============================================================================
 * 
 * [역할]
 * - 프리랜서가 계약을 수락하기 전에 계약서의 위험 요소를 AI로 분석하는 서비스
 * - PDF 계약서, 프로젝트 정보, 계약 조건 등을 종합하여 위험도 평가
 * 
 * [설계 원칙]
 * - 단일 책임: AI 계약 분석만 담당
 * - 이 서비스는 계약 저장을 모른다 (계약 저장은 ContractService)
 * - 이 서비스는 PDF 처리를 모른다 (PDF 처리는 PDFProcessingService)
 * 
 * [구현체]
 * - ContractAnalysisServiceImpl: DeepSeek AI API 구현
 * 
 * [사용 위치]
 * - FreelancerContractController: 프리랜서 계약 분석 리포트 조회
 * 
 * ============================================================================
 */
public interface ContractAnalysisService {

    /**
     * 계약서를 AI로 분석하여 위험도 및 권장사항 제공
     * 
     * [기능]
     * - 계약 상세 정보, 프로젝트 정보, 마일스톤 정보, PDF 텍스트를 종합하여
     *   AI가 계약 위험도를 분석하고 위험 조항을 식별
     * 
     * [처리 흐름]
     * 1. 프롬프트 템플릿 로드
     * 2. 계약 정보, 프로젝트 정보, 마일스톤 정보, PDF 텍스트를 프롬프트에 포함
     * 3. AI API 호출 (DeepSeek)
     * 4. JSON 응답 파싱 및 DTO 변환
     * 
     * [입력 데이터]
     * - contractDetail: 계약 상세 정보 (JOIN 결과)
     * - contract: 계약 정보 (마일스톤 포함)
     * - pdfText: PDF 텍스트 (null 가능, 추출 실패 시 빈 문자열)
     * 
     * [출력 데이터]
     * - ContractAnalysisDTO: 위험도 점수, 위험 조항 목록 등
     * 
     * [에러 처리]
     * - PDF 텍스트 추출 실패: 빈 문자열로 처리하고 계속 진행
     * - AI API 호출 실패: IllegalStateException 발생
     * - JSON 파싱 실패: IllegalStateException 발생
     * 
     * @param contractDetail 계약 상세 정보 (필수)
     * @param contract 계약 정보 (마일스톤 포함, 필수)
     * @param pdfText PDF 텍스트 (null 가능)
     * @return AI 분석 결과 (ContractAnalysisDTO)
     * @throws IllegalStateException AI 분석 실패 시
     */
    ContractAnalysisDTO analyzeContract(
        ContractDetailDTO contractDetail,
        ContractResponseDTO contract,
        String pdfText
    );
}
