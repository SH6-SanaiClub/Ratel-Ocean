package com.sanaiclub.project.dao;

import com.sanaiclub.project.model.dto.ProjectCreateRequestDTO;
import com.sanaiclub.project.model.dto.StackDTO;
import com.sanaiclub.project.model.vo.ProjectStackVO;
import com.sanaiclub.project.model.vo.ProjectsVO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface ProjectCreateMapper {

    // 등록
    void insertProject(ProjectCreateRequestDTO request);
    void insertProjectStack(ProjectStackVO vo);

    // 수정/조회
    ProjectsVO selectProjectById(Integer projectId);
    List<StackDTO> selectStackListByProjectId(Integer projectId);
    ProjectStackVO selectProjectStackConfig(Integer projectId); // 레벨, 연차 복구용

    void updateProject(ProjectCreateRequestDTO request);

    // 삭제
    void deleteProjectStacks(Integer projectId);
    void deleteProject(Integer projectId);
}