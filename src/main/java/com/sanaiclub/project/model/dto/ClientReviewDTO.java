package com.sanaiclub.project.model.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.Date;

@Data
public class ClientReviewDTO {
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