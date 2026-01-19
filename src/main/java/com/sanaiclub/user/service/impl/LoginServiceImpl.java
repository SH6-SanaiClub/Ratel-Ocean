package com.sanaiclub.user.service.impl;

import com.sanaiclub.common.security.JwtTokenProvider;
import com.sanaiclub.user.dao.UserMapper;
import com.sanaiclub.user.model.dto.LoginRequestDTO;
import com.sanaiclub.user.model.dto.LoginResponseDTO;
import com.sanaiclub.user.model.dto.TokenRefreshResponseDTO;
import com.sanaiclub.user.model.dto.UserInfoDTO;
import com.sanaiclub.user.model.vo.UserStatus;
import com.sanaiclub.user.model.vo.UserVO;
import com.sanaiclub.user.service.LoginService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class LoginServiceImpl implements LoginService {

    private static final Logger logger = LoggerFactory.getLogger(LoginServiceImpl.class);

    private final UserMapper userMapper;
    private final JwtTokenProvider jwtTokenProvider;
    private final PasswordEncoder passwordEncoder;

    public LoginServiceImpl(UserMapper userMapper, JwtTokenProvider jwtTokenProvider) {
        this.userMapper = userMapper;
        this.jwtTokenProvider = jwtTokenProvider;
        this.passwordEncoder = new BCryptPasswordEncoder();
    }

    // 로그인
    @Override
    @Transactional  // 쓰기 작업 포함 (Refresh Token 저장)
    public LoginResponseDTO login(LoginRequestDTO request) {
        logger.info("로그인 시도: {}", request.getLoginId());

        // 1. 사용자 조회
        UserVO user = userMapper.findByLoginId(request.getLoginId());

        // 2. 사용자 존재 확인
        if (user == null) {
            logger.warn("로그인 실패 - 존재하지 않는 아이디: {}", request.getLoginId());
            throw new IllegalArgumentException("아이디 또는 비밀번호가 일치하지 않습니다.");
        }

        // 3. 계정 상태 확인
        if (!UserStatus.ACTIVE.equals(user.getStatus())) {
            logger.warn("로그인 실패 - 비활성 계정: {}, 상태: {}", request.getLoginId(), user.getStatus());

            // 상태별 에러 메시지 (선택적으로 상세화 가능)
            if (UserStatus.SUSPENDED.equals(user.getStatus())) {
                throw new IllegalArgumentException("정지된 계정입니다. 고객센터에 문의하세요.");
            } else {
                throw new IllegalArgumentException("비활성화된 계정입니다.");
            }
        }

        // 4. 비밀번호 검증
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            logger.warn("로그인 실패 - 비밀번호 불일치: {}", request.getLoginId());
            throw new IllegalArgumentException("아이디 또는 비밀번호가 일치하지 않습니다.");
        }

        // 5. JWT 토큰 생성
        String accessToken = jwtTokenProvider.createAccessToken(
                user.getUserId(),
                user.getLoginId(),
                user.getUserType()
        );
        String refreshToken = jwtTokenProvider.createRefreshToken(user.getUserId());

        // 6. Refresh Token DB 저장
        userMapper.updateRefreshToken(user.getUserId(), refreshToken);

        // 7. 응답 생성
        UserInfoDTO userInfo = UserInfoDTO.fromVO(user);

        logger.info("로그인 성공: {}", request.getLoginId());

        return LoginResponseDTO.of(
                accessToken,
                refreshToken,
                jwtTokenProvider.getAccessTokenValidityInSeconds(),
                userInfo
        );
    }

    // 로그아웃
    @Override
    @Transactional
    public void logout(Integer userId) {
        logger.info("로그아웃 처리: userId={}", userId);

        // Refresh Token 삭제 (null로 설정)
        int updated = userMapper.updateRefreshToken(userId, null);

        if (updated == 0) {
            logger.warn("로그아웃 실패 - 사용자 없음: userId={}", userId);
            // 이미 로그아웃된 상태일 수 있으므로 에러 발생시키지 않음
        }

        logger.info("로그아웃 완료: userId={}", userId);
    }

    // Access Token 재발급
    @Override
    @Transactional
    public TokenRefreshResponseDTO refreshAccessToken(String refreshToken) {
        logger.info("Access Token 재발급 요청");

        // 1. Refresh Token 유효성 검증
        if (!jwtTokenProvider.validateToken(refreshToken)) {
            logger.warn("토큰 재발급 실패 - 유효하지 않은 Refresh Token");
            throw new IllegalArgumentException("유효하지 않은 Refresh Token입니다. 다시 로그인해주세요.");
        }

        // 2. DB에서 해당 토큰을 가진 사용자 조회
        UserVO user = userMapper.findByRefreshToken(refreshToken);

        if (user == null) {
            logger.warn("토큰 재발급 실패 - DB에 일치하는 토큰 없음");
            throw new IllegalArgumentException("유효하지 않은 Refresh Token입니다. 다시 로그인해주세요.");
        }

        // 3. 새 Access Token 발급
        String newAccessToken = jwtTokenProvider.createAccessToken(
                user.getUserId(),
                user.getLoginId(),
                user.getUserType()
        );

        logger.info("Access Token 재발급 완료: userId={}", user.getUserId());

        return TokenRefreshResponseDTO.of(
                newAccessToken,
                jwtTokenProvider.getAccessTokenValidityInSeconds()
        );
    }

}
