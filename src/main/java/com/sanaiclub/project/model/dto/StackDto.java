package com.sanaiclub.project.model.dto;

import lombok.Data;

@Data
public class StackDto {
    private Integer stackId;
    private String stackName;
    private String category;   // SKILL or POSITION
}