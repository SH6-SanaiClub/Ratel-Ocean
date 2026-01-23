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
 * - 계약 조회 시 클라이언트에게 반환하는 응답 데이터
 * - 화면 표시에 필요한 필드만 포함
 * - Service 계층에서 Controller로 전달되는 데이터 전송 객체
 * 
 * [데이터 흐름]
 * - ContractService.getContractById() → ContractResponseDTO
 * - ContractService.toResponseDTO()에서 VO → DTO 변환
 * - ContractFormController, ContractApiController 등에서 사용
 * 
 * [필드 설명]
 * - contractId: 계약 ID (PK)
 * - projectId: 프로젝트 ID (originContractUrl에서 추출)
 * - freelancerId: 프리랜서 ID (originContractUrl에서 추출)
 * - contractStartDate: 계약 시작일 (YYYY-MM-DD 형식)
 * - contractEndDate: 계약 종료일 (YYYY-MM-DD 형식)
 * - totalBudget: 총 예산 (Long 타입, 원 단위)
 * - paymentMethod: 결제 방식 ("MILESTONE" 또는 "FIXED")
 * - contractStatus: 계약 상태 (WAITING, SIGNED, TERMINATED, COMPLETED)
 * - originContractUrl: 원본 계약서 파일 경로
 * - platformContractUrl: 플랫폼에서 생성한 계약서 경로 (선택)
 * - aiReportUrl: AI 분석 리포트 경로 (선택)
 * - contractedAt: 계약 체결 시각 (YYYY-MM-DD HH:mm:ss 형식)
 * - completedAt: 계약 완료 시각 (완료 전까지는 NULL)
 * - cancelReason: 취소/거절 사유 (취소 전까지는 NULL)
 * - milestones: 마일스톤 목록 (결제 방식이 MILESTONE인 경우)
 * - requirements: 요구사항 목록 (항상 빈 리스트, DB에 저장되지 않음)
 * 
 * [특징]
 * - projectId와 freelancerId는 originContractUrl에서 추출
 *   * 경로 형식: "contracts/{clientId}/{projectId}/{freelancerId}/{fileName}"
 *   * Service 계층에서 경로 파싱하여 설정
 * - milestones는 별도 조회하여 설정
 * - requirements는 DB에 저장되지 않으므로 항상 빈 리스트
 * 
 * [사용 위치]
 * - 계약 상세 페이지: 계약 정보 표시
 * - 계약 목록 페이지: 계약 목록 표시
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
}
