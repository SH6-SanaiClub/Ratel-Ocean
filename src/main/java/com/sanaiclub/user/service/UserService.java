package com.sanaiclub.user.service;

import com.sanaiclub.user.model.dto.UserInfoDTO;

public interface UserService {

    // 현재 로그인 사용자 정보 조회
    UserInfoDTO getUserInfo(Integer userId);

    // 로그인 ID로 사용자 정보 조회
    UserInfoDTO getUserInfoByLoginId(String loginId);

    // 비밀번호 검증 (추가)
    boolean verifyPassword(Integer userId, String password);
}
