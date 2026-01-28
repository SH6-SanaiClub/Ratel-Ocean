package com.sanaiclub.portfolio.model.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CompletedProjectStackDTO {
    private Integer stackId;
    private String stackName;
    private Boolean isPrimary;
}
