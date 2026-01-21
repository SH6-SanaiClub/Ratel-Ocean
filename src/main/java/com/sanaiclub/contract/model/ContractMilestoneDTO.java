package com.sanaiclub.contract.model;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * ContractMilestoneDTO
 * ═══════════════════════════════════════════════════════════════════════
 */
@Getter
@Setter
@NoArgsConstructor
public class ContractMilestoneDTO {

    /**
     * 마일스톤 단계 순서
     */
    private int step;

    /**
     * 마일스톤 제목
     */
    private String title;

    /**
     * 마일스톤 상세 설명
     */
    private String description;

    /**
     * 해당 단계 완료 시 지급될 금액
     */
    private Long amount;

    /**
     * 완료 기준
     */
    private String completionCriteria;
}
