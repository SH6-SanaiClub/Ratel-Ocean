package com.sanaiclub.contract.model.vo;

import lombok.Builder;
import lombok.Getter;

/** 계약 Value Object. contracts 테이블과 1:1 매핑. 불변 객체. cancel_reason은 일시지급 지급 요청 상태 관리에도 재활용. */
@Getter
@Builder
public class ContractVO {
    private final Integer contractId;
    private final String contractStartDate;
    private final String contractEndDate;
    private final Long totalBudget;
    private final String paymentMethod;
    private final ContractStatus contractStatus;
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
