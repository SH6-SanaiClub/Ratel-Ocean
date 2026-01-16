package com.sanaiclub.user.service.impl;

import com.sanaiclub.user.dao.UserMapper;
import com.sanaiclub.user.model.dto.UserSignupRequestDTO;
import com.sanaiclub.user.model.vo.UserStatus;
import com.sanaiclub.user.model.vo.UserVO;
import com.sanaiclub.user.service.JoinService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class JoinServiceImpl implements JoinService {

    private static final Logger logger = LoggerFactory.getLogger(JoinServiceImpl.class);

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;

    public JoinServiceImpl(UserMapper userMapper) {
        this.userMapper = userMapper;
        this.passwordEncoder = new BCryptPasswordEncoder();
    }

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
        // 비밀번호 암호화 (BCrypt)
        String encodedPassword = passwordEncoder.encode(dto.getPassword());

        // DTO -> VO 변환 (Builder 패턴 사용)
        UserVO userVO = UserVO.builder()
                .loginId(dto.getLoginId())
                .password(encodedPassword)
                .email(dto.getEmail())
                .name(dto.getName())
                .phone(dto.getPhone())
                .userType(dto.getUserType())
                .birthDate(dto.getBirth())
                .status(UserStatus.ACTIVE) // 기본 활성화 상태
                .build();

        // DB 저장
        return userMapper.insertUser(userVO) > 0;
    }
}