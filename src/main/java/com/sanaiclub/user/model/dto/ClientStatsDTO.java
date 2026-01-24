package com.sanaiclub.user.model.dto;

import lombok.Data;
import java.util.List;

@Data
public class ClientStatsDTO {
    private double avgRating;          // 평균 평점 (contracts.client_rating)
    private int contractCount;         // 완료된 계약 수 (contracts.contract_status = 'COMPLETED')

    // 리뷰 리스트
    private List<ReviewDTO> reviewList;

    // 내부 클래스: 개별 리뷰 데이터
    @Data
    public static class ReviewDTO {
        private String freelancerName;   // 프리랜서 이름
        private int rating;              // 평점
        private String content;          // 리뷰 내용 (client_experience)
        private String contractedAt;     // 계약일
    }
}