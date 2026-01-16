package com.sanaiclub.user.dao;

import com.sanaiclub.user.model.vo.UserVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UserMapper {

    // ═══════════════════════════════════════════════════════════════
    // 조회 (SELECT) - 로그인/인증용
    // ═══════════════════════════════════════════════════════════════

    /**
     * 로그인 ID로 사용자 조회
     */
    UserVO findByLoginId(@Param("loginId") String loginId);

    /**
     * 사용자 PK로 조회
     */
    UserVO findByUserId(@Param("userId") Integer userId);

    /**
     * 이메일로 사용자 조회
     * - 이메일 로그인 기능 추가 시 사용
     * - 비밀번호 찾기 등에 활용
     */
    UserVO findByEmail(@Param("email") String email);

    /**
     * Refresh Token으로 사용자 조회
     * - 토큰 재발급 시 해당 토큰의 소유자 확인
     */
    UserVO findByRefreshToken(@Param("refreshToken") String refreshToken);

    // ═══════════════════════════════════════════════════════════════
    // 수정 (UPDATE) - 토큰 관리용
    // ═══════════════════════════════════════════════════════════════

    /**
     * Refresh Token 저장/갱신
     * - 로그인 성공 시: 새 토큰 저장
     * - 토큰 재발급 시: 새 토큰으로 갱신
     * - 로그아웃 시: null로 설정하여 무효화
     *
     * [@Param 어노테이션]
     * - 파라미터가 2개 이상일 때 필수
     * - XML에서 #{userId}, #{refreshToken}으로 참조
     *
     * @param userId       사용자 PK
     * @param refreshToken 저장할 Refresh Token (로그아웃 시 null)
     * @return 수정된 행 수 (정상이면 1)
     */
    int updateRefreshToken(@Param("userId") Integer userId,
                           @Param("refreshToken") String refreshToken);

    // ═══════════════════════════════════════════════════════════════
    // 존재 확인 - 중복 검사용 (회원가입에서 주로 사용)
    // ═══════════════════════════════════════════════════════════════

    /**
     * 로그인 ID 중복 확인
     *
     * @param loginId 확인할 로그인 ID
     * @return 존재하면 true
     */
    boolean existsByLoginId(@Param("loginId") String loginId);

    /**
     * 이메일 중복 확인
     *
     * @param email 확인할 이메일
     * @return 존재하면 true
     */
    boolean existsByEmail(@Param("email") String email);

    // ═══════════════════════════════════════════════════════════════
    // 등록 (INSERT) - 회원가입
    // ═══════════════════════════════════════════════════════════════

    /**
     * 신규 사용자 등록
     *
     * @param user 등록할 사용자 정보
     * @return 등록된 행 수 (정상이면 1)
     */
    int insertUser(UserVO user);
}
