package com.sanaiclub.project.service;

import com.sanaiclub.project.dao.ProjectBookmarkMapper;
import com.sanaiclub.project.dao.ProjectDashboardMapper;
import com.sanaiclub.project.dao.ProjectDetailMapper;
import com.sanaiclub.project.model.dto.ProjectDetailDTO;
import com.sanaiclub.project.model.dto.RequiredStackDTO;
import com.sanaiclub.project.model.vo.ApplicationStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ProjectDetailService {

    private final ProjectDetailMapper projectDetailMapper;
    private final ProjectDashboardMapper projectDashboardMapper;
    private final ProjectBookmarkMapper projectBookmarkMapper;

    public ProjectDetailDTO getProjectDetail(Integer projectId, Integer userId) {
        // 프로젝트 기본 정보 조회
        ProjectDetailDTO detail = projectDetailMapper.selectProjectDetail(projectId);

        if (detail == null) {
            throw new RuntimeException("프로젝트를 찾을 수 없습니다.");
        }

        // 기술 스택 조회 및 세팅
        List<RequiredStackDTO> stacks = projectDashboardMapper.selectStacksByProjectId(Collections.singletonList(projectId));
        detail.setStacks(stacks);

        // 로그인 사용자 관련 정보 세팅
        if (userId != null) {
            // [변경] 현재 상태 조회
            String status = projectDetailMapper.selectApplicationStatus(projectId, userId);

            // 상태가 존재하고, 'CANCELED'가 아니면 지원한 것으로 간주
            boolean isApplied = (status != null && !ApplicationStatus.CANCELED.name().equals(status));

            detail.setApplied(isApplied);
            detail.setApplicationStatus(status); // DTO에 상세 상태도 담아둠

            int bookmarkCount = projectBookmarkMapper.isBookmarked(projectId, userId);
            detail.setWishlisted(bookmarkCount > 0);
        } else {
            detail.setApplied(false);
            detail.setWishlisted(false);
        }

        return detail;
    }

    @Transactional
    public String toggleApply(Integer projectId, Integer userId) {
        // 1. 현재 상태 조회
        String currentStatus = projectDetailMapper.selectApplicationStatus(projectId, userId);

        if (currentStatus == null) {
            // 2-1. 기록이 아예 없음 -> 신규 지원 (INSERT)
            projectDetailMapper.insertApplication(projectId, userId);
            return "APPLIED"; // Controller에서 처리할 응답값
        }

        // 2-2. 기록이 있음 -> 상태 판단
        if (ApplicationStatus.CANCELED.name().equals(currentStatus)) {
            // 취소했던 상태라면 -> 다시 지원 (PENDING으로 변경)
            projectDetailMapper.updateApplicationStatus(projectId, userId, ApplicationStatus.PENDING.name());
            return "APPLIED";
        } else {
            // 이미 지원 중인 상태(PENDING, VIEWED 등)라면 -> 지원 취소 (CANCELED로 변경)
            projectDetailMapper.updateApplicationStatus(projectId, userId, ApplicationStatus.CANCELED.name());
            return "CANCELED";
        }
    }

    public String getUserType(Integer userId) {
        return projectDetailMapper.selectUserType(userId);
    }
}
