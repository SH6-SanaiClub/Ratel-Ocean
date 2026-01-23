package com.sanaiclub.contract.model.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * 계약 수정 요청 DTO
 * 
 * [역할]
 * - 계약 수정 시 클라이언트로부터 받는 요청 데이터
 * - ContractController.confirmContract()에서 사용 (UPDATE 시)
 * 
 * [주요 차이점]
 * - ContractCreateRequestDTO와 유사하지만 contractId 포함
 * - projectId, freelancerId는 불필요 (contractId로 식별)
 * 
 * [사용 흐름]
 * - ContractController → ContractService.updateContract()
 */
@Getter
@Setter
public class ContractUpdateRequestDTO {
    private Integer contractId;
    private String contractStartDate;
    private String contractEndDate;
    private Long totalBudget;
    private String paymentMethod;
    private String contractStatus;
    private String originContractUrl;
    private String contractPurpose;
    private String workScope;
    private String deliverables;
    private String paymentCondition;
    private String scheduleCondition;
    private String specialTerms;
    private List<ContractMilestoneRequestDTO> milestones;
}
