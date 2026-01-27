package com.sanaiclub.user.model.dto;

import lombok.Data;
import java.util.List;

@Data
public class ClientStatsDTO {
    private double givenAvgRating;     // 내가 준 점수 평균
    private double receivedAvgRating;  // 내가 받은 점수 평균
    private int contractCount;         // 완료된 계약 수
    private List<ClientReviewHistoryDTO> reviewList;        // 내가 쓴 리뷰 리스트
    private List<ClientReviewHistoryDTO> receivedReviewList; // 내가 받은 리뷰 리스트
}