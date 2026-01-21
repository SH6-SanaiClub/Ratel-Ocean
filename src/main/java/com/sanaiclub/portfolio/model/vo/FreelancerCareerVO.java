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
public class FreelancerCareerVO {
    private Long careerId;
    private Integer freelancerId;

    private String companyName;
    private String role;
    private String position;

    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate startDate;
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate endDate;

    private String description;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
