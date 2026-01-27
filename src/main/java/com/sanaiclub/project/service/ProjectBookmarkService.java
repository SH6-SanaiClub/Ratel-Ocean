package com.sanaiclub.project.service;

import com.sanaiclub.project.dao.ProjectBookmarkMapper;
import com.sanaiclub.project.model.dto.DashboardPageDTO;
import com.sanaiclub.project.model.dto.ProjectDashboardCardDTO;
import com.sanaiclub.project.model.dto.RequiredStackDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ProjectBookmarkService {

    private final ProjectBookmarkMapper projectBookmarkMapper;

    @Transactional
    public boolean toggle(Integer projectId, Integer userId) {
        // 이미 있으면 삭제 → false 반환
        if (projectBookmarkMapper.isBookmarked(projectId, userId) > 0) {
            projectBookmarkMapper.deleteBookmark(projectId, userId);
            return false;
        }
        // 없으면 추가 → true 반환
        projectBookmarkMapper.insertBookmark(projectId, userId);
        return true;
    }

    public DashboardPageDTO getBookmarkedDashboardPage(
            String keyword,
            Integer userId
    ) {

        List<ProjectDashboardCardDTO> list = projectBookmarkMapper.selectBookmarkedDashboardProjects(
                keyword, userId
        );

        // stacks 붙이기
        if (!list.isEmpty()) {
            List<Integer> projectIds = list.stream()
                    .map(ProjectDashboardCardDTO::getProjectId)
                    .collect(java.util.stream.Collectors.toList());

            List<RequiredStackDTO> stacks = projectBookmarkMapper.selectStacksByProjectId(projectIds);

            // projectId로 그룹핑해서 각 카드에 넣기
            Map<Integer, List<RequiredStackDTO>> grouped =
                    stacks.stream().collect(java.util.stream.Collectors.groupingBy(RequiredStackDTO::getProjectId));

            for (ProjectDashboardCardDTO dto : list) {
                dto.setStacks(grouped.getOrDefault(dto.getProjectId(), java.util.Collections.emptyList()));
            }
        }

        DashboardPageDTO dashboardPageDTO = new DashboardPageDTO();
        dashboardPageDTO.setProjectList(list);
        return dashboardPageDTO;
    }
}
