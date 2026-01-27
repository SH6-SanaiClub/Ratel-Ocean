package com.sanaiclub.contract.model.dto;

import lombok.Getter;
import lombok.Setter;
import com.sanaiclub.contract.model.enums.ContractStatus;

import java.util.List;

/** 계약 응답 DTO. 목록 조회용. 마일스톤 집계 정보 포함. ContractDetailDTO와 분리 이유: 목록은 3개 테이블 JOIN, 상세는 6개 테이블 JOIN으로 쿼리 최적화. */
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
    private ContractStatus contractStatus;
    private String originContractUrl;
    private String contractedAt;
    private String completedAt;
    private String cancelReason;
    private List<ContractMilestoneResponseDTO> milestones;
    
    private String projectTitle;
    private String freelancerName;
    private String clientName;
    private String counterpartName;
    
    private Integer totalMilestones;
    private Integer paidMilestones;
    private Integer requestedMilestones;
    private Integer depositedMilestones;
    private Integer waitingMilestones;
}
