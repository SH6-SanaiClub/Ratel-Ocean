package com.sanaiclub.project.dao;

import com.sanaiclub.project.model.vo.ProjectsVO;
import com.sanaiclub.project.model.vo.ProjectStackVO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ProjectCreateMapper {

    // 1. 프로젝트 저장 (VO 사용)
    void insertProject(ProjectsVO projectsVO);

    // 2. 프로젝트 스택 저장 (VO 사용)
    void insertProjectStack(ProjectStackVO projectStackVO);
}