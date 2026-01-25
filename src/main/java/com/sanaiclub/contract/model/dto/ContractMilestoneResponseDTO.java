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
 * Service 계층에서 Controller로 전달되는 마일스톤 정보를 담는 DTO입니다.
 * 계약 조회 시 마일스톤 목록을 포함하여 전달하며, 마일스톤의 현재 상태도 포함합니다.
 * 
 * [연관 파일]
 * 
 * Service 계층:
 * - ContractService.getContractById(): 계약 조회 시 마일스톤 포함
 *   * ContractMilestoneVO → ContractMilestoneResponseDTO 변환
 * - ContractService.getMilestonesByContractId(): 마일스톤 목록 조회
 *   * ContractMilestoneVO 리스트 → ContractMilestoneResponseDTO 리스트 변환
 * 
 * Controller 계층:
 * - ClientContractManagementController: 클라이언트 계약 관리 페이지
 *   * 계약 상세 정보에 마일스톤 목록 포함
 * - FreelancerContractController: 프리랜서 계약 목록 페이지
 *   * 계약 상세 정보에 마일스톤 목록 포함
 * 
 * View 계층:
 * - contractManagement.jsp: 클라이언트 계약 관리 페이지
 *   * 마일스톤 목록 표시, 지급 요청/수락/거부 버튼
 * - freelancerContractList.jsp: 프리랜서 계약 목록 페이지
 *   * 마일스톤 목록 표시, 지급 요청 버튼
 * 
 * [필드 설명]
 * 
 * - step: 마일스톤 단계 순서 (1, 2, 3, ...)
 *   * 계약 내에서 고유
 *   * 오름차순 정렬 (1단계, 2단계, 3단계...)
 * 
 * - title: 마일스톤 제목
 *   * 예: "1단계: 기획 및 설계"
 * 
 * - description: 작업 범위/설명
 *   * 해당 마일스톤에서 수행할 작업의 상세 설명
 * 
 * - amount: 해당 마일스톤의 지급 금액 (원 단위)
 *   * 모든 마일스톤의 amount 합계 = 계약의 totalBudget
 * 
 * - status: 마일스톤 상태
 *   * "WAITING": 대기 중 (아직 지급 요청하지 않음)
 *   * "REQUESTED": 지급 요청됨 (프리랜서가 요청, 클라이언트 수락 대기)
 *   * "DEPOSITED": 입금 완료 (클라이언트가 수락, 에스크로에서 출금 대기)
 *   * "PAID": 지급 완료 (프리랜서에게 실제 지급 완료)
 * 
 * [마일스톤 상태 전이 흐름]
 * 
 * ┌─────────────────────────────────────────────────────────────────────────┐
 * │ 정상 흐름:                                                              │
 * │ WAITING → REQUESTED → DEPOSITED → PAID                                 │
 * │                                                                         │
 * │ 비정상 흐름 (거부 시):                                                  │
 * │ REQUESTED → WAITING (재요청 가능)                                      │
 * └─────────────────────────────────────────────────────────────────────────┘
 * 
 * [상태별 상세 설명]
 * 
 * 1. WAITING (대기 중)
 *    - 마일스톤 작업이 완료되었지만 아직 지급 요청하지 않은 상태
 *    - 프리랜서가 requestPayment()를 호출하면 REQUESTED로 변경
 *    - 초기 생성 시 기본 상태
 * 
 * 2. REQUESTED (지급 요청됨)
 *    - 프리랜서가 지급 요청한 상태
 *    - 클라이언트가 수락하면 DEPOSITED로 변경
 *    - 클라이언트가 거부하면 WAITING으로 되돌림 (재요청 가능)
 * 
 * 3. DEPOSITED (입금 완료)
 *    - 클라이언트가 지급을 수락한 상태
 *    - 에스크로에서 출금하여 프리랜서에게 지급할 준비가 된 상태
 *    - 플랫폼에서 실제 지급이 완료되면 PAID로 변경
 * 
 * 4. PAID (지급 완료)
 *    - 프리랜서에게 실제 지급이 완료된 상태
 *    - 최종 완료 상태 (더 이상 변경 불가)
 *    - 모든 마일스톤이 PAID가 되면 계약 상태가 COMPLETED로 변경
 * 
 * [JSON 직렬화]
 * 
 * @JsonIgnoreProperties(ignoreUnknown = true) 어노테이션 사용:
 * - JSON 역직렬화 시 알 수 없는 속성 무시
 * - API 호환성 향상
 * - 향후 필드 추가 시에도 기존 클라이언트와 호환
 * 
 * [데이터 타입]
 * 
 * - step: Integer (1부터 시작, null 불가)
 * - title: String (null 가능)
 * - description: String (null 가능)
 * - amount: Long (원 단위, null 불가)
 * - status: String (마일스톤 상태, null 불가)
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
    private String status;
}
