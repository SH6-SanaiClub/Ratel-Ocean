package com.sanaiclub.contract.model.vo;

import lombok.Builder;
import lombok.Getter;

/**
 * ContractVO - contracts 테이블 매핑 VO (Value Object)
 * 
 * [역할]
 * - DB의 contracts 테이블과 1:1 매핑
 * - 불변 객체 (setter 없음)
 * - Builder 패턴으로만 생성
 */
@Getter
@Builder
public class ContractVO {
    private final Integer contractId;
    private final String contractStartDate;
    private final String contractEndDate;
    private final Long totalBudget;
    private final String paymentMethod;
    private final String contractStatus;
    private final String originContractUrl;
    private final String platformContractUrl;
    private final String aiReportUrl;
    private final String contractedAt;
    private final String completedAt;
    private final String cancelReason;
    private final Integer clientRating;
    private final String clientExperience;
    private final Boolean clientIsRenewalIntended;
    private final Integer freelancerRating;
    private final String freelancerExperience;
}
