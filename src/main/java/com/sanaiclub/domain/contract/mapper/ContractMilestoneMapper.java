package com.sanaiclub.domain.contract.mapper;

import com.sanaiclub.domain.contract.dto.ContractMilestoneDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * ContractMilestoneMapper (Interface)
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [역할]
 * contract_milestones 테이블에 대한 MyBatis 매퍼입니다.
 * 
 * [설계]
 * - XML 매퍼와 함께 사용 (ContractMilestoneMapper.xml)
 * - 배치 작업 지원 (insertBatch)
 * - 상태 관리 (WAITING → DEPOSITED → REQUESTED → PAID)
 * 
 * [주의]
 * - step_order는 1부터 시작 (중복 불가)
 * - 마일스톤 금액 합계는 contracts.total_budget과 일치해야 함
 * - due_date는 contracts.contract_end_date 이전이어야 함
 */
@Mapper
public interface ContractMilestoneMapper {
    
    /**
     * 계약별 모든 마일스톤을 조회합니다.
     * 
     * [출력]
     * step_order로 정렬된 마일스톤 목록
     * (1번 → 2번 → 3번 → 4번 순서)
     */
    List<ContractMilestoneDTO> selectByContractId(@Param("contractId") Long contractId);
    
    /**
     * 마일스톤 ID로 조회합니다.
     */
    ContractMilestoneDTO selectById(@Param("milestoneId") Long milestoneId);
    
    /**
     * 새로운 마일스톤을 생성합니다.
     * 
     * [입력]
     * milestone: 마일스톤 정보
     *   - contractId: 계약 ID
     *   - stepOrder: 순서 (1, 2, 3...)
     *   - milestoneName: "1단계: 시스템 설계"
     *   - workScope: 상세 작업 범위
     *   - amount: 이 마일스톤의 금액
     *   - dueDate: 완료 예정일
     * 
     * [출력]
     * - 생성된 마일스톤 ID (milestone.milestoneId에 자동 설정)
     * - status는 자동으로 'WAITING' 저장
     */
    int insert(ContractMilestoneDTO milestone);
    
    /**
     * 마일스톤을 배치로 생성합니다.
     * 
     * [목적]
     * - 계약 생성 시 여러 마일스톤을 한 번에 저장
     * - 데이터베이스 왕복 최소화
     * 
     * [입력]
     * List<ContractMilestoneDTO>: 생성할 마일스톤 목록
     * 
     * [출력]
     * - 생성된 행 수
     */
    int insertBatch(List<ContractMilestoneDTO> milestones);
    
    /**
     * 마일스톤 상태를 변경합니다.
     * 
     * [파라미터]
     * @param milestoneId: 마일스톤 ID
     * @param status: 새로운 상태
     *        ('DEPOSITED', 'REQUESTED', 'PAID', 'CANCELED')
     */
    int updateStatus(@Param("milestoneId") Long milestoneId, @Param("status") String status);
    
    /**
     * 계약별 마일스톤 총액을 조회합니다.
     * 
     * [목적]
     * - 계약 예산과 마일스톤 합계 검증
     * - 정산 시 총 지급 금액 계산
     * 
     * [주의]
     * - CANCELED 마일스톤은 제외
     */
    Long selectTotalAmountByContractId(@Param("contractId") Long contractId);
}
