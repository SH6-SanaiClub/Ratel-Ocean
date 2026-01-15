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

    // ═══════════════════════════════════════════════════════════════
    // 식별 정보
    // ═══════════════════════════════════════════════════════════════

    /**
     * 회사 고유 식별자 (PK)
     * - AUTO_INCREMENT로 자동 생성
     */
    private Long companyId;

    // ═══════════════════════════════════════════════════════════════
    // 회사 기본 정보
    // ═══════════════════════════════════════════════════════════════

    /**
     * 회사명 (상호)
     * - 사업자등록증에 기재된 공식 명칭
     * - 예: "(주)삼성전자", "네이버 주식회사"
     */
    private String companyName;

    /**
     * 대표자명
     * - 사업자등록증에 기재된 대표자
     * - 예: "홍길동"
     */
    private String ceoName;

    /**
     * 대표 이메일
     * - 회사 대표 연락처
     * - NULL 허용
     */
    private String ceoEmail;

    // ═══════════════════════════════════════════════════════════════
    // 사업자 정보
    // ═══════════════════════════════════════════════════════════════

    /**
     * 사업자등록번호
     * - 10자리 숫자 (XXX-XX-XXXXX 형태)
     * - 중복 불가 (UNIQUE)
     * - 예: "123-45-67890"
     */
    private String businessNumber;

    /**
     * 사업자 인증 여부
     * - 국세청 API 등으로 진위 확인 후 true 설정
     * - 기본값: false
     */
    private Boolean businessVerified;

    // ═══════════════════════════════════════════════════════════════
    // 회사 상세 정보
    // ═══════════════════════════════════════════════════════════════

    /**
     * 업종
     * - 회사의 주요 사업 분야
     * - 예: "소프트웨어 개발", "IT 서비스", "금융업"
     */
    private String industry;

    /**
     * 회사 주소
     * - 사업장 소재지
     * - 예: "서울특별시 강남구 테헤란로 123"
     */
    private String address;

    /**
     * 회사 규모
     * - 직원 수 또는 매출 기준으로 분류
     * - STARTUP: 스타트업 (10인 미만)
     * - SMALL: 소기업 (10~50인)
     * - MEDIUM: 중기업 (50~300인)
     * - LARGE: 대기업 (300~1000인)
     * - ENTERPRISE: 대기업/그룹사 (1000인 이상)
     */
    private CompanySize companySize;

    /**
     * 회사 웹사이트 URL
     * - 공식 홈페이지 주소
     * - 예: "https://www.samsung.com"
     */
    private String websiteUrl;

    // ═══════════════════════════════════════════════════════════════
    // 시간 정보
    // ═══════════════════════════════════════════════════════════════

    /**
     * 등록일
     * - INSERT 시 자동 설정
     */
    private LocalDateTime createdAt;


    // ═══════════════════════════════════════════════════════════════
    // ENUM 정의
    // ═══════════════════════════════════════════════════════════════

    /**
     * 회사 규모 ENUM
     */
    public enum CompanySize {
        STARTUP,    // 스타트업
        SMALL,      // 소기업
        MEDIUM,     // 중기업
        LARGE,      // 대기업
        ENTERPRISE  // 대기업/그룹사
    }


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