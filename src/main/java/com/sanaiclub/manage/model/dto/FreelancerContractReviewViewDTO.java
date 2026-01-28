package com.sanaiclub.manage.model.dto;

import lombok.Data;

/**
 * 한 계약에 대한 양방향 리뷰 조회용
 * - 프리랜서 → 클라이언트 : freelancer_rating / freelancer_experience
 * - 클라이언트 → 프리랜서 : client_rating / client_experience / client_is_renewal_intended
 */
@Data
public class FreelancerContractReviewViewDTO {
    private Integer contractId;
    private String projectTitle;
    private String clientName;

    private Integer freelancerRating;
    private String freelancerExperience;

    private Integer clientRating;
    private String clientExperience;
    private Boolean clientIsRenewalIntended;
}
