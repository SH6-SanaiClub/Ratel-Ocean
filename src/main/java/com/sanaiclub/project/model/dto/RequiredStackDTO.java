package com.sanaiclub.project.model.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RequiredStackDTO {
    private Integer projectStackId; // 중복 제거용 id
    private Integer stackId;
    private String stackName;
    private String category;
    private Integer stackLevel;
    private Integer stackYear;
    private Integer projectId;
}