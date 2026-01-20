package com.sanaiclub.project.service;

import com.sanaiclub.project.dao.ProjectBookmarkMapper;
import com.sanaiclub.project.dao.ProjectDashboardMapper;
import com.sanaiclub.project.model.dto.DashboardPageDTO;
import com.sanaiclub.project.model.dto.ProjectDashboardCardDTO;
import com.sanaiclub.project.model.dto.ProjectDetailDTO;
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

    @Autowired
    private ProjectBookmarkMapper projectBookmarkMapper;

    public DashboardPageDTO getDashboardProjects(String keyword, boolean onlyActive, Integer pageParam, Integer sizeParam, String summary,
                                                 String sort, List<Integer> positionIds, List<Integer> stackIds,
                                                 Integer minBudget, Integer maxBudget, Integer userId) {

        int size = (sizeParam == null || sizeParam < 1) ? 10 : Math.min(sizeParam, 50);
        int page = (pageParam == null || pageParam < 1) ? 1 : pageParam;

        int totalCount = projectDashboardMapper.countDashboardProjects(
                keyword, onlyActive, summary, positionIds, stackIds, minBudget, maxBudget
        );
        int totalPages = (int) Math.ceil(totalCount / (double) size);
        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;

        int offset = (page - 1) * size;

        // 프로젝트만 페이징 조회
        List<ProjectDashboardCardDTO> projects = projectDashboardMapper.selectDashboardProjects(
                keyword, onlyActive, size, offset, userId, summary,
                sort, positionIds, stackIds, minBudget, maxBudget
        );

        if (projects == null) projects = Collections.emptyList();

        // stacks null 방지
        for (ProjectDashboardCardDTO p : projects) {
            p.setStacks(new ArrayList<>());
        }

        // 현재 페이지 projectIds로 스택 한 번에 조회
        List<Integer> projectIds = projects.stream()
                .map(ProjectDashboardCardDTO::getProjectId)
                .filter(Objects::nonNull)
                .collect(Collectors.toList());

        if (!projectIds.isEmpty()) {
            List<RequiredStackDTO> stacks = projectDashboardMapper.selectStacksByProjectId(projectIds);
            if (stacks != null && !stacks.isEmpty()) {
                Map<Integer, List<RequiredStackDTO>> stackMap =
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

    public ProjectDetailDTO getProjectDetail(Integer projectId, Integer userId) {
        // 1. 프로젝트 기본 정보 조회
        ProjectDetailDTO detail = projectDashboardMapper.selectProjectDetail(projectId);

        if (detail == null) {
            throw new RuntimeException("프로젝트를 찾을 수 없습니다."); // 또는 null 리턴 처리
        }

        // 2. 기술 스택 조회 및 세팅
        // (기존 selectStacksByProjectId 재사용 - List<Integer>를 받으므로 싱글톤 리스트로 전달)
        List<RequiredStackDTO> stacks = projectDashboardMapper.selectStacksByProjectId(Collections.singletonList(projectId));
        detail.setStacks(stacks);

        // 3. 로그인 사용자 관련 정보 세팅
        if (userId != null) {
            // 지원 여부 확인
            boolean applied = projectDashboardMapper.hasUserApplied(projectId, userId);
            detail.setApplied(applied);

            // 찜하기(북마크) 여부 확인
            int bookmarkCount = projectBookmarkMapper.isBookmarked(projectId, userId);
            detail.setWishlisted(bookmarkCount > 0);
        } else {
            // 비로그인 시 기본값
            detail.setApplied(false);
            detail.setWishlisted(false);
        }

        return detail;
    }
}
