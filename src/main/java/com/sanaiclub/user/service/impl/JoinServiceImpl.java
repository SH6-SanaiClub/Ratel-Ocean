package com.sanaiclub.user.service.impl;

import com.sanaiclub.common.util.EncryptionUtil;
import com.sanaiclub.user.dao.UserMapper;
import com.sanaiclub.user.model.dto.AccountDTO;
import com.sanaiclub.user.model.dto.ClientProfileDTO;
import com.sanaiclub.user.model.dto.FreelancerProfileDTO;
import com.sanaiclub.user.model.dto.UserDefaultDTO;
import com.sanaiclub.user.model.vo.AccountVO;
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
    private final EncryptionUtil encryptionUtil;

    public JoinServiceImpl(UserMapper userMapper, EncryptionUtil encryptionUtil, PasswordEncoder passwordEncoder) {
        this.userMapper = userMapper;
        this.encryptionUtil = encryptionUtil;
        this.passwordEncoder = passwordEncoder; // 스프링이 가져다주는 빈을 그대로 사용!
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
    @Transactional(rollbackFor = Exception.class)
    @Override
    public boolean signUpFreelancer(UserDefaultDTO userDto, FreelancerProfileDTO freeDto, AccountDTO accountDto) throws Exception {
        try {
            int userId = insertCommonUser(userDto); // 유저 기본 정보 저장
            userMapper.insertFreelancerProfile(userId, freeDto); // 프로필 저장
            insertCommonAccount(userId, accountDto); // 계좌 정보 저장 (암호화 포함)
            return true;
        } catch (Exception e) {
            logger.error("프리랜서 가입 실패: {}", e.getMessage());
            throw e; // 예외를 던져야 @Transactional이 롤백을 수행함
        }
    }

    @Transactional(rollbackFor = Exception.class)
    @Override
    public boolean signUpClient(UserDefaultDTO userDto, ClientProfileDTO clientDto, AccountDTO accountDto) throws Exception {
        try {
            int userId = insertCommonUser(userDto);
            userMapper.insertCompany(clientDto); // 기업 정보 저장 (Key 식별)
            userMapper.insertClientProfile(userId, clientDto); // 클라이언트 프로필 저장
            insertCommonAccount(userId, accountDto);
            return true;
        } catch (Exception e) {
            logger.error("클라이언트 가입 실패: {}", e.getMessage());
            throw e;
        }
    }

    // ========================================================
    //  Private Helper Methods (중복 제거용 내부 메서드)
    // ========================================================

    private int insertCommonUser(UserDefaultDTO userDto) {
        String encodedPw = passwordEncoder.encode(userDto.getPassword());
        UserVO userVO = UserVO.builder()
                .loginId(userDto.getLoginId())
                .password(encodedPw)
                .email(userDto.getEmail())
                .name(userDto.getName())
                .phone(userDto.getPhone())
                .birthDate(userDto.getBirth())
                .userType(userDto.getUserType())
                .status(UserStatus.ACTIVE)
                .build();

        userMapper.insertUser(userVO);
        return userVO.getUserId(); // useGeneratedKeys로 받아온 ID 리턴
    }

    private void insertCommonAccount(int userId, AccountDTO accountDto) throws Exception {
        String encryptedAccountNumber = encryptionUtil.encrypt(accountDto.getAccountNumber());;
        AccountVO accountVO = AccountVO.builder()
                .userId(userId)
                .bankName(accountDto.getBankName())
                .accountNumber(encryptedAccountNumber)
                .accountHolder(accountDto.getAccountHolder())
                .build();

        userMapper.insertAccount(accountVO);
    }
}