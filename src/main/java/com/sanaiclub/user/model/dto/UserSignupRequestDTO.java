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

    private UserType userType;          // 역할 (FREELANCER / CLIENT)
    private String loginId;             // 로그인 ID
    private String password;            // 비밀번호
    private String passwordConfirm;     // 비밀번호 확인
    private String email;               // 이메일
    private String name;                // 실명
    private String phone;               // 전화번호

    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate birthDate;

    // 약관 및 선택 사항
    private boolean termAgreed; // 이용약관 동의
    private boolean privacyAgreed; // 개인정보 동의


    /**
     * 비밀번호 일치 여부 확인
     */
    public boolean isPasswordMatching() {
        if (password == null || passwordConfirm == null) {
            return false;
        }
        return password.equals(passwordConfirm);
    }

    /**
     * 프리랜서 여부 확인
     */
    public boolean isFreelancer() {
        return UserType.FREELANCER.equals(userType);
    }

    /**
     * 클라이언트 여부 확인
     */
    public boolean isClient() {
        return UserType.CLIENT.equals(userType);
    }
}