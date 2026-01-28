package com.sanaiclub.payment.service;

import com.sanaiclub.payment.model.dto.PayoutRequestDTO;
import com.sanaiclub.payment.model.dto.PayoutResponseDTO;

public interface PayoutService {

    /**
     * 마일스톤 지급 (클라이언트가 직접 지급)
     */
    PayoutResponseDTO releaseMilestone(Integer contractId, Integer milestoneId, Integer userId);

    /**
     * 마일스톤 지급 요청 (프리랜서가 승인 요청)
     */
    void requestPayout(PayoutRequestDTO request);

    /**
     * 마일스톤 지급 승인 (클라이언트가 승인)
     */
    PayoutResponseDTO approvePayout(Integer milestoneId, Integer userId);

    /**
     * FIXED 방식 전액 지급
     */
    PayoutResponseDTO releaseFullAmount(Integer contractId, Integer userId);
}