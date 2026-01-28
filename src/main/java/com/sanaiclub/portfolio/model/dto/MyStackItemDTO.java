package com.sanaiclub.portfolio.model.dto;

import lombok.Data;

@Data
public class MyStackItemDTO {
    private Integer stackId;
    private String stackName;
    private String category;
    private Integer stackLevel;
    private Integer stackYear;
}
