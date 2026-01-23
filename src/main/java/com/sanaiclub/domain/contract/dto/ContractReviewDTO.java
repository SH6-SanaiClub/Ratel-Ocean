package com.sanaiclub.domain.contract.dto;

import java.time.LocalDate;

/**
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 *  ContractReviewDTO - 계약 리뷰 작성/조회 DTO
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 
 * [역할]
 * 계약 완료 후 클라이언트 ↔ 프리랜서 간 상호 리뷰를 주고받기 위한 데이터 전송 객체.
 * 
 * [DB 테이블]
 * contracts 테이블의 리뷰 관련 컬럼 사용:
 * - client_rating (INT 0~20)
 * - client_experience (TEXT)
 * - client_is_renewal_intended (TINYINT(1))
 * - freelancer_rating (INT 0~20)
 * - freelancer_experience (TEXT)
 * 
 * [별점 변환 로직 (중요!)]
 * - 화면 입력: 0.0 ~ 10.0 (0.5 단위, 총 21개 값)
 * - DB 저장: 0 ~ 20 (INT)
 * - 변환 공식:
 *   DB 값 = 화면 값 × 2
 *   화면 값 = DB 값 ÷ 2
 * - 예시:
 *   화면 8.5점 → DB 17
 *   DB 14 → 화면 7.0점
 * 
 * [사용 시나리오]
 * 1. GET /review/client?contractId=1 → 리뷰 작성 화면 로드
 * 2. POST /review/client → 클라이언트가 프리랜서 평가
 * 3. GET /review/freelancer?contractId=1 → 리뷰 작성 화면 로드
 * 4. POST /review/freelancer → 프리랜서가 클라이언트 평가
 * 
 * [중복 방지]
 * - client_rating이 NULL이 아니면 → 클라이언트 리뷰 작성 완료
 * - freelancer_rating이 NULL이 아니면 → 프리랜서 리뷰 작성 완료
 * 
 * @author Ratel Ocean Team
 * @since 2026-01-15
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 */
public class ContractReviewDTO {
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 계약 기본 정보
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    private Long contractId;
    private Long clientId;
    private Long freelancerId;
    private String projectTitle;        // projects.title (JOIN)
    private LocalDate contractStartDate;
    private LocalDate contractEndDate;
    private Long totalBudget;
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 클라이언트 → 프리랜서 평가 (Client Reviews Freelancer)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /**
     * 클라이언트가 준 별점 (DB 저장값: INT 0~20)
     * 화면 표시 시 ÷ 2 하여 0.0 ~ 10.0으로 변환
     */
    private Integer clientRating;
    
    /**
     * 클라이언트가 작성한 공개 리뷰 (최대 500자)
     * contracts.client_experience (TEXT)
     */
    private String clientExperience;
    
    /**
     * 재계약 의사 여부 (클라이언트만 입력)
     * contracts.client_is_renewal_intended (TINYINT(1))
     * - true: 재계약 의사 있음
     * - false: 재계약 의사 없음
     * - null: 아직 작성 안 함
     */
    private Boolean clientIsRenewalIntended;
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 프리랜서 → 클라이언트 평가 (Freelancer Reviews Client)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /**
     * 프리랜서가 준 별점 (DB 저장값: INT 0~20)
     * 화면 표시 시 ÷ 2 하여 0.0 ~ 10.0으로 변환
     */
    private Integer freelancerRating;
    
    /**
     * 프리랜서가 작성한 공개 리뷰 (최대 500자)
     * contracts.freelancer_experience (TEXT)
     */
    private String freelancerExperience;
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 화면 전용 필드 (DB에는 없음, 입력 편의를 위한 필드)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /**
     * 화면에서 입력받는 별점 (0.0 ~ 10.0)
     * setter에서 자동으로 clientRating 또는 freelancerRating으로 변환
     */
    private Double displayRating;
    
    /**
     * 화면에서 입력받는 리뷰 텍스트
     * setter에서 자동으로 clientExperience 또는 freelancerExperience로 변환
     */
    private String displayExperience;
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 리뷰 상태 확인용 헬퍼 메서드
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /**
     * 클라이언트가 이미 리뷰를 작성했는지 확인
     * @return true: 작성 완료, false: 미작성
     */
    public boolean isClientReviewSubmitted() {
        return clientRating != null;
    }
    
    /**
     * 프리랜서가 이미 리뷰를 작성했는지 확인
     * @return true: 작성 완료, false: 미작성
     */
    public boolean isFreelancerReviewSubmitted() {
        return freelancerRating != null;
    }
    
    /**
     * 화면 표시용 클라이언트 별점 (0.0 ~ 10.0)
     * @return DB 값 ÷ 2
     */
    public Double getClientRatingDisplay() {
        return clientRating != null ? clientRating / 2.0 : null;
    }
    
    /**
     * 화면 표시용 프리랜서 별점 (0.0 ~ 10.0)
     * @return DB 값 ÷ 2
     */
    public Double getFreelancerRatingDisplay() {
        return freelancerRating != null ? freelancerRating / 2.0 : null;
    }
    
    /**
     * 화면 입력값 → DB 저장값 변환 (클라이언트 별점)
     * @param rating 0.0 ~ 10.0
     */
    public void setClientRatingFromDisplay(Double rating) {
        if (rating != null) {
            this.clientRating = (int) Math.round(rating * 2);
        }
    }
    
    /**
     * 화면 입력값 → DB 저장값 변환 (프리랜서 별점)
     * @param rating 0.0 ~ 10.0
     */
    public void setFreelancerRatingFromDisplay(Double rating) {
        if (rating != null) {
            this.freelancerRating = (int) Math.round(rating * 2);
        }
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // Getters and Setters (계약 기본 정보)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /**
     * 계약 ID (Primary Key)
     */
    public Long getContractId() {
        return contractId;
    }

    public void setContractId(Long contractId) {
        this.contractId = contractId;
    }

    /**
     * 클라이언트 ID (발주자)
     * 클라이언트가 리뷰 작성 권한 확인에 사용됨
     */
    public Long getClientId() {
        return clientId;
    }

    public void setClientId(Long clientId) {
        this.clientId = clientId;
    }

    /**
     * 프리랜서 ID (수주자)
     * 프리랜서가 리뷰 작성 권한 확인에 사용됨
     */
    public Long getFreelancerId() {
        return freelancerId;
    }

    public void setFreelancerId(Long freelancerId) {
        this.freelancerId = freelancerId;
    }

    /**
     * 프로젝트 제목 (프로젝트 테이블에서 JOIN)
     * 리뷰 작성 화면에서 "어떤 프로젝트에 대한 리뷰인지" 표시
     */
    public String getProjectTitle() {
        return projectTitle;
    }

    public void setProjectTitle(String projectTitle) {
        this.projectTitle = projectTitle;
    }

    /**
     * 계약 시작일
     * 화면에서 계약 기간 표시용
     */
    public LocalDate getContractStartDate() {
        return contractStartDate;
    }

    public void setContractStartDate(LocalDate contractStartDate) {
        this.contractStartDate = contractStartDate;
    }

    /**
     * 계약 종료일
     * 화면에서 계약 기간 표시용
     */
    public LocalDate getContractEndDate() {
        return contractEndDate;
    }

    public void setContractEndDate(LocalDate contractEndDate) {
        this.contractEndDate = contractEndDate;
    }

    /**
     * 계약 총액
     * 화면에서 계약 정보 요약 표시용
     */
    public Long getTotalBudget() {
        return totalBudget;
    }

    public void setTotalBudget(Long totalBudget) {
        this.totalBudget = totalBudget;
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // Getters and Setters (클라이언트 리뷰)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /**
     * 클라이언트가 준 별점 (DB: INT 0~20)
     * 중복 작성 방지에 사용: NULL이 아니면 이미 작성 완료
     */
    public Integer getClientRating() {
        return clientRating;
    }

    public void setClientRating(Integer clientRating) {
        this.clientRating = clientRating;
    }

    /**
     * 클라이언트 공개 리뷰 텍스트
     * 최대 500자, 선택 사항 (NULL 가능)
     */
    public String getClientExperience() {
        return clientExperience;
    }

    public void setClientExperience(String clientExperience) {
        this.clientExperience = clientExperience;
    }

    /**
     * 재계약 의사 (클라이언트만)
     * true: 재계약 원함, false: 재계약 안 함, null: 미작성
     */
    public Boolean getClientIsRenewalIntended() {
        return clientIsRenewalIntended;
    }

    public void setClientIsRenewalIntended(Boolean clientIsRenewalIntended) {
        this.clientIsRenewalIntended = clientIsRenewalIntended;
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // Getters and Setters (프리랜서 리뷰)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /**
     * 프리랜서가 준 별점 (DB: INT 0~20)
     * 중복 작성 방지에 사용: NULL이 아니면 이미 작성 완료
     */
    public Integer getFreelancerRating() {
        return freelancerRating;
    }

    public void setFreelancerRating(Integer freelancerRating) {
        this.freelancerRating = freelancerRating;
    }

    /**
     * 프리랜서 공개 리뷰 텍스트
     * 최대 500자, 선택 사항 (NULL 가능)
     */
    public String getFreelancerExperience() {
        return freelancerExperience;
    }

    public void setFreelancerExperience(String freelancerExperience) {
        this.freelancerExperience = freelancerExperience;
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // Getters and Setters (화면 표시 전용)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /**
     * 화면에서 표시되는 별점 (0.0 ~ 10.0)
     * 주로 getClientRatingDisplay(), getFreelancerRatingDisplay()로 가져옴
     */
    public Double getDisplayRating() {
        return displayRating;
    }

    public void setDisplayRating(Double displayRating) {
        this.displayRating = displayRating;
    }

    /**
     * 화면에서 표시되는 리뷰 텍스트
     * 주로 getClientExperience(), getFreelancerExperience()로 가져옴
     */
    public String getDisplayExperience() {
        return displayExperience;
    }

    public void setDisplayExperience(String displayExperience) {
        this.displayExperience = displayExperience;
    }

    @Override
    public String toString() {
        return "ContractReviewDTO{" +
                "contractId=" + contractId +
                ", clientId=" + clientId +
                ", freelancerId=" + freelancerId +
                ", projectTitle='" + projectTitle + '\'' +
                ", clientRating=" + clientRating +
                ", clientReviewSubmitted=" + isClientReviewSubmitted() +
                ", freelancerRating=" + freelancerRating +
                ", freelancerReviewSubmitted=" + isFreelancerReviewSubmitted() +
                '}';
    }
}
