package com.sanaiclub.user.model.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TokenRefreshResponseDTO {

    private String accessToken;
    @Builder.Default
    private String tokenType = "Bearer";
    private long expiresIn;


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
