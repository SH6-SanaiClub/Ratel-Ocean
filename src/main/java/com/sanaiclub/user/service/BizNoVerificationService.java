package com.sanaiclub.user.service;

import com.sanaiclub.user.model.dto.BizNoVerificationResponseDTO;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * 사업자번호 진위확인 서비스
 * ═══════════════════════════════════════════════════════════════════════
 *
 * [역할]
 * - 국세청 사업자번호 진위확인 API 호출
 * - 사업자 유효성 검증
 *
 */
public interface BizNoVerificationService {

    /**
     * 사업자번호 진위확인
     *
     * @param businessNumber 사업자번호 (하이픈 포함 가능)
     * @param ceoName 대표자명
     * @param openingDate 개업일자 (YYYYMMDD 형식)
     * @return 인증 결과
     * @throws IllegalArgumentException 인증 실패 시
     */
    BizNoVerificationResponseDTO.BusinessData verifyBusinessNumber(
            String businessNumber,
            String ceoName,
            String openingDate
    );

    /**
     * 사업자번호가 유효한지 확인
     *
     * @param businessNumber 사업자번호
     * @param ceoName 대표자명
     * @param openingDate 개업일자 (YYYYMMDD 형식)
     * @return 유효하면 true
     */
    boolean isValidBusinessNumber(
            String businessNumber,
            String ceoName,
            String openingDate
    );
}