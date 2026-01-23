package com.sanaiclub.contract.model.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.util.List;

/**
 * ContractAutoFillDTO - AI 자동 작성 계약 초안 DTO
 * 
 * [역할]
 * - AI가 생성한 계약 초안 정보
 * - 요청/응답 목적
 */
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
