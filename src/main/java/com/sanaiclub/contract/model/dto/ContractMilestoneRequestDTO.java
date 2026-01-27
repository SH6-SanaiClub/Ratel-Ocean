package com.sanaiclub.contract.model.dto;

import lombok.Getter;
import lombok.Setter;

/** 마일스톤 요청 DTO. 계약 생성/수정 시 마일스톤 정보 전달. 모든 마일스톤 amount 합계 = totalBudget. */
@Getter
@Setter
public class ContractMilestoneRequestDTO {
    private Integer step;
    private String title;
    private String description;
    private Long amount;
}
