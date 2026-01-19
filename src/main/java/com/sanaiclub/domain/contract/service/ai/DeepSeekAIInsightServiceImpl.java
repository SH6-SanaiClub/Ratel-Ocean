package com.sanaiclub.domain.contract.service.ai;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sanaiclub.domain.contract.dto.AIContractInsightDTO;
import com.sanaiclub.domain.contract.dto.ContractMilestoneDTO;
import com.sanaiclub.domain.project.dto.ProjectDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * [DEPRECATED - 2026-01-16]
 * ═══════════════════════════════════════════════════════════════════════
 * 이 클래스는 더 이상 사용되지 않습니다.
 * MCPAIInsightServiceImpl로 대체되었습니다.
 * 
 * 이유:
 * - DeepSeek API 사용하지 않음 (이름과 실제 동작 불일치)
 * - 복잡한 Fallback 로직이 유지보수 어려움
 * - MCP 기반 로컬 AI 처리로 전환
 */
// @Service  // MCP로 전환 - 비활성화됨
public class DeepSeekAIInsightServiceImpl implements AIInsightService {
    
    private static final Logger logger = LoggerFactory.getLogger(DeepSeekAIInsightServiceImpl.class);
    private static final String DEEPSEEK_API_URL = "https://api.deepseek.com/v1/chat/completions";
    private static final String MODEL = "deepseek-chat";
    
    @Value("${deepseek.api.key}")
    private String apiKey;
    
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    
    public DeepSeekAIInsightServiceImpl() {
        this.restTemplate = new RestTemplate();
        this.objectMapper = new ObjectMapper();
    }
    
    @Override
    public AIContractInsightDTO analyzeContract(
            String pdfText,
            ProjectDTO projectDTO,
            String projectDescription,
            String freelancerExperience) {
        
        logger.info("=== PDF 기반 동적 분석 시작 ===");
        logger.info("프로젝트: {}, 예산: {}, PDF 길이: {}", 
            projectDTO.getTitle(), projectDTO.getBudget(), pdfText != null ? pdfText.length() : 0);
        
        // DeepSeek API는 사용하지 않고, 항상 동적 폴백 사용
        return createFallbackInsight(projectDTO, pdfText);
    }
    
    /**
     * AI 분석용 프롬프트 생성
     */
    private String buildAnalysisPrompt(String pdfText, ProjectDTO projectDTO, 
                                       String projectDescription, String freelancerExperience) {
        
        // PDF 텍스트 길이 제한 (3000자)
        String limitedPdfText = pdfText.length() > 3000 
            ? pdfText.substring(0, 3000) + "...(이하 생략)"
            : pdfText;
        
        StringBuilder prompt = new StringBuilder();
        prompt.append("당신은 프리랜서 계약서 분석 전문가입니다.\n\n");
        prompt.append("## 분석 대상 계약서\n");
        prompt.append(limitedPdfText).append("\n\n");
        prompt.append("## 프로젝트 정보\n");
        prompt.append("- 프로젝트명: ").append(projectDTO.getTitle()).append("\n");
        prompt.append("- 예산: ").append(String.format("%,d원", projectDTO.getBudget().longValue())).append("\n");
        prompt.append("- 설명: ").append(projectDescription != null ? projectDescription : "없음").append("\n");
        prompt.append("- 프리랜서 경력: ").append(freelancerExperience != null ? freelancerExperience : "정보 없음").append("\n\n");
        prompt.append("## 분석 요청사항\n");
        prompt.append("1. 계약 시작일과 종료일을 제안해주세요 (오늘부터 3개월 후 기준)\n");
        prompt.append("2. 마일스톤을 3~5단계로 분할하고, 각 마일스톤에 예산을 배분하세요\n");
        prompt.append("3. 계약서에서 발견한 리스크 요소를 3~5개 나열하세요\n");
        prompt.append("4. 프리랜서에게 권장할 사항을 3~5개 제안하세요\n\n");
        prompt.append("## 출력 형식 (JSON)\n");
        prompt.append("{\n");
        prompt.append("  \"proposedStartDate\": \"YYYY-MM-DD\",\n");
        prompt.append("  \"proposedEndDate\": \"YYYY-MM-DD\",\n");
        prompt.append("  \"milestones\": [\n");
        prompt.append("    {\n");
        prompt.append("      \"milestoneName\": \"1단계: 요구사항 분석 및 설계\",\n");
        prompt.append("      \"workScope\": \"상세 업무 범위 설명\",\n");
        prompt.append("      \"dueDate\": \"YYYY-MM-DD\",\n");
        prompt.append("      \"amount\": 1000000\n");
        prompt.append("    }\n");
        prompt.append("  ],\n");
        prompt.append("  \"riskFactors\": [\"리스크1\", \"리스크2\"],\n");
        prompt.append("  \"recommendations\": [\"권장사항1\", \"권장사항2\"]\n");
        prompt.append("}\n\n");
        prompt.append("**주의: 반드시 JSON 형식으로만 응답하세요. 설명 없이 JSON만 출력하세요.**");
        
        return prompt.toString();
    }
    
    /**
     * DeepSeek API 호출
     */
    private String callDeepSeekAPI(String prompt) throws Exception {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("Authorization", "Bearer " + apiKey);
        
        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", MODEL);
        requestBody.put("messages", Arrays.asList(
            Map.of("role", "user", "content", prompt)
        ));
        requestBody.put("temperature", 0.7);
        requestBody.put("max_tokens", 4000);
        
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);
        
        ResponseEntity<String> response = restTemplate.exchange(
            DEEPSEEK_API_URL,
            HttpMethod.POST,
            entity,
            String.class
        );
        
        if (!response.getStatusCode().is2xxSuccessful()) {
            throw new RuntimeException("DeepSeek API 호출 실패: " + response.getStatusCode());
        }
        
        // AI 응답에서 content 추출
        JsonNode root = objectMapper.readTree(response.getBody());
        String content = root.path("choices").get(0).path("message").path("content").asText();
        
        return content;
    }
    
    /**
     * AI 응답을 파싱하여 DTO 생성
     */
    private AIContractInsightDTO parseAIResponse(String aiResponse, ProjectDTO projectDTO) {
        AIContractInsightDTO insight = new AIContractInsightDTO();
        
        try {
            // JSON 블록 추출 (```json ... ``` 제거)
            String jsonContent = aiResponse;
            if (aiResponse.contains("```json")) {
                int start = aiResponse.indexOf("```json") + 7;
                int end = aiResponse.lastIndexOf("```");
                jsonContent = aiResponse.substring(start, end).trim();
            } else if (aiResponse.contains("```")) {
                int start = aiResponse.indexOf("```") + 3;
                int end = aiResponse.lastIndexOf("```");
                jsonContent = aiResponse.substring(start, end).trim();
            }
            
            JsonNode root = objectMapper.readTree(jsonContent);
            
            // 계약 기간
            String startDateStr = root.path("proposedStartDate").asText();
            String endDateStr = root.path("proposedEndDate").asText();
            insight.setProposedStartDate(LocalDate.parse(startDateStr));
            insight.setProposedEndDate(LocalDate.parse(endDateStr));
            
            // 마일스톤 파싱
            List<ContractMilestoneDTO> milestones = new ArrayList<>();
            JsonNode milestonesNode = root.path("milestones");
            
            for (JsonNode milestoneNode : milestonesNode) {
                ContractMilestoneDTO milestone = new ContractMilestoneDTO();
                milestone.setMilestoneName(milestoneNode.path("milestoneName").asText());
                milestone.setWorkScope(milestoneNode.path("workScope").asText());
                milestone.setDueDate(LocalDate.parse(milestoneNode.path("dueDate").asText()));
                milestone.setAmount(BigDecimal.valueOf(milestoneNode.path("amount").asLong()));
                milestone.setStepOrder(milestones.size() + 1);
                milestone.setStatus("PENDING");
                milestones.add(milestone);
            }
            insight.setProposedMilestones(milestones);
            
            // 리스크 요소
            List<String> riskFactors = new ArrayList<>();
            JsonNode risksNode = root.path("riskFactors");
            for (JsonNode riskNode : risksNode) {
                riskFactors.add(riskNode.asText());
            }
            insight.setRiskFactors(riskFactors);
            
            // 권장사항
            List<String> recommendations = new ArrayList<>();
            JsonNode recsNode = root.path("recommendations");
            for (JsonNode recNode : recsNode) {
                recommendations.add(recNode.asText());
            }
            insight.setRecommendedReviewPoints(recommendations);
            
            // 메타 정보
            insight.setAnalysisModel("deepseek-chat");
            insight.setAnalysisTimestamp(LocalDate.now().toString());
            insight.setConfidenceScore(0.85);
            
        } catch (Exception e) {
            logger.error("AI 응답 파싱 실패: {}", e.getMessage());
            throw new RuntimeException("AI 응답 파싱 실패", e);
        }
        
        return insight;
    }
    
    /**
     * API 실패 시 Fallback 데이터 - PDF 내용에 따라 동적으로 변경
     */
    private AIContractInsightDTO createFallbackInsight(ProjectDTO projectDTO, String pdfText) {
        AIContractInsightDTO insight = new AIContractInsightDTO();

        // 예산 기본값 및 파싱된 금액 반영(있다면)
        BigDecimal budget = projectDTO.getBudget();
        if (budget == null) budget = new BigDecimal("30000000");

        String textRaw = pdfText != null ? pdfText : "";
        String text = textRaw.toLowerCase();
        
        // PDF 텍스트 복잡도 계산 (0.0 ~ 1.0)
        int textLength = textRaw.length();
        int lineCount = textRaw.split("\n").length;
        int wordCount = textRaw.split("\\s+").length;
        
        // 전문 용어 카운트
        int techTerms = 0;
        String[] techKeywords = {"api", "database", "server", "client", "frontend", "backend", 
                                 "deployment", "testing", "architecture", "framework", "module",
                                 "인터페이스", "데이터베이스", "서버", "클라이언트", "배포", "테스트", "아키텍처"};
        for (String keyword : techKeywords) {
            if (text.contains(keyword.toLowerCase())) techTerms++;
        }
        
        // 복잡도 점수 (0~100)
        double complexity = Math.min(100, 
            (textLength / 100.0) * 0.3 +  // 길이 기여도 30%
            (lineCount / 10.0) * 0.3 +     // 줄 수 기여도 30%
            (techTerms * 5.0) * 0.4        // 전문용어 기여도 40%
        );
        
        logger.info("PDF 복잡도 분석: 길이={}, 줄수={}, 전문용어={}, 복잡도={}/100", 
                    textLength, lineCount, techTerms, String.format("%.1f", complexity));
        
        // 복잡도에 따른 프로젝트 기간 결정 (2주~6개월)
        LocalDate today = LocalDate.now();
        int startDaysOffset = 3 + (int)(complexity * 0.1); // 3~13일 후 시작
        int durationWeeks = 4 + (int)(complexity * 0.5);   // 4~54주 기간
        
        insight.setProposedStartDate(today.plusDays(startDaysOffset));
        insight.setProposedEndDate(today.plusDays(startDaysOffset).plusWeeks(durationWeeks));

        // 간단한 금액/기간 추출로 변동성 강화
        try {
            java.util.regex.Matcher mWon = java.util.regex.Pattern
                .compile("(\\d{1,3}(,\\d{3})+)\\s*원")
                .matcher(textRaw);
            if (mWon.find()) {
                String won = mWon.group(1).replace(",", "");
                budget = new BigDecimal(won);
            }
        } catch (Exception ignore) {}

        // 카테고리 판별 (국문/영문 키워드 모두 지원)
        String category = detectCategory(textRaw, text);
        logger.info("[DeepSeek Fallback] 감지된 카테고리: {}", category);

        // 공통 기능 키워드 검출
        boolean hasApi = text.contains("api") || textRaw.contains("API") || textRaw.contains("명세");
        boolean hasMobile = text.contains("mobile") || text.contains("android") || text.contains("ios") || textRaw.contains("모바일") || textRaw.contains("앱");
        boolean hasFrontend = text.contains("react") || text.contains("vue") || text.contains("frontend") || textRaw.contains("프론트") || textRaw.contains("UI");
        boolean hasBackend = text.contains("backend") || text.contains("spring") || text.contains("java") || textRaw.contains("백엔드");
        boolean hasDb = text.contains("database") || text.contains("mysql") || text.contains("schema") || textRaw.contains("DB") || textRaw.contains("데이터베이스");
        boolean hasTesting = text.contains("test") || text.contains("qa") || text.contains("quality") || textRaw.contains("테스트") || textRaw.contains("검증");
        boolean hasDeploy = text.contains("deploy") || text.contains("release") || text.contains("prod") || textRaw.contains("배포");
        boolean hasScheduleRisk = text.contains("delay") || text.contains("schedule") || text.contains("timeline") || textRaw.contains("지연") || textRaw.contains("일정");
        boolean hasScopeChange = text.contains("change") || text.contains("scope") || text.contains("requir") || textRaw.contains("변경") || textRaw.contains("범위");
        boolean hasBudgetRisk = text.contains("budget") || text.contains("cost") || text.contains("payment") || textRaw.contains("예산") || textRaw.contains("대금") || textRaw.contains("결제");

        // 카테고리별 마일스톤 템플릿
        List<ContractMilestoneDTO> milestones = new ArrayList<>();
        switch (category) {
            case "ai": {
                addMilestone(milestones, 1, "데이터 수집 및 정제", (hasApi ? "API 로그 수집, " : "") + "데이터셋 구성", today.plusWeeks(2), budget.multiply(new BigDecimal("0.25")));
                addMilestone(milestones, 2, "모델 개발 및 학습", "모델링, 실험, 하이퍼파라미터 튜닝", today.plusWeeks(6), budget.multiply(new BigDecimal("0.5")));
                addMilestone(milestones, 3, "검증 및 배포", (hasTesting ? "모델 검증, " : "") + "서빙/모니터링", today.plusMonths(3), budget.multiply(new BigDecimal("0.25")));
                break;
            }
            case "ecommerce": {
                addMilestone(milestones, 1, "카탈로그/결제 구축", (hasFrontend ? "상품 UI, " : "") + (hasBackend ? "결제 백엔드, " : "") + "주문 흐름 설계", today.plusWeeks(3), budget.multiply(new BigDecimal("0.35")));
                addMilestone(milestones, 2, "주문/정산 처리", "주문 상태관리, 정산/영수 처리", today.plusWeeks(7), budget.multiply(new BigDecimal("0.4")));
                addMilestone(milestones, 3, "운영/리포팅", (hasDb ? "데이터 적재, " : "") + "판매 리포트/대시보드", today.plusMonths(3), budget.multiply(new BigDecimal("0.25")));
                break;
            }
            case "blockchain": {
                addMilestone(milestones, 1, "스마트컨트랙트 설계", "토큰/권한 모델, 감사 대응", today.plusWeeks(2), budget.multiply(new BigDecimal("0.3")));
                addMilestone(milestones, 2, "DApp 개발", (hasFrontend ? "지갑 연동 UI, " : "") + "컨트랙트 연동", today.plusWeeks(6), budget.multiply(new BigDecimal("0.45")));
                addMilestone(milestones, 3, "테스트넷/메인넷 배포", "보안 점검, 가스비 최적화", today.plusMonths(3), budget.multiply(new BigDecimal("0.25")));
                break;
            }
            case "mobile": {
                addMilestone(milestones, 1, "앱 UI/UX 설계", "와이어프레임, 핵심 화면 구현", today.plusWeeks(2), budget.multiply(new BigDecimal("0.3")));
                addMilestone(milestones, 2, "백엔드 연동", (hasApi ? "API 연동, " : "") + "푸시/로그인", today.plusWeeks(6), budget.multiply(new BigDecimal("0.45")));
                addMilestone(milestones, 3, "스토어 릴리즈", "QA, 빌드/서명, 배포", today.plusMonths(3), budget.multiply(new BigDecimal("0.25")));
                break;
            }
            case "healthcare": {
                addMilestone(milestones, 1, "요건/규제 정합성 검토", "개인정보/의료법 준수 계획", today.plusWeeks(2), budget.multiply(new BigDecimal("0.25")));
                addMilestone(milestones, 2, "EMR/데이터 연동", "보안/암호화, 접근통제", today.plusWeeks(6), budget.multiply(new BigDecimal("0.5")));
                addMilestone(milestones, 3, "임상/운영 검증", "품질 시험, 장애 대응", today.plusMonths(3), budget.multiply(new BigDecimal("0.25")));
                break;
            }
            case "fintech": {
                addMilestone(milestones, 1, "계정/KYC 구축", "본인인증, 위험평가", today.plusWeeks(2), budget.multiply(new BigDecimal("0.3")));
                addMilestone(milestones, 2, "결제/정산 모듈", "카드/계좌/수수료 처리", today.plusWeeks(6), budget.multiply(new BigDecimal("0.45")));
                addMilestone(milestones, 3, "보안/감사 대응", "로그/이상징후 모니터링", today.plusMonths(3), budget.multiply(new BigDecimal("0.25")));
                break;
            }
            case "education": {
                addMilestone(milestones, 1, "강의/콘텐츠 관리", "커리큘럼/권한 설계", today.plusWeeks(2), budget.multiply(new BigDecimal("0.3")));
                addMilestone(milestones, 2, "수강/평가 기능", "퀴즈/성적/게시판", today.plusWeeks(6), budget.multiply(new BigDecimal("0.45")));
                addMilestone(milestones, 3, "운영/분석", "수강 통계/리포트", today.plusMonths(3), budget.multiply(new BigDecimal("0.25")));
                break;
            }
            default: {
                addMilestone(milestones, 1, "요구사항 분석 및 설계", (hasApi ? "API 명세, " : "") + "아키텍처 설계", today.plusWeeks(2), budget.multiply(new BigDecimal("0.3")));
                addMilestone(milestones, 2, "핵심 기능 개발", (hasBackend ? "백엔드, " : "") + (hasFrontend ? "프론트엔드, " : "") + (hasMobile ? "모바일, " : "") + "단위 테스트", today.plusWeeks(6), budget.multiply(new BigDecimal("0.5")));
                addMilestone(milestones, 3, "테스트 및 배포", (hasTesting ? "QA/테스트, " : "") + (hasDb ? "DB 마이그레이션, " : "") + (hasDeploy ? "배포 파이프라인, " : "") + "프로덕션 배포", today.plusMonths(3), budget.multiply(new BigDecimal("0.2")));
            }
        }

        insight.setProposedMilestones(milestones);

        // 리스크 & 권장사항 (카테고리 특화 항목 포함)
        List<String> risks = new ArrayList<>();
        risks.add("DeepSeek API 402: 결제 필요로 인한 로컬 분석 사용");
        if (hasScheduleRisk) risks.add("일정 지연 위험: 스케줄/타임라인 키워드 감지");
        if (hasScopeChange) risks.add("요구사항 변경 위험: 범위 변경 키워드 감지");
        if (hasBudgetRisk) risks.add("예산/대금 위험: 예산/결제 키워드 감지");
        if (category.equals("healthcare")) risks.add("규제 준수 위험: 개인정보/의료법 적용");
        if (category.equals("blockchain") || category.equals("fintech")) risks.add("보안/감사 위험: 키관리 및 거래 추적 필요");
        if (risks.size() < 3) risks.add("요구사항 상세화 및 승인 절차 정의 필요");
        insight.setRiskFactors(risks);

        List<String> recs = new ArrayList<>();
        recs.add("요구사항 명세서(기능목록, API 명세) 확정");
        recs.add("주간 진행보고 및 변경 절차 명시");
        recs.add("마일스톤별 금액/완료 기준 합의");
        if (category.equals("healthcare")) recs.add("개인정보 보호/접근 제어 정책 수립");
        if (category.equals("ai")) recs.add("데이터 품질 기준/모델 모니터링 정의");
        insight.setRecommendedReviewPoints(recs);

        insight.setAnalysisModel("fallback-mock(" + category + ")");
        insight.setAnalysisTimestamp(LocalDate.now().toString());
        insight.setConfidenceScore(0.35);

        return insight;
    }

    private String detectCategory(String textRaw, String textLower) {
        if (textLower.contains("machine learning") || textLower.contains("ml ") || textRaw.contains("인공지능") || textRaw.contains("머신러닝") || textRaw.contains("모델")) {
            return "ai";
        }
        if (textLower.contains("shop") || textLower.contains("checkout") || textLower.contains("cart") || textRaw.contains("쇼핑몰") || textRaw.contains("전자상거래") || textRaw.contains("주문")) {
            return "ecommerce";
        }
        if (textLower.contains("blockchain") || textLower.contains("solidity") || textRaw.contains("블록체인") || textRaw.contains("스마트컨트랙트") || textRaw.contains("토큰")) {
            return "blockchain";
        }
        if (textLower.contains("android") || textLower.contains("ios") || textLower.contains("mobile") || textRaw.contains("모바일") || textRaw.contains("앱")) {
            return "mobile";
        }
        if (textLower.contains("healthcare") || textLower.contains("medical") || textRaw.contains("의료") || textRaw.contains("병원") || textRaw.contains("헬스케어")) {
            return "healthcare";
        }
        if (textLower.contains("finance") || textLower.contains("payment") || textRaw.contains("금융") || textRaw.contains("결제") || textRaw.contains("수수료")) {
            return "fintech";
        }
        if (textLower.contains("education") || textLower.contains("lms") || textRaw.contains("교육") || textRaw.contains("강의") || textRaw.contains("학습")) {
            return "education";
        }
        return "general";
    }

    private void addMilestone(List<ContractMilestoneDTO> list, int order, String name, String scope, LocalDate due, BigDecimal amount) {
        ContractMilestoneDTO m = new ContractMilestoneDTO();
        m.setStepOrder(order);
        m.setMilestoneName(order + "단계: " + name);
        m.setWorkScope(scope);
        m.setDueDate(due);
        m.setAmount(amount.setScale(0, RoundingMode.HALF_UP));
        m.setStatus("PENDING");
        list.add(m);
    }
    
    @Override
    public String getServiceStatus() {
        return "deepseek-live";
    }
    
    @Override
    public boolean validateMilestoneAmount(Long totalBudget, Long milestoneTotalAmount) {
        if (totalBudget == null || milestoneTotalAmount == null) {
            return false;
        }
        
        // ±10% 오차 허용
        long difference = Math.abs(totalBudget - milestoneTotalAmount);
        double errorRate = (double) difference / totalBudget;
        
        return errorRate <= 0.1; // 10% 이내
    }
}
