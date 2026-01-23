package com.sanaiclub.contract.model.dto;

import lombok.Getter;
import lombok.Setter;

/**
 * ============================================================================
 * ContractMilestoneRequestDTO - 마일스톤 요청 DTO
 * ============================================================================
 * 
 * [역할]
 * - 마일스톤 정보를 요청/수정할 때 사용하는 데이터 전송 객체
 * - ContractCreateRequestDTO, ContractUpdateRequestDTO의 milestones 필드에 포함
 * - 결제 방식이 "MILESTONE"인 계약에서 사용
 * 
 * [사용 흐름]
 * - ContractFormController → ContractService.createContract() / updateContract()
 * - Service에서 VO로 변환하여 DB에 저장
 * 
 * [필드 설명]
 * - step: 마일스톤 단계 순서 (1, 2, 3, ...)
 *   * 1부터 시작하며, 계약 내에서 중복되지 않아야 함
 * - title: 마일스톤 이름/제목 (예: "1단계: 기획 및 설계")
 * - description: 작업 범위/설명 (예: "요구사항 분석, 시스템 설계 문서 작성")
 * - amount: 해당 마일스톤의 결제 금액 (Long 타입, 원 단위)
 * 
 * [주의사항]
 * - step과 amount는 필수
 * - title은 필수 (빈 문자열 불가)
 * - description은 선택 (NULL 가능)
 * - 모든 마일스톤의 amount 합계가 totalBudget과 일치해야 함 (비즈니스 로직 검증 필요)
 * 
 * ============================================================================
 */
@Getter
@Setter
public class ContractMilestoneRequestDTO {
    private Integer step;
    private String title;
    private String description;
    private Long amount;
}
