package com.sanaiclub.project.dao;

import com.sanaiclub.project.model.dto.ProjectDashboardCardDTO;
import com.sanaiclub.project.model.dto.ProjectDetailDTO;
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
            @Param("limit") Integer limit,
            @Param("offset") Integer offset,
            @Param("userId") Integer userId,
            @Param("summary") String summary,
            @Param("sort") String sort,
            @Param("positionIds") List<Integer> positionIds,
            @Param("stackIds") List<Integer> stackIds,
            @Param("minBudget") Integer minBudget,
            @Param("maxBudget") Integer maxBudget
    );

    int countDashboardProjects(
            @Param("keyword") String keyword,
            @Param("onlyActive") boolean onlyActive,
            @Param("summary") String summary,
            @Param("positionIds") List<Integer> positionIds,
            @Param("stackIds") List<Integer> stackIds,
            @Param("minBudget") Integer minBudget,
            @Param("maxBudget") Integer maxBudget
    );

    List<RequiredStackDTO> selectStacksByProjectId(
        @Param("projectIds") List<Integer> projectIds
    );

    int todayNewProject();

    int deadlineWithin7Days();

    ProjectDetailDTO selectProjectDetail(@Param("projectId") Integer projectId);

    boolean hasUserApplied(@Param("projectId") Integer projectId, @Param("userId") Integer userId);
}
