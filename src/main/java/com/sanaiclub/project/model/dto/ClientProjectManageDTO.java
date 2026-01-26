package com.sanaiclub.project.model.dto;

import lombok.Data;
import java.util.Date;

@Data
public class ClientProjectManageDTO {
    private Integer projectId;
    private String title;
    private String projectStatus;
    private Date deadlineDate;
    private Integer applicantCount;
    private Date createdAt;
    private boolean hasPaymentRequest;
    private Integer clientRating;

    public Integer getdDay() {
        if (deadlineDate == null) return 0;

        long today = new Date().getTime();
        long deadline = deadlineDate.getTime();

        long diffSec = (deadline - today) / 1000;
        long diffDays = diffSec / (24 * 60 * 60);

        return (int) diffDays;
    }
}