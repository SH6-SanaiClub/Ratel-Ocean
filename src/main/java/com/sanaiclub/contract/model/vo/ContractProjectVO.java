package com.sanaiclub.contract.model.vo;

import lombok.Builder;
import lombok.Getter;

/**
 * ContractProjectVO - 프로젝트 정보 VO
 * 
 * [역할]
 * - 계약 관련 프로젝트 정보를 담는 불변 객체
 * - Builder 패턴으로만 생성
 */
@Getter
@Builder
public class ContractProjectVO {
    private final Integer projectId;
    private final Integer clientId;
    private final String title;
    private final String description;
    private final String budget;
    private final String estDuration;
    private final String startDate;
    private final String deadlineDate;
}
