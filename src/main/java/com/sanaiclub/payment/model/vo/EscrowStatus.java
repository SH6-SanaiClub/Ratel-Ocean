package com.sanaiclub.payment.model.vo;

public enum EscrowStatus {

    /** 보유 중 (아직 지급 전) */
    HOLDING,

    /** 일부 지급됨 */
    PARTIAL_RELEASED,

    /** 전액 지급 완료 */
    COMPLETED,

    /** 전액 환불됨 */
    REFUNDED,

    /** 부분 환불됨 */
    PARTIAL_REFUNDED

}
