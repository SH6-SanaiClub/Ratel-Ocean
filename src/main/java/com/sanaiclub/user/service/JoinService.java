package com.sanaiclub.user.service;

import com.sanaiclub.user.model.dto.*;
import org.springframework.transaction.annotation.Transactional;

public interface JoinService {

    // 아이디 중복 확인
    boolean isIdDuplicate(String loginId);

    // 이메일 중복 확인
    boolean isEmailDuplicate(String email);

    // 사업자 번호 중복 확인
    boolean isBusinessNumberDuplicate(String businessNumber);

    // 프리랜서 회원가입
    @Transactional(rollbackFor = Exception.class)
    boolean signUpFreelancer(UserSignupRequestDTO userDto, FreelancerProfileDTO freeDto, AccountDTO accountDto) throws Exception;

    // 클라이언트 회원가입 (개인)
    @Transactional(rollbackFor = Exception.class)
    boolean signUpClientPersonal(UserSignupRequestDTO userDto, AccountDTO accountDto) throws Exception;

    // 클라이언트 회원가입 (법인)
    @Transactional(rollbackFor = Exception.class)
    boolean signUpClientCorporation(UserSignupRequestDTO userDto, CompanyRegistrationDTO companyDto, AccountDTO accountDto) throws Exception;
}