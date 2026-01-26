package com.sanaiclub.portfolio.model.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FreelancerProfileBasicViewDTO {
    private Integer userId;

    // users
    private String profileImageUrl;

    // freelancer_profiles
    private String nickname;
    private String introduction;
    private String githubUrl;
    private String websiteUrl;

    // education (freelancer_profiles)
    private String schoolName;
    private String major;
    private String degree;
    private String gradStatus;

    // portfolio (latest 1)
    private Integer portfolioId;
    private String portfolioTitle;
    private String portfolioUrl;
    private Long portfolioFileSize; // bytes
    private Boolean portfolioPublic;
}
