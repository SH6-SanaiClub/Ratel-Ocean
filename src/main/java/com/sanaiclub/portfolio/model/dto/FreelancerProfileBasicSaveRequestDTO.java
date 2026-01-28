package com.sanaiclub.portfolio.model.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FreelancerProfileBasicSaveRequestDTO {
    private Integer userId;

    private String nickname;
    private String introduction;

    private String githubUrl;   // null 가능
    private String websiteUrl;  // null 가능

    // education
    private String schoolName;  // null 가능
    private String major;       // null 가능
    private String degree;      // null 가능
    private String gradStatus;  // null 가능
}
