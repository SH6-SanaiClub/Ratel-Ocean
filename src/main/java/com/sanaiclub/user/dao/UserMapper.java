package com.sanaiclub.user.dao;

import com.sanaiclub.user.model.vo.UserVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UserMapper {
    // 1. 회원 정보 저장
    int insertUser(UserVO user);

    // 2. 아이디 중복 체크 (존재하면 1, 없으면 0 반환)
    int checkId(@Param("loginId") String loginId);

    // 3. 이메일 중복 체크
    int checkEmail(@Param("email") String email);
}