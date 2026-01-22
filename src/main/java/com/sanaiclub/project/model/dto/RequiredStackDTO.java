package com.sanaiclub.project.model.dto;

import lombok.*;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RequiredStackDTO {
    private Integer projectStackId;  // PK
    private Integer projectId;    // 프로젝트 ID
    private Integer stackId;      // 스택 ID
    private String category;      // 'POSITION' 또는 'SKILL'
    private String stackName;     // 스택 이름 (Java, Backend 등)
    private Integer stackLevel;   // 숙련도
    private Integer stackYear;    // 연차
}