package com.sanaiclub.user.model.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * 사업자번호 진위확인 요청 DTO
 * ═══════════════════════════════════════════════════════════════════════
 *
 * [역할]
 * - 국세청 사업자번호 진위확인 API 요청 데이터
 *
 * [API 스펙]
 * - 엔드포인트: /api/nts-businessman/v1/validate
 * - 필수 파라미터: b_no (사업자번호), start_dt (개업일자), p_nm (대표자명)
 * - 배열 형태로 전송 (최대 100개)
 *
 * [회원가입 사용]
 * - 1개의 사업자만 검증하지만 API는 배열 요구
 * - of() 메서드로 간편하게 생성
 *
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BizNoVerificationRequestDTO {

    /**
     * 사업자등록번호 목록
     * - 하이픈(-) 제거된 10자리 숫자
     * - 예: ["1234567890"]
     */
    @JsonProperty("businesses")
    private Business[] businesses;

    /**
     * 사업자 정보
     */
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Business {

        /**
         * 사업자등록번호 (10자리, 하이픈 제거)
         * 예: "1234567890"
         */
        @JsonProperty("b_no")
        private String businessNumber;

        /**
         * 개업일자 (YYYYMMDD)
         * 예: "20200101"
         */
        @JsonProperty("start_dt")
        private String openingDate;

        /**
         * 대표자명
         * 예: "홍길동"
         */
        @JsonProperty("p_nm")
        private String ceoName;
    }

    /**
     * 사업자 검증용 DTO 생성
     */
    public static BizNoVerificationRequestDTO of(
            String businessNumber,
            String ceoName,
            String openingDate
    ) {
        Business business = Business.builder()
                .businessNumber(businessNumber)
                .ceoName(ceoName)
                .openingDate(openingDate)
                .build();

        return BizNoVerificationRequestDTO.builder()
                .businesses(new Business[]{business})
                .build();
    }
}