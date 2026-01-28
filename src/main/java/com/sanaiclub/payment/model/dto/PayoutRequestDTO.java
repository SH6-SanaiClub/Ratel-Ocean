package com.sanaiclub.payment.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;


@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PayoutRequestDTO {

    /** 계약 ID */
    private Integer contractId;

    /** 마일스톤 ID */
    private Integer milestoneId;

    /** 지급 금액 */
    private Long amount;

    /** 요청자 user_id */
    private Integer requestedBy;

    /** 요청 사유 (선택) */
    private String reason;
}