package com.sanaiclub.domain.freelancer.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 프리랜서 DTO
 * Spring MVC Legacy에서 사용하는 프리랜서 데이터 전송 객체
 */
@Data
public class FreelancerDTO {
    
    // 기본 정보
    private Long freelancerId;
    private String name;
    private String email;
    private String phoneNumber;
    
    // 전문성 정보
    private String expertise;
    private String skills;
    private Integer experienceYears;
    private String portfolioUrl;
    
    // 평가 정보
    private BigDecimal rating;
    private Integer completedProjects;
    private Integer totalProjects;
    
    // 상태 정보
    private String status;
    private String availability;
    
    // 메타 정보
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
