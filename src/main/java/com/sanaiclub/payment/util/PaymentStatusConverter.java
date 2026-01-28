// src/main/java/com/sanaiclub/payment/util/PaymentStatusConverter.java
package com.sanaiclub.payment.util;

import com.sanaiclub.payment.model.vo.PaymentTransactionStatus;

/**
 * ============================================================================
 * PaymentStatusConverter - 포트원 결제 상태 변환기
 * ============================================================================
 *
 * [역할]
 * - 포트원 API의 결제 상태를 내부 PaymentStatus Enum으로 변환
 *
 * [포트원 상태]
 * - ready: 결제 대기 (가상계좌 발급 등)
 * - paid: 결제 완료
 * - cancelled: 결제 취소
 * - failed: 결제 실패
 *
 * ============================================================================
 */
public class PaymentStatusConverter {

    /**
     * 포트원 상태 → PaymentStatus 변환
     *
     * @param portoneStatus 포트원 결제 상태 (ready, paid, cancelled, failed)
     * @return PaymentStatus Enum
     */
    public static PaymentTransactionStatus fromPortone(String portoneStatus) {
        if (portoneStatus == null) {
            return PaymentTransactionStatus.PENDING;
        }

        switch (portoneStatus.toLowerCase()) {
            case "paid":
                return PaymentTransactionStatus.PAID;
            case "cancelled":
                return PaymentTransactionStatus.CANCELED;
            case "failed":
                return PaymentTransactionStatus.FAILED;
            case "ready":
            default:
                return PaymentTransactionStatus.PENDING;
        }
    }

    /**
     * PaymentStatus → 포트원 상태 변환
     *
     * @param paymentStatus PaymentStatus Enum
     * @return 포트원 결제 상태
     */
    public static String toPortone(PaymentTransactionStatus paymentStatus) {
        if (paymentStatus == null) {
            return "ready";
        }

        switch (paymentStatus) {
            case PAID:
                return "paid";
            case CANCELED:
                return "cancelled";
            case FAILED:
                return "failed";
            case PENDING:
            default:
                return "ready";
        }
    }
}