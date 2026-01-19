package com.sanaiclub.domain.contract.mapper;

import com.sanaiclub.domain.contract.dto.ContractDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * ContractMapper (Interface)
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [역할]
 * contracts 테이블에 대한 MyBatis 매퍼입니다.
 * 
 * [설계]
 * - XML 매퍼와 함께 사용 (ContractMapper.xml)
 * - @Param 어노테이션으로 파라미터 바인딩
 * - 자동 트랜잭션 관리
 * 
 * [주의]
 * - origin_contract_url: PDF 경로 (계약 생성 시 저장)
 * - ai_report_url: AI 리포트 (계약 확정 후 저장)
 * - application_id는 UNIQUE이므로 중복 계약 방지
 */
@Mapper
public interface ContractMapper {
    
    /**
     * 계약 ID로 계약을 조회합니다.
     */
    ContractDTO selectById(@Param("contractId") Long contractId);
    
    /**
     * 프로젝트 공고별 계약을 조회합니다.
     */
    ContractDTO selectByApplicationId(@Param("applicationId") Long applicationId);
    
    /**
     * 새로운 계약을 생성합니다.
     * 
     * [입력]
     * contract: 계약 정보
     *   - applicationId: 프로젝트 공고 ID
     *   - totalBudget: 계약 총액
     *   - paymentMethod: "LUMPSUM" or "MILESTONE"
     *   - contractStartDate, contractEndDate: 계약 기간
     *   - originContractUrl: 업로드된 PDF 경로
     * 
     * [출력]
     * - 생성된 계약 ID (contract.contractId에 자동 설정)
     * - contract_status는 자동으로 'SIGNED' 저장
     */
    int insert(ContractDTO contract);
    
    /**
     * 계약 상태를 변경합니다.
     * 
     * [파라미터]
     * @param contractId: 계약 ID
     * @param status: 새로운 상태 ('IN_PROGRESS', 'COMPLETED', 'TERMINATED')
     */
    int updateStatus(@Param("contractId") Long contractId, @Param("status") String status);
    
    /**
     * 계약을 완료 상태로 변경합니다.
     */
    int markAsCompleted(@Param("contractId") Long contractId);
    
    /**
     * AI 리포트 URL을 저장합니다.
     */
    int updateAIReportUrl(@Param("contractId") Long contractId, 
                          @Param("aiReportUrl") String aiReportUrl);
    
    /**
     * 특정 상태의 계약 건수를 조회합니다.
     */
    int selectStatusCount(@Param("status") String status);
}
