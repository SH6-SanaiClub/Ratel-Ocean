package com.sanaiclub.portfolio.model.dto;

import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CompletedPlatformProjectDTO {

    private Integer contractId;
    private Integer applicationId;
    private Integer projectId;

    private String projectTitle;
    private String clientName;

    private String completedDate;     // yyyy-MM-dd
    private Long totalBudget;         // 금액은 프로젝트에서도 Long 쓰고 있음(유지)

    private Integer clientRating;     // 1~5, null 가능
    private String clientExperience;  // 한줄/후기

    private List<CompletedProjectStackDTO> stacks; // 지원 시 선택 스택
}
