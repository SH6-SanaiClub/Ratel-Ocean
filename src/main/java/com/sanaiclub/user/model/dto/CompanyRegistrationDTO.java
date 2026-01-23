package com.sanaiclub.user.model.dto;

import com.sanaiclub.user.model.vo.CompanySize;
import lombok.*;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Pattern;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * 회사 등록 정보 DTO
 * ═══════════════════════════════════════════════════════════════════════
 *
 * [역할]
 * - 클라이언트 회원가입 4단계: 법인 회사 정보 입력
 * - companies 테이블 INSERT용 데이터
 *
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CompanyRegistrationDTO {

    /**
     * 회사명
     */
    @NotBlank(message = "회사명을 입력해주세요.")
    private String companyName;

    /**
     * 대표자명
     */
    @NotBlank(message = "대표자명을 입력해주세요.")
    private String ceoName;

    /**
     * 대표 이메일
     */
    private String ceoEmail;

    /**
     * 사업자등록번호
     * - 하이픈 포함 가능 (123-45-67890)
     * - 저장 시 하이픈 제거
     */
    @NotBlank(message = "사업자등록번호를 입력해주세요.")
    @Pattern(regexp = "^\\d{3}-?\\d{2}-?\\d{5}$", message = "올바른 사업자등록번호 형식이 아닙니다.")
    private String businessNumber;

    /**
     * 개업일자 (String 타입)
     * - JSP에서 "2025-01-15" 형식으로 전송
     * - 진위확인 API: "20250115" 형식으로 변환
     * - DB 저장: LocalDate로 변환
     */
    @NotBlank(message = "개업일자를 입력해주세요.")
    @Pattern(regexp = "^\\d{4}-\\d{2}-\\d{2}$", message = "올바른 날짜 형식이 아닙니다. (YYYY-MM-DD)")
    private String openingDate;

    /**
     * 업종
     */
    private String industry;

    /**
     * 주소
     */
    private String address;

    /**
     * 회사 규모
     */
    private CompanySize companySize;

    /**
     * 웹사이트 URL
     */
    private String websiteUrl;

    /**
     * 사업자번호 진위확인 여부
     * - true: 인증 완료
     * - false: 인증 실패 또는 미시도
     */
    private Boolean businessVerified;

    /**
     * 하이픈 제거된 사업자번호 반환
     *
     * @return 10자리 숫자
     */
    public String getCleanBusinessNumber() {
        return this.businessNumber != null
                ? this.businessNumber.replaceAll("-", "")
                : null;
    }

    /**
     * 개업일자를 LocalDate로 변환 (DB 저장용)
     * "2025-01-15" → LocalDate
     *
     * @return LocalDate 객체
     */
    public LocalDate getOpeningDateAsLocalDate() {
        if (this.openingDate == null || this.openingDate.trim().isEmpty()) {
            return null;
        }
        try {
            return LocalDate.parse(this.openingDate, DateTimeFormatter.ISO_LOCAL_DATE);
        } catch (Exception e) {
            throw new IllegalArgumentException("개업일자 형식이 올바르지 않습니다: " + this.openingDate);
        }
    }

    /**
     * 인증 완료 여부 확인
     *
     * @return 인증 완료면 true
     */
    public boolean isVerified() {
        return Boolean.TRUE.equals(this.businessVerified);
    }
}