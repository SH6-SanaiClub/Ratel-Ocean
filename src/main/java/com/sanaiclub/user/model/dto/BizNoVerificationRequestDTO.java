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
 * - API는 배열 형태를 요구: {"b_no": ["1234567890"]}
 * - 회원가입에서는 1개만 전송
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
     * - 배열 형태로 전송 (최대 100개)
     */
    @JsonProperty("b_no")
    private List<String> b_no;

    /**
     * 단일 사업자번호로 요청 객체 생성
     *
     * @param businessNumber 사업자번호 (하이픈 포함 가능)
     * @return BizNoVerificationRequestDTO
     */
    public static BizNoVerificationRequestDTO of(String businessNumber) {
        // 하이픈 제거
        String cleanNumber = businessNumber.replaceAll("-", "");

        return BizNoVerificationRequestDTO.builder()
                .b_no(List.of(cleanNumber))
                .build();
    }
}