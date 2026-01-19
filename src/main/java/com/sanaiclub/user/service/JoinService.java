package com.sanaiclub.user.service;

import com.sanaiclub.user.model.dto.UserSignupRequestDTO;

public interface JoinService {

    // 아이디 중복 체크
    boolean isIdDuplicate(String loginId);

    // 이메일 중복 체크
    boolean isEmailDuplicate(String email);

    // 회원가입 실행
    boolean signUp(UserSignupRequestDTO dto);
}