package com.sanaiclub.wallet.model.vo;

public enum WalletIoType {

    /** 입금 */
    DEPOSIT,

    /** 출금 (지갑 → 계좌) */
    WITHDRAWAL,

    /** 지급 (에스크로 → 지갑) */
    PAYMENT,

    /** 환불 (에스크로 → 지갑) */
    REFUND

}