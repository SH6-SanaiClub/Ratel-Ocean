package com.sanaiclub.project.dao;

import com.sanaiclub.project.model.dto.ProjectDashboardCardDTO;
import com.sanaiclub.project.model.dto.RequiredStackDTO;
import com.sanaiclub.project.model.vo.ProjectsVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ProjectDashboardMapper {

    List<ProjectDashboardCardDTO> selectDashboardProjects(
        @Param("keyword") String keyword,
        @Param("onlyActive") boolean onlyActive,
        @Param("limit") int limit,
        @Param("offset") int offset,
        @Param("userId") int userId,
        @Param("summary") String summary
    );

    int countDashboardProjects(
        @Param("keyword") String keyword,
        @Param("onlyActive") boolean onlyActive,
        @Param("summary") String summary
    );

    List<RequiredStackDTO> selectStacksByProjectId(
        @Param("projectIds") List<Long> projectIds
    );

    int todayNewProject();

    int deadlineWithin7Days();

    ProjectsVO selectProjectDetail(long projectId);
}
