package com.sanaiclub.contract.model;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.util.List;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * ContractAutoFillDTO
 * ═══════════════════════════════════════════════════════════════════════
 */
@Getter
@Setter
@NoArgsConstructor
public class ContractAutoFillDTO {

    /**
     * 계약 시작일 (제안)
     */
    private LocalDate contractStartDate;

    /**
     * 계약 종료일 (제안)
     */
    private LocalDate contractEndDate;

    /**
     * 계약 총 예산
     */
    private Long totalBudget;

    /**
     * 지급 방식
     * FULL / MILESTONE
     */
    private String paymentMethod;

    /**
     * 마일스톤 목록
     */
    private List<ContractMilestoneDTO> milestones;

    /**
     * 주요 기능 및 요구사항 목록
     */
    private List<String> requirements;
}
