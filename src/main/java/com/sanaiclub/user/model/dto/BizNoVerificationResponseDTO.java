package com.sanaiclub.user.model.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import java.util.List;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * 사업자번호 진위확인 응답 DTO
 * ═══════════════════════════════════════════════════════════════════════
 *
 * [API 응답 구조]
 * {
 *   "status_code": "OK",
 *   "match_cnt": 1,
 *   "data": [{
 *     "b_no": "1234567890",
 *     "valid": "01",
 *     "valid_msg": "확인",
 *     "b_stt": "계속사업자",
 *     "b_stt_cd": "01",
 *     "tax_type": "부가가치세 일반과세자",
 *     "tax_type_cd": "01"
 *   }]
 * }
 *
 * [회원가입 사용]
 * - 요청은 1개만 하지만, 응답은 배열로 옴
 * - getFirstData()로 첫 번째(유일한) 결과만 추출
 *
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BizNoVerificationResponseDTO {

    /**
     * 응답 상태 코드
     * - "OK": 정상
     */
    @JsonProperty("status_code")
    private String status_code;

    /**
     * 매칭 건수
     */
    @JsonProperty("match_cnt")
    private Integer match_cnt;

    /**
     * 요청 건수
     */
    @JsonProperty("request_cnt")
    private Integer request_cnt;

    /**
     * 사업자 정보 목록
     * - 회원가입에서는 1개만 포함됨
     */
    @JsonProperty("data")
    private List<BusinessData> data;

    /**
     * 사업자 개별 정보
     */
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class BusinessData {

        /**
         * 사업자등록번호
         */
        @JsonProperty("b_no")
        private String b_no;

        /**
         * 진위확인 결과
         * - "01": 확인 (valid)
         * - "02": 미확인 (invalid)
         */
        @JsonProperty("valid")
        private String valid;

        /**
         * 진위확인 메시지
         */
        @JsonProperty("valid_msg")
        private String valid_msg;

        /**
         * 사업자 상태
         * - "계속사업자": 정상 운영중
         * - "휴업자": 일시적 휴업
         * - "폐업자": 폐업
         */
        @JsonProperty("b_stt")
        private String b_stt;

        /**
         * 사업자 상태 코드
         */
        @JsonProperty("b_stt_cd")
        private String b_stt_cd;

        /**
         * 과세 유형
         * - "부가가치세 일반과세자"
         * - "부가가치세 간이과세자"
         * - "면세사업자"
         */
        @JsonProperty("tax_type")
        private String tax_type;

        /**
         * 과세 유형 코드
         */
        @JsonProperty("tax_type_cd")
        private String tax_type_cd;

        /**
         * 종료일자 (폐업일)
         */
        @JsonProperty("end_dt")
        private String end_dt;

        /**
         * 최종 변경일자
         */
        @JsonProperty("utcc_yn")
        private String utcc_yn;

        /**
         * 세금계산서 적용일자
         */
        @JsonProperty("tax_type_change_dt")
        private String tax_type_change_dt;

        /**
         * 사업자가 유효한지 확인
         *
         * @return 유효하면 true
         */
        public boolean isValid() {
            return "01".equals(this.valid);
        }

        /**
         * 계속사업자인지 확인
         *
         * @return 계속사업자이면 true
         */
        public boolean isActive() {
            return "계속사업자".equals(this.b_stt) || "01".equals(this.b_stt_cd);
        }
    }

    /**
     * 첫 번째 사업자 정보 반환 (회원가입용)
     * - 회원가입에서는 1개만 요청하므로, 첫 번째 결과 사용
     *
     * @return 사업자 정보 (없으면 null)
     */
    public BusinessData getFirstData() {
        return (data != null && !data.isEmpty()) ? data.get(0) : null;
    }

    /**
     * API 호출이 성공했는지 확인
     *
     * @return 성공이면 true
     */
    public boolean isSuccess() {
        return "OK".equals(this.status_code);
    }
}