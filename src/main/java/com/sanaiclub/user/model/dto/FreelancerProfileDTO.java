package com.sanaiclub.user.model.dto;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
public class FreelancerProfileDTO {
    private String nickname;        // 활동명
    private String introduction;    // 자기소개
    private String schoolName;      // 학교명
    private String major;           // 전공
    private String degree;          // 학위
    private String gradStatus;      // 졸업 상태
    private String githubUrl;       // 깃허브 주소
    private String websiteUrl;      // 포트폴리오 URL
}