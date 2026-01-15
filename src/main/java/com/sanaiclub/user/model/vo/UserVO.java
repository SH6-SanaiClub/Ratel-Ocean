package com.sanaiclub.user.model.vo;

import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * UserVO - users 테이블 매핑 VO (Value Object)
 * ═══════════════════════════════════════════════════════════════════════
 *
 * [역할]
 * - 프리랜서/클라이언트 공통 계정 정보를 담는 객체
 * - DB의 users 테이블과 1:1 매핑
 *
 * [ENUM 타입]
 * - UserType: FREELANCER, CLIENT
 * - UserStatus: ACTIVE, INACTIVE, SUSPENDED
 *
 * @author sanaiclub
 * @version 1.0
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserVO {

    private int userId;
    private String loginId;
    private String email;
    private String password;
    private String refreshToken;
    private UserType userType;
    private UserStatus status;
    private String name;
    private String phone;
    private LocalDate birthDate;
    private String profileImageUrl;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;


    // ═══════════════════════════════════════════════════════════════
    // 편의 메서드
    // ═══════════════════════════════════════════════════════════════

    /**
     * 프리랜서 여부 확인
     * @return 프리랜서이면 true
     */
    public boolean isFreelancer() {
        return UserType.FREELANCER.equals(this.userType);
    }

    /**
     * 클라이언트 여부 확인
     * @return 클라이언트이면 true
     */
    public boolean isClient() {
        return UserType.CLIENT.equals(this.userType);
    }

    /**
     * 활성 상태 여부 확인
     * @return 활성 상태이면 true
     */
    public boolean isActive() {
        return UserStatus.ACTIVE.equals(this.status);
    }

    /**
     * 리프레시 토큰 무효화 (로그아웃 시 사용)
     */
    public void invalidateRefreshToken() {
        this.refreshToken = null;
    }
}