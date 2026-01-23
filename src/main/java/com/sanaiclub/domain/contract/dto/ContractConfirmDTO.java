package com.sanaiclub.domain.contract.dto;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * ContractConfirmDTO
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [역할]
 * 사용자가 검토/수정한 계약을 DB에 저장할 때 사용하는 DTO입니다.
 * 
 * [데이터 구성]
 * - 프로젝트/프리랜서 ID (필수)
 * - 사용자가 수정한 계약 정보
 * - 마일스톤 목록
 * - AI 분석 시 받은 PDF 경로
 * 
 * [플로우]
 * 1. contract-review.jsp에서 form 제출
 * 2. ContractController.confirmContract() 수신
 * 3. ContractService.confirmContract() 처리
 * 4. contracts 테이블에 INSERT
 * 5. contract_milestones 테이블에 배치 INSERT
 * 
 * [중요 필드]
 * - pdfPath: 임시 저장된 PDF 경로 (origin_contract_url로 저장)
 * - milestones: 마일스톤 목록 (마일스톤 기반 결제 시 필수)
 * - totalBudget: 마일스톤 예산 합 검증
 */
public class ContractConfirmDTO implements Serializable {
    private static final long serialVersionUID = 1L;
    
    // 식별자 (필수)
    private Long projectId;
    private Long freelancerId;
    private Long applicationId; // project_applications.application_id
    
    // 계약 기본 정보
    private LocalDate contractStartDate;
    private LocalDate contractEndDate;
    private Long totalBudget;
    private String paymentMethod; // "LUMPSUM" or "MILESTONE"
    private Boolean isNegotiable; // 협상 가능 여부
    
    // 마일스톤 정보 (paymentMethod="MILESTONE"일 때)
    private List<ContractMilestoneDTO> milestones;
    
    // 계약 상태
    private String contractStatus = "SIGNED"; // 초기값: SIGNED
    
    // PDF 정보
    private String pdfPath; // 임시 저장된 PDF 경로 (origin_contract_url로 저장)
    private String originalPdfFilename;
    
    // 추가 정보
    private String notes; // 특이사항
    private Long createdBy; // 계약 생성자 ID
    
    // ════════════════════════════════════════════════════════════════════
    // Constructors
    // ════════════════════════════════════════════════════════════════════
    public ContractConfirmDTO() {
    }
    
    // ════════════════════════════════════════════════════════════════════
    // Helper Methods
    // ════════════════════════════════════════════════════════════════════
    
    /**
     * 마일스톤 기반 결제 여부를 확인합니다.
     */
    public boolean isMilestonePayment() {
        return "MILESTONE".equals(paymentMethod);
    }
    
    /**
     * 마일스톤 총액을 계산합니다.
     */
    public BigDecimal calculateMilestoneTotalBudget() {
        if (milestones == null || milestones.isEmpty()) {
            return BigDecimal.ZERO;
        }
        return milestones.stream()
            .map(ContractMilestoneDTO::getAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
    
    // ════════════════════════════════════════════════════════════════════
    // Getters & Setters
    // ════════════════════════════════════════════════════════════════════
    
    public Long getProjectId() { return projectId; }
    public void setProjectId(Long projectId) { this.projectId = projectId; }
    
    public Long getFreelancerId() { return freelancerId; }
    public void setFreelancerId(Long freelancerId) { this.freelancerId = freelancerId; }
    
    public Long getApplicationId() { return applicationId; }
    public void setApplicationId(Long applicationId) { this.applicationId = applicationId; }
    
    public LocalDate getContractStartDate() { return contractStartDate; }
    public void setContractStartDate(LocalDate contractStartDate) { 
        this.contractStartDate = contractStartDate; 
    }
    
    public LocalDate getContractEndDate() { return contractEndDate; }
    public void setContractEndDate(LocalDate contractEndDate) { 
        this.contractEndDate = contractEndDate; 
    }
    
    public Long getTotalBudget() { return totalBudget; }
    public void setTotalBudget(Long totalBudget) { this.totalBudget = totalBudget; }
    
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    
    public Boolean getIsNegotiable() { return isNegotiable; }
    public void setIsNegotiable(Boolean isNegotiable) { this.isNegotiable = isNegotiable; }
    
    public List<ContractMilestoneDTO> getMilestones() { return milestones; }
    public void setMilestones(List<ContractMilestoneDTO> milestones) { 
        this.milestones = milestones; 
    }
    
    public String getContractStatus() { return contractStatus; }
    public void setContractStatus(String contractStatus) { 
        this.contractStatus = contractStatus; 
    }
    
    public String getPdfPath() { return pdfPath; }
    public void setPdfPath(String pdfPath) { this.pdfPath = pdfPath; }
    
    public String getOriginalPdfFilename() { return originalPdfFilename; }
    public void setOriginalPdfFilename(String originalPdfFilename) { 
        this.originalPdfFilename = originalPdfFilename; 
    }
    
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    
    public Long getCreatedBy() { return createdBy; }
    public void setCreatedBy(Long createdBy) { this.createdBy = createdBy; }
}
