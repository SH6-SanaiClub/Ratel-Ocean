package com.sanaiclub.project.model.dto;

import lombok.Data;
import java.util.Date;
import java.util.List;

@Data
public class ClientApplicantDTO {
    // === 기본 정보 ===
    private Integer applicationId;
    private Integer freelancerId;
    private Integer projectId;
    private String freelancerName;
    private String applicationStatus;
    private Date appliedAt;

    // === 리스트용 요약 ===
    private String mainSkill;
    private Integer careerYear;
    private String profileImageUrl;

    // === 상세 정보 ===
    private String email;
    private String introduction;
    private String githubUrl;
    private String websiteUrl;
    private String schoolName;
    private String major;
    private String graduationStatus; // 졸업 여부 (예: 졸업, 재학, 휴학)

    // 포트폴리오 URL
    private String portfolioUrl;

    // 평점 (계약 테이블에서 계산된 평균 값)
    private Double rating;

    // === 1:N 관계 데이터 ===
    private List<String> skills;
    private List<CareerDTO> careers;
    private List<ProjectExpDTO> projects;

    @Data
    public static class CareerDTO {
        private String companyName;
        private String role;
        private Date startDate;
        private Date endDate;
        private String description;
    }

    @Data
    public static class ProjectExpDTO {
        private String title;
        private String clientName;
        private Date startDate;
        private Date endDate;
        private String description;
    }
}