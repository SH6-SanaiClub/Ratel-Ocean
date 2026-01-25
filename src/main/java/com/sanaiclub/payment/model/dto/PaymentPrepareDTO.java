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
public class PaymentPrepareDTO {

    /** 가맹점 주문번호 (서버에서 생성) */
    private String merchantUid;

    /** 계약 ID */
    private Integer contractId;

    /** 결제 금액 */
    private Long amount;

    /** 상품명 */
    private String name;

    /** 구매자 정보 */
    private String buyerName;
    private String buyerEmail;
    private String buyerTel;

    /** 포트원 가맹점 식별코드 */
    private String impCode;
}