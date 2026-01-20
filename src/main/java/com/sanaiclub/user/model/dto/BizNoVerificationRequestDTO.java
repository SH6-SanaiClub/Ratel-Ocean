package com.sanaiclub.user.model.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import java.util.List;

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
 * - 선택 파라미터: p_nm2, b_nm, corp_no, b_sector, b_type
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
    private List<BusinessRequest> businesses;

    /**
     * 개별 사업자 정보
     */
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class BusinessRequest {

        /**
         * 사업자등록번호 (필수)
         * - 하이픈 제거된 10자리
         */
        @JsonProperty("b_no")
        private String b_no;

        /**
         * 개업일자 (필수)
         * - YYYYMMDD 형식
         * - 예: "20200101"
         */
        @JsonProperty("start_dt")
        private String start_dt;

        /**
         * 대표자명 (필수)
         * - 예: "홍길동"
         */
        @JsonProperty("p_nm")
        private String p_nm;

        /**
         * 대표자명2 (선택)
         * - 공동대표인 경우
         */
        @JsonProperty("p_nm2")
        private String p_nm2;

        /**
         * 상호 (선택)
         */
        @JsonProperty("b_nm")
        private String b_nm;

        /**
         * 법인번호 (선택)
         * - 13자리
         */
        @JsonProperty("corp_no")
        private String corp_no;

        /**
         * 주업태 (선택)
         */
        @JsonProperty("b_sector")
        private String b_sector;

        /**
         * 주종목 (선택)
         */
        @JsonProperty("b_type")
        private String b_type;
    }

    /**
     * 단일 사업자로 요청 객체 생성
     *
     * @param businessNumber 사업자번호 (하이픈 포함 가능)
     * @param ceoName 대표자명
     * @param openingDate 개업일자 (YYYYMMDD)
     * @return BizNoVerificationRequestDTO
     */
    public static BizNoVerificationRequestDTO of(
            String businessNumber,
            String ceoName,
            String openingDate
    ) {
        // 하이픈 제거
        String cleanNumber = businessNumber.replaceAll("-", "");

        BusinessRequest business = BusinessRequest.builder()
                .b_no(cleanNumber)
                .start_dt(openingDate)
                .p_nm(ceoName)
                .p_nm2("")  // 빈 문자열
                .b_nm("")
                .corp_no("")
                .b_sector("")
                .b_type("")
                .build();

        return BizNoVerificationRequestDTO.builder()
                .businesses(List.of(business))
                .build();
    }
}