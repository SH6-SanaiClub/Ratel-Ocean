package com.sanaiclub.user.service.impl;

import com.sanaiclub.user.dao.UserMapper;
import com.sanaiclub.user.model.dto.UserInfoDTO;
import com.sanaiclub.user.model.vo.UserStatus;
import com.sanaiclub.user.model.vo.UserVO;
import com.sanaiclub.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserServiceImpl implements UserService {

    private static final Logger logger = LoggerFactory.getLogger(UserServiceImpl.class);

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;

    /**
     * 사용자 ID로 정보 조회
     */
    @Override
    public UserInfoDTO getUserInfo(Integer userId) {
        logger.debug("사용자 정보 조회: userId={}", userId);

        UserVO user = userMapper.findByUserId(userId);

        if (user == null) {
            throw new IllegalArgumentException("사용자를 찾을 수 없습니다.");
        }

        return UserInfoDTO.fromVO(user);
    }

    /**
     * 로그인 ID로 정보 조회
     */
    @Override
    public UserInfoDTO getUserInfoByLoginId(String loginId) {
        logger.debug("사용자 정보 조회: loginId={}", loginId);

        UserVO user = userMapper.findByLoginId(loginId);

        if (user == null) {
            throw new IllegalArgumentException("사용자를 찾을 수 없습니다.");
        }

        // 비활성 사용자 제외
        if (!UserStatus.ACTIVE.equals(user.getStatus())) {
            throw new IllegalArgumentException("비활성화된 계정입니다.");
        }

        return UserInfoDTO.fromVO(user);
    }

    /**
     * 비밀번호 검증 (추가)
     */
    @Override
    public boolean verifyPassword(Integer userId, String password) {
        logger.debug("비밀번호 검증: userId={}", userId);

        // 1. 사용자 조회
        UserVO user = userMapper.findByUserId(userId);

        if (user == null) {
            logger.warn("비밀번호 검증 실패 - 사용자 없음: userId={}", userId);
            return false;
        }

        // 2. 비밀번호 검증
        boolean matches = passwordEncoder.matches(password, user.getPassword());

        if (!matches) {
            logger.warn("비밀번호 검증 실패: userId={}", userId);
        } else {
            logger.debug("비밀번호 검증 성공: userId={}", userId);
        }

        return matches;
    }
}
