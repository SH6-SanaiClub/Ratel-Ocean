package com.sanaiclub.domain.project.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * ProjectStackVO
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [설명]
 * project_stacks 테이블의 레코드를 표현하는 Value Object입니다.
 * 프로젝트와 기술스택/개발분야의 다대다 관계를 매핑하는 중간 테이블입니다.
 * 
 * [위치]
 * 패키지: com.sanaiclub.domain.project.vo
 * 파일: ProjectStackVO.java
 * 
 * [테이블 매핑]
 * 테이블명: project_stacks
 * 
 * [필드 설명]
 * - projectStackId: 프로젝트-스택 매핑 ID (PK, AUTO_INCREMENT)
 * - projectId: 프로젝트 ID (FK -> projects.project_id)
 * - stackId: 스택 ID (FK -> stacks.stack_id)
 * - stackLevel: 요구 숙련도 (1~5)
 * - stackYear: 요구 경력 (년 단위, 0이면 무관)
 * 
 * @author 이은희 (신한DS 금융 SW 아카데미)
 * @version 1.0
 * @since 2026-01-18
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProjectStackVO {
    
    /** 프로젝트-스택 매핑 ID (PK) */
    private Integer projectStackId;
    
    /** 프로젝트 ID (FK) */
    private Integer projectId;
    
    /** 스택 ID (FK) */
    private Integer stackId;
    
    /** 요구 숙련도 (1: 입문 ~ 5: 고급) */
    private Integer stackLevel;
    
    /** 요구 경력 (년 단위, 0이면 무관) */
    private Integer stackYear;
}
