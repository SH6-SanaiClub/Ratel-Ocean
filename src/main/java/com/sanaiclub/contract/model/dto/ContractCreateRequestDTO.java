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
 * - 계약 생성 시 클라이언트로부터 받는 요청 데이터
 * - Controller에서 Service로 전달되는 데이터 전송 객체
 * - ContractFormController.confirmContract()에서 사용 (INSERT 시)
 * 
 * [사용 흐름]
 * - ContractFormController.confirmContract() → ContractService.createContract()
 * - ContractService에서 VO로 변환하여 DB에 저장
 * 
 * [필드 설명]
 * - projectId: 프로젝트 ID (필수)
 * - freelancerId: 프리랜서 ID (필수)
 * - contractStartDate: 계약 시작일 (YYYY-MM-DD 형식, 필수)
 * - contractEndDate: 계약 종료일 (YYYY-MM-DD 형식, 필수)
 * - totalBudget: 총 예산 (Long 타입, 원 단위, 필수)
 * - paymentMethod: 지급 방식 ("MILESTONE" 또는 "FIXED", 필수)
 * - contractStatus: 계약 상태 (기본값: WAITING, 선택)
 * - originContractUrl: 원본 계약서 파일 경로 (선택)
 * 
 * [계약 입력 타입별 필드]
 * - FORM 타입 (직접 작성):
 *   * contractPurpose: 계약 목적
 *   * workScope: 업무 범위
 *   * deliverables: 결과물 정의
 *   * paymentCondition: 지급 조건
 *   * scheduleCondition: 일정 관련 조건
 *   * specialTerms: 기타 특약 사항
 *   * (이 필드들은 PDF 생성에만 사용, DB에 저장되지 않음)
 * 
 * - PDF 타입 (업로드):
 *   * originContractUrl: 업로드된 PDF 경로
 * 
 * [마일스톤 필드]
 * - milestones: 마일스톤 목록 (paymentMethod가 "MILESTONE"일 때 필수)
 *   * 각 마일스톤의 step, title, description, amount 포함
 *   * 모든 마일스톤의 amount 합계가 totalBudget과 일치해야 함
 * 
 * [기타 필드]
 * - requirements: 요구사항 목록 (선택, DB에 저장되지 않음)
 * 
 * [주의사항]
 * - projectId와 freelancerId는 필수
 * - paymentMethod가 "MILESTONE"이면 milestones 필수
 * - FORM 타입의 계약 내용(contractPurpose 등)은 PDF 생성에만 사용
 * - requirements는 DB에 저장되지 않음
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
