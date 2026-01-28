package com.sanaiclub.portfolio.model.dto;

import com.sanaiclub.portfolio.model.vo.FreelancerCareerVO;
import com.sanaiclub.portfolio.model.vo.FreelancerPortfolioVO;
import com.sanaiclub.portfolio.model.vo.FreelancerProjectExperienceVO;
import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FreelancerProfileViewDTO {

    private Integer userId;

    // users
    private String loginId;
    private String email;
    private String profileImageUrl;

    // freelancer_profiles
    private String nickname;
    private String introduction;
    private String githubUrl;
    private String websiteUrl;

    // education
    private String schoolName;
    private String major;
    private String degree;
    private String gradStatus;

    // stacks
    private List<MyStackItemDTO> skills;     // category=SKILL (연차 desc)
    private List<MyStackItemDTO> positions;  // category=POSITION

    // career / experiences
    private List<FreelancerCareerVO> careers;
    private List<FreelancerProjectExperienceVO> projectExperiences;

    // portfolios (public only)
    private List<FreelancerPortfolioVO> publicPortfolios;

    // view flags
    private boolean owner; // 본인 여부
}
