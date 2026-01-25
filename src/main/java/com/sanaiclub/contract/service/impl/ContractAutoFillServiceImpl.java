package com.sanaiclub.contract.service.impl;

import com.sanaiclub.contract.model.dto.ContractAutoFillDTO;
import com.sanaiclub.contract.service.ContractAutoFillService;
import com.sanaiclub.contract.service.PDFProcessingService;
import com.sanaiclub.contract.service.ContractAIService;

import com.sanaiclub.project.model.vo.ProjectsVO;
import com.sanaiclub.user.model.vo.UserVO;
import com.sanaiclub.user.model.vo.FreelancerProfileVO;

import com.sanaiclub.contract.util.PromptTemplateLoader;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.File;


@Slf4j
@Service
@RequiredArgsConstructor
public class ContractAutoFillServiceImpl implements ContractAutoFillService {

    private final PDFProcessingService pdfProcessingService;
    private final ContractAIService contractAIService;

    /**
     * 계약 주요 정보 초안 생성
     */
    @Override
    public ContractAutoFillDTO generateDraft(
            File pdfFile,
            String manualText,
            ProjectsVO project,
            UserVO freelancerUser,
            FreelancerProfileVO freelancerProfile
    ) {

        // ====================================================================
        // 1단계: 파라미터 검증
        // ====================================================================
        
        // Controller에서 전달받은 정보 검증
        // 프로젝트와 프리랜서 정보는 필수
        if (project == null || freelancerUser == null) {
            throw new IllegalStateException("프로젝트 또는 프리랜서 정보 없음");
        }

        // ====================================================================
        // 2단계: 날짜 계산
        // ====================================================================
        
        // AI에 맡기지 않고 Java에서 확정
        // 프로젝트 기간을 기반으로 계약 기간 설정
        String startDate = (project.getStartDate() != null)
            ? project.getStartDate().toString()  // 프로젝트 시작일 사용
            : java.time.LocalDate.now().plusDays(7).toString();  // 기본값: 현재 + 7일
        
        String endDate = (project.getDeadlineDate() != null)
            ? project.getDeadlineDate().toString()  // 프로젝트 마감일 사용
            : java.time.LocalDate.parse(startDate).plusMonths(2).toString();  // 기본값: 시작일 + 2개월

        // ====================================================================
        // 3단계: PDF 텍스트 추출
        // ====================================================================
        
        // PDF가 있으면 텍스트 추출
        // PDF가 없거나 추출 실패해도 계속 진행 (manualText만으로도 초안 생성 가능)
        String pdfText = null;
        if (pdfFile != null) {
            try {
                pdfText = pdfProcessingService.extractText(pdfFile);
            } catch (Exception e) {
                log.error("PDF 추출 에러: {}", e.getMessage(), e);
                pdfText = "";  // 추출 실패 시 빈 문자열로 처리
            }
        }
        if (pdfText == null) pdfText = "";

        // ====================================================================
        // 4단계: 프롬프트 템플릿 로딩
        // ====================================================================
        
        // resources/contract/prompts/contract_autofill_prompt.txt 파일 로드
        // 프롬프트 템플릿에는 ${projectId}, ${pdfText} 등의 치환 필드 포함
        String template = PromptTemplateLoader.load(
            "contract/prompts/contract_autofill_prompt.txt"
        );

        // ====================================================================
        // 5단계: 프롬프트 완성
        // ====================================================================
        
        // 모든 치환 필드(${...})를 실제 값으로 치환
        log.debug("프롬프트 생성 - projectId={}, projectTitle={}, freelancerId={}", 
            project.getProjectId(), project.getTitle(), freelancerUser.getUserId());

        // 예산 값 처리 (null이면 "0"으로 설정)
        String budgetValue = (project.getBudget() != null) ? String.valueOf(project.getBudget()) : "0";
        
        // 프롬프트 템플릿의 모든 치환 필드를 실제 값으로 치환
        String finalPrompt = template
            .replace("${projectId}", safe(project.getProjectId()))
            .replace("${projectTitle}", safe(project.getTitle()))
            .replace("${projectDescription}", safe(project.getDescription()))
            .replace("${projectBudget}", budgetValue)
            .replace("${projectStartDate}", safe(startDate))
            .replace("${projectDeadlineDate}", safe(endDate))
            .replace("${projectEstDuration}", safe(project.getEstDuration()))
            .replace("${projectPaymentMethod}", safe(project.getPaymentMethod()))
            .replace("${communicateMethod}", safe(project.getCommunicateMethod()))
            .replace("${freelancerId}", safe(freelancerUser.getUserId()))
            .replace("${freelancerName}", safe(freelancerUser.getName()))
            .replace("${freelancerEmail}", safe(freelancerUser.getEmail()))
            .replace("${manualContractText}", safe(manualText))
            .replace("${pdfText}", safe(pdfText));

        log.debug("AI 프롬프트 생성 완료");

        // ====================================================================
        // 6단계: AI API 호출
        // ====================================================================
        
        // 완성된 프롬프트를 AI 서비스에 전달
        log.info("AI 계약서 초안 생성 요청");
        String aiResponse = contractAIService.requestContractDraft(finalPrompt);
        log.debug("AI 응답 수신 완료");

        // ====================================================================
        // 7단계: JSON 파싱 및 DTO 변환
        // ====================================================================
        
        // AI 응답(JSON 문자열)을 ContractAutoFillDTO로 변환
        ContractAutoFillDTO dto = parse(aiResponse);
        log.info("AI 계약서 초안 생성 완료");
        return dto;
    }

    /**
     * AI 응답 JSON 파싱
     */
    private ContractAutoFillDTO parse(String json) {
        try {
            // 마크다운 코드블록 제거
            if (json.startsWith("```json")) {
                json = json.replaceFirst("```json", "").trim();
            }
            if (json.endsWith("```")) {
                json = json.substring(0, json.lastIndexOf("```"));
                json = json.trim();
            }
                com.fasterxml.jackson.databind.ObjectMapper mapper =
                        new com.fasterxml.jackson.databind.ObjectMapper();
                // LocalDate 등 Java 8 날짜 타입 파싱을 위해 모듈 등록
                mapper.registerModule(new com.fasterxml.jackson.datatype.jsr310.JavaTimeModule());
                return mapper.readValue(json, ContractAutoFillDTO.class);
        } catch (Exception e) {
            log.error("AI JSON 파싱 실패 - 원문: {}", json, e);
            throw new IllegalStateException("AI JSON 파싱 실패", e);
        }
    }

    /**
     * 안전한 문자열 변환
     */
    private String safe(Object o) {
        return o == null ? "" : o.toString();
    }
}
