package com.sanaiclub.contract.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.sanaiclub.contract.model.dto.ContractAnalysisDTO;
import com.sanaiclub.contract.model.dto.ContractDetailDTO;
import com.sanaiclub.contract.model.dto.ContractMilestoneResponseDTO;
import com.sanaiclub.contract.model.dto.ContractResponseDTO;
import com.sanaiclub.contract.util.PromptTemplateLoader;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * ============================================================================
 * ContractAnalysisServiceImpl - 계약서 AI 분석 서비스 구현체
 * ============================================================================
 * 
 * [역할]
 * - ContractAnalysisService 인터페이스의 구현체
 * - 프리랜서가 계약을 수락하기 전에 계약서의 위험 요소를 AI로 분석
 * 
 * [처리 흐름]
 * 1. 프롬프트 템플릿 로드
 * 2. 마일스톤 정보를 JSON 문자열로 변환 (있는 경우)
 * 3. 모든 치환 필드(${...})를 실제 값으로 치환 (null 안전 처리)
 * 4. AI API 호출 (ContractAIService)
 * 5. JSON 응답 파싱 및 DTO 변환
 * 
 * [의존성]
 * - ContractAIService: AI API 호출
 * - PromptTemplateLoader: 프롬프트 템플릿 로딩
 * 
 * [책임 분리]
 * - AI 호출: ContractAIService에 위임
 * - 프롬프트 생성: 이 서비스에서 담당
 * - JSON 파싱: 이 서비스에서 담당
 * 
 * ============================================================================
 */
@Slf4j
@Service
public class ContractAnalysisServiceImpl implements ContractAnalysisService {

    private final ContractAIService contractAIService;

    public ContractAnalysisServiceImpl(ContractAIService contractAIService) {
        this.contractAIService = contractAIService;
    }

    @Override
    public ContractAnalysisDTO analyzeContract(
        ContractDetailDTO contractDetail,
        ContractResponseDTO contract,
        String pdfText
    ) {
        // ====================================================================
        // 1단계: 프롬프트 템플릿 로드
        // ====================================================================
        
        String template = PromptTemplateLoader.load(
            "contract/prompts/contract_analysis_prompt.txt"
        );

        // ====================================================================
        // 2단계: 마일스톤 정보를 JSON 문자열로 변환
        // ====================================================================
        
        String milestonesJson = milestonesToJson(contract.getMilestones());

        // ====================================================================
        // 3단계: 프롬프트 완성 (null 안전 처리)
        // ====================================================================
        
        log.debug("AI 계약 분석 프롬프트 생성 - contractId={}", 
            contract != null ? contract.getContractId() : "null");

        String finalPrompt = template
            // 계약 기본 정보
            .replace("${contractId}", safe(contract != null ? contract.getContractId() : null))
            .replace("${contractStartDate}", safe(contract != null ? contract.getContractStartDate() : null))
            .replace("${contractEndDate}", safe(contract != null ? contract.getContractEndDate() : null))
            .replace("${totalBudget}", safe(contract != null ? contract.getTotalBudget() : null))
            .replace("${paymentMethod}", safe(contract != null ? contract.getPaymentMethod() : null))
            .replace("${contractStatus}", safe(contract != null ? contract.getContractStatus() : null))
            .replace("${contractedAt}", safe(contract != null ? contract.getContractedAt() : null))
            
            // 프로젝트 정보
            .replace("${projectId}", safe(contractDetail != null && contractDetail.getProject() != null 
                ? contractDetail.getProject().getProjectId() : null))
            .replace("${projectTitle}", safe(contractDetail != null && contractDetail.getProject() != null 
                ? contractDetail.getProject().getTitle() : null))
            .replace("${projectDescription}", safe(contractDetail != null && contractDetail.getProject() != null 
                ? contractDetail.getProject().getDescription() : null))
            .replace("${projectBudget}", safe(contractDetail != null && contractDetail.getProject() != null 
                ? contractDetail.getProject().getBudget() : null))
            .replace("${projectStartDate}", safe(contractDetail != null && contractDetail.getProject() != null 
                ? contractDetail.getProject().getStartDate() : null))
            .replace("${projectDeadlineDate}", safe(contractDetail != null && contractDetail.getProject() != null 
                ? contractDetail.getProject().getDeadlineDate() : null))
            .replace("${projectEstDuration}", safe(contractDetail != null && contractDetail.getProject() != null 
                ? contractDetail.getProject().getEstDuration() : null))
            .replace("${projectPaymentMethod}", safe(contractDetail != null && contractDetail.getProject() != null 
                ? contractDetail.getProject().getPaymentMethod() : null))
            .replace("${communicateMethod}", safe(contractDetail != null && contractDetail.getProject() != null 
                ? contractDetail.getProject().getCommunicateMethod() : null))
            
            // 클라이언트 정보
            .replace("${clientName}", safe(contractDetail != null && contractDetail.getClientUser() != null 
                ? contractDetail.getClientUser().getName() : null))
            .replace("${clientEmail}", safe(contractDetail != null && contractDetail.getClientUser() != null 
                ? contractDetail.getClientUser().getEmail() : null))
            .replace("${clientPhone}", safe(contractDetail != null && contractDetail.getClientUser() != null 
                ? contractDetail.getClientUser().getPhone() : null))
            .replace("${companyName}", safe(contractDetail != null && contractDetail.getCompany() != null 
                ? contractDetail.getCompany().getCompanyName() : null))
            
            // 마일스톤 정보
            .replace("${milestonesJson}", milestonesJson)
            
            // PDF 텍스트
            .replace("${pdfText}", safe(pdfText));

        log.debug("AI 프롬프트 생성 완료");

        // ====================================================================
        // 4단계: AI API 호출
        // ====================================================================
        
        log.info("AI 계약 분석 요청");
        String aiResponse = contractAIService.requestContractDraft(finalPrompt);
        log.debug("AI 응답 수신 완료");

        // ====================================================================
        // 5단계: JSON 파싱 및 DTO 변환
        // ====================================================================
        
        ContractAnalysisDTO analysis = parseResponse(aiResponse);
        log.info("AI 계약 분석 완료");
        return analysis;
    }

    /**
     * 마일스톤 목록을 JSON 문자열로 변환
     * 
     * @param milestones 마일스톤 목록 (null 가능)
     * @return JSON 문자열 (빈 배열 또는 마일스톤 JSON 배열)
     */
    private String milestonesToJson(List<ContractMilestoneResponseDTO> milestones) {
        if (milestones == null || milestones.isEmpty()) {
            return "[]";
        }
        try {
            ObjectMapper mapper = new ObjectMapper();
            return mapper.writeValueAsString(milestones);
        } catch (Exception e) {
            log.warn("마일스톤 JSON 변환 실패: {}", e.getMessage());
            return "[]";
        }
    }

    /**
     * AI 응답 JSON 파싱
     * 
     * [기능]
     * - AI가 반환한 JSON 문자열을 ContractAnalysisDTO로 변환
     * - 마크다운 코드블록 제거 (```json ... ``` 형식)
     * - Jackson ObjectMapper를 사용하여 JSON 파싱
     * 
     * [처리]
     * 1. 마크다운 코드블록 제거 (```json ... ```)
     * 2. Jackson ObjectMapper로 JSON 파싱
     * 3. ContractAnalysisDTO로 변환
     * 
     * [에러 처리]
     * - 파싱 실패 시 IllegalStateException 발생
     * - 원문 JSON을 로그에 기록
     * 
     * @param json AI가 반환한 JSON 문자열
     * @return ContractAnalysisDTO 객체
     * @throws IllegalStateException JSON 파싱 실패 시
     */
    private ContractAnalysisDTO parseResponse(String json) {
        try {
            // 마크다운 코드블록 제거
            if (json.startsWith("```json")) {
                json = json.replaceFirst("```json", "").trim();
            }
            if (json.endsWith("```")) {
                json = json.substring(0, json.lastIndexOf("```")).trim();
            }
            
            ObjectMapper mapper = new ObjectMapper();
            return mapper.readValue(json, ContractAnalysisDTO.class);
        } catch (Exception e) {
            log.error("AI 분석 결과 파싱 실패 - 원문: {}", json, e);
            throw new IllegalStateException("AI 분석 결과 파싱 실패", e);
        }
    }

    /**
     * 안전한 문자열 변환
     * 
     * [기능]
     * - null 값을 빈 문자열로 변환
     * - 프롬프트 치환 시 null 값으로 인한 오류 방지
     * 
     * @param o 변환할 객체
     * @return 문자열 (null이면 빈 문자열)
     */
    private String safe(Object o) {
        return o == null ? "" : o.toString();
    }
}
