package com.sanaiclub.project.model.dto;

import lombok.Data;

@Data
public class SaveReviewRequestDTO {
    private Integer contractId;
    private Integer rating;
    private String experience;
}
