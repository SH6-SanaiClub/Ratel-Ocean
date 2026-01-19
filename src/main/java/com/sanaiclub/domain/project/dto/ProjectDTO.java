package com.sanaiclub.domain.project.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 프로젝트 DTO
 * Spring MVC Legacy에서 사용하는 프로젝트 데이터 전송 객체
 */
@Data
public class ProjectDTO {
    
    // 기본 정보
    private Long projectId;
    private String title;
    private String description;
    private String category;
    private String status;
    
    // 예산 정보
    private BigDecimal budget;
    private String budgetType;
    
    // 기간 정보
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer duration;
    
    // 기술 스택
    private String techStack;
    
    // 클라이언트 정보
    private Long clientId;
    private String clientName;
    private String clientEmail;
    
    // 메타 정보
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String createdBy;
    private String updatedBy;
}
