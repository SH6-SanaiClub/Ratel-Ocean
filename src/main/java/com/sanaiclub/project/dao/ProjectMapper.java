package com.sanaiclub.project.dao;

import com.sanaiclub.project.model.vo.ProjectVO;
import com.sanaiclub.project.model.vo.ProjectStackVO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ProjectMapper {

    // 1. 프로젝트 저장 (VO 사용)
    void insertProject(ProjectVO projectVO);

    // 2. 프로젝트 스택 저장 (VO 사용)
    void insertProjectStack(ProjectStackVO projectStackVO);
}