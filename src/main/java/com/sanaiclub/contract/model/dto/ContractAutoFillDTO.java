package com.sanaiclub.contract.model.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.util.List;

/** AI 자동 작성 계약 초안 DTO. PDF 또는 사용자 입력 분석 결과. 사용자 검토 및 수정 필요. */
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
