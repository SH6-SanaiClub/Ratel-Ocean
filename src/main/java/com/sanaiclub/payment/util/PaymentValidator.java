package com.sanaiclub.payment.util;

import com.fasterxml.jackson.databind.JsonNode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public class PaymentValidator {

    private static final Logger logger = LoggerFactory.getLogger(PaymentValidator.class);

    /**
     * 결제 정보 검증
     *
     * @param paymentInfo 포트원 API에서 조회한 결제 정보
     * @param expectedMerchantUid 기대하는 가맹점 주문번호
     * @param expectedAmount 기대하는 결제 금액
     * @return 검증 성공 여부
     */
    public static boolean validate(JsonNode paymentInfo, String expectedMerchantUid, Long expectedAmount) {

        // 1. merchant_uid 검증
        String actualMerchantUid = paymentInfo.get("merchant_uid").asText();
        if (!expectedMerchantUid.equals(actualMerchantUid)) {
            logger.error("merchant_uid 불일치: expected={}, actual={}", expectedMerchantUid, actualMerchantUid);
            return false;
        }

        // 2. 결제 금액 검증
        Long actualAmount = paymentInfo.get("amount").asLong();
        if (!expectedAmount.equals(actualAmount)) {
            logger.error("결제 금액 불일치: expected={}, actual={}", expectedAmount, actualAmount);
            return false;
        }

        // 3. 결제 상태 확인
        String status = paymentInfo.get("status").asText();
        if (!"paid".equals(status)) {
            logger.warn("결제 상태가 paid가 아님: status={}", status);
            return false;
        }

        logger.info("결제 정보 검증 성공: merchant_uid={}, amount={}", actualMerchantUid, actualAmount);
        return true;
    }
}