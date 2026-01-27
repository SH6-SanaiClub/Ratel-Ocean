package com.sanaiclub.common.util;

import com.sanaiclub.common.dto.AuthenticatedUser;
import com.sanaiclub.user.model.vo.UserType;

// AuthContext - 인증 컨텍스트
public class AuthContext {

    /**
     * ThreadLocal: 각 쓰레드마다 독립적인 AuthenticatedUser 저장
     */
    private static final ThreadLocal<AuthenticatedUser> userHolder = new ThreadLocal<>();

    // Private Constructor (유틸리티 클래스는 인스턴스화 방지)
    private AuthContext() {
        throw new IllegalStateException("Utility class");
    }

    // 저장 및 삭제
    /**
     * 현재 쓰레드에 인증된 사용자 정보 저장
     * - Filter에서 JWT 검증 후 호출
     *
     * @param user 인증된 사용자 정보
     */
    public static void setCurrentUser(AuthenticatedUser user) {
        userHolder.set(user);
    }

    /**
     * 현재 쓰레드의 인증 정보 삭제
     * - Filter의 finally 블록에서 반드시 호출
     * - 메모리 누수 방지 (ThreadLocal은 쓰레드 풀 환경에서 재사용됨)
     */
    public static void clear() {
        userHolder.remove();
    }

    // 조회 메서드
    /**
     * 현재 인증된 사용자 정보 전체 조회
     *
     * @return 인증된 사용자 정보 (없으면 null)
     */
    public static AuthenticatedUser getCurrentUser() {
        return userHolder.get();
    }

    /**
     * 현재 사용자 ID 조회
     *
     * @return 사용자 PK (없으면 null)
     */
    public static Integer getCurrentUserId() {
        AuthenticatedUser user = getCurrentUser();
        return user != null ? user.getUserId() : null;
    }

    /**
     * 현재 로그인 ID 조회
     *
     * @return 로그인 ID (없으면 null)
     */
    public static String getCurrentLoginId() {
        AuthenticatedUser user = getCurrentUser();
        return user != null ? user.getLoginId() : null;
    }

    /**
     * 현재 사용자 유형 조회
     *
     * @return UserType (FREELANCER / CLIENT, 없으면 null)
     */
    public static UserType getCurrentUserType() {
        AuthenticatedUser user = getCurrentUser();
        return user != null ? user.getUserType() : null;
    }

    // 인증 상태 확인
    /**
     * 현재 인증된 사용자가 있는지 확인
     *
     * @return 인증된 사용자가 있으면 true
     */
    public static boolean isAuthenticated() {
        return getCurrentUser() != null;
    }

    /**
     * 현재 사용자가 프리랜서인지 확인
     *
     * @return 프리랜서이면 true
     */
    public static boolean isFreelancer() {
        AuthenticatedUser user = getCurrentUser();
        return user != null && user.isFreelancer();
    }

    /**
     * 현재 사용자가 클라이언트인지 확인
     *
     * @return 클라이언트이면 true
     */
    public static boolean isClient() {
        AuthenticatedUser user = getCurrentUser();
        return user != null && user.isClient();
    }

    /**
     * 현재 사용자가 특정 유형인지 확인
     *
     * @param userType 확인할 사용자 유형
     * @return 일치하면 true
     */
    public static boolean hasUserType(UserType userType) {
        AuthenticatedUser user = getCurrentUser();
        return user != null && user.hasUserType(userType);
    }

    /**
     * 현재 사용자가 특정 userId의 소유자인지 확인
     * - 본인 확인용
     *
     * @param userId 확인할 사용자 ID
     * @return 본인이면 true
     */
    public static boolean isOwner(Integer userId) {
        AuthenticatedUser user = getCurrentUser();
        return user != null && user.isOwner(userId);
    }

    // 예외 발생 메서드 (인증 필수 시)
    /**
     * 현재 사용자 ID 조회 (인증 필수)
     * - 인증되지 않은 경우 예외 발생
     *
     * @return 사용자 PK
     * @throws IllegalStateException 인증되지 않은 경우
     */
    public static Integer requireCurrentUserId() {
        Integer userId = getCurrentUserId();
        if (userId == null) {
            throw new IllegalStateException("인증되지 않은 사용자입니다.");
        }
        return userId;
    }

    /**
     * 현재 사용자 정보 조회 (인증 필수)
     * - 인증되지 않은 경우 예외 발생
     *
     * @return 인증된 사용자 정보
     * @throws IllegalStateException 인증되지 않은 경우
     */
    public static AuthenticatedUser requireCurrentUser() {
        AuthenticatedUser user = getCurrentUser();
        if (user == null) {
            throw new IllegalStateException("인증되지 않은 사용자입니다.");
        }
        return user;
    }
}
