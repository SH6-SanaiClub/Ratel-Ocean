package com.sanaiclub.contract.model.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.util.List;


@Getter
@Setter
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class ContractAutoFillDTO {
    private LocalDate contractStartDate;
    private LocalDate contractEndDate;
    private Long totalBudget;
    private String paymentMethod;
    private List<ContractMilestoneResponseDTO> milestones;
    private List<String> requirements;
}
