package com.sanaiclub.domain.contract.service.ai;

import com.sanaiclub.domain.contract.dto.AIContractInsightDTO;
import com.sanaiclub.domain.project.dto.ProjectDTO;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * AIInsightService (Interface)
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [역할]
 * 계약 분석을 위한 AI 서비스의 표준 인터페이스입니다.
 * 
 * [설계 의도]
 * 1. 인터페이스에 의존 → Mock/Real AI 변경이 자유로움
 * 2. 테스트 환경과 프로덕션 환경 구분 가능
 * 3. AI를 제거해도 시스템이 무너지지 않도록 설계
 * 4. AI는 "조언자"이지 "결정권자"가 아님을 명시
 * 
 * [호출 흐름]
 * ContractController 
 *   → ContractService 
 *     → AIInsightService.analyzeContract()
 *       → 초안 정보 반환 (DB 저장 X)
 *   → JSP 수정 폼 표시
 *   → 사용자 확정 시 DB INSERT
 * 
 * [주의]
 * - AI 결과는 "제안"일 뿐, 최종 결정권은 사용자에게 있음
 * - 이를 JSP에 반드시 명시해야 함
 */
public interface AIInsightService {
    
    /**
     * 계약서 PDF + 프로젝트 정보를 기반으로 AI 분석을 수행합니다.
     * 
     * [입력]
     * @param pdfText               : PDF에서 추출한 텍스트
     * @param projectDTO            : 프로젝트 기본 정보 (스택, 설명 등)
     * @param projectDescription    : 프로젝트 상세 설명
     * @param freelancerExperience  : 프리랜서 경력/스택 정보
     * 
     * [출력]
     * @return AIContractInsightDTO : 계약 초안 + 인사이트
     *         - null이 반환될 수 없음 (항상 유효한 초안 반환)
     *         - 오류 시 DefaultMilestones 포함한 Fallback DTO 반환
     * 
     * [플로우]
     * 1. 입력 유효성 검증
     * 2. AI API 호출 (또는 Mock 데이터 사용)
     * 3. JSON 파싱 → DTO 변환
     * 4. 사용자 수정 가능한 형태로 반환
     * 5. DB 저장은 여기서 하지 않음 (계약 확정 후)
     * 
     * [오류 처리]
     * - API 실패: Graceful Fallback (기본값 + 경고)
     * - 파싱 실패: 구조적 기본값 제공
     * - 네트워크 오류: Mock 데이터로 대체
     */
    AIContractInsightDTO analyzeContract(
        String pdfText,
        ProjectDTO projectDTO,
        String projectDescription,
        String freelancerExperience
    );
    
    /**
     * AI 서비스의 현재 상태를 반환합니다.
     * 
     * [사용 목적]
     * - UI에서 "Mock AI 사용 중" 또는 "실제 AI 사용 중" 표시
     * - 로깅 및 디버깅
     * 
     * @return "mock" | "deepseek-live" | "degraded" 등
     */
    String getServiceStatus();
    
    /**
     * 마일스톤 금액 총합이 예산과 일치하는지 검증합니다.
     * 
     * [설계 의도]
     * - AI가 제안한 마일스톤이 현실적인지 판단
     * - 사용자에게 불일치 항목 명시
     * 
     * @param totalBudget : 계약 총 예산
     * @param milestoneTotalAmount : 마일스톤 금액 합계
     * @return true if (milestoneTotalAmount == totalBudget)
     */
    boolean validateMilestoneAmount(Long totalBudget, Long milestoneTotalAmount);
}
