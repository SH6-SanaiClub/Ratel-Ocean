package com.sanaiclub.domain.wallet.mapper;

import com.sanaiclub.domain.wallet.dto.Account;
import com.sanaiclub.domain.wallet.dto.FreelancerWallet;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * Account & Wallet Mapper Interface
 */
@Mapper
public interface AccountMapper {
    
    /**
     * 계좌 정보 저장
     */
    int insertAccount(Account account);
    
    /**
     * 프리랜서 지갑 생성
     */
    int insertFreelancerWallet(FreelancerWallet wallet);
    
    /**
     * user_id로 계좌 조회
     */
    Account findAccountByUserId(@Param("userId") Long userId);
    
    /**
     * freelancer_id로 지갑 조회
     */
    FreelancerWallet findWalletByFreelancerId(@Param("freelancerId") Long freelancerId);
}
