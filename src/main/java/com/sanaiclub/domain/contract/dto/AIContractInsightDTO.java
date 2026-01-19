package com.sanaiclub.domain.contract.dto;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * AIContractInsightDTO
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [설명]
 * AI(DeepSeek)가 분석한 계약 인사이트를 담는 DTO입니다.
 * 
 * [설계 의도]
 * 1. 계약 기본 정보 초안 제공
 * 2. 마일스톤 분해 제안
 * 3. 리스크 & 주의사항 제시
 * 4. 모든 정보는 "초안"이며 사용자 수정 가능
 * 
 * [DB 저장 규칙]
 * - AI 분석 단계: DB 저장 금지 (메모리상에만 존재)
 * - 계약 확정 단계: contracts/contract_milestones 테이블에만 저장
 * - ai_report_url: 계약 확정 후 HTML/PDF 생성해서 저장
 */
public class AIContractInsightDTO implements Serializable {
    private static final long serialVersionUID = 1L;
    
    // ════════════════════════════════════════════════════════════
    // Part 1: 계약 기본 정보 초안 (AI가 제안, 사용자가 수정)
    // ════════════════════════════════════════════════════════════
    
    private LocalDate proposedStartDate;           // AI가 제안한 계약 시작일
    private LocalDate proposedEndDate;             // AI가 제안한 계약 종료일
    private String proposedDuration;               // "3개월 (13주)" 형식
    private BigDecimal proposedBudget;             // AI가 제안한 예산
    private String budgetAnalysis;                 // 예산 적절성 분석
    private Boolean budgetNegotiable;              // 협의 가능 여부 (AI 판단)
    
    private String paymentMethod;                  // "ESCROW" 등
    private List<String> communicationMethods;     // ["MESSENGER", "VIDEOCALL", "EMAIL"]
    private String changePolicy;                   // 변경 정책
    private Integer maxRevisionCount;              // 최대 수정 횟수
    
    // ════════════════════════════════════════════════════════════
    // Part 2: 프로젝트 분석 (AI 제안)
    // ════════════════════════════════════════════════════════════
    
    private List<String> developmentAreas;         // ["백엔드 개발", "데이터베이스 설계"]
    private List<String> technicalStacks;          // ["Java 17", "Spring MVC", "MySQL"]
    private String expectedDeliverables;           // 예상 산출물 상세 설명
    private String mainFeatures;                   // 주요 기능 목록
    
    // ════════════════════════════════════════════════════════════
    // Part 3: 마일스톤 초안 (매우 중요)
    // ════════════════════════════════════════════════════════════
    
    private List<ContractMilestoneDTO> proposedMilestones;  // AI가 제안한 마일스톤 분해
    
    // ════════════════════════════════════════════════════════════
    // Part 4: AI 인사이트 (플랫폼 관점)
    // ════════════════════════════════════════════════════════════
    
    private String contractSummary;                // 계약 핵심 요약 (1-2문단)
    private List<String> riskFactors;              // ["예산 부족 가능성", "기간 단축 위험"]
    private List<String> warningPoints;            // ["상세한 API 명세 필요", "..."]
    private List<String> recommendedReviewPoints;  // 사용자가 꼭 검토해야 할 항목
    private String aiAnalysisNotes;                // AI의 종합 의견
    
    // ════════════════════════════════════════════════════════════
    // Part 5: 메타 정보
    // ════════════════════════════════════════════════════════════
    
    private String analysisTimestamp;              // AI 분석 시간
    private String analysisModel;                  // "deepseek-chat" 또는 "mock"
    private Double confidenceScore;                // AI 신뢰도 (0.0 ~ 1.0)
    
    // Constructors
    public AIContractInsightDTO() {}
    
    // Getters & Setters
    public LocalDate getProposedStartDate() {
        return proposedStartDate;
    }
    
    public void setProposedStartDate(LocalDate proposedStartDate) {
        this.proposedStartDate = proposedStartDate;
    }
    
    public LocalDate getProposedEndDate() {
        return proposedEndDate;
    }
    
    public void setProposedEndDate(LocalDate proposedEndDate) {
        this.proposedEndDate = proposedEndDate;
    }
    
    public String getProposedDuration() {
        return proposedDuration;
    }
    
    public void setProposedDuration(String proposedDuration) {
        this.proposedDuration = proposedDuration;
    }
    
    public BigDecimal getProposedBudget() {
        return proposedBudget;
    }
    
    public void setProposedBudget(BigDecimal proposedBudget) {
        this.proposedBudget = proposedBudget;
    }
    
    public String getBudgetAnalysis() {
        return budgetAnalysis;
    }
    
    public void setBudgetAnalysis(String budgetAnalysis) {
        this.budgetAnalysis = budgetAnalysis;
    }
    
    public Boolean getBudgetNegotiable() {
        return budgetNegotiable;
    }
    
    public void setBudgetNegotiable(Boolean budgetNegotiable) {
        this.budgetNegotiable = budgetNegotiable;
    }
    
    public String getPaymentMethod() {
        return paymentMethod;
    }
    
    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }
    
    public List<String> getCommunicationMethods() {
        return communicationMethods;
    }
    
    public void setCommunicationMethods(List<String> communicationMethods) {
        this.communicationMethods = communicationMethods;
    }
    
    public String getChangePolicy() {
        return changePolicy;
    }
    
    public void setChangePolicy(String changePolicy) {
        this.changePolicy = changePolicy;
    }
    
    public Integer getMaxRevisionCount() {
        return maxRevisionCount;
    }
    
    public void setMaxRevisionCount(Integer maxRevisionCount) {
        this.maxRevisionCount = maxRevisionCount;
    }
    
    public List<String> getDevelopmentAreas() {
        return developmentAreas;
    }
    
    public void setDevelopmentAreas(List<String> developmentAreas) {
        this.developmentAreas = developmentAreas;
    }
    
    public List<String> getTechnicalStacks() {
        return technicalStacks;
    }
    
    public void setTechnicalStacks(List<String> technicalStacks) {
        this.technicalStacks = technicalStacks;
    }
    
    public String getExpectedDeliverables() {
        return expectedDeliverables;
    }
    
    public void setExpectedDeliverables(String expectedDeliverables) {
        this.expectedDeliverables = expectedDeliverables;
    }
    
    public String getMainFeatures() {
        return mainFeatures;
    }
    
    public void setMainFeatures(String mainFeatures) {
        this.mainFeatures = mainFeatures;
    }
    
    public List<ContractMilestoneDTO> getProposedMilestones() {
        return proposedMilestones;
    }
    
    public void setProposedMilestones(List<ContractMilestoneDTO> proposedMilestones) {
        this.proposedMilestones = proposedMilestones;
    }
    
    public String getContractSummary() {
        return contractSummary;
    }
    
    public void setContractSummary(String contractSummary) {
        this.contractSummary = contractSummary;
    }
    
    public List<String> getRiskFactors() {
        return riskFactors;
    }
    
    public void setRiskFactors(List<String> riskFactors) {
        this.riskFactors = riskFactors;
    }
    
    public List<String> getWarningPoints() {
        return warningPoints;
    }
    
    public void setWarningPoints(List<String> warningPoints) {
        this.warningPoints = warningPoints;
    }
    
    public List<String> getRecommendedReviewPoints() {
        return recommendedReviewPoints;
    }
    
    public void setRecommendedReviewPoints(List<String> recommendedReviewPoints) {
        this.recommendedReviewPoints = recommendedReviewPoints;
    }
    
    public String getAiAnalysisNotes() {
        return aiAnalysisNotes;
    }
    
    public void setAiAnalysisNotes(String aiAnalysisNotes) {
        this.aiAnalysisNotes = aiAnalysisNotes;
    }
    
    public String getAnalysisTimestamp() {
        return analysisTimestamp;
    }
    
    public void setAnalysisTimestamp(String analysisTimestamp) {
        this.analysisTimestamp = analysisTimestamp;
    }
    
    public String getAnalysisModel() {
        return analysisModel;
    }
    
    public void setAnalysisModel(String analysisModel) {
        this.analysisModel = analysisModel;
    }
    
    public Double getConfidenceScore() {
        return confidenceScore;
    }
    
    public void setConfidenceScore(Double confidenceScore) {
        this.confidenceScore = confidenceScore;
    }
}
