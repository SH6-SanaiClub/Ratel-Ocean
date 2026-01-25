package com.sanaiclub.payment.model.vo;

public enum RefundStatus {

    /** 환불 요청됨 */
    REQUESTED,

    /** 환불 처리 중 */
    PROCESSING,

    /** 환불 완료 */
    COMPLETED,

    /** 환불 실패 */
    FAILED

}
