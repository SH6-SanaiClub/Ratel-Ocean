package com.sanaiclub.wallet.model.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class FreelancerWalletDTO {
    private Integer walletId;
    private Integer freelancerId;
    private Integer accountId;
    private Integer balance;
    private Integer totalEarned;
}
