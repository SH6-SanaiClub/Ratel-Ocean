package com.sanaiclub.user.model.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * 국세청 사업자번호 진위확인 API 응답 DTO
 * ═══════════════════════════════════════════════════════════════════════
 *
 * [API 응답 구조]
 * {
 *   "status_code": "OK",
 *   "request_cnt": 1,
 *   "valid_cnt": 1,
 *   "data": [
 *     {
 *       "b_no": "2208162517",
 *       "valid": "01",
 *       "status": {
 *         "b_stt": "계속사업자",
 *         "b_stt_cd": "01",
 *         "tax_type": "부가가치세 일반과세자",
 *         ...
 *       }
 *     }
 *   ]
 * }
 *
 * @author sanaiclub
 * @version 3.0 (실제 API 응답 구조 반영)
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class BizNoVerificationResponseDTO {

    /**
     * 응답 상태 코드 (OK, ERROR 등)
     */
    @JsonProperty("status_code")
    private String status_code;

    /**
     * 요청 건수
     */
    @JsonProperty("request_cnt")
    private Integer request_cnt;

    /**
     * 유효 건수
     */
    @JsonProperty("valid_cnt")
    private Integer valid_cnt;

    /**
     * 조회 결과 데이터 배열
     */
    @JsonProperty("data")
    private List<BusinessData> data;

    /**
     * API 호출 성공 여부
     */
    public boolean isSuccess() {
        return "OK".equalsIgnoreCase(status_code);
    }

    /**
     * 첫 번째 데이터 반환
     */
    public BusinessData getFirstData() {
        return (data != null && !data.isEmpty()) ? data.get(0) : null;
    }

    // ═══════════════════════════════════════════════════════════════
    // 내부 클래스: BusinessData
    // ═══════════════════════════════════════════════════════════════

    /**
     * 사업자 정보 데이터
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class BusinessData {

        /**
         * 사업자등록번호
         */
        @JsonProperty("b_no")
        private String b_no;

        /**
         * 진위확인 결과
         * - "01": 확인 (국세청에 등록된 사업자등록번호)
         * - "02": 확인불가 (국세청에 등록되지 않은 사업자등록번호)
         */
        @JsonProperty("valid")
        private String valid;

        /**
         * 요청 파라미터 (참고용)
         */
        @JsonProperty("request_param")
        private RequestParam request_param;

        /**
         * 사업자 상태 정보
         */
        @JsonProperty("status")
        private Status status;

        /**
         * 진위확인 성공 여부
         */
        public boolean isValid() {
            return "01".equals(valid);
        }

        /**
         * 사업자 활성 상태 여부
         * - 계속사업자: true
         * - 휴업자/폐업자: false
         */
        public boolean isActive() {
            if (status == null || status.getB_stt_cd() == null) {
                // status 정보가 없으면 valid만으로 판단
                return isValid();
            }
            // "01" = 계속사업자
            return "01".equals(status.getB_stt_cd());
        }

        /**
         * 사업자 상태명 반환
         */
        public String getB_stt() {
            return status != null ? status.getB_stt() : null;
        }

        /**
         * 사업자 상태 코드 반환
         */
        public String getB_stt_cd() {
            return status != null ? status.getB_stt_cd() : null;
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // 내부 클래스: RequestParam
    // ═══════════════════════════════════════════════════════════════

    /**
     * 요청 파라미터 (참고용)
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class RequestParam {

        @JsonProperty("b_no")
        private String b_no;

        @JsonProperty("start_dt")
        private String start_dt;

        @JsonProperty("p_nm")
        private String p_nm;

        @JsonProperty("p_nm2")
        private String p_nm2;

        @JsonProperty("b_nm")
        private String b_nm;

        @JsonProperty("corp_no")
        private String corp_no;

        @JsonProperty("b_type")
        private String b_type;

        @JsonProperty("b_sector")
        private String b_sector;

        @JsonProperty("b_adr")
        private String b_adr;
    }

    // ═══════════════════════════════════════════════════════════════
    // 내부 클래스: Status
    // ═══════════════════════════════════════════════════════════════

    /**
     * 사업자 상태 정보
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Status {

        /**
         * 사업자등록번호
         */
        @JsonProperty("b_no")
        private String b_no;

        /**
         * 사업자 상태명
         * - "계속사업자": 정상 운영 중
         * - "휴업자": 휴업 중
         * - "폐업자": 폐업
         */
        @JsonProperty("b_stt")
        private String b_stt;

        /**
         * 사업자 상태 코드
         * - "01": 계속사업자
         * - "02": 휴업자
         * - "03": 폐업자
         */
        @JsonProperty("b_stt_cd")
        private String b_stt_cd;

        /**
         * 과세 유형명
         */
        @JsonProperty("tax_type")
        private String tax_type;

        /**
         * 과세 유형 코드
         * - "01": 부가가치세 일반과세자
         * - "02": 부가가치세 간이과세자
         * - "03": 면세사업자
         * - "04": 비영리법인
         */
        @JsonProperty("tax_type_cd")
        private String tax_type_cd;

        /**
         * 폐업일 (YYYYMMDD)
         */
        @JsonProperty("end_dt")
        private String end_dt;

        /**
         * 단위과세 전환 폐지 여부
         */
        @JsonProperty("utcc_yn")
        private String utcc_yn;

        /**
         * 과세 유형 전환일
         */
        @JsonProperty("tax_type_change_dt")
        private String tax_type_change_dt;

        /**
         * 전자세금계산서 적용일
         */
        @JsonProperty("invoice_apply_dt")
        private String invoice_apply_dt;

        /**
         * 간이과세 적용 세율
         */
        @JsonProperty("rbf_tax_type")
        private String rbf_tax_type;

        /**
         * 간이과세 적용 세율 코드
         */
        @JsonProperty("rbf_tax_type_cd")
        private String rbf_tax_type_cd;
    }
}