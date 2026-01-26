package com.sanaiclub.portfolio.model.vo;

import lombok.*;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class FreelancerSkillVO {
    private Integer freelancerStackId;   // freelancer_stack_id
    private Integer freelancerId;
    private Integer stackId;
    private Integer stackLevel;       // 1~5
    private Integer stackYear;        // 0~ (SKILL/ POSITION 공통)
}
