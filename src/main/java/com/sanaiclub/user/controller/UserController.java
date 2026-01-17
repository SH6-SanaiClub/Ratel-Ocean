package com.sanaiclub.user.controller;

import com.sanaiclub.common.dto.ApiResponse;
import com.sanaiclub.common.security.JwtAuthService;
import com.sanaiclub.user.model.dto.UserInfoDTO;
import com.sanaiclub.user.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;

// UserController - 사용자 정보 조회 및 관리
@Controller
@RequestMapping("/user")
public class UserController {

    private static final Logger logger = LoggerFactory.getLogger(UserController.class);

    //의존성 주입
    private final UserService userService;
    private final JwtAuthService jwtAuthService;

    /**
     * 생성자 주입
     */
    public UserController(UserService userService, JwtAuthService jwtAuthService) {
        this.userService = userService;
        this.jwtAuthService = jwtAuthService;
    }

    // 현재 로그인한 사용자 정보 조회
    @GetMapping("/me")
    @ResponseBody
    public ResponseEntity<ApiResponse<UserInfoDTO>> getMyInfo(HttpServletRequest request) {
        logger.debug("내 정보 조회 요청");

        try {
            // 1. userId 추출 (JwtAuthService)
            Integer userId = jwtAuthService.extractUserIdFromRequest(request);

            // 2. 사용자 정보 조회 (UserService)
            UserInfoDTO userInfo = userService.getUserInfo(userId);

            logger.debug("내 정보 조회 성공: userId={}", userId);

            // 3. HTTP 응답 반환
            return ResponseEntity.ok(
                    ApiResponse.success(userInfo, "사용자 정보 조회 성공")
            );

        } catch (IllegalArgumentException e) {
            // JwtAuthService에서 발생한 인증 실패 예외
            logger.warn("사용자 정보 조회 실패: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    // 로그인 ID로 사용자 정보 조회
    @GetMapping("/by-login-id")
    @ResponseBody
    public ResponseEntity<ApiResponse<UserInfoDTO>> getUserByLoginId(
            @RequestParam("loginId") String loginId) {

        logger.debug("로그인 ID로 사용자 조회: {}", loginId);

        try {
            // 사용자 정보 조회 (UserService)
            UserInfoDTO userInfo = userService.getUserInfoByLoginId(loginId);

            logger.debug("사용자 조회 성공: loginId={}", loginId);

            return ResponseEntity.ok(
                    ApiResponse.success(userInfo, "사용자 정보 조회 성공")
            );

        } catch (IllegalArgumentException e) {
            logger.warn("사용자 조회 실패: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

}