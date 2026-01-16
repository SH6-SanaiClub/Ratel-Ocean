package com.sanaiclub.project.model.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RequiredStackDTO {
    private Long projectStackId; // ✅ 중복 제거용 id
    private Long stackId;
    private String stackName;
    private Integer stackLevel;
    private Integer stackYear;
}