package com.sanaiclub.contract.service;

import com.sanaiclub.contract.model.dto.ContractAutoFillDTO;
import com.sanaiclub.contract.service.ContractService;
import com.sanaiclub.contract.service.ContractAIService;
import com.sanaiclub.contract.service.PDFProcessingService;

import com.sanaiclub.contract.model.vo.ContractProjectVO;
import com.sanaiclub.contract.model.vo.ContractFreelancerVO;

import com.sanaiclub.contract.util.PromptTemplateLoader;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.io.File;

@Service
public class ContractAutoFillServiceImpl implements ContractAutoFillService {

    private static final Logger logger = LoggerFactory.getLogger(ContractAutoFillServiceImpl.class);

    private final ContractService contractService;
    private final PDFProcessingService pdfProcessingService;
    private final ContractAIService contractAIService;

    public ContractAutoFillServiceImpl(
            ContractService contractService,
            PDFProcessingService pdfProcessingService,
            ContractAIService contractAIService
    ) {
        this.contractService = contractService;
        this.pdfProcessingService = pdfProcessingService;
        this.contractAIService = contractAIService;
    }

    @Override
    public ContractAutoFillDTO generateDraft(
            File pdfFile,
            String manualText,
            Integer projectId,
            Integer freelancerId
    ) {

        // 1. DB 조회
        ContractProjectVO project = contractService.getProjectById(projectId);
        ContractFreelancerVO freelancer = contractService.getFreelancerById(freelancerId);
        if (project == null || freelancer == null) {
            throw new IllegalStateException("프로젝트 또는 프리랜서 정보 없음");
        }

        // 2. 날짜 계산 (AI에 맡기지 않고 Java에서 확정)
        String startDate = (project.getStartDate() != null && !project.getStartDate().isEmpty())
            ? project.getStartDate()
            : java.time.LocalDate.now().plusDays(7).toString();
        String endDate = (project.getDeadlineDate() != null && !project.getDeadlineDate().isEmpty())
            ? project.getDeadlineDate()
            : java.time.LocalDate.parse(startDate).plusMonths(2).toString();

        // 3. PDF 텍스트
        String pdfText = null;
        if (pdfFile != null) {
            try {
                pdfText = pdfProcessingService.extractText(pdfFile);
            } catch (Exception e) {
                logger.error("PDF 추출 에러: {}", e.getMessage(), e);
                pdfText = "";
            }
        }
        if (pdfText == null) pdfText = "";

        // 4. 프롬프트 로딩
        String template = PromptTemplateLoader.load(
            "com/sanaiclub/contract/util/contract_autofill_prompt.txt"
        );

        // 5. 프롬프트 완성 (모든 치환 필드 명시)
        logger.debug("프롬프트 생성 - projectId={}, projectTitle={}, freelancerId={}", 
            project.getProjectId(), project.getTitle(), freelancer.getId());

        String budgetValue = (project.getBudget() != null && !project.getBudget().isEmpty()) ? project.getBudget() : "0";
        String finalPrompt = template
            .replace("${projectId}", safe(project.getProjectId()))
            .replace("${projectTitle}", safe(project.getTitle()))
            .replace("${projectDescription}", safe(project.getDescription()))
            .replace("${projectBudget}", budgetValue)
            .replace("${projectStartDate}", safe(startDate))
            .replace("${projectDeadlineDate}", safe(endDate))
            .replace("${projectEstDuration}", safe(project.getEstDuration()))
            .replace("${projectPaymentMethod}", "")
            .replace("${communicateMethod}", "")
            .replace("${freelancerId}", safe(freelancer.getId()))
            .replace("${freelancerName}", safe(freelancer.getName()))
            .replace("${freelancerEmail}", safe(freelancer.getEmail()))
            .replace("${manualContractText}", safe(manualText))
            .replace("${pdfText}", safe(pdfText));

        logger.debug("AI 프롬프트 생성 완료");

        // 6. AI 호출
        logger.info("AI 계약서 초안 생성 요청");
        String aiResponse = contractAIService.requestContractDraft(finalPrompt);
        logger.debug("AI 응답 수신 완료");

        // 7. JSON → DTO
        ContractAutoFillDTO dto = parse(aiResponse);
        logger.info("AI 계약서 초안 생성 완료");
        return dto;
    }

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
            logger.error("AI JSON 파싱 실패 - 원문: {}", json, e);
            throw new IllegalStateException("AI JSON 파싱 실패", e);
        }
    }

    private String safe(Object o) {
        return o == null ? "" : o.toString();
    }
}
