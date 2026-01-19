package com.sanaiclub.domain.wallet.dto;

/**
 * FreelancerWallet DTO - freelancer_wallets 테이블 매핑
 */
public class FreelancerWallet {
    private Long walletId;
    private Long freelancerId;
    private Long accountId;
    private Long balance;
    private Long totalEarned;
    private String walletPw;
    private Integer version;

    // Getters and Setters
    public Long getWalletId() {
        return walletId;
    }

    public void setWalletId(Long walletId) {
        this.walletId = walletId;
    }

    public Long getFreelancerId() {
        return freelancerId;
    }

    public void setFreelancerId(Long freelancerId) {
        this.freelancerId = freelancerId;
    }

    public Long getAccountId() {
        return accountId;
    }

    public void setAccountId(Long accountId) {
        this.accountId = accountId;
    }

    public Long getBalance() {
        return balance;
    }

    public void setBalance(Long balance) {
        this.balance = balance;
    }

    public Long getTotalEarned() {
        return totalEarned;
    }

    public void setTotalEarned(Long totalEarned) {
        this.totalEarned = totalEarned;
    }

    public String getWalletPw() {
        return walletPw;
    }

    public void setWalletPw(String walletPw) {
        this.walletPw = walletPw;
    }

    public Integer getVersion() {
        return version;
    }

    public void setVersion(Integer version) {
        this.version = version;
    }
}
