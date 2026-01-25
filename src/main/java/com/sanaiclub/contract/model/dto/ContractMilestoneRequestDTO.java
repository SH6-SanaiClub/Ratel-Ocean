package com.sanaiclub.contract.model.dto;

import lombok.Getter;
import lombok.Setter;

/**
 * ============================================================================
 * ContractMilestoneRequestDTO - 마일스톤 요청 DTO
 * ============================================================================
 * 
 * [역할]
 * 계약 생성/수정 시 마일스톤 정보를 전달하는 DTO입니다.
 * 마일스톤 방식 결제에서 단계별 지급 계획을 표현합니다.
 * 
 * [연관 파일]
 * 
 * DTO 계층:
 * - ContractCreateRequestDTO: 계약 생성 요청 DTO (milestones 필드에 포함)
 * - ContractUpdateRequestDTO: 계약 수정 요청 DTO (milestones 필드에 포함)
 * 
 * Service 계층:
 * - ContractService.createContract(): 마일스톤 생성
 *   * ContractMilestoneRequestDTO → ContractMilestoneVO 변환
 *   * ContractMilestoneMapper.insertMilestone() 호출
 * - ContractService.updateContract(): 마일스톤 수정
 *   * 기존 마일스톤 삭제 후 새로운 마일스톤 저장
 * 
 * [필드 설명]
 * 
 * - step: 마일스톤 단계 순서 (1, 2, 3, ...)
 *   * 계약 내에서 고유해야 함
 *   * 오름차순 정렬 (1단계, 2단계, 3단계...)
 * 
 * - title: 마일스톤 제목
 *   * 예: "1단계: 기획 및 설계", "2단계: 개발", "3단계: 테스트 및 배포"
 * 
 * - description: 작업 범위/설명
 *   * 해당 마일스톤에서 수행할 작업의 상세 설명
 *   * 예: "기획서 작성, UI/UX 설계, 기술 스택 선정"
 * 
 * - amount: 해당 마일스톤의 지급 금액 (원 단위)
 *   * 모든 마일스톤의 amount 합계 = 계약의 totalBudget
 *   * 비즈니스 로직 검증 필요
 * 
 * [사용 시나리오]
 * 
 * 1. 계약 생성 시:
 *    - 사용자가 계약서 작성 폼에서 마일스톤 정보 입력
 *    - ContractCreateRequestDTO의 milestones 필드에 포함
 *    - ContractService.createContract()에서 마일스톤 저장
 * 
 * 2. 계약 수정 시:
 *    - 기존 마일스톤 정보를 조회하여 폼에 표시
 *    - 사용자가 마일스톤 정보 수정
 *    - ContractUpdateRequestDTO의 milestones 필드에 포함
 *    - ContractService.updateContract()에서 기존 마일스톤 삭제 후 새로운 마일스톤 저장
 * 
 * [주의사항]
 * 
 * - step은 1부터 시작하는 정수 (null 불가)
 * - title과 description은 선택 (null 가능)
 * - amount는 필수 (null 불가, 0보다 커야 함)
 * - 모든 마일스톤의 amount 합계가 계약의 totalBudget과 일치해야 함
 * - 결제 방식이 FIXED/FULL인 경우 마일스톤 없음 (milestones = null 또는 빈 리스트)
 * 
 * [데이터 타입]
 * 
 * - step: Integer (1부터 시작, null 불가)
 * - title: String (null 가능)
 * - description: String (null 가능)
 * - amount: Long (원 단위, null 불가, 0보다 커야 함)
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
