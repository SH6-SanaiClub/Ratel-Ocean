package com.sanaiclub.user.model.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoginResponseDTO {

    /**
     * Access Token (JWT)
     * - API 요청 시 Authorization 헤더에 포함
     * - 형식: "Bearer {accessToken}"
     */
    private String accessToken;

    /**
     * Refresh Token (JWT)
     * - Access Token 만료 시 재발급에 사용
     * - HttpOnly Cookie로 저장 (보안상 권장)
     * - 또는 클라이언트가 안전하게 저장
     */
    private String refreshToken;

    /**
     * 토큰 타입
     * - 항상 "Bearer" (OAuth 2.0 표준)
     * - Authorization: Bearer {token}
     */
    @Builder.Default
    private String tokenType = "Bearer";

    /**
     * Access Token 만료 시간 (초)
     */
    private long expiresIn;

    /**
     * 로그인한 사용자 정보
     */
    private UserInfoDTO userInfo;

    // ═══════════════════════════════════════════════════════════════
    // 정적 팩토리 메서드
    // ═══════════════════════════════════════════════════════════════

    /**
     * 로그인 성공 응답 생성
     *
     * @param accessToken  발급된 Access Token
     * @param refreshToken 발급된 Refresh Token
     * @param expiresIn    Access Token 만료 시간(초)
     * @param userInfo     사용자 정보
     * @return LoginResponseDTO
     */
    public static LoginResponseDTO of(String accessToken,
                                      String refreshToken,
                                      long expiresIn,
                                      UserInfoDTO userInfo) {
        return LoginResponseDTO.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(expiresIn)
                .userInfo(userInfo)
                .build();
    }
}
