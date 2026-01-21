package com.sanaiclub.user.model.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ClientProfileDTO {
    // 기업 정보 (companies 테이블)
    private String companyName;     // 회사명
    private String ceoName;         // 대표자명
    private String businessNumber;  // 사업자등록번호
    private String industry;        // 업종
    private String address;         // 주소
    private String companySize;     // 기업 규모 (STARTUP, SMALL, MEDIUM...)
    private String websiteUrl;      // 회사 홈페이지

    // 클라이언트 프로필 (client_profiles 테이블)
    private String clientType;      // 유형 (GENERAL, PERSONAL, CORPORATION)
}