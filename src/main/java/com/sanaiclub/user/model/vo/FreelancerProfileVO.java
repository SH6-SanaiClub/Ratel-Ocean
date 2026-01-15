package com.sanaiclub.user.model.vo;

import lombok.*;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * FreelancerProfileVO - freelancer_profiles 테이블 매핑 VO
 * ═══════════════════════════════════════════════════════════════════════
 *
 * [역할]
 * - 프리랜서 전용 프로필 정보를 담는 객체
 * - users 테이블과 1:1 관계 (userId가 PK이자 FK)
 *
 * [테이블 관계]
 * users (1) ──────── (1) freelancer_profiles
 *        userId(PK) ←── userId(PK, FK)
 *
 * [1:1 관계에서 PK가 FK인 이유]
 * - 프리랜서 프로필은 users 없이 존재할 수 없음
 * - userId를 공유하여 JOIN 시 성능 최적화
 * - users.user_type = 'FREELANCER'인 경우에만 생성
 *
 * @author sanaiclub
 * @version 1.0
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FreelancerProfileVO {

    private Integer freelancerId;
    private String nickname;
    private String introduction;
    private String githubUrl;
    private String websiteUrl;
    private String schoolName;
    private String major;
    private String degree;
    private String gradStatus;
    private Boolean isProfileComplete;


    // ═══════════════════════════════════════════════════════════════
    // 편의 메서드
    // ═══════════════════════════════════════════════════════════════

    /**
     * 프로필 완성 여부 확인 (null-safe)
     * @return 완성되었으면 true
     */
    public boolean checkProfileComplete() {
        return Boolean.TRUE.equals(this.isProfileComplete);
    }

    /**
     * GitHub 등록 여부 확인
     * @return 등록되어 있으면 true
     */
    public boolean hasGithub() {
        return this.githubUrl != null && !this.githubUrl.trim().isEmpty();
    }

    /**
     * 학력 정보 등록 여부 확인
     * @return 학교명이 등록되어 있으면 true
     */
    public boolean hasEducation() {
        return this.schoolName != null && !this.schoolName.trim().isEmpty();
    }
}


