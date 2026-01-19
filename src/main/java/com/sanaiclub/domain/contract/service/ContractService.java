package com.sanaiclub.domain.contract.service;

import com.sanaiclub.domain.contract.dto.*;
import com.sanaiclub.domain.project.dto.ProjectDTO;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * ContractService (Interface)
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [역할]
 * 계약 생성 전체 플로우를 조율하는 비즈니스 로직입니다.
 * 
 * [플로우 구성]
 * 1. [초기화] getInitialContract()
 *    - 프로젝트 정보 + 프리랜서 정보 조회
 *    - 계약 생성 전 UI에 표시할 데이터 준비
 * 
 * 2. [AI 분석] analyzeWithAI()
 *    - PDF 텍스트 추출
 *    - AI 계약 초안 + 인사이트 생성
 *    - 메모리에만 저장 (DB 저장 X)
 * 
 * 3. [사용자 검토] (JSP에서 수정)
 *    - 사용자가 AI 초안 수정 가능
 *    - DB 저장 X
 * 
 * 4. [계약 확정] confirmContract()
 *    - 사용자가 "확정" 버튼 클릭
 *    - contracts 테이블에 INSERT
 *    - contract_milestones 테이블에 배치 INSERT
 * 
 * 5. [리포트 생성] generateAIReport()
 *    - 계약 확정 후 AI 분석 리포트 저장
 *    - 프리랜서가 열람 가능
 * 
 * [핵심 규칙]
 * ✓ AI 결과는 메모리에만 존재 (DB 저장 X)
 * ✓ 계약 확정이 유일한 DB 저장 지점
 * ✓ 사용자가 최종 결정권 행사
 * ✓ PDF 텍스트만 저장 (이미지 X)
 * 
 * [주의]
 * - Spring @Transactional 사용 금지 (각 단계별 개별 처리)
 * - AI 실패해도 PDF 파일은 유지
 * - 계약 확정 실패하면 롤백 구현 필요
 */
public interface ContractService {
    
    /**
     * 계약 생성을 위한 초기 정보를 조회합니다.
     * 
     * [목적]
     * - contract-init.jsp에서 표시할 데이터
     * - 프로젝트 정보 + 프리랜서 정보 통합 조회
     * 
     * [입력]
     * @param projectId : 공고 ID
     * @param freelancerId : 지원한 프리랜서 ID
     * 
     * [출력]
     * @return ContractInitDTO
     *   - projectDTO: 공고 상세 정보
     *   - freelancerDTO: 프리랜서 프로필
     *   - estimatedBudget: AI가 예상하는 예산
     * 
     * [에러]
     * - 공고가 없으면 null
     * - 프리랜서가 없으면 null
     */
    ContractInitDTO getInitialContract(Long projectId, Long freelancerId);
    
    /**
     * PDF를 분석하고 AI 계약 초안을 생성합니다.
     * 
     * [플로우]
     * 1. PDF 텍스트 추출
     * 2. 파일 임시 저장
     * 3. AI 분석 (Mock or DeepSeek)
     * 4. 메모리에서 반환
     * 
     * [입력]
     * @param pdfFile : 업로드된 계약 PDF
     * @param originalFilename : 원본 파일명
     * @param projectDTO : 공고 정보
     * @param freelancerInfo : 프리랜서 정보
     * 
     * [출력]
     * @return AIContractInsightDTO
     *   - proposedStartDate, proposedEndDate
     *   - proposedBudget, proposedMilestones
     *   - riskFactors, warningPoints, reviewPoints
     *   - analysisModel ("mock" or "deepseek-live")
     *   - pdfPath (임시 저장 경로)
     * 
     * [중요]
     * - 이 메서드는 DB를 수정하지 않습니다
     * - extractedPdfPath는 메모리에만 저장
     * - 계약 확정 시에만 origin_contract_url에 저장
     * 
     * [에러 처리]
     * - PDF 읽기 실패 → null 반환 + 로그
     * - AI 요청 실패 → MockAI로 폴백
     */
    AIContractInsightDTO analyzeWithAI(
        File pdfFile,
        String originalFilename,
        ProjectDTO projectDTO,
        String freelancerInfo
    ) throws IOException;
    
    /**
     * 사용자가 수정한 계약을 확정하고 DB에 저장합니다.
     * 
     * [플로우]
     * 1. 유효성 검증 (예산, 마일스톤)
     * 2. contracts 테이블 INSERT
     * 3. contract_milestones 테이블 배치 INSERT
     * 4. 파일 경로 저장
     * 
     * [입력]
     * @param confirmDTO : 사용자가 수정한 계약 정보
     *   - projectId, freelancerId (필수)
     *   - contractDates: { startDate, endDate }
     *   - totalBudget (최소 값 검증)
     *   - paymentMethod: LUMPSUM or MILESTONE
     *   - milestones: List<ContractMilestoneDTO>
     *   - pdfPath: AI 분석 단계에서 받은 임시 경로
     * 
     * [출력]
     * @return 생성된 contract_id
     * 
     * [DB 상태 변경]
     * ✓ contracts 테이블에 행 추가
     * ✓ contract_milestones 테이블에 배치 추가
     * ✓ 각 마일스톤 status = "WAITING"
     * ✓ contracts.contract_status = "SIGNED"
     * ✓ contracts.origin_contract_url = pdfPath
     * 
     * [유효성 검증]
     * - 마일스톤 총액 == 계약 총액
     * - 모든 마일스톤에 due_date 있음
     * - paymentMethod에 따라 다른 검증
     * 
     * [에러]
     * - 검증 실패 → exception 발생
     * - DB INSERT 실패 → 롤백 로직 필요
     */
    Long confirmContract(ContractConfirmDTO confirmDTO) throws Exception;
    
    /**
     * 마일스톤 예산이 계약 예산과 일치하는지 검증합니다.
     * 
     * [목적]
     * - JS 유효성 검증 보완
     * - 서버사이드 검증
     * 
     * [입력]
     * @param contractBudget : 계약 총액
     * @param milestoneTotalBudget : 마일스톤 총액
     * 
     * [출력]
     * @return true (일치), false (불일치)
     * 
     * [규칙]
     * - 정확히 일치해야 함 (1원 오차도 허용 X)
     * - 마일스톤이 없으면 false
     */
    boolean validateMilestoneBudget(Long contractBudget, BigDecimal milestoneTotalBudget);
}
