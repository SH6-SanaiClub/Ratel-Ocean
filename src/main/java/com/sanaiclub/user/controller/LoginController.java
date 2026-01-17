package com.sanaiclub.user.controller;

import com.sanaiclub.common.security.JwtAuthService;
import com.sanaiclub.user.service.LoginService;
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

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.validation.Valid;


@Controller
public class LoginController {

    private static final Logger logger = LoggerFactory.getLogger(LoginController.class);

    private final LoginService loginService;
    private final JwtAuthService jwtAuthService;

    /**
     * 생성자 주입
     */
    public LoginController(LoginService loginService, JwtAuthService jwtAuthService) {
        this.loginService = loginService;
        this.jwtAuthService = jwtAuthService;
    }

    /**
     * 로그인 페이지 표시
     *
     * @return 로그인 페이지 (login.jsp)
     */
    @GetMapping("/login")
    public String loginPage() {
        return "user/login";
    }

    /**
     * 로그인
     *
     * @param request  로그인 요청 DTO
     * @param response HTTP 응답 (쿠키 설정용)
     * @return 로그인 결과
     */
    @PostMapping("/login")
    @ResponseBody
    public ResponseEntity<ApiResponse<LoginResponseDTO>> login(
            @Valid @RequestBody LoginRequestDTO request,
            HttpServletResponse response) {

        logger.info("로그인 요청: loginId={}", request.getLoginId());

        try {
            // 1. 로그인 처리 (LoginService)
            LoginResponseDTO loginResponse = loginService.login(request);

            // 2. 쿠키 설정 (JwtAuthService)
            jwtAuthService.setAuthCookies(
                    response,
                    loginResponse.getAccessToken(),
                    loginResponse.getRefreshToken(),
                    loginResponse.getExpiresIn()
            );

            logger.info("로그인 성공: loginId={}", request.getLoginId());

            // 3. HTTP 응답 반환
            return ResponseEntity.ok(ApiResponse.success(loginResponse, "로그인 성공"));

        } catch (IllegalArgumentException e) {
            logger.warn("로그인 실패: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            logger.error("로그인 처리 중 예상치 못한 오류", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("로그인 처리 중 오류가 발생했습니다."));
        }
    }

    /**
     * 로그아웃
     */
    @PostMapping("/logout")
    @ResponseBody
    public ResponseEntity<ApiResponse<Void>> logout(
            HttpServletRequest request,
            HttpServletResponse response) {

        logger.info("로그아웃 요청");

        try {
            // JWT 인증: userId 추출 (JwtAuthService)
            Integer userId = jwtAuthService.extractUserIdFromRequest(request);

            // 로그아웃 처리 (LoginService)
            loginService.logout(userId);

            // 쿠키 삭제 (JwtAuthService)
            jwtAuthService.clearAuthCookies(response);

            logger.info("로그아웃 완료");

            return ResponseEntity.ok(ApiResponse.success("로그아웃 성공"));

        } catch (IllegalArgumentException e) {
            // 토큰이 유효하지 않아도 쿠키는 삭제 (클라이언트 정리)
            logger.warn("로그아웃 처리 중 인증 실패: {}", e.getMessage());
            jwtAuthService.clearAuthCookies(response);
            return ResponseEntity.ok(ApiResponse.success("로그아웃 성공"));

        } catch (Exception e) {
            // 예상치 못한 오류 발생 시에도 쿠키 삭제
            logger.error("로그아웃 처리 중 오류", e);
            jwtAuthService.clearAuthCookies(response);
            return ResponseEntity.ok(ApiResponse.success("로그아웃 성공"));
        }
    }

    /**
     * Access Token 재발급
     */
    @PostMapping("/refresh-token")
    @ResponseBody
    public ResponseEntity<ApiResponse<TokenRefreshResponseDTO>> refreshToken(
            @RequestBody(required = false) TokenRefreshRequestDTO requestBody,
            HttpServletRequest request,
            HttpServletResponse response) {

        logger.info("토큰 재발급 요청");

        try {
            // 1. Refresh Token 추출 (JwtAuthService)
            // Body 우선, 없으면 Cookie
            String refreshTokenFromBody = (requestBody != null) ? requestBody.getRefreshToken() : null;
            String refreshToken = jwtAuthService.extractRefreshToken(refreshTokenFromBody, request);

            if (refreshToken == null || refreshToken.isEmpty()) {
                logger.warn("Refresh Token 없음");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(ApiResponse.error("Refresh Token이 없습니다. 다시 로그인해주세요."));
            }

            // 토큰 재발급 (LoginService)
            TokenRefreshResponseDTO refreshResponse = loginService.refreshAccessToken(refreshToken);

            // 새 Access Token 쿠키 설정 (JwtAuthService)
            jwtAuthService.setAccessTokenCookie(
                    response,
                    refreshResponse.getAccessToken(),
                    refreshResponse.getExpiresIn()
            );

            logger.info("토큰 재발급 성공");

            return ResponseEntity.ok(ApiResponse.success(refreshResponse, "토큰 재발급 성공"));

        } catch (IllegalArgumentException e) {
            logger.warn("토큰 재발급 실패: {}", e.getMessage());

            // Refresh Token 무효 → 모든 쿠키 삭제 후 재로그인 유도
            jwtAuthService.clearAuthCookies(response);

            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error(e.getMessage()));
        }
    }
}