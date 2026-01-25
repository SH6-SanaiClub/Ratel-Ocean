package com.sanaiclub.user.service;

import com.sanaiclub.user.model.dto.ClientMyPageDTO;
import org.springframework.web.multipart.MultipartFile;

public interface ClientMyPageService {

    // 프로필 조회
    ClientMyPageDTO getClientProfile(Integer userId);

    // 프로필 수정 (파일 업로드 포함)
    void updateProfile(ClientMyPageDTO dto, MultipartFile file) throws Exception;

    // 비밀번호 변경
    boolean updatePassword(Integer userId, String currentPw, String newPw);

    void updateCompanyProfile(ClientMyPageDTO dto);
}