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
public class EscrowVO {

    /** 에스크로 ID (PK) */
    private Integer escrowId;

    /** 결제 ID (FK) */
    private Integer paymentId;

    /** 계약 ID (FK) */
    private Integer contractId;

    /** 총 예치금 (결제 금액) */
    private Long totalAmount;

    /** 현재 보유 중인 금액 (아직 지급 안 된 금액) */
    private Long heldAmount;

    /** 지급 완료된 누적 금액 */
    private Long releasedAmount;

    /** 환불된 금액 */
    private Long refundedAmount;

    /** 에스크로 상태 (HOLDING, PARTIAL_RELEASED, COMPLETED, REFUNDED, PARTIAL_REFUNDED) */
    private EscrowStatus escrowStatus;

    /** 생성일시 */
    private LocalDateTime createdAt;

    /** 수정일시 */
    private LocalDateTime updatedAt;
}