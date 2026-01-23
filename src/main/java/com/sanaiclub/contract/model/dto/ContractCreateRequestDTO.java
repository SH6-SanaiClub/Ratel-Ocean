package com.sanaiclub.contract.model.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * 계약 생성 요청 DTO
 * 
 * [역할]
 * - 계약 생성 시 클라이언트로부터 받는 요청 데이터
 * - ContractController.confirmContract()에서 사용 (INSERT 시)
 * 
 * [주요 필드]
 * - projectId, freelancerId: 프로젝트 및 프리랜서 식별
 * - contractStartDate, contractEndDate: 계약 기간
 * - totalBudget: 총 예산
 * - paymentMethod: 지급 방식 ("ONE_TIME" 또는 "MILESTONE")
 * - milestones: 마일스톤 목록 (MILESTONE 타입일 때)
 * - contractPurpose, workScope, deliverables 등: 계약 내용 (FORM 타입일 때)
 * - originContractUrl: PDF 경로 (PDF 타입일 때)
 * 
 * [사용 흐름]
 * - ContractController → ContractService.createContract()
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
