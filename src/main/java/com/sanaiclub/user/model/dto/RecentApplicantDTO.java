package com.sanaiclub.user.model.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class RecentApplicantDTO {
    private Integer applicationId;
    private Integer freelancerId;
    private String freelancerName; // 프리랜서 이름
    private String profileTitle;   // 직무 제목 (예: 백엔드 개발자)
    private Integer careerYear;    // 경력 연수
    private String projectTitle;   // 지원한 프로젝트 제목
    private Double rating;         // 평점
    private LocalDateTime appliedAt; // 지원 일시
}