package com.sanaiclub.user.model.dto;

import lombok.Data;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

@Data
public class RecentProjectDTO {
    private Integer projectId;
    private String title;
    private String projectStatus; // 'RECRUITING', 'ONGOING' 등
    private Integer budget;
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer applicantCount; // 지원자 수

    // 기간(개월 수) 계산 메서드 (JSP에서 사용)
    public long getDurationMonths() {
        if (startDate == null || endDate == null) return 0;
        long months = ChronoUnit.MONTHS.between(startDate, endDate);
        return months > 0 ? months : 1; // 최소 1개월로 표시
    }
}