package com.sanaiclub.contract.model.vo;

import lombok.Builder;
import lombok.Getter;
import com.sanaiclub.contract.model.enums.MilestoneStatus;

import java.time.LocalDate;

/** 계약 마일스톤 Value Object. contract_milestones 테이블과 1:1 매핑. 불변 객체. 상태 전이: WAITING → REQUESTED → DEPOSITED → PAID. */
@Getter
@Builder
public class ContractMilestoneVO {
    
    private final Long milestoneId;
    private final Integer contractId;
    private final Integer step;
    private final String title;
    private final String description;
    private final Long amount;
    private final LocalDate dueDate;
    private final MilestoneStatus status;
}
