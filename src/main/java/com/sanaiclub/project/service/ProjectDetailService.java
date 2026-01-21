package com.sanaiclub.project.service;

import com.sanaiclub.project.dao.ProjectBookmarkMapper;
import com.sanaiclub.project.dao.ProjectDashboardMapper;
import com.sanaiclub.project.dao.ProjectDetailMapper;
import com.sanaiclub.project.model.dto.ProjectDetailDTO;
import com.sanaiclub.project.model.dto.RequiredStackDTO;
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
            // 지원 여부 확인
            boolean applied = projectDetailMapper.hasUserApplied(projectId, userId);
            detail.setApplied(applied);

            // 북마크 여부 확인
            int bookmarkCount = projectBookmarkMapper.isBookmarked(projectId, userId);
            detail.setWishlisted(bookmarkCount > 0);
        } else {
            // 비로그인 시 기본값
            detail.setApplied(false);
            detail.setWishlisted(false);
        }

        return detail;
    }

    @Transactional
    public String toggleApply(Integer projectId, Integer userId) {
        // 이미 지원했는지 확인
        boolean isApplied = projectDetailMapper.hasUserApplied(projectId, userId);

        if (isApplied) {
            // 이미 지원했으면 취소
            projectDetailMapper.deleteApplication(projectId, userId);
            return "CANCELED";
        } else {
            // 지원 안 했으면 지원
            projectDetailMapper.insertApplication(projectId, userId);
            return "APPLIED";
        }
    }

    public String getUserType(Integer userId) {
        return projectDetailMapper.selectUserType(userId);
    }
}
