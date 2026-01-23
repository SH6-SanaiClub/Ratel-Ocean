package com.sanaiclub.contract.model.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * 계약 응답 DTO
 * 
 * [역할]
 * - 계약 조회 시 클라이언트에게 반환하는 응답 데이터
 * - 화면 표시에 필요한 필드만 포함
 * 
 * [주요 필드]
 * - contractId: 계약 ID
 * - projectId, freelancerId: originContractUrl에서 추출
 * - contractStatus: 계약 상태 (WAITING, SIGNED, TERMINATED, COMPLETED)
 * - originContractUrl: PDF 경로
 * - milestones: 마일스톤 목록
 * 
 * [데이터 흐름]
 * - ContractService.getContractById() → ContractResponseDTO
 * - ContractService.toResponseDTO()에서 VO → DTO 변환
 */
@Getter
@Setter
public class ContractResponseDTO {
    private Integer contractId;
    private Integer projectId;
    private Integer freelancerId;
    private String contractStartDate;
    private String contractEndDate;
    private Long totalBudget;
    private String paymentMethod;
    private String contractStatus;
    private String originContractUrl;
    private String platformContractUrl;
    private String aiReportUrl;
    private String contractedAt;
    private String completedAt;
    private String cancelReason;
    private String contractPurpose;
    private String workScope;
    private String deliverables;
    private String paymentCondition;
    private String scheduleCondition;
    private String specialTerms;
    private List<ContractMilestoneResponseDTO> milestones;
    private List<String> requirements;
    private String contractSummary;
}
