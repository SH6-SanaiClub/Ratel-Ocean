package com.sanaiclub.project.dao;

import com.sanaiclub.project.model.dto.ProjectDashboardCardDTO;
import com.sanaiclub.project.model.dto.RequiredStackDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ProjectBookmarkMapper {
    int isBookmarked(@Param("projectId") Integer projectId, @Param("userId") Integer userId);
    int insertBookmark(@Param("projectId") Integer projectId, @Param("userId") Integer userId);
    int deleteBookmark(@Param("projectId") Integer projectId, @Param("userId") Integer userId);

    List<ProjectDashboardCardDTO> selectBookmarkedDashboardProjects(
            @Param("keyword") String keyword,
            @Param("userId") Integer userId
    );

    List<RequiredStackDTO> selectStacksByProjectId(
            @Param("projectIds") List<Integer> projectIds
    );

}