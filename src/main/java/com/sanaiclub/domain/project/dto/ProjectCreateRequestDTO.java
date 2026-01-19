package com.sanaiclub.domain.project.dto;

import com.sanaiclub.domain.project.vo.ProjectStatus;
import lombok.Data;
import java.util.List;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * ProjectCreateRequestDTO
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [설명]
 * 프로젝트 등록 요청 시 클라이언트로부터 전달받는 데이터를 담는 DTO입니다.
 * 5단계 폼으로 구성된 프로젝트 등록 페이지의 입력값을 매핑합니다.
 * 
 * [위치]
 * 패키지: com.sanaiclub.domain.project.dto
 * 파일: ProjectCreateRequestDTO.java
 * 
 * [필드 구성]
 * Step 1 (프로젝트 개요):
 *   - title: 프로젝트 제목
 *   - description: 프로젝트 상세 설명
 *   - planFile: 기획서 파일 (MultipartFile로 별도 수신)
 * 
 * Step 2 (개발 영역 및 기술 스택):
 *   - positionId: 개발 분야 (POSITION 카테고리 스택 ID)
 *   - stackIds: 관련 기술 리스트 (SKILL 카테고리 스택 ID들)
 *   - stackIdsUnknown: 기술 스택 미정 여부
 *   - minLevel: 최소 숙련도 (1~5)
 *   - minYear: 최소 경력 (년)
 * 
 * Step 3 (예산 및 일정):
 *   - budget: 프로젝트 예산 (콤마 포함 문자열)
 *   - budgetNegotiable: 예산 협의 가능 여부
 *   - startType: 시작일 유형 (DATE/ASAP)
 *   - startDate: 시작일 (DATE 선택 시)
 *   - startNegotiable: 시작일 협의 가능 여부
 *   - estDuration: 예상 진행 기간
 *   - durationNegotiable: 기간 협의 가능 여부
 * 
 * Step 4 (계약 및 소통):
 *   - communicateMethod: 미팅 방식 (ONLINE/OFFLINE)
 *   - paymentMethod: 대금 지급 방식 (LUMP_SUM/INSTALLMENT)
 *   - maxRevisionCount: 수정 요청 횟수 (0~3)
 *   - changePolicy: 수정 관련 상세 규정
 * 
 * Hidden Fields:
 *   - isPublic: 공개 여부 (기본 true)
 *   - projectStatus: 프로젝트 상태 (기본 READY)
 *   - planUrl: 업로드된 기획서 URL (서버 저장 후 설정)
 *   - fileSize: 파일 크기
 * 
 * @author 이은희 (신한DS 금융 SW 아카데미)
 * @version 1.0
 * @since 2026-01-18
 */
@Data
public class ProjectCreateRequestDTO {
    
    // ────────── Step 1: 프로젝트 개요 ──────────
    
    /** 프로젝트 제목 */
    private String title;
    
    /** 프로젝트 상세 설명 */
    private String description;
    
    
    // ────────── Step 2: 개발 영역 및 기술 스택 (모달 방식) ──────────
    
    /** 
     * 기술 스택 ID 목록 (개발 영역 + 기술 스택)
     * 모달에서 선택된 모든 스택 (POSITION + SKILL)
     */
    private List<String> stackIds;
    
    /**
     * 각 스택의 요구 레벨 (1~5)
     * stackIds와 인덱스가 일치함
     */
    private List<String> stackLevels;
    
    /**
     * 각 스택의 요구 경력 (년)
     * stackIds와 인덱스가 일치함
     */
    private List<String> stackYears;
    
    
    // ────────── Step 3: 예산 및 일정 ──────────
    
    /** 프로젝트 예산 (콤마 포함 문자열, 예: "1,000,000") */
    private String budget;
    
    /** 예산 협의 가능 여부 */
    private Boolean budgetNegotiable;
    
    /** 시작일 유형 (DATE: 날짜 지정, ASAP: 즉시 시작) */
    private String startType;
    
    /** 희망 시작일 (startType이 DATE일 때만 사용) */
    private String startDate;
    
    /** 시작일 협의 가능 여부 */
    private Boolean startNegotiable;
    
    /** 예상 진행 기간 (예: "1~3개월") */
    private String estDuration;
    
    /** 기간 협의 가능 여부 */
    private Boolean durationNegotiable;
    
    
    // ────────── Step 4: 계약 및 소통 ──────────
    
    /** 미팅 방식 (ONLINE/OFFLINE) */
    private String communicateMethod;
    
    /** 대금 지급 방식 (LUMP_SUM: 일괄 지급, INSTALLMENT: 분할 지급) */
    private String paymentMethod;
    
    /** 최대 수정 요청 횟수 (0~3) */
    private Integer maxRevisionCount;
    
    /** 수정 관련 상세 규정 (선택 사항) */
    private String changePolicy;
    
    
    // ────────── Hidden Fields ──────────
    
    /** 프로젝트 공개 여부 (기본: true) */
    private Boolean isPublic;
    
    /** 프로젝트 상태 (기본: READY) */
    private ProjectStatus projectStatus;
    
    /** 업로드된 기획서 파일 URL */
    private String planUrl;
    
    /** 업로드된 파일 크기 */
    private String fileSize;
}
