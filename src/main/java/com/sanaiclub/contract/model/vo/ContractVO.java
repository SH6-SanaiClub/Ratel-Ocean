package com.sanaiclub.contract.model.vo;

import lombok.Builder;
import lombok.Getter;


@Getter
@Builder
public class ContractVO {
    /** 계약 ID (PK, AUTO_INCREMENT) */
    private final Integer contractId;
    
    /** 계약 시작일 (YYYY-MM-DD 형식) */
    private final String contractStartDate;
    
    /** 계약 종료일 (YYYY-MM-DD 형식) */
    private final String contractEndDate;
    
    /** 총 예산 (Long 타입, 원 단위) */
    private final Long totalBudget;
    
    /** 결제 방식 ("MILESTONE" 또는 "FULL") */
    private final String paymentMethod;
    
    /** 계약 상태 (WAITING, SIGNED, TERMINATED, COMPLETED) */
    private final ContractStatus contractStatus;

    /** 결제 상태 (UNPAID, PAID, PARTIAL_REFUNDED, REFUNDED) - 추가 */
    private final PaymentStatus paymentStatus;
    
    /** 원본 계약서 파일 경로 (contracts/{clientId}/{projectId}/{freelancerId}/{fileName}) */
    private final String originContractUrl;
    
    /** 플랫폼에서 생성한 계약서 경로 (선택, NULL 가능) */
    private final String platformContractUrl;
    
    /** AI 분석 리포트 경로 (선택, NULL 가능) */
    private final String aiReportUrl;
    
    /** 계약 체결 시각 (YYYY-MM-DD HH:mm:ss 형식) */
    private final String contractedAt;
    
    /** 계약 완료 시각 (완료 전까지는 NULL) */
    private final String completedAt;
    
    /** 취소/거절 사유 (취소 전까지는 NULL) */
    private final String cancelReason;
    
    /** 클라이언트가 프리랜서에게 준 평점 (1~5, 완료 후 입력, NULL 가능) */
    private final Integer clientRating;
    
    /** 클라이언트의 경험 평가 (완료 후 입력, NULL 가능) */
    private final String clientExperience;
    
    /** 재계약 의향 (완료 후 입력, NULL 가능) */
    private final Boolean clientIsRenewalIntended;
    
    /** 프리랜서가 클라이언트에게 준 평점 (1~5, 완료 후 입력, NULL 가능) */
    private final Integer freelancerRating;
    
    /** 프리랜서의 경험 평가 (완료 후 입력, NULL 가능) */
    private final String freelancerExperience;
}
