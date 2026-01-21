package com.sanaiclub.project.model.dto;

import com.sanaiclub.project.model.vo.ProjectsVO;
import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@ToString(callSuper = true) // 부모 클래스(ProjectsVO)의 데이터까지 출력
public class ProjectDetailDTO extends ProjectsVO {

    private Boolean budgetNegotiable;   // 예산 협의 가능 여부
    private Boolean durationNegotiable; // 기간 협의 가능 여부
    private String planUrl;             // 기획서 파일 경로

    private List<RequiredStackDTO> stacks; // 기술 스택 목록

    private boolean isApplied;    // 지원 여부
    private boolean isWishlisted; // 찜하기 여부

    /**
     * DTO 생성 편의 메서드
     * * @param budgetNegotiable 예산 협의 여부
     * @param durationNegotiable 기간 협의 여부
     * @param planUrl 기획서 경로
     * @param stacks 기술 스택
     * @return ProjectDetailDTO
     */
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