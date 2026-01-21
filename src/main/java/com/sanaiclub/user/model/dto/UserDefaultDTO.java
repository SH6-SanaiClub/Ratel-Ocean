package com.sanaiclub.user.model.dto;

import com.sanaiclub.user.model.vo.UserType;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import java.sql.Date;

@Getter
@Setter
@ToString
public class UserDefaultDTO {
    private UserType userType;      // 역할 (FREELANCER / CLIENT)
    private String loginId;         // 로그인 ID
    private String password;        // 비밀번호
    private String email;           // 이메일
    private String name;            // 실명
    private String phone;           // 전화번호
    private Date birth;             // 생년월일

    // 약관 동의
    private boolean termAgreed;
    private boolean privacyAgreed;
}