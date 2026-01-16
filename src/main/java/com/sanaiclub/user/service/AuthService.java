package com.sanaiclub.user.service;

import com.sanaiclub.user.model.dto.LoginRequestDTO;
import com.sanaiclub.user.model.dto.LoginResponseDTO;
import com.sanaiclub.user.model.dto.TokenRefreshResponseDTO;

public interface AuthService {

    // 로그인 처리
    LoginResponseDTO login(LoginRequestDTO request);

    // 로그아웃 처리
    void logout(Integer userId);

    // Access Token 재발급
    TokenRefreshResponseDTO refreshAccessToken(String refreshToken);

}
