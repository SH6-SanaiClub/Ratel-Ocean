package com.sanaiclub.contract.model.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Getter;
import lombok.Setter;
import com.sanaiclub.contract.model.vo.MilestoneStatus;

import java.time.LocalDate;

/** 마일스톤 응답 DTO. 계약 조회 시 마일스톤 목록 포함. 상태 전이: WAITING → REQUESTED → DEPOSITED → PAID. */
@Getter
@Setter
@JsonIgnoreProperties(ignoreUnknown = true)
public class ContractMilestoneResponseDTO {
    private Long milestoneId;
    private Integer step;
    private String title;
    private String description;
    private Long amount;
    private LocalDate dueDate;
    private MilestoneStatus status;
}
