package com.sanaiclub.domain.project.dao;

import com.sanaiclub.domain.project.dto.StackDto;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * StackMapper
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [설명]
 * 기술 스택 및 개발 분야 조회를 위한 MyBatis Mapper 인터페이스입니다.
 * stacks 테이블에서 POSITION(개발분야) 및 SKILL(기술스택)을 조회합니다.
 * 
 * [위치]
 * 패키지: com.sanaiclub.domain.project.dao
 * 파일: StackMapper.java
 * 매퍼 XML: mybatis/mappers/project/StackMapper.xml
 * 
 * [메서드 설명]
 * - findAll: stacks 테이블의 모든 스택 조회 (POSITION + SKILL)
 * 
 * @author 이은희 (신한DS 금융 SW 아카데미)
 * @version 1.0
 * @since 2026-01-18
 */
@Mapper
public interface StackMapper {

    /**
     * 모든 스택 목록 조회 (개발분야 + 기술스택)
     * 
     * @return 스택 DTO 리스트
     */
    List<StackDto> findAll();
}
