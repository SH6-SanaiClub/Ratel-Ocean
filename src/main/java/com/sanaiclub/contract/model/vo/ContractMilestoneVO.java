package com.sanaiclub.contract.model.vo;

import lombok.Builder;
import lombok.Getter;

/**
 * ============================================================================
 * ContractMilestoneVO - 계약 마일스톤 Value Object (DB 엔티티)
 * ============================================================================
 * 
 * [역할]
 * contract_milestones 테이블과 1:1 매핑되는 불변 객체입니다.
 * 마일스톤 방식 결제에서 단계별 지급 정보를 담는 객체로, 계약의 세부 지급 계획을
 * 표현합니다. Builder 패턴을 사용하여 불변성을 보장합니다.
 * 
 * [연관 파일]
 * 
 * DAO 계층:
 * - ContractMilestoneMapper: contract_milestones 테이블 CRUD 작업
 * - ContractMilestoneMapper.selectMilestonesByContractId(): 계약의 마일스톤 목록 조회
 * - ContractMilestoneMapper.insertMilestone(): 마일스톤 생성
 * - ContractMilestoneMapper.updateMilestoneStatus(): 마일스톤 상태 변경
 * - ContractMilestoneMapper.deleteMilestonesByContractId(): 마일스톤 삭제
 * 
 * Service 계층:
 * - ContractService: ContractMilestoneVO를 사용하여 마일스톤 관리
 * - ContractService.createContract(): 마일스톤 생성
 * - ContractService.requestPayment(): 마일스톤 지급 요청 (WAITING → REQUESTED)
 * - ContractService.approvePayment(): 마일스톤 지급 수락 (REQUESTED → DEPOSITED)
 * - ContractService.rejectPayment(): 마일스톤 지급 거부 (REQUESTED → WAITING)
 * 
 * DTO 계층:
 * - ContractMilestoneRequestDTO: 마일스톤 생성/수정 요청 DTO
 * - ContractMilestoneResponseDTO: 마일스톤 응답 DTO
 * 
 * [DB 테이블 구조]
 * 테이블명: contract_milestones
 * 
 * 주요 컬럼:
 * - contract_id (FK): 계약 ID (contracts 테이블 참조)
 * - step (INT): 마일스톤 단계 순서 (1, 2, 3, ...)
 * - title (VARCHAR): 마일스톤 제목
 * - description (TEXT): 작업 범위/설명
 * - amount (BIGINT): 해당 마일스톤의 지급 금액 (원 단위)
 * - status (VARCHAR): 마일스톤 상태
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
 *    - ContractService.requestPayment()에서 설정
 * 
 * 3. DEPOSITED (입금 완료)
 *    - 클라이언트가 지급을 수락한 상태
 *    - 에스크로에서 출금하여 프리랜서에게 지급할 준비가 된 상태
 *    - 플랫폼에서 실제 지급이 완료되면 PAID로 변경
 *    - ContractService.approvePayment()에서 설정
 * 
 * 4. PAID (지급 완료)
 *    - 프리랜서에게 실제 지급이 완료된 상태
 *    - 최종 완료 상태 (더 이상 변경 불가)
 *    - 모든 마일스톤이 PAID가 되면 계약 상태가 COMPLETED로 변경
 *    - ContractService.completeMilestonePayment()에서 설정
 * 
 * [마일스톤과 일시지급의 차이]
 * 
 * 마일스톤 방식:
 * - 여러 단계로 나누어 지급
 * - 각 마일스톤마다 상태 관리 (WAITING, REQUESTED, DEPOSITED, PAID)
 * - contract_milestones 테이블에 저장
 * - ContractMilestoneVO로 표현
 * 
 * 일시지급 방식:
 * - 전체 금액을 한 번에 지급
 * - 마일스톤 없음 (contract_milestones 테이블에 데이터 없음)
 * - cancel_reason 컬럼을 재활용하여 지급 요청 상태 관리
 * - ContractVO의 cancelReason 필드로 표현
 * 
 * [불변성 보장]
 * 
 * - 모든 필드는 final로 선언되어 한 번 생성되면 변경할 수 없음
 * - Builder 패턴을 사용하여 객체 생성
 * - setter 메서드 없음 (불변 객체)
 * - 상태 변경은 DB 업데이트를 통해 새로운 VO 객체 생성
 * 
 * [사용 패턴]
 * 
 * 1. 마일스톤 생성 시:
 *    - ContractService.createContract()에서 ContractMilestoneRequestDTO → VO 변환
 *    - ContractMilestoneMapper.insertMilestone() 호출
 *    - 초기 상태는 항상 "WAITING"
 * 
 * 2. 마일스톤 상태 변경 시:
 *    - ContractService.requestPayment(), approvePayment(), rejectPayment()에서
 *    - ContractMilestoneMapper.updateMilestoneStatus() 호출
 *    - DB 업데이트 후 새로운 VO 객체 조회
 * 
 * 3. 마일스톤 조회 시:
 *    - ContractMilestoneMapper.selectMilestonesByContractId()로 목록 조회
 *    - step 오름차순 정렬 (1단계, 2단계, 3단계...)
 *    - VO → DTO 변환하여 Controller에 전달
 * 
 * [주의사항]
 * 
 * - step은 계약 내에서 고유해야 함 (1, 2, 3, ...)
 * - amount의 합계가 계약의 totalBudget과 일치해야 함 (비즈니스 로직 검증 필요)
 * - contractId는 반드시 존재하는 계약을 참조해야 함 (FK 제약)
 * - status는 위의 4가지 값 중 하나여야 함
 * - 일시지급 계약은 마일스톤이 없음 (totalMilestones == 0)
 * 
 * [데이터 타입]
 * 
 * - contractId: Integer (FK, null 불가)
 * - step: Integer (1부터 시작, null 불가)
 * - title: String (마일스톤 제목, null 가능)
 * - description: String (작업 범위/설명, null 가능)
 * - amount: Long (원 단위, null 불가)
 * - status: String (마일스톤 상태, null 불가)
 * 
 * ============================================================================
 */
@Getter
@Builder
public class ContractMilestoneVO {
    private final Integer contractId;
    private final Integer step;
    private final String title;
    private final String description;
    private final Long amount;
    private final String status;
}
