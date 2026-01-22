package com.sanaiclub.project.dao;

import com.sanaiclub.project.model.dto.ProjectDetailDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ProjectDetailMapper {

    ProjectDetailDTO selectProjectDetail(@Param("projectId") Integer projectId);

    boolean hasUserApplied(@Param("projectId") Integer projectId, @Param("userId") Integer userId);

    // 프로젝트 지원하기
    void insertApplication(@Param("projectId") Integer projectId, @Param("userId") Integer userId);

    // 프로젝트 지원 취소
    void deleteApplication(@Param("projectId") Integer projectId, @Param("userId") Integer userId);

    String selectUserType(@Param("userId") Integer userId);
}
