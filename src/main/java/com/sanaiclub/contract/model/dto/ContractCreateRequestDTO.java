package com.sanaiclub.contract.model.dto;

import lombok.Getter;
import lombok.Setter;
import com.sanaiclub.contract.model.vo.ContractStatus;

import java.util.List;

/** 계약 생성 요청 DTO. 계약서 작성 폼 데이터 수집용. 마일스톤 정보 포함. */
@Getter
@Setter
public class ContractCreateRequestDTO {
    private Integer projectId;
    private Integer freelancerId;
    private Integer applicationId;
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
    private List<String> requirements;
}
