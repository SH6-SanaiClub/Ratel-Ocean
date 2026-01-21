package com.sanaiclub.project.model.dto;

import com.sanaiclub.project.model.vo.ProjectsVO;
import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@ToString(callSuper = true)
public class ProjectDetailDTO extends ProjectsVO {

    private Boolean budgetNegotiable;   // 예산 협의 여부
    private Boolean durationNegotiable; // 기간 협의 여부
    private String planUrl;             // 기획서 파일

    private List<RequiredStackDTO> stacks; // 기술 스택

    private boolean isApplied;    // 지원 여부
    private boolean isWishlisted; // 찜 여부

    private String clientName;  // 개인 이름
    private String companyName; // 회사명
    private String clientType;  // 유형
    private String companyIndustry; // 업종

    // DTO 생성 편의 메서드
    public static ProjectDetailDTO of(Boolean budgetNegotiable,
                                      Boolean durationNegotiable,
                                      String planUrl,
                                      List<RequiredStackDTO> stacks) {
        return ProjectDetailDTO.builder()
                .budgetNegotiable(budgetNegotiable)
                .durationNegotiable(durationNegotiable)
                .planUrl(planUrl)
                .stacks(stacks)
                .build();
    }
}