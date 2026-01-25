package com.sanaiclub.contract.model.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * ============================================================================
 * ContractCreateRequestDTO - 계약 생성 요청 DTO
 * ============================================================================
 * 
 * [역할]
 * Controller에서 Service로 전달되는 계약 생성 요청 데이터를 담는 DTO입니다.
 * 계약서 작성 폼에서 입력받은 모든 정보를 포함하며, 마일스톤 정보도 함께 포함합니다.
 * 
 * [연관 파일]
 * 
 * Controller 계층:
 * - ContractFormController: 계약서 작성 폼 처리
 *   * 계약서 작성 완료 시 이 DTO로 데이터 수집
 *   * ContractService.createContract() 호출
 * 
 * Service 계층:
 * - ContractService.createContract(): 계약 생성 로직
 *   * DTO → VO 변환 후 DB 저장
 *   * 마일스톤 정보도 함께 저장
 * 
 * View 계층:
 * - contractForm.jsp: 계약서 작성 폼
 *   * 사용자가 입력한 데이터를 이 DTO로 전달
 * 
 * [데이터 흐름]
 * 
 * 1. 사용자가 계약서 작성 폼에 입력
 * 2. Controller에서 폼 데이터를 이 DTO로 수집
 * 3. ContractService.createContract() 호출
 * 4. DTO → VO 변환 후 DB 저장
 * 
 * [필드 설명]
 * 
 * 기본 계약 정보:
 * - projectId: 프로젝트 ID (어떤 프로젝트에 대한 계약인지)
 * - freelancerId: 프리랜서 ID (계약 대상 프리랜서)
 * - contractStartDate: 계약 시작일 (YYYY-MM-DD 형식)
 * - contractEndDate: 계약 종료일 (YYYY-MM-DD 형식)
 * - totalBudget: 총 예산 (원 단위, Long 타입)
 * - paymentMethod: 결제 방식
 *   * "MILESTONE": 마일스톤 방식 (단계별 지급)
 *   * "FIXED" 또는 "FULL": 일시지급 방식 (전체 금액 한 번에 지급)
 * - contractStatus: 계약 상태 (선택, 기본값: WAITING)
 *   * ContractStatus enum의 name() 값
 *   * 일반적으로는 null로 전달하여 기본값 사용
 * - originContractUrl: 원본 계약서 파일 경로
 *   * 형식: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
 *   * 파일 업로드 후 경로 설정
 * 
 * 계약서 내용 (DB에 저장되지 않음, 계약서 생성 시에만 사용):
 * - contractPurpose: 계약 목적
 * - workScope: 작업 범위
 * - deliverables: 납품물
 * - paymentCondition: 결제 조건
 * - scheduleCondition: 일정 조건
 * - specialTerms: 특별 약관
 * - requirements: 요구사항 목록
 * 
 * 마일스톤 정보:
 * - milestones: 마일스톤 목록 (List<ContractMilestoneRequestDTO>)
 *   * 결제 방식이 MILESTONE인 경우에만 사용
 *   * 각 마일스톤의 step, title, description, amount 포함
 *   * 결제 방식이 FIXED/FULL인 경우 null 또는 빈 리스트
 * 
 * [주의사항]
 * 
 * - projectId와 freelancerId는 필수 (어떤 프로젝트의 어떤 프리랜서인지 명시)
 * - totalBudget은 필수 (총 예산 명시)
 * - paymentMethod는 필수 (결제 방식 명시)
 * - milestones의 amount 합계가 totalBudget과 일치해야 함 (비즈니스 로직 검증 필요)
 * - 계약서 내용 필드들은 DB에 저장되지 않음 (계약서 생성 시에만 사용)
 * - originContractUrl은 파일 업로드 후 별도로 설정 가능
 * 
 * [마일스톤 처리]
 * 
 * 결제 방식에 따른 마일스톤 처리:
 * 
 * - MILESTONE 방식:
 *   * milestones 필드에 마일스톤 목록 포함
 *   * 각 마일스톤의 amount 합계 = totalBudget
 *   * ContractService.createContract()에서 마일스톤도 함께 저장
 * 
 * - FIXED/FULL 방식:
 *   * milestones는 null 또는 빈 리스트
 *   * 마일스톤 없이 일시지급으로 처리
 *   * ContractService.createContract()에서 마일스톤 저장 생략
 * 
 * [데이터 타입]
 * 
 * - projectId, freelancerId: Integer (null 가능, 하지만 일반적으로는 필수)
 * - 날짜 필드: String (YYYY-MM-DD 형식)
 * - totalBudget: Long (원 단위, 큰 금액 처리)
 * - paymentMethod, contractStatus: String (enum의 name() 값)
 * - originContractUrl: String (파일 경로)
 * - 계약서 내용 필드: String (TEXT 타입)
 * - milestones: List<ContractMilestoneRequestDTO>
 * - requirements: List<String>
 * 
 * ============================================================================
 */
@Getter
@Setter
public class ContractCreateRequestDTO {
    private Integer projectId;
    private Integer freelancerId;
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
    private List<String> requirements;
}
