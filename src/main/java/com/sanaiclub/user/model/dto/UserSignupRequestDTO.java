package com.sanaiclub.user.model.dto;

import com.sanaiclub.user.model.vo.UserType;
import java.time.LocalDate;

import lombok.*;
import org.springframework.format.annotation.DateTimeFormat;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
@Builder
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

    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate birth;

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