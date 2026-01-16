package com.sanaiclub.user.dao;

import com.sanaiclub.user.model.vo.UserVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UserMapper {

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
     */
    UserVO findByEmail(@Param("email") String email);

    /**
     * Refresh Token으로 사용자 조회
     */
    UserVO findByRefreshToken(@Param("refreshToken") String refreshToken);

    /**
     * Refresh Token 저장/갱신
     * - 로그인 성공 시: 새 토큰 저장
     * - 토큰 재발급 시: 새 토큰으로 갱신
     * - 로그아웃 시: null로 설정하여 무효화
     *
     * @param userId       사용자 PK
     * @param refreshToken 저장할 Refresh Token (로그아웃 시 null)
     * @return 수정된 행 수 (정상이면 1)
     */
    int updateRefreshToken(@Param("userId") Integer userId,
                           @Param("refreshToken") String refreshToken);

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

    /**
     * 신규 사용자 등록
     *
     * @param user 등록할 사용자 정보
     * @return 등록된 행 수 (정상이면 1)
     */
    int insertUser(UserVO user);
}
