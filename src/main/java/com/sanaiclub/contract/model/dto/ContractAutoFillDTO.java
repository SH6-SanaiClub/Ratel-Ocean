package com.sanaiclub.contract.model.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.util.List;

/**
 * ============================================================================
 * ContractAutoFillDTO - AI 자동 작성 계약 초안 DTO
 * ============================================================================
 * 
 * [역할]
 * - AI가 생성한 계약 초안 정보를 담는 데이터 전송 객체
 * - ContractAutoFillService.generateDraft()의 반환 타입
 * - PDF 계약서 또는 사용자 입력 내용을 분석하여 계약 정보 추출
 * 
 * [데이터 흐름]
 * - ContractAutoFillService.generateDraft() → ContractAutoFillDTO
 * - ContractFormController.contractCheck()에서 AI 초안 생성 후 화면에 표시
 * - 사용자가 초안을 검토하고 수정한 후 confirmContract()로 확정
 * 
 * [필드 설명]
 * - contractStartDate: 계약 시작일 (LocalDate 타입, AI가 추출)
 * - contractEndDate: 계약 종료일 (LocalDate 타입, AI가 추출)
 * - totalBudget: 총 예산 (Long 타입, 원 단위, AI가 추출)
 * - paymentMethod: 결제 방식 ("MILESTONE" 또는 "FIXED", AI가 추출)
 * - milestones: 마일스톤 목록 (결제 방식이 MILESTONE인 경우, AI가 추출)
 * - requirements: 요구사항 목록 (AI가 추출, 선택)
 * 
 * [AI 추출 과정]
 * 1. PDF 계약서 텍스트 추출 (PDF 타입일 때)
 * 2. 사용자 입력 내용 수집 (FORM 타입일 때)
 * 3. 프로젝트/프리랜서 정보 수집
 * 4. AI API 호출하여 계약 정보 추출
 * 5. 추출된 정보를 ContractAutoFillDTO로 변환
 * 
 * [특징]
 * - @JsonIgnoreProperties(ignoreUnknown = true): JSON 역직렬화 시 알 수 없는 필드 무시
 * - LocalDate 타입 사용: 날짜 정보를 타입 안전하게 표현
 * - AI가 추출한 정보이므로 사용자 검토 및 수정 필요
 * 
 * [사용 위치]
 * - 계약서 작성 화면: AI 초안 표시
 * - 계약서 확인 화면: 초안 검토 및 수정
 * - 계약서 확정: 초안을 기반으로 최종 계약 생성
 * 
 * [주의사항]
 * - AI가 추출한 정보는 100% 정확하지 않을 수 있음
 * - 사용자가 반드시 검토하고 수정해야 함
 * - milestones가 없으면 결제 방식이 FIXED로 추정
 * 
 * ============================================================================
 */
@Getter
@Setter
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class ContractAutoFillDTO {
    private LocalDate contractStartDate;
    private LocalDate contractEndDate;
    private Long totalBudget;
    private String paymentMethod;
    private List<ContractMilestoneResponseDTO> milestones;
    private List<String> requirements;
}
