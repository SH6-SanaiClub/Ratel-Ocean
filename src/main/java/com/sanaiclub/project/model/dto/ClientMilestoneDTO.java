package com.sanaiclub.project.model.dto;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.Date;

@Data
public class ClientMilestoneDTO {
    private Integer milestoneId;
    private Integer contractId;
    private Integer stepOrder;
    private String milestoneName;
    private Integer amount;
    private LocalDateTime dueDate;
    private String status;
    private String freelancerName;
}