package com.sanaiclub.project.model.dto;

import lombok.Data;

import java.time.LocalDateTime;
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
    private LocalDateTime appliedAt;

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

    // 포트폴리오 URL
    private String portfolioUrl;

    // 평점
    private Double rating;

    // === 1:N 관계 데이터 ===
    private List<String> skills;
    private List<CareerDTO> careers;
    private List<ProjectExpDTO> projects;

    @Data
    public static class CareerDTO {
        private String companyName;
        private String role;
        private LocalDateTime startDate;
        private LocalDateTime endDate;
        private String description;
    }

    @Data
    public static class ProjectExpDTO {
        private String title;
        private String clientName;
        private LocalDateTime startDate;
        private LocalDateTime endDate;
        private String description;
    }
}