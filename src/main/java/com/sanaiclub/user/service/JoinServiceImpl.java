package com.sanaiclub.user.service;

import com.sanaiclub.user.dao.UserMapper;
import com.sanaiclub.user.model.dto.UserSignupRequestDTO;
import com.sanaiclub.user.model.vo.AccountVO;
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
    @Transactional // 모든 데이터가 성공해야만 Commit, 하나라도 실패하면 Rollback
    public boolean signUp(UserSignupRequestDTO dto) {
        try {
            // 1. 비밀번호 암호화 및 UserVO 빌드
            String encodedPassword = passwordEncoder.encode(dto.getPassword());
            UserVO userVO = UserVO.builder()
                    .loginId(dto.getLoginId())
                    .password(encodedPassword)
                    .email(dto.getEmail())
                    .name(dto.getName())
                    .phone(dto.getPhone())
                    .userType(dto.getUserType())
                    .birthDate(dto.getBirth())
                    .status(UserStatus.ACTIVE)
                    .build();

            // 2. 유저 정보 저장 (MyBatis useGeneratedKeys로 userId 확보)
            userMapper.insertUser(userVO);

            // 3. 계좌 정보 저장 (User 가입 후 생성된 PK 사용)
            AccountVO accountVO = AccountVO.builder()
                    .userId(userVO.getUserId()) // insertUser 후 채워진 ID
                    .bankName(dto.getBankName())
                    .accountNumber(dto.getAccountNumber())
                    .accountHolder(dto.getAccountHolder())
                    .build();

            // userMapper에 계좌 저장 메서드가 있다고 가정 (또는 AccountMapper 별도 사용)
            int result = userMapper.insertAccount(accountVO);

            return result > 0;
        } catch (Exception e) {
            // 로깅 후 false 반환 (Spring의 @Transactional이 런타임 예외 시 롤백 수행)
            return false;
        }
    }
}