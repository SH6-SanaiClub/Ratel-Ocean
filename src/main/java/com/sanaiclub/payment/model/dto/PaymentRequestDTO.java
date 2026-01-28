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
public class PaymentRequestDTO {

    /** 계약 ID */
    private Integer contractId;

    /** 결제 금액 */
    private Long amount;

    /** 구매자 이름 */
    private String buyerName;

    /** 구매자 이메일 */
    private String buyerEmail;

    /** 구매자 연락처 */
    private String buyerTel;

    /** 상품명 (계약서 제목) */
    private String name;
}