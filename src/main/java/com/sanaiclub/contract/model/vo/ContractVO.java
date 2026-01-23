package com.sanaiclub.contract.model.vo;

import lombok.Builder;
import lombok.Getter;

/**
 * ============================================================================
 * ContractVO - 계약 Value Object (DB 엔티티)
 * ============================================================================
 * 
 * [역할]
 * - DB의 contracts 테이블과 1:1 매핑되는 불변 객체
 * - MyBatis를 통해 DB에서 조회한 데이터를 담는 컨테이너
 * - Service 계층에서 사용되는 DB 엔티티 표현
 * 
 * [특징]
 * - 불변 객체: final 필드, setter 없음
 * - Builder 패턴: ContractVO.builder()로만 생성 가능
 * - Lombok 사용: @Getter, @Builder 어노테이션으로 보일러플레이트 코드 제거
 * 
 * [사용 계층]
 * - Mapper → Service: DB 조회 결과를 VO로 반환
 * - Service → Service: 비즈니스 로직에서 VO 사용
 * - Service → DTO: VO를 DTO로 변환하여 Controller에 전달
 * 
 * [필드 설명]
 * - contractId: 계약 ID (PK, AUTO_INCREMENT)
 * - contractStartDate: 계약 시작일 (YYYY-MM-DD 형식)
 * - contractEndDate: 계약 종료일 (YYYY-MM-DD 형식)
 * - totalBudget: 총 예산 (Long 타입, 원 단위)
 * - paymentMethod: 결제 방식 ("MILESTONE" 또는 "FIXED")
 * - contractStatus: 계약 상태 (WAITING, SIGNED, TERMINATED, COMPLETED)
 * - originContractUrl: 원본 계약서 파일 경로 (contracts/{clientId}/{projectId}/{freelancerId}/{fileName})
 * - platformContractUrl: 플랫폼에서 생성한 계약서 경로 (선택)
 * - aiReportUrl: AI 분석 리포트 경로 (선택)
 * - contractedAt: 계약 체결 시각 (YYYY-MM-DD HH:mm:ss 형식)
 * - completedAt: 계약 완료 시각 (완료 전까지는 NULL)
 * - cancelReason: 취소/거절 사유 (취소 전까지는 NULL)
 * - clientRating: 클라이언트가 프리랜서에게 준 평점 (1~5, 완료 후 입력)
 * - clientExperience: 클라이언트의 경험 평가 (완료 후 입력)
 * - clientIsRenewalIntended: 재계약 의향 (완료 후 입력)
 * - freelancerRating: 프리랜서가 클라이언트에게 준 평점 (1~5, 완료 후 입력)
 * - freelancerExperience: 프리랜서의 경험 평가 (완료 후 입력)
 * 
 * [주의사항]
 * - NULL 가능한 필드: originContractUrl, platformContractUrl, aiReportUrl, completedAt, cancelReason, 평가 관련 필드
 * - contractStatus는 ContractStatus enum의 name() 값 (문자열)
 * - originContractUrl은 경로 패턴으로 프로젝트/프리랜서 정보 추출 가능
 * 
 * ============================================================================
 */
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
    
    /** 결제 방식 ("MILESTONE" 또는 "FIXED") */
    private final String paymentMethod;
    
    /** 계약 상태 (WAITING, SIGNED, TERMINATED, COMPLETED) */
    private final String contractStatus;
    
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
