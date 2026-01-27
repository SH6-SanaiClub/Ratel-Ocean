package com.sanaiclub.contract.model.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

/** AI 계약 분석 결과 DTO. 위험도 점수, 레벨, 위험 조항 목록 포함. 프리랜서 참고용. */
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

    /** 위험 조항 정보 */
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
