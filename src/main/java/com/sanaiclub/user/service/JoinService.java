package com.sanaiclub.user.service;

import com.sanaiclub.user.model.dto.*;
import org.springframework.transaction.annotation.Transactional;

public interface JoinService {

    // 아이디 중복 체크
    boolean isIdDuplicate(String loginId);

    // 이메일 중복 체크
    boolean isEmailDuplicate(String email);

    @Transactional(rollbackFor = Exception.class)
    boolean signUpFreelancer(UserDefaultDTO userDto, FreelancerProfileDTO freeDto, AccountDTO accountDto) throws Exception;

    @Transactional(rollbackFor = Exception.class)
    boolean signUpClient(UserDefaultDTO userDto, ClientProfileDTO clientDto, AccountDTO accountDto) throws Exception;
}