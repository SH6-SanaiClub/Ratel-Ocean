package com.sanaiclub.project.model.dto;

import java.util.List;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProjectDashboardCardDTO {
    private Long projectId;
    private String title;

    private String estDuration;
    private Integer applicantCount;
    private Long budget;

    private Integer dday;        // DATEDIFF(deadline_date, CURDATE())
    private String deadlineDate; // 화면 표시용

    private List<RequiredStackDTO> stacks;
}