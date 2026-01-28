package com.sanaiclub.user.model.dto;

import lombok.Data;

@Data
public class ClientReviewHistoryDTO {
    // 기본 정보
    private String freelancerName;   // 프리랜서 이름
    private Integer rating;          // 평점
    private String content;          // 리뷰 내용
    private String contractedAt;     // 계약일

    // 상세 정보 (화면 이동 및 표시용)
    private Integer freelancerId;       // 프로필 이동용 ID
    private String projectTitle;        // 프로젝트 제목
    private String startDate;           // 시작일
    private String endDate;             // 종료일
    private Long budget;                // 예산
    private Boolean recontractIntended; // 재계약 의사
}