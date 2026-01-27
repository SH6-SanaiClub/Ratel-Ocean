package com.sanaiclub.user.model.dto;

import lombok.Data;
import java.util.List;

@Data
public class ClientStatsDTO {
    private double avgRating;          // 평균 평점
    private int contractCount;         // 완료된 계약 수

    // 방금 만든 DTO를 리스트로 사용
    private List<ClientReviewHistoryDTO> reviewList;
}