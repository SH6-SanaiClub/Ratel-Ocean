package com.sanaiclub.user.model.dto;

import lombok.Data;

@Data
public class ClientMyPageDTO {
    // 1. 유저 정보
    private Integer userId;
    private String loginId;
    private String email;
    private String name;
    private String phone;
    private String profileImageUrl;
    private String userStatus;

    // 2. 클라이언트 정보
    private String clientType;

    // 3. 회사 정보
    private Integer companyId;
    private String companyName;
    private String ceoName;
    private String businessNumber;
    private String industry;
    private String address;
    private String websiteUrl;

    // 4. 통계 및 리뷰 정보
    private ClientStatsDTO stats;

    // 5. 비밀번호 변경용
    private String currentPassword;
    private String newPassword;
}