package com.sanaiclub.domain.project.dto;

import lombok.Data;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * StackDto
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [설명]
 * 기술 스택 및 개발 분야 정보를 전달하는 DTO입니다.
 * stacks 테이블의 데이터를 조회할 때 사용합니다.
 * 
 * [위치]
 * 패키지: com.sanaiclub.domain.project.dto
 * 파일: StackDto.java
 * 
 * [필드 설명]
 * - stackId: 스택 고유 ID (PK)
 * - stackName: 스택 이름 (예: "Java", "React", "웹")
 * - category: 카테고리 (POSITION: 개발분야, SKILL: 기술스택)
 * 
 * @author 이은희 (신한DS 금융 SW 아카데미)
 * @version 1.0
 * @since 2026-01-18
 */
@Data
public class StackDto {
    
    /** 스택 고유 ID */
    private Integer stackId;
    
    /** 스택 이름 */
    private String stackName;
    
    /** 카테고리 (POSITION/SKILL) */
    private String category;

    /** 스택 숙련도 (project_stacks.stack_level) */
    private Integer stackLevel;

    /** 스택 경력 (project_stacks.stack_year) */
    private Integer stackYear;
}
