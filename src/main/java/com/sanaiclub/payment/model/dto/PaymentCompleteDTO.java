package com.sanaiclub.payment.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;


@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentCompleteDTO {

    /** 포트원 결제 고유번호 */
    private String impUid;

    /** 가맹점 주문번호 */
    private String merchantUid;

    /** 결제 상태 (success, failed 등) */
    private String status;

    /** 에러 메시지 (결제 실패 시) */
    private String errorMsg;
}