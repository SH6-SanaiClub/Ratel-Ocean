package com.sanaiclub.contract.model.dto;

import com.sanaiclub.contract.model.vo.ContractStatus;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * ============================================================================
 * ContractUpdateRequestDTO - 계약 수정 요청 DTO
 * ============================================================================
 * 
 * [역할]
 * - 계약 수정 시 클라이언트로부터 받는 요청 데이터
 * - Controller에서 Service로 전달되는 데이터 전송 객체
 * - ContractFormController.confirmContract()에서 사용 (UPDATE 시)
 * 
 * [사용 흐름]
 * - ContractFormController.confirmContract() → ContractService.updateContract()
 * - ContractService에서 VO로 변환하여 DB에 업데이트
 * 
 * [ContractCreateRequestDTO와의 차이점]
 * - contractId 포함 (필수, 수정할 계약 식별)
 * - projectId, freelancerId 불필요 (contractId로 식별)
 * - requirements 필드 없음 (INSERT 시에만 사용)
 * 
 * [필드 설명]
 * - contractId: 계약 ID (필수, 수정할 계약 식별)
 * - contractStartDate: 계약 시작일 (YYYY-MM-DD 형식, 수정)
 * - contractEndDate: 계약 종료일 (YYYY-MM-DD 형식, 수정)
 * - totalBudget: 총 예산 (Long 타입, 원 단위, 수정)
 * - paymentMethod: 지급 방식 ("MILESTONE" 또는 "FIXED", 수정)
 * - contractStatus: 계약 상태 (기본값: WAITING, 수정)
 * - originContractUrl: 원본 계약서 파일 경로 (수정)
 * 
 * [계약 입력 타입별 필드]
 * - FORM 타입 (직접 작성):
 *   * contractPurpose: 계약 목적 (PDF 생성에만 사용)
 *   * workScope: 업무 범위 (PDF 생성에만 사용)
 *   * deliverables: 결과물 정의 (PDF 생성에만 사용)
 *   * paymentCondition: 지급 조건 (PDF 생성에만 사용)
 *   * scheduleCondition: 일정 관련 조건 (PDF 생성에만 사용)
 *   * specialTerms: 기타 특약 사항 (PDF 생성에만 사용)
 * 
 * [마일스톤 필드]
 * - milestones: 마일스톤 목록 (paymentMethod가 "MILESTONE"일 때)
 *   * UPDATE 시 기존 마일스톤 삭제 후 새로 추가 (전체 교체)
 *   * 모든 마일스톤의 amount 합계가 totalBudget과 일치해야 함
 * 
 * [주의사항]
 * - contractId는 필수
 * - UPDATE 시 기존 값 유지: contractedAt, platformContractUrl, aiReportUrl, 평가 관련 필드
 * - 마일스톤은 전체 교체 방식 (부분 수정 불가)
 * - FORM 타입의 계약 내용은 PDF 생성에만 사용 (DB에 저장되지 않음)
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
    private ContractStatus contractStatus;
    private String originContractUrl;
    private String contractPurpose;
    private String workScope;
    private String deliverables;
    private String paymentCondition;
    private String scheduleCondition;
    private String specialTerms;
    private List<ContractMilestoneRequestDTO> milestones;
}
