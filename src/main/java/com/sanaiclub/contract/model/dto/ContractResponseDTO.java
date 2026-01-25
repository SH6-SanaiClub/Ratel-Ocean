package com.sanaiclub.contract.model.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * ============================================================================
 * ContractResponseDTO - 계약 응답 DTO
 * ============================================================================
 * 
 * [역할]
 * Service 계층에서 Controller로 전달되는 계약 정보를 담는 DTO입니다.
 * 화면 표시에 필요한 모든 정보를 포함하며, 마일스톤 상태 집계 정보도 포함합니다.
 * 
 * [연관 파일]
 * - ContractService.toResponseDTO(): ContractVO → ContractResponseDTO 변환
 * - ContractService.getAllContracts(): 모든 계약 조회 시 이 DTO로 변환
 * - ContractMapper.selectAllContractsWithDetails(): 마일스톤 집계 정보 포함 조회
 * - ClientContractManagementController: 클라이언트 계약 관리 페이지에서 사용
 * - FreelancerContractController: 프리랜서 계약 목록 페이지에서 사용
 * - contractManagement.jsp: 클라이언트 계약 관리 뷰
 * - freelancerContractList.jsp: 프리랜서 계약 목록 뷰
 * 
 * [데이터 흐름]
 * 1. ContractMapper.selectAllContractsWithDetails() → Map<String, Object>
 * 2. ContractService.getAllContracts() → Map을 ContractResponseDTO로 변환
 * 3. Controller → Model에 추가
 * 4. JSP → 화면에 표시
 * 
 * [필드 설명]
 * 
 * 기본 계약 정보:
 * - contractId: 계약 ID (PK)
 * - projectId: 프로젝트 ID (originContractUrl에서 추출)
 * - freelancerId: 프리랜서 ID (originContractUrl에서 추출)
 * - contractStartDate: 계약 시작일 (YYYY-MM-DD)
 * - contractEndDate: 계약 종료일 (YYYY-MM-DD)
 * - totalBudget: 총 예산 (원 단위)
 * - paymentMethod: 결제 방식 ("MILESTONE" 또는 "FIXED")
 * - contractStatus: 계약 상태 (ContractStatus enum의 name() 값)
 * - originContractUrl: 원본 계약서 파일 경로
 * - platformContractUrl: 플랫폼 생성 계약서 경로
 * - aiReportUrl: AI 분석 리포트 경로
 * - contractedAt: 계약 체결 시각
 * - completedAt: 계약 완료 시각
 * - cancelReason: 취소/거절 사유 (일시지급 지급 요청 상태도 포함)
 * 
 * 마일스톤 및 요구사항:
 * - milestones: 마일스톤 목록 (ContractMilestoneResponseDTO)
 * - requirements: 요구사항 목록 (항상 빈 리스트, DB에 저장되지 않음)
 * 
 * UI 표시용 필드:
 * - projectTitle: 프로젝트 이름 (사이드바 표시용)
 * - freelancerName: 프리랜서 이름
 * - clientName: 클라이언트 이름
 * - counterpartName: 상대방 이름
 *   * 클라이언트 시점: 프리랜서 이름
 *   * 프리랜서 시점: 클라이언트 이름
 * 
 * 마일스톤 상태 집계 필드 (UI 표시용):
 * - totalMilestones: 전체 마일스톤 개수
 * - paidMilestones: 지급 완료된 마일스톤 개수 (status = 'PAID')
 * - requestedMilestones: 지급 요청된 마일스톤 개수 (status = 'REQUESTED')
 * - depositedMilestones: 입금 완료된 마일스톤 개수 (status = 'DEPOSITED')
 * - waitingMilestones: 대기 중인 마일스톤 개수 (status = 'WAITING')
 * 
 * [특수 필드: cancelReason 활용]
 * DB 스키마 변경 없이 일시지급 지급 요청 상태를 관리하기 위해 cancel_reason 컬럼을 재활용합니다.
 * 
 * - cancel_reason = null: 일시지급 계약에서 아직 지급 요청하지 않은 상태
 * - cancel_reason = "[지급요청]": 일시지급 계약에서 프리랜서가 지급 요청한 상태
 * - cancel_reason = "[거절] {사유}": 프리랜서가 계약을 거절한 상태
 * - cancel_reason = "[취소] {사유}": 클라이언트가 계약을 취소한 상태
 * 
 * 이는 ContractService.requestPayment(), approvePayment(), rejectPayment()에서 활용됩니다.
 * 
 * [집계 정보 조회]
 * 마일스톤 상태 집계 정보는 ContractMapper.selectAllContractsWithDetails()에서
 * LEFT JOIN 서브쿼리로 계산됩니다:
 * 
 * - contract_milestones 테이블을 GROUP BY하여 각 상태별 개수 집계
 * - totalMilestones: COUNT(*)
 * - paidMilestones: SUM(CASE WHEN status = 'PAID' THEN 1 ELSE 0 END)
 * - requestedMilestones: SUM(CASE WHEN status = 'REQUESTED' THEN 1 ELSE 0 END)
 * - depositedMilestones: SUM(CASE WHEN status = 'DEPOSITED' THEN 1 ELSE 0 END)
 * - waitingMilestones: SUM(CASE WHEN status = 'WAITING' THEN 1 ELSE 0 END)
 * 
 * [사용 위치]
 * - 계약 목록 페이지: 사이드바에 상태별 계약 목록 표시
 * - 계약 상세 페이지: 선택한 계약의 상세 정보 표시
 * - API 응답: REST API로 계약 정보 반환
 * 
 * ============================================================================
 */
@Getter
@Setter
public class ContractResponseDTO {
    private Integer contractId;
    private Integer projectId;
    private Integer freelancerId;
    private String contractStartDate;
    private String contractEndDate;
    private Long totalBudget;
    private String paymentMethod;
    private String contractStatus;
    private String originContractUrl;
    private String platformContractUrl;
    private String aiReportUrl;
    private String contractedAt;
    private String completedAt;
    private String cancelReason;
    private List<ContractMilestoneResponseDTO> milestones;
    private List<String> requirements;
    
    private String projectTitle;
    private String freelancerName;
    private String clientName;
    private String counterpartName;
    
    private Integer totalMilestones;
    private Integer paidMilestones;
    private Integer requestedMilestones;
    private Integer depositedMilestones;
    private Integer waitingMilestones;
}
