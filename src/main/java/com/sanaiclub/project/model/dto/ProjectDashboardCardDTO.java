package com.sanaiclub.project.model.dto;

import java.util.List;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProjectDashboardCardDTO {
    private Integer projectId;
    private String title;

    private String estDuration;
    private Integer applicantCount;
    private Integer budget;

    private Integer dday;
    private String deadlineDate;

    private List<RequiredStackDTO> stacks;

    private Boolean bookmarked;

    private String companyName;  // 클라이언트 회사명
    private String clientName;   // 클라이언트 이름 ( 개인 클라이언트의 경우 )
}