package com.sanaiclub.contract.model.vo;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;


@Getter
@Builder
public class ContractMilestoneVO {

    private final Integer milestoneId;

    /** 계약 ID (FK, contracts 테이블 참조) */
    private final Integer contractId;
    
    /** 마일스톤 단계 순서 (1, 2, 3, ...) */
    private final Integer step;
    
    /** 마일스톤 이름/제목 (예: "1단계: 기획 및 설계") */
    private final String title;
    
    /** 작업 범위/설명 (예: "요구사항 분석, 시스템 설계 문서 작성") */
    private final String description;
    
    /** 해당 마일스톤의 결제 금액 (Long 타입, 원 단위) */
    private final Long amount;

    private final LocalDate dueDate;

    private final MilestoneStatus status;

}
