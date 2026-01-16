package com.sanaiclub.user.model.dto;

import lombok.*;

import javax.validation.constraints.NotBlank;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TokenRefreshRequestDTO {

    @NotBlank(message = "Refresh Token이 필요합니다.")
    private String refreshToken;
}
