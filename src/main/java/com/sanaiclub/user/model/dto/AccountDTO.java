package com.sanaiclub.user.model.dto;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
public class AccountDTO {
    private String bankName;        // 은행명
    private String accountNumber;   // 계좌번호
    private String accountHolder;   // 예금주

    private String walletPassword;  // 지갑 출금 비밀번호
    private String walletPasswordConfirm;  //지갑 출금 비밀번호 확인

    public boolean isWalletPasswordMatching() {
        if (walletPassword == null || walletPasswordConfirm == null) {
            return false;
        }
        return walletPassword.equals(walletPasswordConfirm);
    }

}