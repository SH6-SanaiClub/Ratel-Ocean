package com.sanaiclub.contract.model.vo;

public enum PaymentStatus {

    /** 미결제 */
    UNPAID,

    /** 결제 완료 */
    PAID,

    /** 부분 환불 (일부 마일스톤 지급 후 환불) */
    PARTIAL_REFUNDED,

    /** 전액 환불 */
    REFUNDED

}
