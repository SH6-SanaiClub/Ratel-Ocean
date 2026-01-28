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
public class PaymentVO {

    /** 결제 ID (PK) */
    private Integer paymentId;

    /** 계약 ID (FK) */
    private Integer contractId;

    /** 포트원 결제 고유번호 */
    private String impUid;

    /** 가맹점 주문번호 (contract_{contractId}_{timestamp}) */
    private String merchantUid;

    /** 결제 금액 */
    private Long amount;

    /** 결제 수단 (card, trans, vbank 등) */
    private String paymentMethod;

    /** 결제 상태 (PENDING, PAID, FAILED, CANCELED) */
    private PaymentTransactionStatus paymentStatus;

    /** 결제 완료 시각 */
    private LocalDateTime paidAt;

    /** 결제 실패 사유 */
    private String failedReason;

    /** 구매자 이름 */
    private String buyerName;

    /** 구매자 이메일 */
    private String buyerEmail;

    /** 구매자 연락처 */
    private String buyerTel;

    /** PG사 (html5_inicis, nice 등) */
    private String pgProvider;

    /** PG사 거래 고유번호 */
    private String pgTid;

    /** 카드사 이름 */
    private String cardName;

    /** 카드번호 (마스킹) */
    private String cardNumber;

    /** 영수증 URL */
    private String receiptUrl;

    /** 생성일시 */
    private LocalDateTime createdAt;

    /** 수정일시 */
    private LocalDateTime updatedAt;
}