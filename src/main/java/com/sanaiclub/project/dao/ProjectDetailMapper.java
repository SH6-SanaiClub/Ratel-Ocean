package com.sanaiclub.project.dao;

import com.sanaiclub.project.model.dto.ProjectDetailDTO;
import com.sanaiclub.project.model.vo.ProjectsVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ProjectDetailMapper {

    ProjectDetailDTO selectProjectDetail(@Param("projectId") Integer projectId);

    /**
     * 프로젝트 ID로 ProjectsVO 조회 (contract 도메인에서 사용)
     */
    ProjectsVO selectProjectById(@Param("projectId") Integer projectId);

    /**
     * 클라이언트 ID로 프로젝트 목록 조회 (contract 도메인에서 사용)
     */
    List<ProjectsVO> selectProjectsByClientId(@Param("clientId") Integer clientId);

    boolean hasUserApplied(@Param("projectId") Integer projectId, @Param("userId") Integer userId);

    // 프로젝트 지원하기
    void insertApplication(@Param("projectId") Integer projectId, @Param("userId") Integer userId);

    // 프로젝트 지원 취소
    void deleteApplication(@Param("projectId") Integer projectId, @Param("userId") Integer userId);

    String selectUserType(@Param("userId") Integer userId);

    /**
     * 프로젝트에 지원한 프리랜서 목록 조회 (contract 도메인에서 사용)
     * 
     * @param projectId 프로젝트 ID
     * @return 프리랜서 정보 리스트 (userId, name, email)
     */
    List<java.util.Map<String, Object>> selectFreelancersByProjectId(@Param("projectId") Integer projectId);

    /**
     * 프로젝트 상태 업데이트 (payment 도메인에서 사용)
     * 
     * @param projectId 프로젝트 ID
     * @param projectStatus 프로젝트 상태 (READY, IN_PROGRESS, CLOSED)
     */
    int updateProjectStatus(@Param("projectId") Integer projectId, @Param("projectStatus") String projectStatus);
}
