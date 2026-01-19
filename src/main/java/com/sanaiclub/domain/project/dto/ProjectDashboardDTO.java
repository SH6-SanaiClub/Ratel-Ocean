package com.sanaiclub.domain.project.dto;

import lombok.Data;
import java.util.List;

@Data
public class ProjectDashboardDTO {
    private Integer projectId;
    private String title;
    private String estDuration;
    private Integer budget;
    private Integer applicantCount;
    private Integer dday;
    private List<StackDto> stacks;
}
