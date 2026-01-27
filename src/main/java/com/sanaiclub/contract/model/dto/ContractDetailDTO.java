package com.sanaiclub.contract.model.dto;

import com.sanaiclub.contract.model.vo.ContractStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.sql.Date;

/** 계약 상세 정보 화면 전용 DTO. 6개 테이블 JOIN으로 모든 상세 정보 포함. AI 분석 및 자동 채우기에 필수. ContractResponseDTO와 분리 이유: 목록은 3개 테이블 JOIN으로 최적화. */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ContractDetailDTO {
    // ========================================================================
    // 계약 기본 정보
    // ========================================================================
    private Integer contractId;
    private String contractStartDate;
    private String contractEndDate;
    private Long totalBudget;
    private String paymentMethod;
    private ContractStatus contractStatus;
    private String originContractUrl;
    private String contractedAt;
    private String completedAt;
    private String cancelReason;
    
    // ========================================================================
    // 프로젝트 정보 (필요한 필드만)
    // ========================================================================
    private Integer projectId;
    private String projectTitle;
    private String projectDescription;
    private Date projectStartDate;
    private Date projectDeadlineDate;
    private String projectEstDuration;
    private Integer projectBudget;
    private String projectCommunicateMethod;
    private String projectPaymentMethod;
    
    // ========================================================================
    // 프리랜서 정보 (필요한 필드만)
    // ========================================================================
    private Integer freelancerId;
    private String freelancerName;
    private String freelancerEmail;
    
    // ========================================================================
    // 클라이언트 정보 (필요한 필드만)
    // ========================================================================
    private Integer clientId;
    private String clientName;
    private String clientEmail;
    private String clientPhone;
    
    // ========================================================================
    // 회사 정보 (필요한 필드만)
    // ========================================================================
    private String companyName;
}
