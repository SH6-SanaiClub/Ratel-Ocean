package com.sanaiclub.project.model.dto;

import lombok.Data;

import java.util.Date;

@Data
public class ReviewWriteDTO {
    private Integer projectId;
    private Integer contractId;
    private String projectTitle;
    private Date startDate;
    private Date endDate;

    private Integer freelancerId;
    private String freelancerName;

    private Integer rating;
    private String reviewContent;

    private Boolean renewalIntended;
}