package com.sanaiclub.contract.model.vo;

import lombok.Builder;
import lombok.Getter;

/**
 * ============================================================================
 * ContractMilestoneVO - 계약 마일스톤 Value Object (DB 엔티티)
 * ============================================================================
 * 
 * [역할]
 * - DB의 contract_milestones 테이블과 1:1 매핑되는 불변 객체
 * - MyBatis를 통해 DB에서 조회한 마일스톤 데이터를 담는 컨테이너
 * - 계약의 단계별 작업 및 결제 계획을 표현
 * 
 * [특징]
 * - 불변 객체: final 필드, setter 없음
 * - Builder 패턴: ContractMilestoneVO.builder()로만 생성 가능
 * - Lombok 사용: @Getter, @Builder 어노테이션으로 보일러플레이트 코드 제거
 * 
 * [사용 계층]
 * - Mapper → Service: DB 조회 결과를 VO로 반환
 * - Service → Service: 비즈니스 로직에서 VO 사용
 * - Service → DTO: VO를 DTO로 변환하여 Controller에 전달
 * 
 * [마일스톤 개념]
 * - 계약의 작업을 여러 단계로 나누어 관리
 * - 각 단계마다 작업 범위와 결제 금액을 정의
 * - 결제 방식이 "MILESTONE"인 계약에서만 사용
 * - 예) 1단계: 기획 및 설계 (30%), 2단계: 개발 (50%), 3단계: 테스트 및 배포 (20%)
 * 
 * [필드 설명]
 * - contractId: 계약 ID (FK, contracts 테이블 참조)
 * - step: 마일스톤 단계 순서 (1, 2, 3, ...)
 * - title: 마일스톤 이름/제목 (예: "1단계: 기획 및 설계")
 * - description: 작업 범위/설명 (예: "요구사항 분석, 시스템 설계 문서 작성")
 * - amount: 해당 마일스톤의 결제 금액 (Long 타입, 원 단위)
 * 
 * [관계]
 * - contract_milestones.contract_id → contracts.contract_id (FK)
 * - 하나의 계약은 여러 개의 마일스톤을 가질 수 있음 (1:N 관계)
 * 
 * [주의사항]
 * - step은 1부터 시작하며, 계약 내에서 중복되지 않아야 함
 * - 모든 마일스톤의 amount 합계가 totalBudget과 일치해야 함 (비즈니스 로직 검증 필요)
 * - 결제 방식이 "FIXED"인 계약은 마일스톤이 없을 수 있음
 * 
 * ============================================================================
 */
@Getter
@Builder
public class ContractMilestoneVO {
    /** 계약 ID (FK, contracts 테이블 참조) */
    private final Integer contractId;
    
    /** 마일스톤 단계 순서 (1, 2, 3, ...) */
    private final Integer step;
    
    /** 마일스톤 이름/제목 (예: "1단계: 기획 및 설계") */
    private final String title;
    
    /** 작업 범위/설명 (예: "요구사항 분석, 시스템 설계 문서 작성") */
    private final String description;
    
    /** 해당 마일스톤의 결제 금액 (Long 타입, 원 단위) */
    private final Long amount;
}
