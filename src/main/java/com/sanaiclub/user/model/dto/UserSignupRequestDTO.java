package com.sanaiclub.user.model.dto;

import com.sanaiclub.user.model.vo.UserType;
import java.sql.Date;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
public class UserSignupRequestDTO {
    // 1단계 선택 값
    private UserType userType;

    // 공통 필수 정보
    private String loginId;
    private String password;
    private String passwordConfirm; // 비밀번호 일치 확인용
    private String email;
    private String name;
    private String phone;
    private Date birth;

    // 약관 및 선택 사항
    private boolean termAgreed; // 이용약관 동의
    private boolean privacyAgreed; // 개인정보 동의


    /**
     * 비즈니스 로직: 비밀번호 일치 여부 확인
     */
    public boolean isPasswordMatching() {
        return password != null && password.equals(passwordConfirm);
    }
}