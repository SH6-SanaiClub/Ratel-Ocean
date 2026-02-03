package com.sanaiclub.project.model.dto;

import lombok.Data;

@Data
public class FreelancerProjectCardDTO {
    private Integer projectId;
    private Integer applicationId; // contract_id = application_id (지원과 1:1)
    private Integer contractId;

    private String title;
    private String clientName;

    private String badgeText;      // 예: "계약 진행중", "지원중", "완료"
    private String applicationStatus; // PENDING/VIEWED/...
    private String contractStatus; // SIGNED/COMPLETED/...

    private String startDate;      // yyyy-mm-dd
    private String endDate;

    private String nextMilestoneName;
    private String nextMilestoneDueDate; // yyyy-mm-dd

    private Integer progressPercent; // milestone 기반(0~100)

    private Long totalBudget;
    private Integer dday; // 마감(D-day)용 (endDate - today)

    private Integer clientRating;        // contracts.client_rating
    private String  clientExperience;    // contracts.client_experience

    private Integer freelancerRating;    // contracts.freelancer_rating
    private String  freelancerExperience;// contracts.freelancer_experience
}