package com.sanaiclub.contract.model.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.sanaiclub.contract.model.vo.MilestoneStatus;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;


@Getter
@Setter
@JsonIgnoreProperties(ignoreUnknown = true)
public class ContractMilestoneResponseDTO {
    private Integer milestoneId;
    private Integer step;
    private String title;
    private String description;
    private Long amount;
    private LocalDate dueDate;
    private MilestoneStatus status;


}
