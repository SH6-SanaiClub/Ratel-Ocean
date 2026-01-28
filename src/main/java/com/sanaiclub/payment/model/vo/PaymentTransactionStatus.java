package com.sanaiclub.payment.model.vo;

public enum PaymentTransactionStatus {

    /** 결제 대기 중 */
    PENDING,

    /** 결제 완료 */
    PAID,

    /** 결제 실패 */
    FAILED,

    /** 결제 취소 */
    CANCELED
}
