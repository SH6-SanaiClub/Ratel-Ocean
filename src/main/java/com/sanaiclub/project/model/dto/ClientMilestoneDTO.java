package com.sanaiclub.project.model.dto;

import lombok.Data;
import java.util.Date;

@Data
public class ClientMilestoneDTO {
    private Integer milestoneId;
    private Integer contractId;
    private Integer stepOrder;
    private String milestoneName;
    private Integer amount;
    private Date dueDate;
    private String status;
}