package com.sanaiclub.user.service;

import com.sanaiclub.user.dao.UserMapper;
import com.sanaiclub.user.model.dto.UserSignupRequestDTO;
import com.sanaiclub.user.model.vo.UserStatus;
import com.sanaiclub.user.model.vo.UserVO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Date;

@Service
@RequiredArgsConstructor
public class JoinServiceImpl implements  JoinService {

    private final UserMapper userMapper;
    private final BCryptPasswordEncoder passwordEncoder;

    @Override
    public boolean isIdDuplicate(String loginId) {
        return userMapper.checkId(loginId) > 0;
    }

    @Override
    public boolean isEmailDuplicate(String email) {
        return userMapper.checkEmail(email) > 0;
    }

    /**
     * 회원가입 핵심 로직
     */
    @Override
    @Transactional
    public boolean signUp(UserSignupRequestDTO dto) {
        // 1. 비밀번호 암호화 (BCrypt)
        String encodedPassword = passwordEncoder.encode(dto.getPassword());

        // 2. 생년월일 포맷 변환 (YYYY.MM.DD -> YYYY-MM-DD)
        // input에서 들어오는 형식을 처리합니다.
        String birthStr = dto.getBirth().replace(".", "-");
        Date sqlDate = Date.valueOf(birthStr);

        // 3. DTO -> VO 변환 (Builder 패턴 사용)
        UserVO userVO = UserVO.builder()
                .loginId(dto.getLoginId())
                .password(encodedPassword)
                .email(dto.getEmail())
                .name(dto.getName())
                .phone(dto.getPhone())
                .userType(dto.getUserType())
                .birthDate(sqlDate)
                .status(UserStatus.ACTIVE) // 기본 활성화 상태
                .build();

        // 4. DB 저장
        return userMapper.insertUser(userVO) > 0;
    }
}