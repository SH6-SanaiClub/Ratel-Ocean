package com.sanaiclub.payment.model.vo;

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
public class RefundVO {

    /** 환불 ID (PK) */
    private Integer refundId;

    /** 원본 결제 ID (FK) */
    private Integer paymentId;

    /** 계약 ID (FK) */
    private Integer contractId;

    /** 환불 금액 */
    private Long refundAmount;

    /** 환불 사유 */
    private String reason;

    /** 환불 요청자 user_id */
    private Integer requestedBy;

    /** 환불 상태 (REQUESTED, PROCESSING, COMPLETED, FAILED) */
    private RefundStatus refundStatus;

    /** 포트원 환불 고유번호 */
    private String impRefundUid;

    /** 환불 완료 시각 */
    private LocalDateTime refundedAt;

    /** 환불 실패 사유 */
    private String failedReason;

    /** 생성일시 */
    private LocalDateTime createdAt;

    /** 수정일시 */
    private LocalDateTime updatedAt;
}