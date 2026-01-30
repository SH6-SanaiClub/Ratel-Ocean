package com.sanaiclub.wallet.model.vo;

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
public class WalletHistoryVO {

    /** 지갑 거래 내역 ID (PK) */
    private Integer walletHistoryId;

    /** 지갑 ID (FK) */
    private Integer walletId;

    /** 거래 유형 (DEPOSIT, WITHDRAWAL, PAYMENT, REFUND) */
    private WalletIoType ioType;

    /** 거래 금액 */
    private Long amount;

    /** 거래 후 잔액 (스냅샷) */
    private Long balance;

    /** 거래 요약 */
    private String summary;

    /** 생성일시 */
    private LocalDateTime createdAt;
}