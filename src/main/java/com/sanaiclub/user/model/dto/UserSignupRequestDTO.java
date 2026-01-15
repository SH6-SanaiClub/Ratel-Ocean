package com.sanaiclub.user.model.dto;

import com.sanaiclub.user.model.vo.UserType;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
public class UserSignupRequestDTO {
    // selectRole.jsp에서 결정된 값
    private UserType userType;

    // signup.jsp 공통 입력 값
    private String loginId;
    private String password;
    private String email;
    private String name;
    private String phone;
    private String birth; // YYYY.MM.DD 형식으로 받아 서비스에서 Date로 변환

    // 선택 사항: 약관 동의 여부 등
    private boolean termAgreed;
}