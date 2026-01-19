package com.sanaiclub.domain.project.dao;

import com.sanaiclub.domain.project.dto.ProjectDashboardDTO;
import com.sanaiclub.domain.project.dto.ProjectDetailDTO;
import com.sanaiclub.domain.project.dto.StackDto;
import com.sanaiclub.domain.project.vo.ProjectStackVO;
import com.sanaiclub.domain.project.vo.ProjectVO;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * ProjectMapper
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [설명]
 * 프로젝트 등록 및 관리를 위한 MyBatis Mapper 인터페이스입니다.
 * projects 테이블과 project_stacks 테이블에 대한 CRUD 작업을 정의합니다.
 * 
 * [위치]
 * 패키지: com.sanaiclub.domain.project.dao
 * 파일: ProjectMapper.java
 * 매퍼 XML: mybatis/mappers/project/ProjectMapper.xml
 * 
 * [메서드 설명]
 * - insertProject: 프로젝트 기본 정보 삽입 (useGeneratedKeys로 ID 자동 매핑)
 * - insertProjectStack: 프로젝트-스택 관계 삽입 (개발분야 및 기술스택)
 * 
 * @author 이은희 (신한DS 금융 SW 아카데미)
 * @version 1.0
 * @since 2026-01-18
 */
@Mapper
public interface ProjectMapper {

    /**
     * 프로젝트 기본 정보 삽입
     * 
     * @param projectVO 프로젝트 정보 (projectId는 자동 생성되어 매핑됨)
     */
    void insertProject(ProjectVO projectVO);

    /**
     * 프로젝트-스택 관계 삽입
     * 
     * @param projectStackVO 프로젝트-스택 매핑 정보
     */
    void insertProjectStack(ProjectStackVO projectStackVO);

    /**
     * 모든 공개 프로젝트 목록 조회 (대시보드/프리랜서 목록 공용)
     */
    List<ProjectDashboardDTO> findAllProjects();

    /**
     * 특정 프로젝트의 기술 스택 목록 조회
     */
    List<StackDto> selectStacksByProjectId(Integer projectId);

    /**
     * 특정 클라이언트가 등록한 프로젝트 목록 조회
     */
    List<ProjectDashboardDTO> findProjectsByClientId(Integer clientId);

    /**
     * 프로젝트 상세 조회 (스택 포함)
     */
    ProjectDetailDTO findProjectById(Integer projectId);
}
