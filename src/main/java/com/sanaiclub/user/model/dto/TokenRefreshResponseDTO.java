package com.sanaiclub.user.model.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TokenRefreshResponseDTO {

    /**
     * 새로 발급된 Access Token
     */
    private String accessToken;

    /**
     * 토큰 타입 (항상 "Bearer")
     */
    @Builder.Default
    private String tokenType = "Bearer";

    /**
     * Access Token 만료 시간 (초)
     */
    private long expiresIn;

    // ═══════════════════════════════════════════════════════════════
    // 정적 팩토리 메서드
    // ═══════════════════════════════════════════════════════════════

    /**
     * 토큰 재발급 응답 생성
     *
     * @param accessToken 새 Access Token
     * @param expiresIn   만료 시간(초)
     * @return TokenRefreshResponseDTO
     */
    public static TokenRefreshResponseDTO of(String accessToken, long expiresIn) {
        return TokenRefreshResponseDTO.builder()
                .accessToken(accessToken)
                .tokenType("Bearer")
                .expiresIn(expiresIn)
                .build();
    }
}
