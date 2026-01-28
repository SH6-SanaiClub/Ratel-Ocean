package com.sanaiclub.project.service.impl;

import com.sanaiclub.project.dao.FreelancerProjectManageMapper;
import com.sanaiclub.project.model.dto.CalendarEventDTO;
import com.sanaiclub.project.model.dto.FreelancerProjectCardDTO;
import com.sanaiclub.project.model.dto.FreelancerProjectSummaryDTO;
import com.sanaiclub.project.service.FreelancerProjectManageService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class FreelancerProjectManageServiceImpl implements FreelancerProjectManageService {

    private final FreelancerProjectManageMapper freelancerProjectManageMapper;

    public FreelancerProjectSummaryDTO getSummary(Integer freelancerId) {
        return freelancerProjectManageMapper.selectSummary(freelancerId);
    }

    public List<FreelancerProjectCardDTO> getInProgressProjects(Integer freelancerId) {
        return freelancerProjectManageMapper.selectInProgressProjects(freelancerId);
    }

    public List<FreelancerProjectCardDTO> getAppliedProjects(Integer freelancerId) {
        return freelancerProjectManageMapper.selectAppliedProjects(freelancerId);
    }

    public List<FreelancerProjectCardDTO> getCompletedProjects(Integer freelancerId) {
        return freelancerProjectManageMapper.selectCompletedProjects(freelancerId);
    }

    public List<CalendarEventDTO> getCalendarEvents(Integer freelancerId, LocalDate start, LocalDate end) {
        return freelancerProjectManageMapper.selectCalendarEvents(freelancerId, start, end);
    }
}