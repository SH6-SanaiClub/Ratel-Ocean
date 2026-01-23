package com.sanaiclub.contract.model.vo;

import lombok.Builder;
import lombok.Getter;

/**
 * ContractMilestoneVO - 계약 마일스톤 VO
 * 
 * [역할]
 * - DB의 contract_milestones 테이블과 매핑
 * - 불변 객체 (setter 없음)
 * - Builder 패턴으로만 생성
 */
@Getter
@Builder
public class ContractMilestoneVO {
    private final Integer contractId;
    private final Integer step;
    private final String title;
    private final String description;
    private final Long amount;
}
