package com.sanaiclub.project.service;

import com.sanaiclub.project.dao.ProjectDashboardMapper;
import com.sanaiclub.project.model.dto.DashboardPageDTO;
import com.sanaiclub.project.model.dto.ProjectDashboardCardDTO;
import com.sanaiclub.project.model.dto.RequiredStackDTO;
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

    /**
     * 프로젝트 목록 + 프로젝트별 요구 스택 조회
     * (keyword / onlyActive 조건만 적용)
     */
//    public List<ProjectDashboardCardDTO> getDashboardProjects(
//            String keyword,
//            boolean onlyActive
//    ) {
//
//        // 프로젝트 목록 조회 (조건만 적용, 아직 페이징 없음)
//        List<ProjectDashboardCardDTO> projects =
//                projectDashboardMapper.selectDashboardProjects(keyword, onlyActive);
//
//        if (projects == null || projects.isEmpty()) {
//            return Collections.emptyList();
//        }
//
//        // stacks 초기화
//        for (ProjectDashboardCardDTO p : projects) {
//            p.setStacks(new ArrayList<>());
//        }
//
//        // projectId 목록 추출
//        List<Long> projectIds = projects.stream()
//                .map(ProjectDashboardCardDTO::getProjectId)
//                .filter(Objects::nonNull)
//                .collect(Collectors.toList());
//
//        if (projectIds.isEmpty()) {
//            return projects;
//        }
//
//        // 스택 조회
//        List<RequiredStackDTO> stacks =
//                projectDashboardMapper.selectStacksByProjectId(projectIds);
//
//        if (stacks == null || stacks.isEmpty()) {
//            return projects;
//        }
//
//        // projectId 기준으로 그룹핑
//        Map<Long, List<RequiredStackDTO>> stackMap =
//                stacks.stream()
//                        .filter(s -> s.getProjectId() != null)
//                        .collect(Collectors.groupingBy(RequiredStackDTO::getProjectId));
//
//        // 프로젝트에 스택 붙이기
//        for (ProjectDashboardCardDTO p : projects) {
//            List<RequiredStackDTO> list = stackMap.get(p.getProjectId());
//            if (list != null) {
//                p.getStacks().addAll(list);
//            }
//        }
//
//        return projects;
//    }
    public DashboardPageDTO getDashboardProjects(String keyword, boolean onlyActive, Integer pageParam, Integer sizeParam) {

        int size = (sizeParam == null || sizeParam < 1) ? 10 : Math.min(sizeParam, 50);
        int page = (pageParam == null || pageParam < 1) ? 1 : pageParam;

        int totalCount = projectDashboardMapper.countDashboardProjects(keyword, onlyActive);
        int totalPages = (int) Math.ceil(totalCount / (double) size);
        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;

        int offset = (page - 1) * size;

        // 1) 프로젝트(부모)만 페이징 조회
        List<ProjectDashboardCardDTO> projects =
                projectDashboardMapper.selectDashboardProjects(keyword, onlyActive, size, offset);

        if (projects == null) projects = Collections.emptyList();

        // stacks null 방지
        for (ProjectDashboardCardDTO p : projects) {
            p.setStacks(new ArrayList<>());
        }

        // 2) 현재 페이지 projectIds로 스택 한 번에 조회
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

        // 3) 페이지 블록 계산(1~10, 11~20 이런 느낌)
        int blockSize = 10;
        int startPage = ((page - 1) / blockSize) * blockSize + 1;
        int endPage = Math.min(startPage + blockSize - 1, totalPages);

        DashboardPageDTO dto = new DashboardPageDTO();
        dto.setProjectList(projects);
        dto.setPage(page);
        dto.setSize(size);
        dto.setTotalCount(totalCount);
        dto.setTotalPages(totalPages);
        dto.setStartPage(startPage);
        dto.setEndPage(endPage);
        dto.setHasPrevBlock(startPage > 1);
        dto.setHasNextBlock(endPage < totalPages);
        dto.setPrevBlockPage(startPage - 1);
        dto.setNextBlockPage(endPage + 1);

        return dto;
    }

    public int countTodayNewProjects() {
        return projectDashboardMapper.todayNewProject();
    }

    public int countDeadlineWithinDays() {
        return projectDashboardMapper.deadlineWithin7Days();
    }
}
