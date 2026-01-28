package com.sanaiclub.project.model.dto;

import lombok.Data;

/**
 * 프리랜서 프로젝트 관리 좌측 목록 카드용 DTO
 */
@Data
public class FreelancerBoardProjectDTO {
    private Integer projectId;
    private Integer applicationId;
    private Integer contractId;

    private String title;
    private String clientName;
    private String companyName;

    // contracts.contract_status
    private String contractStatus;

    private String startDate; // yyyy-MM-dd
    private String endDate;   // yyyy-MM-dd
    private Integer dday;

    // 리뷰 존재 여부
    private Integer hasFreelancerReview;
    private Integer hasClientReview;
}
