package com.sanaiclub.domain.contract.dto;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * ContractMilestoneDTO
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [설명]
 * AI가 생성한 마일스톤 정보를 담는 DTO입니다.
 * 
 * [설계 의도]
 * - AI의 초안 마일스톤을 사용자가 수정 가능하도록 설계
 * - 마일스톤은 계약 확정 시점에만 DB에 저장됨
 * - AI 분석 단계에서는 메모리상에만 존재
 */
public class ContractMilestoneDTO implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private Long milestoneId;              // DB milestone_id (계약 확정 후 할당)
    private Integer stepOrder;             // 마일스톤 순서 (1부터 시작)
    private String milestoneName;          // 마일스톤명 (예: "1단계: 요구사항 분석")
    private String workScope;              // 작업 범위 (예: "문서화, 회의")
    private BigDecimal amount;             // 금액 (원)
    private LocalDate dueDate;             // 완료 예정일
    private String status;                 // WAITING, DEPOSITED, REQUESTED, PAID, CANCELED
    
    // Constructors
    public ContractMilestoneDTO() {}
    
    public ContractMilestoneDTO(Integer stepOrder, String milestoneName, 
                               String workScope, BigDecimal amount, LocalDate dueDate) {
        this.stepOrder = stepOrder;
        this.milestoneName = milestoneName;
        this.workScope = workScope;
        this.amount = amount;
        this.dueDate = dueDate;
        this.status = "WAITING";  // 초기 상태
    }
    
    // Getters & Setters
    public Long getMilestoneId() {
        return milestoneId;
    }
    
    public void setMilestoneId(Long milestoneId) {
        this.milestoneId = milestoneId;
    }
    
    public Integer getStepOrder() {
        return stepOrder;
    }
    
    public void setStepOrder(Integer stepOrder) {
        this.stepOrder = stepOrder;
    }
    
    public String getMilestoneName() {
        return milestoneName;
    }
    
    public void setMilestoneName(String milestoneName) {
        this.milestoneName = milestoneName;
    }
    
    public String getWorkScope() {
        return workScope;
    }
    
    public void setWorkScope(String workScope) {
        this.workScope = workScope;
    }
    
    public BigDecimal getAmount() {
        return amount;
    }
    
    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }
    
    public LocalDate getDueDate() {
        return dueDate;
    }
    
    public void setDueDate(LocalDate dueDate) {
        this.dueDate = dueDate;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    @Override
    public String toString() {
        return "ContractMilestoneDTO{" +
                "milestoneId=" + milestoneId +
                ", stepOrder=" + stepOrder +
                ", milestoneName='" + milestoneName + '\'' +
                ", amount=" + amount +
                ", dueDate=" + dueDate +
                ", status='" + status + '\'' +
                '}';
    }
}
