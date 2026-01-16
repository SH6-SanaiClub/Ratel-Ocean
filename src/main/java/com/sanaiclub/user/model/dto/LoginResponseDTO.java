package com.sanaiclub.user.model.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoginResponseDTO {

    private String accessToken;
    private String refreshToken;
    @Builder.Default
    private String tokenType = "Bearer";
    private long expiresIn;
    private UserInfoDTO userInfo; // 로그인한 사용자 정보


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
