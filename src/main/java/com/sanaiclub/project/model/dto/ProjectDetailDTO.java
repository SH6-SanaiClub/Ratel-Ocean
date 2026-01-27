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


    private boolean isApplied;      // 화면 표시용 (CANCELED가 아니면 true)
    private String applicationStatus; // 상세 상태 (PENDING, CANCELED 등)
    private boolean isWishlisted; // 찜 여부

    private String clientName;  // 개인 이름
    private String companyName; // 회사명
    private String clientType;  // 유형
    private String companyIndustry; // 업종

    private Integer minLevel;           // 요구 숙련도
    private Integer minYear;            // 필요 경력
    private String communicateMethod;   // 미팅 방식 (ONLINE, OFFLINE)
    private String paymentMethod;       // 대금 지급 (LUMP_SUM, INSTALLMENT)
    private Integer maxRevisionCount;   // 수정 횟수
    private String changePolicy;        // 수정 정책

    private Integer completedContractCount;  // 클라이언트 계약 건수
    private Double clientAvgRating;     // 클라이언트 평균 평점
    private String clientProfileImageUrl;   // 클라이언트 프로필 이미지 URL

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