package com.sanaiclub.user.model.dto;

import lombok.Data;

@Data
public class ClientDashboardDTO {
    private Integer totalProjects;      // 등록한 프로젝트 총 개수
    private Integer activeContracts;    // 진행 중인 계약 건수
    private Integer totalApplicants;    // 누적 지원자 수
    private Integer completedProjects;  // 완료된 프로젝트 수
}