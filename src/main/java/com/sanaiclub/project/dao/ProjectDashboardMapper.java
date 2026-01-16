package com.sanaiclub.project.dao;


import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.sanaiclub.project.model.dto.ProjectDashboardCardDTO;

import java.util.List;

@Mapper
public interface ProjectDashboardMapper {
    List<ProjectDashboardCardDTO> selectDashboardCards(
            @Param("keyword") String keyword,
            @Param("onlyActive") Boolean onlyActive,
            @Param("limit") Integer limit,
            @Param("offset") Integer offset
    );
}