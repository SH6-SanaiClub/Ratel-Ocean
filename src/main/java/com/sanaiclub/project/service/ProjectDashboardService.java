package com.sanaiclub.project.service;

import com.sanaiclub.project.dao.ProjectDashboardMapper;
import com.sanaiclub.project.model.dto.DashboardPageDTO;
import com.sanaiclub.project.model.dto.ProjectDashboardCardDTO;
import com.sanaiclub.project.model.dto.RequiredStackDTO;
import com.sanaiclub.project.model.vo.ProjectsVO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProjectDashboardService {

    @Autowired
    private ProjectDashboardMapper projectDashboardMapper;

    public DashboardPageDTO getDashboardProjects(String keyword, boolean onlyActive, Integer pageParam, Integer sizeParam, String summary) {

        int size = (sizeParam == null || sizeParam < 1) ? 10 : Math.min(sizeParam, 50);
        int page = (pageParam == null || pageParam < 1) ? 1 : pageParam;

        int totalCount = projectDashboardMapper.countDashboardProjects(keyword, onlyActive, summary);
        int totalPages = (int) Math.ceil(totalCount / (double) size);
        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;

        int offset = (page - 1) * size;

        int userId = 1; // 임시

        // 프로젝트만 페이징 조회
        List<ProjectDashboardCardDTO> projects =
                projectDashboardMapper.selectDashboardProjects(keyword, onlyActive, size, offset, userId, summary);

        if (projects == null) projects = Collections.emptyList();

        // stacks null 방지
        for (ProjectDashboardCardDTO p : projects) {
            p.setStacks(new ArrayList<>());
        }

        // 현재 페이지 projectIds로 스택 한 번에 조회
        List<Long> projectIds = projects.stream()
                .map(ProjectDashboardCardDTO::getProjectId)
                .filter(Objects::nonNull)
                .collect(Collectors.toList());

        if (!projectIds.isEmpty()) {
            List<RequiredStackDTO> stacks = projectDashboardMapper.selectStacksByProjectId(projectIds);
            if (stacks != null && !stacks.isEmpty()) {
                Map<Long, List<RequiredStackDTO>> stackMap =
                        stacks.stream().collect(Collectors.groupingBy(RequiredStackDTO::getProjectId));
                for (ProjectDashboardCardDTO p : projects) {
                    List<RequiredStackDTO> list = stackMap.get(p.getProjectId());
                    if (list != null) p.getStacks().addAll(list);
                }
            }
        }

        // 페이지 블록 계산(1~10, 11~20)
        int blockSize = 10;
        int startPage = ((page - 1) / blockSize) * blockSize + 1;
        int endPage = Math.min(startPage + blockSize - 1, totalPages);

        DashboardPageDTO dashboardPageDTO = new DashboardPageDTO();
        dashboardPageDTO.setProjectList(projects);
        dashboardPageDTO.setPage(page);
        dashboardPageDTO.setSize(size);
        dashboardPageDTO.setTotalCount(totalCount);
        dashboardPageDTO.setTotalPages(totalPages);
        dashboardPageDTO.setStartPage(startPage);
        dashboardPageDTO.setEndPage(endPage);
        dashboardPageDTO.setHasPrevBlock(startPage > 1);
        dashboardPageDTO.setHasNextBlock(endPage < totalPages);
        dashboardPageDTO.setPrevBlockPage(startPage - 1);
        dashboardPageDTO.setNextBlockPage(endPage + 1);

        return dashboardPageDTO;
    }

    public int countTodayNewProjects() {
        return projectDashboardMapper.todayNewProject();
    }

    public int countDeadlineWithinDays() {
        return projectDashboardMapper.deadlineWithin7Days();
    }

    public ProjectsVO getProjectDetail(long projectId) {
        return projectDashboardMapper.selectProjectDetail(projectId);
    }
}
