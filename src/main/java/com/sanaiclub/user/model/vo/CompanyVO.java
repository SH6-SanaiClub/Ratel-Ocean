package com.sanaiclub.user.model.vo;

import lombok.*;

import java.time.LocalDateTime;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * CompanyVO - companies 테이블 매핑 VO
 * ═══════════════════════════════════════════════════════════════════════
 *
 * [역할]
 * - 법인/사업자 클라이언트의 회사 정보를 담는 객체
 * - client_profiles와 N:1 관계 (여러 담당자가 같은 회사 소속 가능)
 *
 * [테이블 관계]
 * client_profiles (N) ──────── (1) companies
 *          companyId(FK) ──→ companyId(PK)
 *
 * [사업자 인증]
 * - business_number로 사업자 진위 확인
 * - business_verified = true면 인증 완료
 * - 인증된 회사만 특정 기능 사용 가능 (예: 대규모 프로젝트 발주)
 *
 * @author sanaiclub
 * @version 1.0
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CompanyVO {

    private Integer companyId;
    private String companyName;
    private String ceoName;
    private String ceoEmail;
    private String businessNumber;
    private Boolean businessVerified;
    private String industry;
    private String address;
    private CompanySize companySize;
    private String websiteUrl;
    private LocalDateTime createdAt;


    // ═══════════════════════════════════════════════════════════════
    // 편의 메서드
    // ═══════════════════════════════════════════════════════════════

    /**
     * 사업자 인증 완료 여부 (null-safe)
     * @return 인증되었으면 true
     */
    public boolean isVerified() {
        return Boolean.TRUE.equals(this.businessVerified);
    }

    /**
     * 웹사이트 등록 여부
     * @return 등록되어 있으면 true
     */
    public boolean hasWebsite() {
        return this.websiteUrl != null && !this.websiteUrl.trim().isEmpty();
    }

    /**
     * 대기업 이상 여부
     * @return LARGE 또는 ENTERPRISE면 true
     */
    public boolean isLargeCompany() {
        return CompanySize.LARGE.equals(this.companySize)
                || CompanySize.ENTERPRISE.equals(this.companySize);
    }

    /**
     * 스타트업 여부
     * @return STARTUP이면 true
     */
    public boolean isStartup() {
        return CompanySize.STARTUP.equals(this.companySize);
    }
}