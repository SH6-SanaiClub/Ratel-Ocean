package com.sanaiclub.contract.model.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Getter;
import lombok.Setter;

/**
 * ============================================================================
 * ContractMilestoneResponseDTO - 마일스톤 응답 DTO
 * ============================================================================
 * 
 * [역할]
 * - 마일스톤 정보를 응답할 때 사용하는 데이터 전송 객체
 * - ContractResponseDTO의 milestones 필드에 포함
 * - Service 계층에서 Controller로 전달되는 응답 데이터
 * 
 * [데이터 흐름]
 * - ContractMilestoneVO → ContractMilestoneResponseDTO (Service에서 변환)
 * - ContractService.toMilestoneResponseDTO()에서 VO → DTO 변환
 * - ContractResponseDTO.milestones에 포함되어 반환
 * 
 * [필드 설명]
 * - step: 마일스톤 단계 순서 (1, 2, 3, ...)
 * - title: 마일스톤 이름/제목
 * - description: 작업 범위/설명
 * - amount: 해당 마일스톤의 결제 금액 (Long 타입, 원 단위)
 * 
 * [특징]
 * - @JsonIgnoreProperties(ignoreUnknown = true): JSON 역직렬화 시 알 수 없는 필드 무시
 * - ContractMilestoneRequestDTO와 동일한 필드 구조
 * - 화면 표시에 필요한 정보만 포함
 * 
 * [사용 위치]
 * - 계약 상세 페이지: 마일스톤 목록 표시
 * - 계약 목록 페이지: 마일스톤 정보 표시
 * - API 응답: REST API로 마일스톤 정보 반환
 * 
 * ============================================================================
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
