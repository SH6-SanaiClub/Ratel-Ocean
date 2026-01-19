package com.sanaiclub.domain.user.mapper;

import com.sanaiclub.domain.user.dto.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * User Mapper Interface
 */
@Mapper
public interface UserMapper {
    
    /**
     * 이메일로 사용자 조회
     */
    User findByEmail(@Param("email") String email);
    
    /**
     * login_id로 사용자 조회
     */
    User findByLoginId(@Param("loginId") String loginId);
    
    /**
     * 이메일과 비밀번호로 사용자 조회 (로그인)
     */
    User findByEmailAndPassword(@Param("email") String email, @Param("password") String password);
    
    /**
     * 신규 사용자 등록
     */
    int insertUser(User user);
    
    /**
     * 이메일 중복 확인
     */
    int countByEmail(@Param("email") String email);
    
    /**
     * loginId 중복 확인
     */
    int countByLoginId(@Param("loginId") String loginId);
}
