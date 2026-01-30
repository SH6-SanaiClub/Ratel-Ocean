package com.sanaiclub.user.dao;

import com.sanaiclub.user.model.dto.ClientMyPageDTO;
import com.sanaiclub.user.model.vo.CompanyVO;
import com.sanaiclub.user.model.vo.UserVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface FreelancerMyPageMapper {
    UserVO selectFreelancerProfile(Integer userId);

    void updateUserInfo(UserVO userVO);

    String selectPassword(Integer userId);

    void updatePassword(@Param("userId") Integer userId,
                        @Param("newPassword") String newPassword);
}

