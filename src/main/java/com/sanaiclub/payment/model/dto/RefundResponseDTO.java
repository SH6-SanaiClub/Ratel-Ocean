package com.sanaiclub.payment.model.dto;

import com.sanaiclub.payment.model.vo.RefundStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;


@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RefundResponseDTO {

    /** 환불 ID */
    private Integer refundId;

    /** 계약 ID */
    private Integer contractId;

    /** 환불 금액 */
    private Long refundAmount;

    /** 환불 상태 */
    private RefundStatus refundStatus;

    /** 포트원 환불 고유번호 */
    private String impRefundUid;

    /** 환불 완료 시각 */
    private LocalDateTime refundedAt;

    /** 성공 여부 */
    private Boolean success;

    /** 메시지 */
    private String message;
}