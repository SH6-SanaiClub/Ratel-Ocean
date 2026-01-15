package com.sanaiclub.user.model.dto;

import lombok.*;

import javax.validation.constraints.NotBlank;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TokenRefreshRequestDTO {

    /**
     * Refresh Token
     * - DB에 저장된 값과 일치해야 함
     * - 만료되지 않았어야 함
     */
    @NotBlank(message = "Refresh Token이 필요합니다.")
    private String refreshToken;
}
