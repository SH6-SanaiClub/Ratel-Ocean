package com.sanaiclub.domain.contract.dto;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * ContractDTO
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [역할]
 * contracts 테이블의 데이터를 나타내는 DTO입니다.
 * 
 * [데이터 구성]
 * - 기본 정보: contract_id, application_id, 금액, 기간
 * - URL: origin_contract_url, platform_contract_url, ai_report_url
 * - 상태: contract_status, contracted_at, completed_at
 * 
 * [DB 필드와 매핑]
 * contract_id (PK) → contractId
 * application_id (FK) → applicationId
 * total_budget → totalBudget
 * payment_method → paymentMethod ('LUMPSUM' or 'MILESTONE')
 * contract_start_date → contractStartDate
 * contract_end_date → contractEndDate
 * contract_status → contractStatus ('SIGNED', 'IN_PROGRESS', 'COMPLETED', 'TERMINATED')
 * origin_contract_url → originContractUrl (사용자 업로드 PDF)
 * platform_contract_url → platformContractUrl (플랫폼 생성 계약서)
 * ai_report_url → aiReportUrl (AI 분석 리포트)
 * contracted_at → contractedAt
 * completed_at → completedAt
 * updated_at → updatedAt
 * 
 * [사용 시나리오]
 * 1. ContractService.confirmContract() → ContractMapper.insert()
 * 2. ContractController.getContractDetails() → 조회
 * 3. 상태 변경 (진행 중 → 완료 → 종료)
 */
public class ContractDTO implements Serializable {
    private static final long serialVersionUID = 1L;
    
    // 기본 정보
    private Long contractId;
    private Long applicationId; // 프로젝트 공고 ID (FK)
    private Long totalBudget;
    private String paymentMethod; // "LUMPSUM" or "MILESTONE"
    
    // 계약 기간
    private LocalDate contractStartDate;
    private LocalDate contractEndDate;
    
    // 상태
    private String contractStatus; // "SIGNED", "IN_PROGRESS", "COMPLETED", "TERMINATED"
    
    // URL 정보
    private String originContractUrl;      // 사용자 업로드 PDF 경로
    private String platformContractUrl;    // 플랫폼 생성 계약서 (향후)
    private String aiReportUrl;            // AI 분석 리포트 (계약 확정 후)
    
    // 타임스탬프
    private LocalDateTime contractedAt;    // 계약 생성 시간
    private LocalDateTime completedAt;     // 계약 완료 시간 (선택)
    private LocalDateTime updatedAt;       // 마지막 수정 시간
    
    // ════════════════════════════════════════════════════════════════════
    // Constructors
    // ════════════════════════════════════════════════════════════════════
    public ContractDTO() {
    }
    
    public ContractDTO(Long applicationId, Long totalBudget, String paymentMethod) {
        this.applicationId = applicationId;
        this.totalBudget = totalBudget;
        this.paymentMethod = paymentMethod;
    }
    
    // ════════════════════════════════════════════════════════════════════
    // Helper Methods
    // ════════════════════════════════════════════════════════════════════
    
    /**
     * 계약이 진행 중인지 확인합니다.
     */
    public boolean isInProgress() {
        return "IN_PROGRESS".equals(contractStatus);
    }
    
    /**
     * 계약이 완료되었는지 확인합니다.
     */
    public boolean isCompleted() {
        return "COMPLETED".equals(contractStatus);
    }
    
    /**
     * 계약이 마일스톤 기반 결제인지 확인합니다.
     */
    public boolean isMilestonePayment() {
        return "MILESTONE".equals(paymentMethod);
    }
    
    /**
     * 계약 기간(일 수)을 계산합니다.
     */
    public long getDurationDays() {
        if (contractStartDate == null || contractEndDate == null) {
            return 0;
        }
        return java.time.temporal.ChronoUnit.DAYS.between(contractStartDate, contractEndDate);
    }
    
    // ════════════════════════════════════════════════════════════════════
    // Getters & Setters
    // ════════════════════════════════════════════════════════════════════
    
    public Long getContractId() { return contractId; }
    public void setContractId(Long contractId) { this.contractId = contractId; }
    
    public Long getApplicationId() { return applicationId; }
    public void setApplicationId(Long applicationId) { this.applicationId = applicationId; }
    
    public Long getTotalBudget() { return totalBudget; }
    public void setTotalBudget(Long totalBudget) { this.totalBudget = totalBudget; }
    
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    
    public LocalDate getContractStartDate() { return contractStartDate; }
    public void setContractStartDate(LocalDate contractStartDate) { 
        this.contractStartDate = contractStartDate; 
    }
    
    public LocalDate getContractEndDate() { return contractEndDate; }
    public void setContractEndDate(LocalDate contractEndDate) { 
        this.contractEndDate = contractEndDate; 
    }
    
    public String getContractStatus() { return contractStatus; }
    public void setContractStatus(String contractStatus) { 
        this.contractStatus = contractStatus; 
    }
    
    public String getOriginContractUrl() { return originContractUrl; }
    public void setOriginContractUrl(String originContractUrl) { 
        this.originContractUrl = originContractUrl; 
    }
    
    public String getPlatformContractUrl() { return platformContractUrl; }
    public void setPlatformContractUrl(String platformContractUrl) { 
        this.platformContractUrl = platformContractUrl; 
    }
    
    public String getAiReportUrl() { return aiReportUrl; }
    public void setAiReportUrl(String aiReportUrl) { 
        this.aiReportUrl = aiReportUrl; 
    }
    
    public LocalDateTime getContractedAt() { return contractedAt; }
    public void setContractedAt(LocalDateTime contractedAt) { 
        this.contractedAt = contractedAt; 
    }
    
    public LocalDateTime getCompletedAt() { return completedAt; }
    public void setCompletedAt(LocalDateTime completedAt) { 
        this.completedAt = completedAt; 
    }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { 
        this.updatedAt = updatedAt; 
    }
}
