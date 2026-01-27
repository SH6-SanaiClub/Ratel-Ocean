package com.sanaiclub.manage.model.dto;

import lombok.Data;

@Data
public class MilestoneDTO {
    private Integer milestoneId;
    private Integer contractId;
    private Integer stepOrder;
    private String milestoneName;
    private String workScope;
    private Long amount;
    private String dueDate; // yyyy-MM-dd (nullable)
    private String status;  // WAITING/DEPOSITED/REQUESTED/PAID/CANCELED

    /**
     * 이 단계에만 "승인요청"/"요청취소" 버튼 노출
     */
    private Boolean actionable;
}
