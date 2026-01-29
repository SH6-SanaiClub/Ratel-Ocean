package com.sanaiclub.user.service.impl;

import com.sanaiclub.user.dao.ClientMyPageMapper;
import com.sanaiclub.user.dao.FreelancerMyPageMapper;
import com.sanaiclub.user.model.dto.ClientMyPageDTO;
import com.sanaiclub.user.model.vo.CompanyVO;
import com.sanaiclub.user.model.vo.UserVO;
import com.sanaiclub.user.service.FreelancerMyPageService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
public class FreelancerMyPageServiceImpl implements FreelancerMyPageService {

    private final FreelancerMyPageMapper mapper;
    private final PasswordEncoder passwordEncoder;

    @Override
    public UserVO getFreelancerProfile(Integer userId) {
        return mapper.selectFreelancerProfile(userId);
    }

    @Override
    @Transactional
    public void updateProfile(UserVO userVO) {
        mapper.updateUserInfo(userVO);
    }

    @Override
    @Transactional
    public boolean updatePassword(Integer userId, String currentPw, String newPw) {
        String dbPassword = mapper.selectPassword(userId);

        if (!passwordEncoder.matches(currentPw, dbPassword)) return false;

        String encodedNewPw = passwordEncoder.encode(newPw);
        mapper.updatePassword(userId, encodedNewPw);
        return true;
    }

}
