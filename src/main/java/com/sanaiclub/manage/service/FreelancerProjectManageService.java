package com.sanaiclub.manage.service;

import com.sanaiclub.manage.model.dto.CalendarEventDTO;
import com.sanaiclub.manage.model.dto.FreelancerProjectCardDTO;
import com.sanaiclub.manage.model.dto.FreelancerProjectSummaryDTO;

import java.time.LocalDate;
import java.util.List;

public interface FreelancerProjectManageService {
    /**
     * 대시보드 상단 요약 정보
     */
    FreelancerProjectSummaryDTO getSummary(Integer freelancerId);

    /**
     * 진행 중인 프로젝트 목록
     */
    List<FreelancerProjectCardDTO> getInProgressProjects(Integer freelancerId);

    /**
     * 지원한 프로젝트 목록
     */
    List<FreelancerProjectCardDTO> getAppliedProjects(Integer freelancerId);

    /**
     * 완료된 프로젝트 목록
     */
    List<FreelancerProjectCardDTO> getCompletedProjects(Integer freelancerId);

    /**
     * 캘린더 이벤트 조회
     */
    List<CalendarEventDTO> getCalendarEvents(
            Integer freelancerId,
            LocalDate start,
            LocalDate end
    );
}
