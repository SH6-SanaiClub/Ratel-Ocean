package com.sanaiclub.project.model.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProjectStackVO {
    private Integer projectStackId;
    private Integer projectId;
    private Integer stackId;
    private Integer stackLevel;
    private Integer stackYear;
}