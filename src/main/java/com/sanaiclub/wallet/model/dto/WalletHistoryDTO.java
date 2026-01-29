package com.sanaiclub.wallet.model.dto;

import com.sanaiclub.payment.model.vo.WalletIoType;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class WalletHistoryDTO {
    private Integer walletHistoryId;
    private Integer walletId;
    private WalletIoType ioType;   //  enum
    private Integer amount;
    private Integer balance;
    private String summary;
    private String createdAt;      // 문자열로 내려줌
}
