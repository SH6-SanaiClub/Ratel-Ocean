package com.sanaiclub.user.service.impl;

import com.sanaiclub.user.dao.ClientMyPageMapper; // (패키지명 맞는지 확인)
import com.sanaiclub.user.model.dto.ClientMyPageDTO;
import com.sanaiclub.user.model.vo.CompanySize;
import com.sanaiclub.user.service.ClientMyPageService;
import com.sanaiclub.user.model.vo.CompanyVO;
import com.sanaiclub.user.model.vo.UserVO;

import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.time.LocalDate;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ClientMyPageServiceImpl implements ClientMyPageService {

    private final ClientMyPageMapper mapper;
    private final PasswordEncoder passwordEncoder;

    // 프로필 이미지 저장 경로
    private static final String PROFILE_UPLOAD_DIR = "D:\\workspace\\Ratel-Ocean\\src\\main\\webapp\\resources\\upload\\profile\\";

    @Override
    public ClientMyPageDTO getClientProfile(Integer userId) {
        return mapper.selectClientProfile(userId);
    }

    @Override
    @Transactional
    public void updateProfile(ClientMyPageDTO dto, MultipartFile file) throws Exception {
        // 1. 파일 업로드 처리
        if (file != null && !file.isEmpty()) {
            dto.setProfileImageUrl(uploadFile(file));
        }

        // 2. [DTO -> UserVO 변환] 유저 정보 수정
        UserVO userVO = new UserVO();
        userVO.setUserId(dto.getUserId());
        userVO.setName(dto.getName());
        userVO.setPhone(dto.getPhone());
        userVO.setProfileImageUrl(dto.getProfileImageUrl()); // 파일 경로가 있으면 세팅됨

        mapper.updateUserInfo(userVO);

        // 3. [DTO -> CompanyVO 변환] 회사 정보 수정 (법인/정보 있을 때만)
        if ("CORPORATION".equals(dto.getClientType()) || (dto.getCompanyName() != null && !dto.getCompanyName().isEmpty())) {

            // DTO에 회사 ID가 없으면 DB에서 찾음
            Integer companyId = dto.getCompanyId();
            if (companyId == null) {
                companyId = mapper.selectCompanyIdByClientId(dto.getUserId());
            }

            if (companyId != null) {
                CompanyVO companyVO = new CompanyVO();
                companyVO.setCompanyId(companyId);
                companyVO.setCompanyName(dto.getCompanyName());
                companyVO.setCeoName(dto.getCeoName());
                companyVO.setBusinessNumber(dto.getBusinessNumber());
                companyVO.setIndustry(dto.getIndustry());
                companyVO.setAddress(dto.getAddress());
                companyVO.setWebsiteUrl(dto.getWebsiteUrl());

                // CompanyVO로 업데이트 실행
                mapper.updateCompanyInfo(companyVO);
            }
        }
    }

    @Override
    @Transactional
    public boolean updatePassword(Integer userId, String currentPw, String newPw) {
        // 1. DB 비밀번호 조회
        String dbPassword = mapper.selectPassword(userId);

        // 2. 현재 비밀번호 일치 확인
        if (!passwordEncoder.matches(currentPw, dbPassword)) {
            return false;
        }

        // 3. 새 비밀번호 암호화 후 업데이트
        String encodedNewPw = passwordEncoder.encode(newPw);
        mapper.updatePassword(userId, encodedNewPw);
        return true;
    }

    // 파일 업로드 유틸 메서드
    private String uploadFile(MultipartFile file) throws Exception {
        File dir = new File(PROFILE_UPLOAD_DIR);
        if (!dir.exists()) dir.mkdirs();

        String savedName = UUID.randomUUID() + "_" + file.getOriginalFilename();
        file.transferTo(new File(dir, savedName));
        return "/resources/upload/profile/" + savedName;
    }

    @Override
    @Transactional
    public void updateCompanyProfile(ClientMyPageDTO dto) {
        if (dto.getCompanyId() != null) {
            CompanyVO vo = CompanyVO.builder()
                    .companyId(dto.getCompanyId())
                    .companyName(dto.getCompanyName())
                    .ceoName(dto.getCeoName())
                    .businessNumber(dto.getBusinessNumber())
                    .industry(dto.getIndustry())
                    .address(dto.getAddress())
                    .websiteUrl(dto.getWebsiteUrl())
                    .build();
            mapper.updateCompanyInfo(vo);
        }
    }
}