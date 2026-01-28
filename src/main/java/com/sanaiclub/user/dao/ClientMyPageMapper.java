package com.sanaiclub.user.dao;

import com.sanaiclub.user.model.dto.ClientMyPageDTO;
import com.sanaiclub.user.model.vo.CompanyVO;
import com.sanaiclub.user.model.vo.UserVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ClientMyPageMapper {

    // 프로필 조회
    ClientMyPageDTO selectClientProfile(Integer userId);

    // 유저 정보 수정
    void updateUserInfo(UserVO userVO);

    // 회사 정보 수정
    void updateCompanyInfo(CompanyVO companyVO);

    // 비밀번호 조회/변경
    String selectPassword(Integer userId);
    void updatePassword(@Param("userId") Integer userId, @Param("newPassword") String newPassword);

    // 유저 ID로 연결된 회사 ID 찾기
    Integer selectCompanyIdByClientId(Integer clientId);
}