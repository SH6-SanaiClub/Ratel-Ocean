package com.sanaiclub.project.service;

import com.sanaiclub.project.dao.ProjectDashboardMapper;
import com.sanaiclub.project.model.dto.ProjectDashboardCardDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProjectDashboardService {

    private final ProjectDashboardMapper projectDashboardMapper;

    public List<ProjectDashboardCardDTO> getDashboardCards(String keyword, Integer page, Integer size) {
        int safeSize = (size == null || size <= 0) ? 10 : Math.min(size, 50);
        int safePage = (page == null || page < 1) ? 1 : page;
        int offset = (safePage - 1) * safeSize;

        return projectDashboardMapper.selectDashboardCards(keyword, true, safeSize, offset);
    }
}
