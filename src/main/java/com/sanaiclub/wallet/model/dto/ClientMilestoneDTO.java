package com.sanaiclub.wallet.model.dto;

import com.sanaiclub.contract.model.vo.MilestoneStatus;
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

    private MilestoneStatus status;
}