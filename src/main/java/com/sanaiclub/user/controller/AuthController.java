package com.sanaiclub.user.controller;

import com.sanaiclub.common.security.JwtTokenProvider;
import com.sanaiclub.user.service.AuthService;
import com.sanaiclub.common.dto.ApiResponse;
import com.sanaiclub.user.model.dto.LoginRequestDTO;
import com.sanaiclub.user.model.dto.LoginResponseDTO;
import com.sanaiclub.user.model.dto.TokenRefreshRequestDTO;
import com.sanaiclub.user.model.dto.TokenRefreshResponseDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.validation.Valid;


@Controller
public class AuthController {

    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

    // 쿠키 설정 상수
    private static final String ACCESS_TOKEN_COOKIE = "accessToken";
    private static final String REFRESH_TOKEN_COOKIE = "refreshToken";
    private static final boolean COOKIE_HTTP_ONLY = true;
    private static final boolean COOKIE_SECURE = false;  // 개발환경: false, 운영환경: true
    private static final String COOKIE_PATH = "/";

    private final AuthService authService;
    private final JwtTokenProvider jwtTokenProvider;

    /**
     * 생성자 주입
     */
    public AuthController(AuthService authService, JwtTokenProvider jwtTokenProvider) {
        this.authService = authService;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    @GetMapping("/login")
    public String loginPage() {
        return "user/login";
    }


    // ═══════════════════════════════════════════════════════════════
    // 로그인 API
    // ═══════════════════════════════════════════════════════════════

    /**
     * 로그인 처리
     *
     * @param request  로그인 요청 DTO
     * @param response HTTP 응답 (쿠키 설정용)
     * @return 로그인 결과
     */
    @PostMapping("/login.do")
    @ResponseBody
    public ResponseEntity<ApiResponse<LoginResponseDTO>> login(
            @Valid @RequestBody LoginRequestDTO request,
            HttpServletResponse response) {

        logger.info("로그인 요청: loginId={}", request.getLoginId());

        try {
            // 1. 로그인 처리 (Service 호출)
            LoginResponseDTO loginResponse = authService.login(request);

            // 2. Access Token 쿠키 설정
            addCookie(response, ACCESS_TOKEN_COOKIE, loginResponse.getAccessToken(),
                    (int) loginResponse.getExpiresIn());

            // 3. Refresh Token 쿠키 설정 (7일)
            addCookie(response, REFRESH_TOKEN_COOKIE, loginResponse.getRefreshToken(),
                    7 * 24 * 60 * 60);

            logger.info("로그인 성공: loginId={}", request.getLoginId());

            return ResponseEntity.ok(ApiResponse.success(loginResponse, "로그인 성공"));

        } catch (IllegalArgumentException e) {
            logger.warn("로그인 실패: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 로그아웃 처리
     */
    @PostMapping("/logout.do")
    @ResponseBody
    public ResponseEntity<ApiResponse<Void>> logout(
            HttpServletRequest request,
            HttpServletResponse response) {

        logger.info("로그아웃 요청");

        try {
            // 1. 쿠키에서 Access Token 추출
            String accessToken = getCookieValue(request, ACCESS_TOKEN_COOKIE);

            if (accessToken != null) {
                // 2. 토큰에서 userId 추출하여 로그아웃 처리
                // (JwtTokenProvider 주입 필요 - 아래 개선 버전 참고)
                 Integer userId = jwtTokenProvider.getUserId(accessToken);
                 authService.logout(userId);
            }

            // 3. 쿠키 삭제
            deleteCookie(response, ACCESS_TOKEN_COOKIE);
            deleteCookie(response, REFRESH_TOKEN_COOKIE);

            logger.info("로그아웃 완료");

            return ResponseEntity.ok(ApiResponse.success("로그아웃 성공"));

        } catch (Exception e) {
            logger.error("로그아웃 처리 중 오류: {}", e.getMessage());
            // 쿠키는 삭제 (클라이언트 측 정리)
            deleteCookie(response, ACCESS_TOKEN_COOKIE);
            deleteCookie(response, REFRESH_TOKEN_COOKIE);
            return ResponseEntity.ok(ApiResponse.success("로그아웃 성공"));
        }
    }

    /**
     * Access Token 재발급
     */
    @PostMapping("/auth/refresh.do")
    @ResponseBody
    public ResponseEntity<ApiResponse<TokenRefreshResponseDTO>> refreshToken(
            @RequestBody(required = false) TokenRefreshRequestDTO requestBody,
            HttpServletRequest request,
            HttpServletResponse response) {

        logger.info("토큰 재발급 요청");

        try {
            // 1. Refresh Token 추출 (Body 우선, 없으면 Cookie에서)
            String refreshToken = null;

            if (requestBody != null && requestBody.getRefreshToken() != null) {
                refreshToken = requestBody.getRefreshToken();
            } else {
                refreshToken = getCookieValue(request, REFRESH_TOKEN_COOKIE);
            }

            if (refreshToken == null || refreshToken.isEmpty()) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(ApiResponse.error("Refresh Token이 없습니다. 다시 로그인해주세요."));
            }

            // 2. 토큰 재발급 (Service 호출)
            TokenRefreshResponseDTO refreshResponse = authService.refreshAccessToken(refreshToken);

            // 3. 새 Access Token 쿠키 설정
            addCookie(response, ACCESS_TOKEN_COOKIE, refreshResponse.getAccessToken(),
                    (int) refreshResponse.getExpiresIn());

            logger.info("토큰 재발급 성공");

            return ResponseEntity.ok(ApiResponse.success(refreshResponse, "토큰 재발급 성공"));

        } catch (IllegalArgumentException e) {
            logger.warn("토큰 재발급 실패: {}", e.getMessage());
            // Refresh Token 무효 → 쿠키 삭제 후 재로그인 유도
            deleteCookie(response, ACCESS_TOKEN_COOKIE);
            deleteCookie(response, REFRESH_TOKEN_COOKIE);
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error(e.getMessage()));
        }
    }
    /**
     * 쿠키 추가
     *
     * @param response HTTP 응답
     * @param name     쿠키 이름
     * @param value    쿠키 값
     * @param maxAge   유효 시간 (초)
     */
    private void addCookie(HttpServletResponse response, String name, String value, int maxAge) {
        Cookie cookie = new Cookie(name, value);
        cookie.setHttpOnly(COOKIE_HTTP_ONLY);
        cookie.setSecure(COOKIE_SECURE);
        cookie.setPath(COOKIE_PATH);
        cookie.setMaxAge(maxAge);
        response.addCookie(cookie);
    }

    /**
     * 쿠키 삭제
     *
     * @param response HTTP 응답
     * @param name     삭제할 쿠키 이름
     */
    private void deleteCookie(HttpServletResponse response, String name) {
        Cookie cookie = new Cookie(name, null);
        cookie.setHttpOnly(COOKIE_HTTP_ONLY);
        cookie.setSecure(COOKIE_SECURE);
        cookie.setPath(COOKIE_PATH);
        cookie.setMaxAge(0);  // 즉시 만료
        response.addCookie(cookie);
    }

    /**
     * 요청에서 쿠키 값 추출
     *
     * @param request HTTP 요청
     * @param name    쿠키 이름
     * @return 쿠키 값 (없으면 null)
     */
    private String getCookieValue(HttpServletRequest request, String name) {
        Cookie[] cookies = request.getCookies();

        if (cookies == null) {
            return null;
        }

        for (Cookie cookie : cookies) {
            if (name.equals(cookie.getName())) {
                return cookie.getValue();
            }
        }

        return null;
    }
}