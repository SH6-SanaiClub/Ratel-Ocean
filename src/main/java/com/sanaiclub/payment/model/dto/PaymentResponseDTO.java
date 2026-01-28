package com.sanaiclub.payment.model.dto;

import com.sanaiclub.contract.model.vo.PaymentStatus;
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
public class PaymentResponseDTO {

    /** 결제 ID */
    private Integer paymentId;

    /** 계약 ID */
    private Integer contractId;

    /** 포트원 결제 고유번호 */
    private String impUid;

    /** 가맹점 주문번호 */
    private String merchantUid;

    /** 결제 금액 */
    private Long amount;

    /** 결제 수단 */
    private String paymentMethod;

    /** 결제 상태 */
    private PaymentStatus paymentStatus;

    /** 결제 완료 시각 */
    private LocalDateTime paidAt;

    /** 영수증 URL */
    private String receiptUrl;

    /** 성공 여부 */
    private Boolean success;

    /** 메시지 */
    private String message;
}