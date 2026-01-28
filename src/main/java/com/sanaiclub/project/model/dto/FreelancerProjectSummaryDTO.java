package com.sanaiclub.project.model.dto;

import lombok.Data;

@Data
public class FreelancerProjectSummaryDTO {
    private int inProgressCount;
    private int appliedCount;
    private int completedCount;

    // 진행중 계약 총액 합 (예상 수익 느낌)
    private Long expectedRevenue;
}