package com.sanaiclub.project.dao;

import com.sanaiclub.project.model.dto.ProjectDetailDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ProjectDetailMapper {

    // 프로젝트 상세 조회
    ProjectDetailDTO selectProjectDetail(@Param("projectId") Integer projectId);

    // 현재 나의 지원 상태 조회 (PENDING, CANCELED 등)
    String selectApplicationStatus(@Param("projectId") Integer projectId, @Param("userId") Integer userId);

    // 최초 지원 (INSERT)
    void insertApplication(@Param("projectId") Integer projectId, @Param("userId") Integer userId);

    // 상태 변경 (UPDATE) - 지원취소/재지원 포함
    void updateApplicationStatus(@Param("projectId") Integer projectId,
                                 @Param("userId") Integer userId,
                                 @Param("status") String status);

    // 유저 타입 조회
    String selectUserType(@Param("userId") Integer userId);
}