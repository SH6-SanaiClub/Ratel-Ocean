package com.sanaiclub.portfolio.model.vo;

import lombok.*;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FreelancerProjectExperienceVO {
    private Long experienceId;
    private Integer freelancerId;

    private String title;
    private String clientName;

    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate startDate;
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate endDate;

    private String role;
    private String description;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
