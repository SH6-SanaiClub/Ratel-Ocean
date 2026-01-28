package com.sanaiclub.contract.model.dto;

import lombok.Getter;
import lombok.Setter;
import com.sanaiclub.contract.model.vo.ContractStatus;

import java.util.List;

/** 계약 수정 요청 DTO. 기존 마일스톤 삭제 후 새 마일스톤으로 교체. */
@Getter
@Setter
public class ContractUpdateRequestDTO {
    private Integer contractId;
    private String contractStartDate;
    private String contractEndDate;
    private Long totalBudget;
    private String paymentMethod;
    private ContractStatus contractStatus;
    private String originContractUrl;
    private String contractPurpose;
    private String workScope;
    private String deliverables;
    private String paymentCondition;
    private String scheduleCondition;
    private String specialTerms;
    private List<ContractMilestoneRequestDTO> milestones;
}
