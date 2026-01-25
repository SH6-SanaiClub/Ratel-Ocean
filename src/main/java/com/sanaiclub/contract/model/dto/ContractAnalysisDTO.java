package com.sanaiclub.contract.model.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

/**
 * ============================================================================
 * ContractAnalysisDTO - AI 계약 분석 결과 DTO
 * ============================================================================
 * 
 * [역할]
 * - AI가 분석한 계약 위험도 및 권장사항을 담는 데이터 전송 객체
 * - ContractAnalysisService.analyzeContract()의 반환 타입
 * - 프리랜서가 계약을 수락하기 전에 위험 요소를 파악하는 데 사용
 * 
 * [데이터 흐름]
 * - ContractAnalysisService.analyzeContract() → ContractAnalysisDTO
 * - FreelancerContractController.analyzeContract()에서 AI 분석 후 화면에 표시
 * - contractAnalysis.jsp에서 리포트 형태로 표시
 * 
 * [필드 설명]
 * - riskScore: 위험도 점수 (0-100, Integer)
 * - riskLevel: 위험도 레벨 ("LOW", "MEDIUM", "HIGH")
 * - riskDescription: 위험도 설명 (예: "프리랜서 평균 계약 대비 다소 불리")
 * - totalAmount: 총 금액 (예: "3,000,000원")
 * - contractPeriod: 계약 기간 (예: "2026-01-25 ~ 2026-02-24 (1개월)")
 * - paymentMethod: 지급 방식 (예: "일시 지급" 또는 "분할 지급 (마일스톤별)")
 * - delayPenalty: 지연 손해 배상 (예: "계약서에 명시되지 않음")
 * - riskClauses: 위험 조항 목록 (RiskClause)
 * 
 * [특징]
 * - @JsonIgnoreProperties(ignoreUnknown = true): JSON 역직렬화 시 알 수 없는 필드 무시
 * - AI가 생성한 정보이므로 사용자가 참고용으로만 사용
 * - 리포트 페이지에서만 표시 (계약 수락/거절 버튼 없음)
 * 
 * [사용 위치]
 * - 계약 분석 리포트 페이지: AI 분석 결과 표시
 * 
 * ============================================================================
 */
@Getter
@Setter
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class ContractAnalysisDTO {
    private Integer riskScore;
    private String riskLevel;
    private String riskDescription;
    private String totalAmount;
    private String contractPeriod;
    private String paymentMethod;
    private String delayPenalty;
    private List<RiskClause> riskClauses;

    /**
     * 위험 조항 정보
     */
    @Getter
    @Setter
    @NoArgsConstructor
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class RiskClause {
        private String level; // "HIGH", "MEDIUM"
        private String clauseNumber; // 예: "제 7조"
        private String clauseTitle; // 예: "지식재산권 귀속"
        private String problemDescription; // 왜 문제인가
        private String aiRecommendation; // AI 권장 대응
    }
}
