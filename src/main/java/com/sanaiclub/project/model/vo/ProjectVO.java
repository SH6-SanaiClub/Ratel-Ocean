package com.sanaiclub.project.model.vo;

import lombok.Data;
import java.sql.Date;
import java.time.LocalDateTime;

@Data
public class ProjectVO {
    private Integer projectId;
    private Integer clientId;
    private String title;
    private String description;
    private Date startDate;
    private Date deadlineDate;
    private String estDuration;
    private Boolean durationNegotiable;
    private Integer budget;
    private Boolean budgetNegotiable;
    private String communicateMethod;
    private String paymentMethod;
    private String changePolicy;
    private Integer maxRevisionCount;
    private ProjectStatus projectStatus;
    private Boolean isPublic;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Integer viewCount;
    private Integer applicantCount;
    private String planUrl;
    private String fileSize;
}