package com.sanaiclub.project.model.dto;

import lombok.Data;
import java.util.Date;
import java.time.temporal.ChronoUnit;

@Data
public class ClientProjectManageDTO {
    private Integer projectId;
    private String title;
    private String projectStatus;
    private Date deadlineDate;
    private Integer applicantCount;
    private Date createdAt;

    public long getdDay() {
        if (deadlineDate == null) return 0;

        long now = new Date().getTime();
        long deadline = deadlineDate.getTime();
        long gap = deadline - now;

        // 밀리초 -> 일(Day) 변환
        return gap / (1000 * 60 * 60 * 24);
    }
}