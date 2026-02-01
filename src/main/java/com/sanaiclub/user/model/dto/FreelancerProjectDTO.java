package com.sanaiclub.user.model.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class FreelancerProjectDTO {
    private Integer projectId;
    private String title;           // 프로젝트명
    private Integer budget;         // 예산
    private String estDuration;     // 예상 기간
    private String applicationStatus; // 지원 상태 (PENDING, REJECTED, ACCEPTED)
    private LocalDateTime appliedAt;  // 지원 일시
}