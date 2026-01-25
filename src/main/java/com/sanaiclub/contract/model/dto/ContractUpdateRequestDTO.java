package com.sanaiclub.contract.model.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * ============================================================================
 * ContractUpdateRequestDTO - 계약 수정 요청 DTO
 * ============================================================================
 * 
 * [역할]
 * Controller에서 Service로 전달되는 계약 수정 요청 데이터를 담는 DTO입니다.
 * 기존 계약의 정보를 수정할 때 사용하며, 마일스톤 정보도 함께 수정합니다.
 * 
 * [연관 파일]
 * 
 * Controller 계층:
 * - ContractFormController: 계약서 수정 폼 처리
 *   * 기존 계약 정보를 조회하여 폼에 표시
 *   * 수정 완료 시 이 DTO로 데이터 수집
 *   * ContractService.updateContract() 호출
 * 
 * Service 계층:
 * - ContractService.updateContract(): 계약 수정 로직
 *   * DTO → VO 변환 후 DB 업데이트
 *   * 기존 마일스톤 삭제 후 새로운 마일스톤 저장
 * 
 * View 계층:
 * - contractForm.jsp: 계약서 수정 폼
 *   * 기존 계약 정보를 표시하고 수정 가능
 * 
 * [데이터 흐름]
 * 
 * 1. 기존 계약 정보 조회 (ContractService.getContractById())
 * 2. 사용자가 계약서 수정 폼에서 정보 수정
 * 3. Controller에서 폼 데이터를 이 DTO로 수집
 * 4. ContractService.updateContract() 호출
 * 5. DTO → VO 변환 후 DB 업데이트
 * 
 * [필드 설명]
 * 
 * 기본 계약 정보:
 * - contractId: 계약 ID (PK, 필수, 수정할 계약 식별)
 * - contractStartDate: 계약 시작일 (수정)
 * - contractEndDate: 계약 종료일 (수정)
 * - totalBudget: 총 예산 (수정)
 * - paymentMethod: 결제 방식 (수정)
 * - contractStatus: 계약 상태 (수정 또는 기본값: WAITING)
 * - originContractUrl: 원본 계약서 파일 경로 (수정)
 * 
 * 계약서 내용 (DB에 저장되지 않음, 계약서 생성 시에만 사용):
 * - contractPurpose: 계약 목적
 * - workScope: 작업 범위
 * - deliverables: 납품물
 * - paymentCondition: 결제 조건
 * - scheduleCondition: 일정 조건
 * - specialTerms: 특별 약관
 * 
 * 마일스톤 정보:
 * - milestones: 새로운 마일스톤 목록 (전체 교체)
 *   * 기존 마일스톤을 모두 삭제하고 새로운 마일스톤으로 교체
 *   * 부분 수정 불가 (전체 교체만 가능)
 *   * 결제 방식이 FIXED/FULL인 경우 null 또는 빈 리스트
 * 
 * [기존 값 유지 전략]
 * 
 * ContractService.updateContract()에서 일부 필드는 기존 값 유지:
 * 
 * - contractedAt: 계약 체결 시각 (수정 시점이 아니라 계약 체결 시점)
 * - platformContractUrl: 플랫폼 생성 계약서 경로 (별도 업데이트)
 * - aiReportUrl: AI 분석 리포트 경로 (별도 업데이트)
 * - completedAt: 계약 완료 시각 (완료 처리 시에만 변경)
 * - cancelReason: 취소 사유 (취소 처리 시에만 변경)
 * - 평가 관련 필드: clientRating, freelancerRating 등 (완료 후에만 입력)
 * 
 * [마일스톤 처리]
 * 
 * 기존 마일스톤을 모두 삭제하고 새로운 마일스톤으로 교체:
 * 
 * 1. ContractMilestoneMapper.deleteMilestonesByContractId() 호출
 * 2. 기존 마일스톤 모두 삭제
 * 3. 새로운 마일스톤 목록 저장
 * 4. 부분 수정 불가 (전체 교체만 가능)
 * 
 * [주의사항]
 * 
 * - contractId는 필수 (수정할 계약 식별)
 * - 계약 상태가 TERMINATED 또는 COMPLETED인 경우 수정 불가 (비즈니스 로직 검증 필요)
 * - milestones의 amount 합계가 totalBudget과 일치해야 함 (비즈니스 로직 검증 필요)
 * - 계약서 내용 필드들은 DB에 저장되지 않음 (계약서 생성 시에만 사용)
 * - 트랜잭션 처리: 마일스톤 삭제, 계약 업데이트, 마일스톤 추가가 모두 성공해야 커밋
 * 
 * [데이터 타입]
 * 
 * - contractId: Integer (필수, PK)
 * - 날짜 필드: String (YYYY-MM-DD 형식)
 * - totalBudget: Long (원 단위)
 * - paymentMethod, contractStatus: String (enum의 name() 값)
 * - originContractUrl: String (파일 경로)
 * - 계약서 내용 필드: String (TEXT 타입)
 * - milestones: List<ContractMilestoneRequestDTO>
 * 
 * ============================================================================
 */
@Getter
@Setter
public class ContractUpdateRequestDTO {
    private Integer contractId;
    private String contractStartDate;
    private String contractEndDate;
    private Long totalBudget;
    private String paymentMethod;
    private String contractStatus;
    private String originContractUrl;
    private String contractPurpose;
    private String workScope;
    private String deliverables;
    private String paymentCondition;
    private String scheduleCondition;
    private String specialTerms;
    private List<ContractMilestoneRequestDTO> milestones;
}
