package com.sanaiclub.wallet.dao;

import com.sanaiclub.wallet.model.dto.FreelancerWalletDTO;
import com.sanaiclub.wallet.model.dto.WalletHistoryDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface FreelancerWalletMapper {

    // 프리랜서 지갑 1건 조회
    FreelancerWalletDTO selectWalletByFreelancerId(Integer freelancerId);

    // 거래내역 최신순 페이징 조회
    List<WalletHistoryDTO> selectHistories(@Param("walletId") Integer walletId,
                                           @Param("offset") int offset,
                                           @Param("limit") int limit);
}
