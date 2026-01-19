package com.sanaiclub.domain.project.vo;

import lombok.Data;
import java.sql.Date;
import java.time.LocalDateTime;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * ProjectVO
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [설명]
 * projects 테이블의 레코드를 표현하는 Value Object입니다.
 * 프로젝트의 전체 정보를 담으며, DB INSERT 시 MyBatis가 자동 생성된 
 * projectId를 매핑합니다 (useGeneratedKeys=true).
 * 
 * [위치]
 * 패키지: com.sanaiclub.domain.project.vo
 * 파일: ProjectVO.java
 * 
 * [테이블 매핑]
 * 테이블명: projects
 * 
 * [필드 설명]
 * - projectId: 프로젝트 고유 ID (PK, AUTO_INCREMENT)
 * - clientId: 클라이언트 ID (FK -> users.user_id)
 * - title: 프로젝트 제목
 * - description: 프로젝트 상세 설명
 * - startDate: 시작일
 * - deadlineDate: 마감일 (지원 마감일)
 * - estDuration: 예상 진행 기간
 * - durationNegotiable: 기간 협의 가능 여부
 * - budget: 프로젝트 예산 (정수)
 * - budgetNegotiable: 예산 협의 가능 여부
 * - communicateMethod: 미팅 방식 (ONLINE/OFFLINE)
 * - paymentMethod: 대금 지급 방식 (LUMP_SUM/INSTALLMENT)
 * - changePolicy: 수정 관련 상세 규정
 * - maxRevisionCount: 최대 수정 요청 횟수
 * - projectStatus: 프로젝트 상태 (READY/RECRUITING/IN_PROGRESS/COMPLETED/CANCELLED)
 * - isPublic: 공개 여부
 * - createdAt: 생성일시 (DB DEFAULT)
 * - updatedAt: 수정일시 (DB DEFAULT ON UPDATE)
 * - viewCount: 조회수
 * - applicantCount: 지원자 수
 * - planUrl: 기획서 파일 URL
 * - fileSize: 기획서 파일 크기
 * 
 * @author 이은희 (신한DS 금융 SW 아카데미)
 * @version 1.0
 * @since 2026-01-18
 */
@Data
public class ProjectVO {
    
    /** 프로젝트 고유 ID (PK) */
    private Integer projectId;
    
    /** 클라이언트 ID (FK) */
    private Integer clientId;
    
    /** 프로젝트 제목 */
    private String title;
    
    /** 프로젝트 상세 설명 */
    private String description;
    
    /** 시작일 */
    private Date startDate;
    
    /** 마감일 (지원 마감일) */
    private Date deadlineDate;
    
    /** 예상 진행 기간 */
    private String estDuration;
    
    /** 기간 협의 가능 여부 */
    private Boolean durationNegotiable;
    
    /** 프로젝트 예산 */
    private Integer budget;
    
    /** 예산 협의 가능 여부 */
    private Boolean budgetNegotiable;
    
    /** 미팅 방식 (ONLINE/OFFLINE) */
    private String communicateMethod;
    
    /** 대금 지급 방식 (LUMP_SUM/INSTALLMENT) */
    private String paymentMethod;
    
    /** 수정 관련 상세 규정 */
    private String changePolicy;
    
    /** 최대 수정 요청 횟수 */
    private Integer maxRevisionCount;
    
    /** 프로젝트 상태 */
    private ProjectStatus projectStatus;
    
    /** 공개 여부 */
    private Boolean isPublic;
    
    /** 생성일시 */
    private LocalDateTime createdAt;
    
    /** 수정일시 */
    private LocalDateTime updatedAt;
    
    /** 조회수 */
    private Integer viewCount;
    
    /** 지원자 수 */
    private Integer applicantCount;
    
    /** 기획서 파일 URL */
    private String planUrl;
    
    /** 기획서 파일 크기 */
    private String fileSize;
}
