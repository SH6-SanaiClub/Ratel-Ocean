package com.sanaiclub.contract.model.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Getter;
import lombok.Setter;

/**
 * 마일스톤 응답 DTO
 * 
 * [역할]
 * - 마일스톤 정보를 응답할 때 사용
 * - ContractResponseDTO의 milestones 필드에 포함
 * 
 * [주요 필드]
 * - step: 단계 번호
 * - title: 마일스톤 제목
 * - description: 마일스톤 설명
 * - amount: 마일스톤 금액
 */
@Getter
@Setter
@JsonIgnoreProperties(ignoreUnknown = true)
public class ContractMilestoneResponseDTO {
    private Integer step;
    private String title;
    private String description;
    private Long amount;
}
