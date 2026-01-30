package com.sanaiclub.wallet.service.impl;

import com.sanaiclub.wallet.dao.FreelancerWalletMapper;
import com.sanaiclub.wallet.model.dto.FreelancerWalletDTO;
import com.sanaiclub.wallet.model.dto.WalletHistoryDTO;
import com.sanaiclub.wallet.service.FreelancerWalletService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;

@Service
@RequiredArgsConstructor
public class FreelancerWalletServiceImpl implements FreelancerWalletService {

    private final FreelancerWalletMapper walletMapper;

    public FreelancerWalletDTO getWallet(Integer freelancerId) {
        return walletMapper.selectWalletByFreelancerId(freelancerId);
    }

    public List<WalletHistoryDTO> getHistories(Integer freelancerId, int offset, int limit) {
        FreelancerWalletDTO wallet = getWallet(freelancerId);
        if (wallet == null) return Collections.emptyList();
        return walletMapper.selectHistories(wallet.getWalletId(), offset, limit);
    }
}
