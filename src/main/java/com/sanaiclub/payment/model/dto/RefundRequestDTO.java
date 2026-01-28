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
public class RefundRequestDTO {

    /** 계약 ID */
    private Integer contractId;

    /** 환불 사유 (필수) */
    private String reason;

    /** 요청자 user_id */
    private Integer requestedBy;

    /** 환불 금액 (선택 - 없으면 가능한 최대 금액 환불) */
    private Long refundAmount;
}