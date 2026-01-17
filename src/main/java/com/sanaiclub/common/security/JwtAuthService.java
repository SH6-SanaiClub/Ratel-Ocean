package com.sanaiclub.common.security;

import com.sanaiclub.common.util.CookieUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// JwtAuthService - JWT 인증 비즈니스 로직
@Service
public class JwtAuthService {

    private static final Logger logger = LoggerFactory.getLogger(JwtAuthService.class);
    // 쿠키 이름 상수
    private static final String ACCESS_TOKEN_COOKIE = "accessToken";
    private static final String REFRESH_TOKEN_COOKIE = "refreshToken";
    // 의존성 주입
    private final JwtTokenProvider jwtTokenProvider;

    /**
     * 생성자 주입
     */
    public JwtAuthService(JwtTokenProvider jwtTokenProvider) {
        this.jwtTokenProvider = jwtTokenProvider;
    }

    // 요청에서 사용자 정보 추출
    public Integer extractUserIdFromRequest(HttpServletRequest request) {
        logger.debug("요청에서 userId 추출 시도");

        // 1. 쿠키에서 토큰 추출
        String accessToken = CookieUtil.getCookieValue(request, ACCESS_TOKEN_COOKIE);

        if (accessToken == null || accessToken.isEmpty()) {
            logger.warn("Access Token 없음");
            throw new IllegalArgumentException("로그인이 필요합니다.");
        }

        // 2. 토큰 유효성 검증
        if (!jwtTokenProvider.validateToken(accessToken)) {
            logger.warn("유효하지 않은 Access Token");
            throw new IllegalArgumentException("유효하지 않은 토큰입니다. 다시 로그인해주세요.");
        }

        // 3. 토큰에서 userId 추출
        Integer userId = jwtTokenProvider.getUserId(accessToken);

        logger.debug("userId 추출 성공: {}", userId);

        return userId;
    }

    // 요청에서 loginId 추출
    public String extractLoginIdFromRequest(HttpServletRequest request) {
        logger.debug("요청에서 loginId 추출 시도");

        String accessToken = CookieUtil.getCookieValue(request, ACCESS_TOKEN_COOKIE);

        if (accessToken == null || accessToken.isEmpty()) {
            throw new IllegalArgumentException("로그인이 필요합니다.");
        }

        if (!jwtTokenProvider.validateToken(accessToken)) {
            throw new IllegalArgumentException("유효하지 않은 토큰입니다. 다시 로그인해주세요.");
        }

        String loginId = jwtTokenProvider.getLoginId(accessToken);

        logger.debug("loginId 추출 성공: {}", loginId);

        return loginId;
    }

    // Access Token 쿠키 설정
    public void setAccessTokenCookie(HttpServletResponse response,
                                     String accessToken,
                                     long expiresIn) {
        logger.debug("Access Token 쿠키 설정: expiresIn={}초", expiresIn);

        CookieUtil.addCookie(response, ACCESS_TOKEN_COOKIE, accessToken, (int) expiresIn);
    }

    // Refresh Token 쿠키 설정
    public void setRefreshTokenCookie(HttpServletResponse response, String refreshToken) {
        logger.debug("Refresh Token 쿠키 설정: expiresIn=7일");

        int sevenDaysInSeconds = 7 * 24 * 60 * 60;
        CookieUtil.addCookie(response, REFRESH_TOKEN_COOKIE, refreshToken, sevenDaysInSeconds);
    }

    // 로그인 성공 시 쿠키 일괄 설정
    public void setAuthCookies(HttpServletResponse response,
                               String accessToken,
                               String refreshToken,
                               long expiresIn) {
        logger.info("인증 쿠키 일괄 설정");

        setAccessTokenCookie(response, accessToken, expiresIn);
        setRefreshTokenCookie(response, refreshToken);
    }

    // 모든 인증 쿠키 삭제 (로그아웃 시 사용)
    public void clearAuthCookies(HttpServletResponse response) {
        logger.info("인증 쿠키 삭제");

        CookieUtil.deleteCookie(response, ACCESS_TOKEN_COOKIE);
        CookieUtil.deleteCookie(response, REFRESH_TOKEN_COOKIE);
    }

    // 요청에서 Refresh Token 추출 (쿠키에서만)
    public String extractRefreshTokenFromRequest(HttpServletRequest request) {
        logger.debug("요청에서 Refresh Token 추출");

        String refreshToken = CookieUtil.getCookieValue(request, REFRESH_TOKEN_COOKIE);

        if (refreshToken == null || refreshToken.isEmpty()) {
            logger.warn("Refresh Token 없음");
            return null;
        }

        return refreshToken;
    }

    // 요청에서 Refresh Token 추출 (Body 우선, 없으면 Cookie)
    public String extractRefreshToken(String refreshTokenFromBody, HttpServletRequest request) {
        logger.debug("Refresh Token 추출 시도 (Body 우선, Cookie 대체)");

        // 1. Body에서 추출 시도
        if (refreshTokenFromBody != null && !refreshTokenFromBody.isEmpty()) {
            logger.debug("Body에서 Refresh Token 추출 성공");
            return refreshTokenFromBody;
        }

        // 2. Cookie에서 추출 시도
        logger.debug("Body에 Refresh Token 없음, Cookie 확인");
        return extractRefreshTokenFromRequest(request);
    }

    // Access Token 유효성 검증
    public boolean isAccessTokenValid(HttpServletRequest request) {
        String accessToken = CookieUtil.getCookieValue(request, ACCESS_TOKEN_COOKIE);

        if (accessToken == null || accessToken.isEmpty()) {
            return false;
        }

        return jwtTokenProvider.validateToken(accessToken);
    }
}