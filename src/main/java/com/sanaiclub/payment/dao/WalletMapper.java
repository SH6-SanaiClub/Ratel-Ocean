package com.sanaiclub.payment.dao;

import com.sanaiclub.payment.model.vo.FreelancerWalletVO;
import com.sanaiclub.payment.model.vo.WalletHistoryVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface WalletMapper {

    /**
     * 프리랜서 지갑 생성
     */
    int insertWallet(FreelancerWalletVO wallet);

    /**
     * user_id로 지갑 조회
     */
    FreelancerWalletVO selectWalletByUserId(@Param("userId") Integer userId);

    /**
     * wallet_id로 지갑 조회
     */
    FreelancerWalletVO selectWalletById(@Param("walletId") Integer walletId);

    /**
     * 지갑 거래 내역 저장 (트리거가 자동으로 잔액 업데이트)
     */
    int insertWalletHistory(WalletHistoryVO history);

    /**
     * 지갑 거래 내역 조회
     */
    List<WalletHistoryVO> selectWalletHistoriesByWalletId(@Param("walletId") Integer walletId);

    /**
     * 지갑 잔액 조회 (FOR UPDATE - 비관적 락)
     */
    FreelancerWalletVO selectWalletForUpdate(@Param("walletId") Integer walletId);
}