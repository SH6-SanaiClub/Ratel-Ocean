package com.sanaiclub.payment.model.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
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
public class PaymentWebhookDTO {

    /** 포트원 결제 고유번호 */
    @JsonProperty("imp_uid")
    private String impUid;

    /** 가맹점 주문번호 */
    @JsonProperty("merchant_uid")
    private String merchantUid;

    /** 결제 상태 (paid, cancelled 등) */
    @JsonProperty("status")
    private String status;
}