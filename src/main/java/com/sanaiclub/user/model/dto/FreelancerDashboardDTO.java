package com.sanaiclub.user.model.dto;

import lombok.Data;
import java.util.List;

@Data
public class FreelancerDashboardDTO {
    // 상단 카드용
    private int ongoingProjects;
    private long totalEarnings;
    private int pendingApplications;
    private long walletBalance;

    // 차트 및 리스트용 (추가된 필드)
    private List<String> monthlyLabels;      // 월별 수익 차트 X축
    private List<Long> monthlyData;          // 월별 수익 차트 Y축
    private List<Integer> statusCounts;      // 완료율 차트 데이터 [완료, 진행, 취소]
    private List<FreelancerProjectDTO> recentProjects; // 최근 지원한 프로젝트 리스트
}