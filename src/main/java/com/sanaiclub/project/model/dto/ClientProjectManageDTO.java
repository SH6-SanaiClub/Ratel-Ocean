package com.sanaiclub.project.model.dto;

import lombok.Data;
import java.util.Date;

@Data
public class ClientProjectManageDTO {
    private Integer projectId;
    private String title;
    private String projectStatus;
    private Date deadlineDate;
    private Integer applicantCount;     // 총 지원자 수
    private Integer newApplicantCount;  // 새로운(미열람) 지원자 수
    private Date createdAt;

    private boolean hasPaymentRequest; // 지급 요청 여부
    private Integer clientRating;      // 별점

    public Integer getdDay() {
        if (deadlineDate == null) return 0;

        long today = new Date().getTime();
        long deadline = deadlineDate.getTime();

        long diffSec = (deadline - today) / 1000;
        long diffDays = diffSec / (24 * 60 * 60);

        return (int) diffDays;
    }
}