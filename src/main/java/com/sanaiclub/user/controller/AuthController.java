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

/**
 * ═══════════════════════════════════════════════════════════════════════
 * AuthController - 인증 관련 API 컨트롤러
 * ═══════════════════════════════════════════════════════════════════════
 *
 * [역할]
 * - 로그인 / 로그아웃 / 토큰 재발급 API 제공
 * - JWT 토큰을 HttpOnly Cookie로 관리
 *
 * [엔드포인트 목록]
 * ┌────────────────────┬────────┬─────────────────────────┐
 * │ URL                │ Method │ 설명                    │
 * ├────────────────────┼────────┼─────────────────────────┤
 * │ /login             │ GET    │ 로그인 페이지           │
 * │ /login.do          │ POST   │ 로그인 처리 (API)       │
 * │ /logout.do         │ POST   │ 로그아웃 처리           │
 * │ /auth/refresh.do   │ POST   │ Access Token 재발급     │
 * └────────────────────┴────────┴─────────────────────────┘
 *
 * [쿠키 설정]
 * - HttpOnly: true (JavaScript 접근 차단 → XSS 방어)
 * - Secure: true (HTTPS에서만 전송, 개발 시 false)
 * - Path: "/" (모든 경로에서 쿠키 전송)
 *
 * @author sanaiclub
 * @version 1.0
 */
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


    // ═══════════════════════════════════════════════════════════════
    // 페이지 이동
    // ═══════════════════════════════════════════════════════════════

    /**
     * 로그인 페이지
     */
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
     * [요청]
     * POST /login.do
     * Content-Type: application/json
     * {
     *   "loginId": "user123",
     *   "password": "password123"
     * }
     *
     * [응답 - 성공]
     * HTTP 200 OK
     * Set-Cookie: accessToken=eyJ...; HttpOnly; Path=/
     * Set-Cookie: refreshToken=eyJ...; HttpOnly; Path=/
     * {
     *   "success": true,
     *   "message": "로그인 성공",
     *   "data": {
     *     "accessToken": "eyJ...",
     *     "refreshToken": "eyJ...",
     *     "tokenType": "Bearer",
     *     "expiresIn": 1800,
     *     "userInfo": { ... }
     *   }
     * }
     *
     * [응답 - 실패]
     * HTTP 401 Unauthorized
     * {
     *   "success": false,
     *   "message": "아이디 또는 비밀번호가 일치하지 않습니다."
     * }
     *
     * [@Valid 어노테이션]
     * - LoginRequestDTO의 @NotBlank, @Size 등 검증 수행
     * - 검증 실패 시 MethodArgumentNotValidException 발생
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


    // ═══════════════════════════════════════════════════════════════
    // 로그아웃 API
    // ═══════════════════════════════════════════════════════════════

    /**
     * 로그아웃 처리
     *
     * [처리 흐름]
     * 1. 쿠키에서 Access Token 추출
     * 2. 토큰에서 userId 추출
     * 3. DB에서 Refresh Token 삭제
     * 4. 클라이언트 쿠키 삭제
     *
     * [요청]
     * POST /logout.do
     * Cookie: accessToken=eyJ...
     *
     * [응답]
     * HTTP 200 OK
     * Set-Cookie: accessToken=; Max-Age=0; Path=/
     * Set-Cookie: refreshToken=; Max-Age=0; Path=/
     * {
     *   "success": true,
     *   "message": "로그아웃 성공"
     * }
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

//                // 임시: Service에서 토큰으로 직접 처리하도록 변경 가능
//                logger.info("Access Token으로 로그아웃 처리");
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


    // ═══════════════════════════════════════════════════════════════
    // 토큰 재발급 API
    // ═══════════════════════════════════════════════════════════════

    /**
     * Access Token 재발급
     *
     * [사용 시점]
     * - Access Token 만료 시 (401 응답 받았을 때)
     * - 클라이언트가 Refresh Token으로 새 Access Token 요청
     *
     * [요청 방식 1 - 쿠키 자동 전송]
     * POST /auth/refresh.do
     * Cookie: refreshToken=eyJ...
     *
     * [요청 방식 2 - Body로 전송]
     * POST /auth/refresh.do
     * Content-Type: application/json
     * { "refreshToken": "eyJ..." }
     *
     * [응답]
     * HTTP 200 OK
     * Set-Cookie: accessToken=eyJ...(새토큰); HttpOnly; Path=/
     * {
     *   "success": true,
     *   "data": {
     *     "accessToken": "eyJ...",
     *     "tokenType": "Bearer",
     *     "expiresIn": 1800
     *   }
     * }
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


    // ═══════════════════════════════════════════════════════════════
    // 쿠키 유틸리티 메서드
    // ═══════════════════════════════════════════════════════════════

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