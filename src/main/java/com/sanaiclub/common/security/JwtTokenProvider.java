package com.sanaiclub.common.security;

import com.sanaiclub.user.model.dto.LoginRequestDTO;
import com.sanaiclub.user.model.vo.UserType;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * JwtTokenProvider - JWT 토큰 생성/검증/파싱 유틸리티
 * ═══════════════════════════════════════════════════════════════════════
 *
 * [역할]
 * - Access Token / Refresh Token 생성
 * - 토큰 유효성 검증
 * - 토큰에서 사용자 정보 추출
 *
 * [보안 주의사항]
 * - SECRET_KEY는 절대 코드에 하드코딩하지 말 것!
 * - 환경변수 또는 외부 설정 파일에서 읽어올 것
 * - 최소 256비트(32자) 이상의 키 사용
 *
 * @author sanaiclub
 * @version 1.0
 */
@Component
public class JwtTokenProvider {

    private static final Logger logger = LoggerFactory.getLogger(JwtTokenProvider.class);

    /**
     * JWT 서명에 사용할 비밀키 (Base64 인코딩된 문자열)
     * - 최소 256비트(32자) 이상 권장
     */
    @Value("${jwt.secret}")
    private String secretKeyString;

    /**
     * Access Token 유효 시간 (밀리초)
     * - 기본값: 30분 (1800000ms)
     */
    @Value("${jwt.access-token-validity:1800000}")
    private long accessTokenValidity;

    /**
     * Refresh Token 유효 시간 (밀리초)
     * - 기본값: 7일 (604800000ms)
     */
    @Value("${jwt.refresh-token-validity:604800000}")
    private long refreshTokenValidity;

    /**
     * 서명에 사용할 SecretKey 객체
     * - 초기화 시 secretKeyString으로부터 생성
     */
    private SecretKey secretKey;

    // ═══════════════════════════════════════════════════════════════
    // 초기화
    // ═══════════════════════════════════════════════════════════════

    /**
     * 빈 생성 후 SecretKey 초기화
     *
     * [@PostConstruct 설명]
     * - 의존성 주입(@Value) 완료 후 실행되는 초기화 메서드
     * - 생성자에서는 @Value 값이 아직 주입되지 않음
     */
    @PostConstruct
    protected void init() {
        // 🔍 디버깅용 로그 (범인 색출)
        logger.warn("==================================================");
        logger.warn(">>> 현재 로드된 비밀키: [{}]", secretKeyString);
        logger.warn(">>> 키 길이: {} 글자", secretKeyString != null ? secretKeyString.length() : 0);
        logger.warn("==================================================");

        // 문자열 → SecretKey 변환
        this.secretKey = Keys.hmacShaKeyFor(secretKeyString.getBytes(StandardCharsets.UTF_8));
        logger.info("JwtTokenProvider 초기화 완료");
        logger.info("Access Token 유효시간: {}분", accessTokenValidity / 1000 / 60);
        logger.info("Refresh Token 유효시간: {}일", refreshTokenValidity / 1000 / 60 / 60 / 24);
    }

    // ═══════════════════════════════════════════════════════════════
    // 토큰 생성
    // ═══════════════════════════════════════════════════════════════

    /**
     * Access Token 생성
     *
     * [Payload에 담기는 정보 (Claims)]
     * - sub (subject): 사용자 식별자 (loginId)
     * - userId: 사용자 PK
     * - userType: FREELANCER / CLIENT
     * - iat (issued at): 발급 시간
     * - exp (expiration): 만료 시간
     *
     * [주의] Payload는 암호화가 아닌 인코딩!
     * - 민감정보(비밀번호 등) 절대 포함 금지
     * - 누구나 디코딩해서 볼 수 있음
     *
     * @param userId   사용자 PK
     * @param loginId  로그인 ID (subject로 사용)
     * @param userType 사용자 유형
     * @return Access Token 문자열
     */
    public String createAccessToken(Integer userId, String loginId, UserType userType) {
        Date now = new Date();
        Date expiration = new Date(now.getTime() + accessTokenValidity);

        return Jwts.builder()
                .setSubject(loginId)                          // sub: 토큰 주체 (사용자 식별)
                .claim("userId", userId)                      // 커스텀 클레임: 사용자 PK
                .claim("userType", userType.name())           // 커스텀 클레임: 사용자 유형
                .setIssuedAt(now)                             // iat: 발급 시간
                .setExpiration(expiration)                    // exp: 만료 시간
                .signWith(secretKey, SignatureAlgorithm.HS256) // 서명
                .compact();                                   // 토큰 문자열 생성
    }

    /**
     * Refresh Token 생성
     *
     * [Access Token과의 차이]
     * - 유효기간이 길다 (7일)
     * - 최소한의 정보만 포함 (userId만)
     * - DB에 저장하여 서버에서 관리/무효화 가능
     *
     * @param userId 사용자 PK
     * @return Refresh Token 문자열
     */
    public String createRefreshToken(Integer userId) {
        Date now = new Date();
        Date expiration = new Date(now.getTime() + refreshTokenValidity);

        return Jwts.builder()
                .setSubject(String.valueOf(userId))           // sub: userId
                .claim("type", "refresh")               // 토큰 타입 구분
                .setIssuedAt(now)
                .setExpiration(expiration)
                .signWith(secretKey, SignatureAlgorithm.HS256)
                .compact();
    }

    // ═══════════════════════════════════════════════════════════════
    // 토큰 검증
    // ═══════════════════════════════════════════════════════════════

    /**
     * 토큰 유효성 검증
     *
     * [검증 항목]
     * 1. 서명 검증: 토큰이 위변조되지 않았는지
     * 2. 만료 검증: 현재 시간이 exp 이전인지
     * 3. 형식 검증: JWT 형식에 맞는지
     *
     * @param token 검증할 토큰
     * @return 유효하면 true, 아니면 false
     */
    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder()
                    .setSigningKey(secretKey)
                    .build()
                    .parseClaimsJws(token);  // 파싱 성공 = 유효한 토큰
            return true;

        } catch (ExpiredJwtException e) {
            // 토큰 만료
            logger.warn("만료된 JWT 토큰입니다: {}", e.getMessage());
        } catch (MalformedJwtException e) {
            // 토큰 형식 오류
            logger.warn("잘못된 JWT 토큰 형식입니다: {}", e.getMessage());
        } catch (UnsupportedJwtException e) {
            // 지원하지 않는 토큰
            logger.warn("지원하지 않는 JWT 토큰입니다: {}", e.getMessage());
        } catch (SignatureException e) {
            // 서명 검증 실패 (위변조 의심)
            logger.warn("JWT 서명 검증에 실패했습니다: {}", e.getMessage());
        } catch (IllegalArgumentException e) {
            // 토큰이 비어있음
            logger.warn("JWT 토큰이 비어있습니다: {}", e.getMessage());
        }

        return false;
    }

    /**
     * 토큰 만료 여부만 확인
     * - 만료된 토큰에서도 정보 추출이 필요한 경우 사용
     * - 예: Refresh Token으로 재발급 시
     *
     * @param token 확인할 토큰
     * @return 만료되었으면 true
     */
    public boolean isTokenExpired(String token) {
        try {
            Claims claims = getClaims(token);
            return claims.getExpiration().before(new Date());
        } catch (ExpiredJwtException e) {
            return true;
        } catch (Exception e) {
            return true;
        }
    }


    // ═══════════════════════════════════════════════════════════════
    // 토큰 정보 추출
    // ═══════════════════════════════════════════════════════════════

    /**
     * 토큰에서 Claims(페이로드) 추출
     *
     * [Claims란?]
     * - JWT Payload에 담긴 정보들의 집합
     * - 표준 클레임: sub, iat, exp 등
     * - 커스텀 클레임: userId, userType 등
     *
     * @param token JWT 토큰
     * @return Claims 객체
     */
    public Claims getClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(secretKey)
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    /**
     * 토큰에서 로그인 ID(subject) 추출
     *
     * @param token JWT 토큰
     * @return 로그인 ID
     */
    public String getLoginId(String token) {
        return getClaims(token).getSubject();
    }

    /**
     * 토큰에서 사용자 ID 추출
     *
     * @param token JWT 토큰
     * @return 사용자 PK
     */
    public Integer getUserId(String token) {
        return getClaims(token).get("userId", Integer.class);
    }

    /**
     * 토큰에서 사용자 유형 추출
     *
     * @param token JWT 토큰
     * @return UserType (FREELANCER / CLIENT)
     */
    public UserType getUserType(String token) {
        String userTypeStr = getClaims(token).get("userType", String.class);
        return UserType.valueOf(userTypeStr);
    }

    /**
     * 만료된 토큰에서 Claims 추출
     * - 토큰 재발급 시 사용
     * - 만료되었어도 서명이 유효하면 정보 추출 가능
     *
     * @param token 만료된 JWT 토큰
     * @return Claims 객체
     */
    public Claims getClaimsFromExpiredToken(String token) {
        try {
            return getClaims(token);
        } catch (ExpiredJwtException e) {
            // 만료된 토큰에서도 Claims 추출 가능
            return e.getClaims();
        }
    }


    // ═══════════════════════════════════════════════════════════════
    // 유틸리티
    // ═══════════════════════════════════════════════════════════════

    /**
     * Access Token 유효 시간 반환 (초 단위)
     * - LoginResponseDTO.expiresIn에 사용
     *
     * @return 유효 시간 (초)
     */
    public long getAccessTokenValidityInSeconds() {
        return accessTokenValidity / 1000;
    }

    /**
     * Refresh Token 유효 시간 반환 (초 단위)
     *
     * @return 유효 시간 (초)
     */
    public long getRefreshTokenValidityInSeconds() {
        return refreshTokenValidity / 1000;
    }
}
