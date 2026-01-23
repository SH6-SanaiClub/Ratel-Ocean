package com.sanaiclub.contract.model.dto;

import lombok.Getter;
import lombok.Setter;

/**
 * 마일스톤 요청 DTO
 * 
 * [역할]
 * - 마일스톤 정보를 요청/수정할 때 사용
 * - MILESTONE 타입 계약에서 사용
 * 
 * [주요 필드]
 * - step: 단계 번호 (1부터 시작)
 * - title: 마일스톤 제목
 * - description: 마일스톤 설명
 * - amount: 마일스톤 금액
 */
@Getter
@Setter
public class ContractMilestoneRequestDTO {
    private Integer step;
    private String title;
    private String description;
    private Long amount;
}
