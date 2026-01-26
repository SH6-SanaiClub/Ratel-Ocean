package com.sanaiclub.project.model.dto;

import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.Date;

@Data
public class ClientProjectManageDTO {
    private Integer projectId;
    private String title;
    private String projectStatus;
    private LocalDateTime deadlineDate;
    private Integer applicantCount;
    private LocalDateTime createdAt;

    private boolean hasPaymentRequest; // 지급 요청 여부
    private Integer clientRating;      // 별점 (null이면 리뷰 안 쓴 것)

    public Integer getdDay() {
        if (deadlineDate == null) return 0;

        LocalDate today = LocalDate.now();
        LocalDate deadline = deadlineDate.toLocalDate();

        return (int) ChronoUnit.DAYS.between(today, deadline);
    }
}