package com.sanaiclub.domain.project.vo;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * ProjectStatus (Enum)
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [설명]
 * 프로젝트의 상태를 나타내는 Enum 타입입니다.
 * projects 테이블의 project_status 컬럼값과 매핑됩니다.
 * 
 * [위치]
 * 패키지: com.sanaiclub.domain.project.vo
 * 파일: ProjectStatus.java
 * 
 * [상태 값]
 * - READY: 준비 중 (등록 직후)
 * - RECRUITING: 모집 중 (프리랜서 지원 가능)
 * - IN_PROGRESS: 진행 중 (계약 체결 후)
 * - COMPLETED: 완료됨
 * - CANCELLED: 취소됨
 * 
 * @author 이은희 (신한DS 금융 SW 아카데미)
 * @version 1.0
 * @since 2026-01-18
 */
public enum ProjectStatus {
    
    /** 준비 중 (등록 직후) */
    READY,
    
    /** 모집 중 (프리랜서 지원 가능) */
    RECRUITING,
    
    /** 진행 중 (계약 체결 후) */
    IN_PROGRESS,
    
    /** 완료됨 */
    COMPLETED,
    
    /** 취소됨 */
    CANCELLED
}
