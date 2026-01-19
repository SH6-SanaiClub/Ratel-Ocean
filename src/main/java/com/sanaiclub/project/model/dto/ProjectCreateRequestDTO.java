package com.sanaiclub.project.model.dto;

import com.sanaiclub.project.model.vo.ProjectStatus;
import lombok.Data;
import java.util.List;

@Data
public class ProjectCreateRequestDTO {
    // Step 1
    private Integer positionId;
    private String title;

    // Step 2
    private String description;
    private List<Integer> stackIds;
    private Boolean stackIdsUnknown;
    private Integer minLevel;
    private Integer minYear;

    // Step 3
    private String budget;
    private Boolean budgetNegotiable;

    private String startType;
    private String startDate;
    private Boolean startNegotiable;

    private String estDuration;
    private Boolean durationNegotiable;

    // Step 4
    private String communicateMethod;
    private String paymentMethod;
    private Integer maxRevisionCount;
    private String changePolicy;

    // Hidden Fields
    private Boolean isPublic;
    private ProjectStatus projectStatus;

    private String planUrl;
    private String fileSize;
}