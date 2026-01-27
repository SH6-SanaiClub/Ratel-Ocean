package com.sanaiclub.manage.model.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
public class FreelancerMilestoneDTO {

    private Long milestoneId;
    private Integer stepOrder;
    private String milestoneName;
    private String workScope;
    private Long amount;
    private LocalDate dueDate;
    private String status;

    // 화면용
    private Boolean isFirstWaiting;
    private Boolean canToggleRequest;
}
