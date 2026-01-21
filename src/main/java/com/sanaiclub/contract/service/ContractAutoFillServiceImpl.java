package com.sanaiclub.contract.service;

import com.sanaiclub.contract.model.ContractAutoFillDTO;
import com.sanaiclub.contract.service.ContractService;
import com.sanaiclub.contract.service.ContractAIService;
import com.sanaiclub.contract.service.PDFProcessingService;

import com.sanaiclub.contract.model.ContractProjectVO;
import com.sanaiclub.contract.model.ContractFreelancerVO;

import com.sanaiclub.contract.util.PromptTemplateLoader;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;

import java.io.File;

@Service
public class ContractAutoFillServiceImpl implements ContractAutoFillService {

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

        // 2. PDF 텍스트
        String pdfText = null;
        if (pdfFile != null) {
            try {
                pdfText = pdfProcessingService.extractText(pdfFile);
            } catch (Exception ignored) {}
        }

        // 3. 프롬프트 로딩
        String template = PromptTemplateLoader.load(
                "com/sanaiclub/contract/util/contract_autofill_prompt.txt"
        );

        // 4. 프롬프트 완성
        String finalPrompt = template
                .replace("${projectTitle}", safe(project.getTitle()))
                .replace("${projectDescription}", safe(project.getDescription()))
                .replace("${projectBudget}", safe(project.getBudget()))
                .replace("${freelancerName}", safe(freelancer.getName()))
                .replace("${manualContractText}", safe(manualText))
                .replace("${pdfText}", safe(pdfText));
        System.out.println("[AI 프롬프트] " + finalPrompt); // 프롬프트 로그 추가

        // 5. AI 호출
        String aiResponse = contractAIService.requestContractDraft(finalPrompt);
        System.out.println("[AI Raw Response] " + aiResponse); // 디버깅용 로그

        // 6. JSON → DTO
        return parse(aiResponse);
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
            System.err.println("[AI JSON 파싱 실패] 원문: " + json);
            e.printStackTrace();
            throw new IllegalStateException("AI JSON 파싱 실패", e);
        }
    }

    private String safe(Object o) {
        return o == null ? "" : o.toString();
    }
}
