package com.sanaiclub.manage.model.dto;

import lombok.Data;

@Data
public class CalendarEventDTO {

    private String date;     // yyyy-mm-dd
    private String type;     // MILESTONE / CONTRACT_START / CONTRACT_END
    private String title;    // 표시 텍스트
    private Integer projectId;
    private Integer contractId;
    private Integer milestoneId; // milestone이면 세팅
    private Integer stepOrder;
}