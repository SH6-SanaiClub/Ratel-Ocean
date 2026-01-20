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
}