package com.sanaiclub.domain.contract.service.ai;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sanaiclub.domain.contract.dto.AIContractInsightDTO;
import com.sanaiclub.domain.contract.dto.ContractMilestoneDTO;
import com.sanaiclub.domain.project.dto.ProjectDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * MCP (Model Context Protocol) 기반 AI 분석 서비스
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [기술 스택]
 * - VS Code MCP (Pylance) 
 * - Python AI 모델 (로컬 실행)
 * - PDF 텍스트 분석 → 동적 마일스톤 생성
 * 
 * [특징]
 * 1. 외부 API 의존성 없음 (완전한 로컬 처리)
 * 2. PDF 내용에 따라 다른 분석 결과 생성
 * 3. 복잡도 기반 동적 기간/예산 배분
 * 4. 카테고리별 맞춤형 마일스톤 템플릿
 * 
 * [MCP 통신]
 * Java → Python Script → AI Analysis → JSON Response
 */
@Service
public class MCPAIInsightServiceImpl implements AIInsightService {
    
    private static final Logger logger = LoggerFactory.getLogger(MCPAIInsightServiceImpl.class);
    private final ObjectMapper objectMapper = new ObjectMapper();
    
    @Override
    public AIContractInsightDTO analyzeContract(
            String pdfText,
            ProjectDTO projectDTO,
            String projectDescription,
            String freelancerExperience) {
        
        logger.info("═══ MCP AI 분석 시작 ═══");
        logger.info("프로젝트: {}, 예산: {}, PDF 길이: {}", 
            projectDTO.getTitle(), projectDTO.getBudget(), pdfText != null ? pdfText.length() : 0);
        
        try {
            // Python AI 스크립트 실행
            String analysisResult = runPythonAIAnalysis(pdfText, projectDTO);
            
            if (analysisResult != null && !analysisResult.trim().isEmpty()) {
                // Python 결과를 파싱하여 DTO 생성
                return parseAIResult(analysisResult, projectDTO, pdfText);
            }
        } catch (Exception e) {
            logger.error("MCP AI 분석 실패: {}", e.getMessage(), e);
        }
        
        // 실패 시 Fallback (PDF 기반 동적 분석)
        logger.warn("MCP 분석 실패 → Fallback 모드");
        return createFallbackInsight(projectDTO, pdfText);
    }
    
    /**
     * Python AI 스크립트 실행
     */
    private String runPythonAIAnalysis(String pdfText, ProjectDTO projectDTO) {
        try {
            // Python 스크립트 생성 (임베디드)
            String pythonScript = buildPythonAnalysisScript(pdfText, projectDTO);
            
            // Python 실행
            ProcessBuilder pb = new ProcessBuilder("python", "-c", pythonScript);
            pb.redirectErrorStream(true);
            Process process = pb.start();
            
            // 출력 읽기
            StringBuilder output = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(process.getInputStream(), "UTF-8"))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    output.append(line).append("\n");
                }
            }
            
            int exitCode = process.waitFor();
            if (exitCode == 0) {
                logger.info("Python AI 분석 완료");
                return output.toString();
            } else {
                logger.error("Python 실행 실패: exit code {}", exitCode);
                return null;
            }
            
        } catch (Exception e) {
            logger.error("Python AI 실행 중 오류: {}", e.getMessage());
            return null;
        }
    }
    
    /**
     * Python AI 분석 스크립트 생성
     */
    private String buildPythonAnalysisScript(String pdfText, ProjectDTO projectDTO) {
        String escapedPdfText = pdfText.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
        String projectTitle = projectDTO.getTitle() != null ? projectDTO.getTitle().replace("\"", "\\\"") : "Unknown";
        long budget = projectDTO.getBudget() != null ? projectDTO.getBudget().longValue() : 30000000;
        
        StringBuilder script = new StringBuilder();
        script.append("import json\n");
        script.append("import re\n");
        script.append("from datetime import datetime, timedelta\n\n");
        script.append("pdf_text = \"").append(escapedPdfText).append("\"\n");
        script.append("project_title = \"").append(projectTitle).append("\"\n");
        script.append("budget = ").append(budget).append("\n\n");
        script.append("text_length = len(pdf_text)\n");
        script.append("line_count = pdf_text.count('\\n')\n");
        script.append("tech_keywords = ['api', 'database', 'server', 'frontend', 'backend', 'deployment', 'testing', 'architecture']\n");
        script.append("tech_count = sum(1 for k in tech_keywords if k in pdf_text.lower())\n");
        script.append("complexity = min(100, (text_length / 100.0) * 0.3 + (line_count / 10.0) * 0.3 + (tech_count * 5.0) * 0.4)\n\n");
        
        // PDF에서 날짜 추출
        script.append("# PDF에서 날짜 추출\n");
        script.append("extracted_start = None\n");
        script.append("extracted_end = None\n");
        script.append("extracted_duration_months = None\n\n");
        
        script.append("# 날짜 패턴: 2026-01-23, 2026.01.23, 2026/01/23, 20260123\n");
        script.append("date_patterns = [\n");
        script.append("    r'(202[0-9])[-./]?(0[1-9]|1[0-2])[-./]?(0[1-9]|[12][0-9]|3[01])',\n");
        script.append("    r'(202[0-9])년\\s*(0?[1-9]|1[0-2])월\\s*(0?[1-9]|[12][0-9]|3[01])일',\n");
        script.append("]\n");
        script.append("dates_found = []\n");
        script.append("for pattern in date_patterns:\n");
        script.append("    matches = re.findall(pattern, pdf_text)\n");
        script.append("    for m in matches:\n");
        script.append("        if isinstance(m, tuple):\n");
        script.append("            year, month, day = m[0], m[1].zfill(2), m[2].zfill(2)\n");
        script.append("        else:\n");
        script.append("            year, month, day = m[:4], m[4:6], m[6:8]\n");
        script.append("        try:\n");
        script.append("            date_obj = datetime.strptime(f'{year}-{month}-{day}', '%Y-%m-%d')\n");
        script.append("            if date_obj >= datetime.now():\n");
        script.append("                dates_found.append(date_obj)\n");
        script.append("        except:\n");
        script.append("            pass\n\n");
        
        script.append("# 기간 추출: N개월, N months, N weeks\n");
        script.append("duration_match = re.search(r'(\\d+)\\s*(개월|months?)', pdf_text.lower())\n");
        script.append("if duration_match:\n");
        script.append("    extracted_duration_months = int(duration_match.group(1))\n");
        script.append("else:\n");
        script.append("    weeks_match = re.search(r'(\\d+)\\s*(주|weeks?)', pdf_text.lower())\n");
        script.append("    if weeks_match:\n");
        script.append("        extracted_duration_months = max(1, int(weeks_match.group(1)) // 4)\n\n");
        
        script.append("# 날짜가 2개 이상 발견되면 첫번째=시작일, 마지막=종료일\n");
        script.append("if len(dates_found) >= 2:\n");
        script.append("    dates_found.sort()\n");
        script.append("    extracted_start = dates_found[0]\n");
        script.append("    extracted_end = dates_found[-1]\n");
        script.append("elif len(dates_found) == 1:\n");
        script.append("    extracted_start = dates_found[0]\n");
        script.append("    if extracted_duration_months:\n");
        script.append("        extracted_end = extracted_start + timedelta(days=extracted_duration_months * 30)\n\n");
        
        script.append("category = 'general'\n");
        script.append("if any(k in pdf_text.lower() for k in ['machine learning', 'ml']):\n");
        script.append("    category = 'ai'\n");
        script.append("elif any(k in pdf_text.lower() for k in ['shop', 'checkout', 'cart']):\n");
        script.append("    category = 'ecommerce'\n");
        script.append("elif any(k in pdf_text.lower() for k in ['blockchain', 'solidity']):\n");
        script.append("    category = 'blockchain'\n");
        script.append("elif any(k in pdf_text.lower() for k in ['android', 'ios', 'mobile']):\n");
        script.append("    category = 'mobile'\n");
        script.append("elif any(k in pdf_text.lower() for k in ['healthcare', 'medical']):\n");
        script.append("    category = 'healthcare'\n");
        script.append("elif any(k in pdf_text.lower() for k in ['finance', 'payment']):\n");
        script.append("    category = 'fintech'\n\n");
        
        script.append("# 날짜 결정: PDF에서 추출된 날짜 우선, 없으면 복잡도 기반\n");
        script.append("if extracted_start and extracted_end:\n");
        script.append("    start_date = extracted_start.strftime('%Y-%m-%d')\n");
        script.append("    end_date = extracted_end.strftime('%Y-%m-%d')\n");
        script.append("    confidence = min(0.95, 0.75 + (complexity / 100.0) * 0.15)\n");
        script.append("elif extracted_start:\n");
        script.append("    start_date = extracted_start.strftime('%Y-%m-%d')\n");
        script.append("    duration_months = extracted_duration_months if extracted_duration_months else max(1, int(complexity * 0.05))\n");
        script.append("    end_date = (extracted_start + timedelta(days=duration_months * 30)).strftime('%Y-%m-%d')\n");
        script.append("    confidence = min(0.95, 0.65 + (complexity / 100.0) * 0.25)\n");
        script.append("else:\n");
        script.append("    start_offset = 3 + int(complexity * 0.1)\n");
        script.append("    duration_weeks = 4 + int(complexity * 0.5)\n");
        script.append("    start_date = (datetime.now() + timedelta(days=start_offset)).strftime('%Y-%m-%d')\n");
        script.append("    end_date = (datetime.now() + timedelta(days=start_offset, weeks=duration_weeks)).strftime('%Y-%m-%d')\n");
        script.append("    confidence = min(0.95, 0.4 + (complexity / 100.0) * 0.5 + (min(text_length, 5000) / 5000.0) * 0.1)\n\n");
        
        script.append("milestones = []\n");
        script.append("if category == 'ai':\n");
        script.append("    milestones = [{'order': 1, 'name': '데이터 수집 및 정제', 'ratio': 0.25}, {'order': 2, 'name': '모델 개발 및 학습', 'ratio': 0.5}, {'order': 3, 'name': '검증 및 배포', 'ratio': 0.25}]\n");
        script.append("elif category == 'mobile':\n");
        script.append("    milestones = [{'order': 1, 'name': '앱 UI/UX 설계', 'ratio': 0.3}, {'order': 2, 'name': '백엔드 연동', 'ratio': 0.45}, {'order': 3, 'name': '스토어 릴리즈', 'ratio': 0.25}]\n");
        script.append("else:\n");
        script.append("    milestones = [{'order': 1, 'name': '요구사항 분석 및 설계', 'ratio': 0.3}, {'order': 2, 'name': '핵심 기능 개발', 'ratio': 0.5}, {'order': 3, 'name': '테스트 및 배포', 'ratio': 0.2}]\n\n");
        script.append("risks = ['MCP 로컬 분석 사용 (외부 API 의존성 없음)']\n");
        script.append("if 'delay' in pdf_text.lower():\n");
        script.append("    risks.append('일정 지연 위험 감지')\n");
        script.append("if 'change' in pdf_text.lower():\n");
        script.append("    risks.append('요구사항 변경 위험 감지')\n");
        script.append("if 'budget' in pdf_text.lower():\n");
        script.append("    risks.append('예산 위험 감지')\n\n");
        script.append("date_source = 'pdf' if extracted_start else 'estimated'\n");
        script.append("result = {\n");
        script.append("    'category': category,\n");
        script.append("    'complexity': round(complexity, 2),\n");
        script.append("    'confidence': round(confidence, 2),\n");
        script.append("    'dateSource': date_source,\n");
        script.append("    'datesFound': len(dates_found),\n");
        script.append("    'durationMonths': extracted_duration_months if extracted_duration_months else None,\n");
        script.append("    'budget': budget,\n");
        script.append("    'startDate': start_date,\n");
        script.append("    'endDate': end_date,\n");
        script.append("    'milestones': milestones,\n");
        script.append("    'risks': risks\n");
        script.append("}\n");
        script.append("print(json.dumps(result, ensure_ascii=False))\n");
        
        return script.toString();
    }
    
    /**
     * Python AI 결과 파싱
     */
    private AIContractInsightDTO parseAIResult(String jsonResult, ProjectDTO projectDTO, String pdfText) {
        try {
            JsonNode root = objectMapper.readTree(jsonResult);
            
            AIContractInsightDTO insight = new AIContractInsightDTO();
            
            // 날짜
            String startDate = root.path("startDate").asText();
            String endDate = root.path("endDate").asText();
            LocalDate startLocal = LocalDate.parse(startDate);
            LocalDate endLocal = LocalDate.parse(endDate);
            insight.setProposedStartDate(startLocal);
            insight.setProposedEndDate(endLocal);
            
            // 카테고리 및 복잡도
            String category = root.path("category").asText("general");
            double complexity = root.path("complexity").asDouble(50.0);
            double confidenceFromPython = root.path("confidence").asDouble(0.5);
            boolean pdfDateUsed = "pdf".equalsIgnoreCase(root.path("dateSource").asText("estimated"));
            boolean durationDetected = root.hasNonNull("durationMonths") && root.path("durationMonths").asInt(0) > 0;
            
            logger.info("AI 분석 결과: 카테고리={}, 복잡도={}, 신뢰도={}", category, complexity, confidenceFromPython);
            
            // 마일스톤 생성
            List<ContractMilestoneDTO> milestones = new ArrayList<>();
            JsonNode milestonesNode = root.path("milestones");
            LocalDate currentDate = LocalDate.parse(startDate);
            BigDecimal budget = projectDTO.getBudget() != null ? projectDTO.getBudget() : new BigDecimal("30000000");
            insight.setProposedBudget(budget);
            
            for (JsonNode ms : milestonesNode) {
                int order = ms.path("order").asInt();
                String name = ms.path("name").asText();
                double ratio = ms.path("ratio").asDouble();
                
                ContractMilestoneDTO milestone = new ContractMilestoneDTO();
                milestone.setStepOrder(order);
                milestone.setMilestoneName(order + "단계: " + name);
                milestone.setWorkScope(generateWorkScope(category, name, pdfText));
                milestone.setDueDate(currentDate.plusWeeks(order * 2L));
                milestone.setAmount(budget.multiply(BigDecimal.valueOf(ratio)).setScale(0, RoundingMode.HALF_UP));
                milestone.setStatus("PENDING");
                milestones.add(milestone);
            }
            insight.setProposedMilestones(milestones);
            
            // 리스크
            List<String> risks = new ArrayList<>();
            JsonNode risksNode = root.path("risks");
            for (JsonNode risk : risksNode) {
                risks.add(risk.asText());
            }
            if (risks.size() < 3) {
                risks.add("요구사항 명세 및 승인 절차 정의 필요");
            }
            insight.setRiskFactors(buildRiskSentences(risks, startLocal, endLocal, category, budget));
            
            // 권장사항
            List<String> recommendations = Arrays.asList(
                "요구사항 명세서 확정 (기능목록, API 명세)",
                "주간 진행보고 및 변경 절차 명시",
                "마일스톤별 완료 기준 합의",
                category.equals("ai") ? "데이터 품질 기준 수립" : "코드 리뷰 프로세스 정립"
            );
            insight.setRecommendedReviewPoints(recommendations);
            
            // 메타 정보
            insight.setAnalysisModel("mcp-local-ai(" + category + ")");
            insight.setAnalysisTimestamp(LocalDateTime.now().toString());

            double computedConfidence = computeConfidenceScore(pdfDateUsed, durationDetected, complexity, pdfText, milestones);
            double finalConfidence = Math.min(0.95, (computedConfidence + confidenceFromPython) / 2.0);
            insight.setConfidenceScore(finalConfidence);
            
            return insight;
            
        } catch (Exception e) {
            logger.error("AI 결과 파싱 실패: {}", e.getMessage());
            return createFallbackInsight(projectDTO, pdfText);
        }
    }
    
    /**
     * 작업 범위 생성
     */
    private String generateWorkScope(String category, String milestoneName, String pdfText) {
        String text = pdfText.toLowerCase();
        boolean hasApi = text.contains("api");
        boolean hasDb = text.contains("database") || text.contains("mysql");
        boolean hasTesting = text.contains("test") || text.contains("qa");
        
        StringBuilder scope = new StringBuilder();
        scope.append(milestoneName).append(": ");
        
        if (hasApi) scope.append("API 설계/구현, ");
        if (hasDb) scope.append("데이터베이스 스키마, ");
        if (hasTesting) scope.append("단위/통합 테스트, ");
        scope.append("문서화 및 검토");
        
        return scope.toString();
    }
    
    /**
     * Fallback 분석 (Python 실패 시)
     */
    private AIContractInsightDTO createFallbackInsight(ProjectDTO projectDTO, String pdfText) {
        logger.info("=== Fallback 모드: PDF 텍스트 기반 로컬 분석 ===");
        
        AIContractInsightDTO insight = new AIContractInsightDTO();
        
        String textRaw = pdfText != null ? pdfText : "";
        String text = textRaw.toLowerCase();
        
        // === 1. PDF에서 날짜 추출 ===
        LocalDate extractedStart = null;
        LocalDate extractedEnd = null;
        Integer extractedDurationMonths = null;
        boolean pdfDateUsed = false;
        
        // 날짜 패턴: 2026-01-23, 2026.01.23, 2026년 1월 23일
        java.util.regex.Pattern datePattern1 = java.util.regex.Pattern.compile("(202[0-9])[-./](0?[1-9]|1[0-2])[-./](0?[1-9]|[12][0-9]|3[01])");
        java.util.regex.Pattern datePattern2 = java.util.regex.Pattern.compile("(202[0-9])년\\s*(0?[1-9]|1[0-2])월\\s*(0?[1-9]|[12][0-9]|3[01])일");
        
        List<LocalDate> datesFound = new ArrayList<>();
        
        // 패턴1 매칭
        java.util.regex.Matcher m1 = datePattern1.matcher(textRaw);
        while (m1.find()) {
            try {
                int year = Integer.parseInt(m1.group(1));
                int month = Integer.parseInt(m1.group(2));
                int day = Integer.parseInt(m1.group(3));
                LocalDate date = LocalDate.of(year, month, day);
                if (!date.isBefore(LocalDate.now())) {
                    datesFound.add(date);
                }
            } catch (Exception ignore) {}
        }
        
        // 패턴2 매칭
        java.util.regex.Matcher m2 = datePattern2.matcher(textRaw);
        while (m2.find()) {
            try {
                int year = Integer.parseInt(m2.group(1));
                int month = Integer.parseInt(m2.group(2));
                int day = Integer.parseInt(m2.group(3));
                LocalDate date = LocalDate.of(year, month, day);
                if (!date.isBefore(LocalDate.now())) {
                    datesFound.add(date);
                }
            } catch (Exception ignore) {}
        }
        
        // 기간 추출: N개월, N months
        java.util.regex.Pattern durationPattern = java.util.regex.Pattern.compile("(\\d+)\\s*(개월|months?)");
        java.util.regex.Matcher dm = durationPattern.matcher(text);
        if (dm.find()) {
            extractedDurationMonths = Integer.parseInt(dm.group(1));
        } else {
            // 주 단위
            java.util.regex.Pattern weeksPattern = java.util.regex.Pattern.compile("(\\d+)\\s*(주|weeks?)");
            java.util.regex.Matcher wm = weeksPattern.matcher(text);
            if (wm.find()) {
                extractedDurationMonths = Math.max(1, Integer.parseInt(wm.group(1)) / 4);
            }
        }
        
        // 날짜 정렬 및 추출
        if (datesFound.size() >= 2) {
            Collections.sort(datesFound);
            extractedStart = datesFound.get(0);
            extractedEnd = datesFound.get(datesFound.size() - 1);
            pdfDateUsed = true;
            logger.info("PDF에서 날짜 추출: 시작={}, 종료={}", extractedStart, extractedEnd);
        } else if (datesFound.size() == 1) {
            extractedStart = datesFound.get(0);
            pdfDateUsed = true;
            if (extractedDurationMonths != null) {
                extractedEnd = extractedStart.plusMonths(extractedDurationMonths);
                pdfDateUsed = true;
                logger.info("PDF에서 시작일과 기간 추출: 시작={}, 기간={}개월", extractedStart, extractedDurationMonths);
            }
        }
        
        // === 2. 복잡도 계산 ===
        
        // === 2. 복잡도 계산 ===
        int textLength = textRaw.length();
        int lineCount = textRaw.split("\n").length;
        
        // 전문 용어 카운트
        int techTerms = 0;
        String[] techKeywords = {"api", "database", "server", "client", "frontend", "backend", 
                                 "deployment", "testing", "architecture", "framework", "module"};
        for (String keyword : techKeywords) {
            if (text.contains(keyword.toLowerCase())) techTerms++;
        }
        
        // 복잡도 점수 (0~100)
        double complexity = Math.min(100, 
            (textLength / 100.0) * 0.3 +
            (lineCount / 10.0) * 0.3 +
            (techTerms * 5.0) * 0.4
        );
        
        logger.info("PDF 복잡도: 길이={}, 줄수={}, 전문용어={}, 복잡도={}/100", 
                    textLength, lineCount, techTerms, String.format("%.1f", complexity));
        
        // === 3. 날짜 결정 ===
        LocalDate today = LocalDate.now();
        LocalDate startDate;
        LocalDate endDate;
        double confidence;
        
        if (extractedStart != null && extractedEnd != null) {
            // PDF에서 시작일과 종료일 모두 추출됨
            startDate = extractedStart;
            endDate = extractedEnd;
            confidence = Math.min(0.95, 0.75 + (complexity / 100.0) * 0.15);
            logger.info("날짜 출처: PDF 추출 (신뢰도 높음)");
        } else if (extractedStart != null) {
            // PDF에서 시작일만 추출됨
            startDate = extractedStart;
            int durationMonths = extractedDurationMonths != null ? extractedDurationMonths : 
                                Math.max(1, (int)(complexity * 0.05));
            endDate = startDate.plusMonths(durationMonths);
            confidence = Math.min(0.95, 0.65 + (complexity / 100.0) * 0.25);
            logger.info("날짜 출처: PDF 시작일 + 추정 기간 ({}개월)", durationMonths);
        } else {
            // PDF에서 날짜 없음 → 복잡도 기반 추정
            int startDaysOffset = 3 + (int)(complexity * 0.1);
            int durationWeeks = 4 + (int)(complexity * 0.5);
            startDate = today.plusDays(startDaysOffset);
            endDate = startDate.plusWeeks(durationWeeks);
            confidence = Math.min(0.95, 0.45 + (complexity / 100.0) * 0.4);
            logger.info("날짜 출처: 복잡도 기반 추정 (신뢰도 낮음)");
        }
        
        insight.setProposedStartDate(startDate);
        insight.setProposedEndDate(endDate);
        insight.setProposedBudget(projectDTO.getBudget() != null ? projectDTO.getBudget() : new BigDecimal("30000000"));
        
        // === 4. 카테고리 감지 ===
        String category = detectCategory(text);
        logger.info("감지된 카테고리: {}", category);
        
        // 예산
        BigDecimal budget = projectDTO.getBudget() != null ? projectDTO.getBudget() : new BigDecimal("30000000");
        
        // 카테고리별 마일스톤
        List<ContractMilestoneDTO> milestones = new ArrayList<>();
        LocalDate milestoneStart = startDate;
        
        switch (category) {
            case "ai":
                addMilestone(milestones, 1, "데이터 수집 및 정제", "데이터셋 구성, 전처리", 
                            milestoneStart.plusWeeks(2), budget.multiply(new BigDecimal("0.25")));
                addMilestone(milestones, 2, "모델 개발 및 학습", "모델링, 실험, 튜닝", 
                            milestoneStart.plusWeeks(6), budget.multiply(new BigDecimal("0.5")));
                addMilestone(milestones, 3, "검증 및 배포", "모델 검증, 서빙", 
                            milestoneStart.plusWeeks(10), budget.multiply(new BigDecimal("0.25")));
                break;
            case "mobile":
                addMilestone(milestones, 1, "앱 UI/UX 설계", "와이어프레임, 핵심 화면", 
                            milestoneStart.plusWeeks(2), budget.multiply(new BigDecimal("0.3")));
                addMilestone(milestones, 2, "백엔드 연동", "API 연동, 푸시/로그인", 
                            milestoneStart.plusWeeks(6), budget.multiply(new BigDecimal("0.45")));
                addMilestone(milestones, 3, "스토어 릴리즈", "QA, 빌드/서명, 배포", 
                            milestoneStart.plusWeeks(10), budget.multiply(new BigDecimal("0.25")));
                break;
            case "fintech":
                addMilestone(milestones, 1, "계정/KYC 구축", "본인인증, 위험평가", 
                            milestoneStart.plusWeeks(2), budget.multiply(new BigDecimal("0.3")));
                addMilestone(milestones, 2, "결제/정산 모듈", "카드/계좌/수수료", 
                            milestoneStart.plusWeeks(6), budget.multiply(new BigDecimal("0.45")));
                addMilestone(milestones, 3, "보안/감사 대응", "로그/모니터링", 
                            milestoneStart.plusWeeks(10), budget.multiply(new BigDecimal("0.25")));
                break;
            default:
                addMilestone(milestones, 1, "요구사항 분석 및 설계", "기능 명세, 아키텍처", 
                            milestoneStart.plusWeeks(2), budget.multiply(new BigDecimal("0.3")));
                addMilestone(milestones, 2, "핵심 기능 개발", "백엔드/프론트엔드, 단위 테스트", 
                            milestoneStart.plusWeeks(6), budget.multiply(new BigDecimal("0.5")));
                addMilestone(milestones, 3, "테스트 및 배포", "통합 테스트, 프로덕션", 
                            milestoneStart.plusWeeks(10), budget.multiply(new BigDecimal("0.2")));
        }
        
        insight.setProposedMilestones(milestones);
        
        // 리스크 (동적 감지)
        List<String> risks = new ArrayList<>();
        if (text.contains("delay") || text.contains("지연")) {
            risks.add("일정 지연 위험 감지");
        }
        if (text.contains("change") || text.contains("변경") || text.contains("범위")) {
            risks.add("요구사항 변경 위험");
        }
        if (text.contains("budget") || text.contains("예산") || text.contains("대금")) {
            risks.add("예산 초과 위험");
        }
        if (risks.size() < 2) {
            risks.add("요구사항 명세 필요");
            risks.add("일정 관리 필요");
        }
        insight.setRiskFactors(buildRiskSentences(risks, startDate, endDate, category, budget));
        
        // 권장사항
        insight.setRecommendedReviewPoints(Arrays.asList(
            "요구사항 명세서 확정 (기능목록, API 명세)",
            "주간 진행보고 및 변경 절차 명시",
            "마일스톤별 완료 기준 합의",
            category.equals("ai") ? "데이터 품질 기준 수립" : "코드 리뷰 프로세스 정립"
        ));
        
        // 메타 정보
        insight.setAnalysisModel("mcp-fallback(" + category + ")");
        insight.setAnalysisTimestamp(LocalDateTime.now().toString());
        
        // 신뢰도
        double computedConfidence = computeConfidenceScore(pdfDateUsed, extractedDurationMonths != null, complexity, textRaw, milestones);
        double finalConfidence = Math.min(0.95, (confidence + computedConfidence) / 2.0);
        insight.setConfidenceScore(finalConfidence);
        
        logger.info("Fallback 분석 완료: 신뢰도={}%, 카테고리={}, 날짜={} ~ {}", 
                    String.format("%.0f", confidence * 100), category, startDate, endDate);
        
        return insight;
    }
    
    private String detectCategory(String text) {
        if (text.contains("machine learning") || text.contains("ml") || text.contains("인공지능") || text.contains("머신러닝")) {
            return "ai";
        }
        if (text.contains("android") || text.contains("ios") || text.contains("mobile") || text.contains("모바일") || text.contains("앱")) {
            return "mobile";
        }
        if (text.contains("finance") || text.contains("payment") || text.contains("금융") || text.contains("결제") || text.contains("핀테크")) {
            return "fintech";
        }
        if (text.contains("blockchain") || text.contains("solidity") || text.contains("블록체인")) {
            return "blockchain";
        }
        if (text.contains("healthcare") || text.contains("medical") || text.contains("의료") || text.contains("병원")) {
            return "healthcare";
        }
        if (text.contains("shop") || text.contains("checkout") || text.contains("cart") || text.contains("쇼핑몰") || text.contains("전자상거래")) {
            return "ecommerce";
        }
        return "general";
    }
    
    private void addMilestone(List<ContractMilestoneDTO> list, int order, String name, 
                             String scope, LocalDate due, BigDecimal amount) {
        ContractMilestoneDTO m = new ContractMilestoneDTO();
        m.setStepOrder(order);
        m.setMilestoneName(order + "단계: " + name);
        m.setWorkScope(scope);
        m.setDueDate(due);
        m.setAmount(amount.setScale(0, RoundingMode.HALF_UP));
        m.setStatus("PENDING");
        list.add(m);
    }

    // 리스크 키워드를 실제 문장으로 확장해 UI에 바로 노출할 수 있게 변환한다.
    private List<String> buildRiskSentences(List<String> rawRisks, LocalDate startDate, LocalDate endDate,
                                            String category, BigDecimal budget) {
        List<String> sentences = new ArrayList<>();
        BigDecimal safeBudget = budget != null ? budget : BigDecimal.ZERO;

        if (rawRisks == null || rawRisks.isEmpty()) {
            sentences.add("요구사항 변경 시 영향도 평가와 승인 절차를 사전에 정의하세요.");
            sentences.add("주간 단위로 진행 상황을 공유해 일정 지연을 조기에 발견하세요.");
            return sentences;
        }

        for (String risk : rawRisks) {
            String lower = risk.toLowerCase();
            if (lower.contains("지연") || lower.contains("delay")) {
                sentences.add(String.format("일정 지연 가능성이 있습니다. %s부터 %s까지 주요 마일스톤을 명확히 정의하고 슬랙 타임을 확보하세요.",
                        startDate, endDate));
                continue;
            }
            if (lower.contains("변경") || lower.contains("change") || lower.contains("scope")) {
                sentences.add("요구사항 변경 위험이 감지되었습니다. 변경 요청서를 표준화하고 승인·반려 SLA를 명시하세요.");
                continue;
            }
            if (lower.contains("예산") || lower.contains("budget")) {
                sentences.add(String.format("예산 초과 가능성이 있습니다. 총액 %,d원 기준으로 마일스톤별 한도를 명시하고 초과분 승인 절차를 넣으세요.",
                        safeBudget.longValue()));
                continue;
            }
            sentences.add(risk + "에 대비해 역할과 검증 절차를 명확히 해주세요.");
        }

        if ("fintech".equalsIgnoreCase(category)) {
            sentences.add("금융 데이터 처리 시 로그·모니터링과 접근제어를 명확히 정의하세요.");
        }

        // 중복 제거 유지
        return new ArrayList<>(new LinkedHashSet<>(sentences));
    }

    // 추출 품질(날짜/기간), 텍스트 정보량, 마일스톤 커버리지로 신뢰도를 산정한다.
    private double computeConfidenceScore(boolean pdfDateUsed, boolean durationDetected, double complexity,
                                          String pdfText, List<ContractMilestoneDTO> milestones) {
        double score = 0.55;
        score += pdfDateUsed ? 0.18 : 0.08;
        score += durationDetected ? 0.05 : 0.0;

        String safeText = pdfText != null ? pdfText : "";
        double lengthFactor = Math.min(1.0, Math.min(safeText.length(), 5000) / 5000.0);
        score += lengthFactor * 0.12;

        int milestoneCount = milestones != null ? milestones.size() : 0;
        score += Math.min(0.08, milestoneCount * 0.02);

        score += Math.min(0.1, (complexity / 100.0) * 0.1);

        return Math.min(0.95, Math.max(0.35, score));
    }
    
    @Override
    public String getServiceStatus() {
        return "mcp-local-ai";
    }
    
    @Override
    public boolean validateMilestoneAmount(Long totalBudget, Long milestoneTotalAmount) {
        if (totalBudget == null || milestoneTotalAmount == null) {
            return false;
        }
        
        // ±10% 오차 허용
        long difference = Math.abs(totalBudget - milestoneTotalAmount);
        double errorRate = (double) difference / totalBudget;
        
        return errorRate <= 0.1;
    }
}
