package com.sanaiclub.wallet.service;

import com.sanaiclub.wallet.model.dto.FreelancerWalletDTO;
import com.sanaiclub.wallet.model.dto.WalletHistoryDTO;

import java.util.List;

public interface FreelancerWalletService {

    FreelancerWalletDTO getWallet(Integer freelancerId);

    List<WalletHistoryDTO> getHistories(Integer freelancerId, int offset, int limit);

}

