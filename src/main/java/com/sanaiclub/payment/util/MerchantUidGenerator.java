package com.sanaiclub.payment.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * ============================================================================
 * MerchantUidGenerator - 가맹점 주문번호 생성기
 * ============================================================================
 *
 * [역할]
 * - 포트원 결제 시 사용할 가맹점 주문번호(merchant_uid) 생성
 * - 형식: contract_{contractId}_{timestamp}
 *
 * [예시]
 * - contract_123_20260124153045
 *
 * [특징]
 * - 고유성 보장 (계약 ID + 타임스탬프)
 * - 결제 내역 추적 용이
 *
 * ============================================================================
 */
public class MerchantUidGenerator {

    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    /**
     * 가맹점 주문번호 생성
     *
     * @param contractId 계약 ID
     * @return merchant_uid (예: contract_123_20260124153045)
     */
    public static String generate(Integer contractId) {
        String timestamp = LocalDateTime.now().format(FORMATTER);
        return String.format("contract_%d_%s", contractId, timestamp);
    }

    /**
     * 가맹점 주문번호에서 계약 ID 추출
     *
     * @param merchantUid 가맹점 주문번호
     * @return 계약 ID
     */
    public static Integer extractContractId(String merchantUid) {
        try {
            // contract_123_20260124153045 → 123
            String[] parts = merchantUid.split("_");
            if (parts.length >= 2) {
                return Integer.parseInt(parts[1]);
            }
        } catch (Exception e) {
            // 파싱 실패 시 null 반환
        }
        return null;
    }
}