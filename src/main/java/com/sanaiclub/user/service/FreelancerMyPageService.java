package com.sanaiclub.user.service;

import com.sanaiclub.user.model.dto.ClientMyPageDTO;
import com.sanaiclub.user.model.vo.UserVO;
import org.springframework.web.multipart.MultipartFile;

public interface FreelancerMyPageService {

    UserVO getFreelancerProfile(Integer userId);
    void updateProfile(UserVO userVO);
    boolean updatePassword(Integer userId, String currentPw, String newPw);
}
