package com.sanaiclub.portfolio.model.vo;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FreelancerPortfolioVO {
    private Integer portfolioId;
    private Integer freelancerId;

    private String title;
    private String description;
    private String portfolioUrl;
    private Long fileSize;        // bytes
    private Boolean isPublic;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
