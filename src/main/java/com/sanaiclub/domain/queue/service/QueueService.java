package com.sanaiclub.domain.queue.service;

import com.sanaiclub.domain.queue.model.QueuePageData;
import java.util.List;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * QueueService - 큐 관련 비즈니스 로직 인터페이스
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * 프리랜서의 프로젝트 추천 큐(자동 추천, 조건 기반)를 관리하는
 * 서비스 계층의 인터페이스입니다.
 * 
 * [책임]
 * 1. 프리랜서별 자동 추천 큐 조회
 * 2. 프리랜서의 조건 큐 조회
 * 3. 각 큐에 포함된 프로젝트 목록 조회
 * 4. 기존 DB 테이블을 조합하여 데이터 제공
 * 
 * [참고]
 * - DB 새로 생성 금지 (기존 테이블만 사용)
 * - queues, queue_stacks, projects, project_stacks, stacks 조합
 * - 알고리즘 구현은 선택 사항 (더미 데이터 반환 가능)
 */
public interface QueueService {
    
    /**
     * ─────────────────────────────────────────────────────────────────
     * 큐 페이지 데이터 조회
     * ─────────────────────────────────────────────────────────────────
     * 
     * 주어진 프리랜서의 전체 큐 관련 데이터를 조회합니다.
     * - 자동 추천 큐 프로젝트
     * - 조건 큐 목록과 각 큐의 프로젝트
     * 
     * @param freelancerId 프리랜서 ID
     * @return 큐 페이지 렌더링용 데이터 (자동 추천 + 조건 큐)
     */
    QueuePageData getQueuePageData(Long freelancerId);
    
    /**
     * ─────────────────────────────────────────────────────────────────
     * 프리랜서의 조건 큐 목록 조회
     * ─────────────────────────────────────────────────────────────────
     * 
     * 프리랜서가 생성한 조건 큐(최대 2개)를 조회합니다.
     * 각 큐에는 해당 조건의 추천 프로젝트(최대 5개)를 포함합니다.
     * 
     * @param freelancerId 프리랜서 ID
     * @return 조건 큐 목록 (최대 2개)
     */
    List<com.sanaiclub.domain.queue.model.QueueDTO> getCustomQueues(Long freelancerId);
    
    /**
     * ─────────────────────────────────────────────────────────────────
     * 자동 추천 큐 프로젝트 조회
     * ─────────────────────────────────────────────────────────────────
     * 
     * 시스템이 프리랜서의 정보(스킬, 경력)를 바탕으로
     * 추천하는 프로젝트 목록을 조회합니다.
     * 
     * [조건]
     * - 최대 5개만 반환
     * - 프로젝트 status가 ACTIVE인 것만
     * - 프리랜서가 이미 지원하지 않은 프로젝트
     * 
     * @param freelancerId 프리랜서 ID
     * @return 추천 프로젝트 목록 (최대 5개)
     */
    List<com.sanaiclub.domain.queue.model.ProjectQueueDTO> getSystemQueueProjects(Long freelancerId);
    
    /**
     * ─────────────────────────────────────────────────────────────────
     * 조건 큐의 프로젝트 조회
     * ─────────────────────────────────────────────────────────────────
     * 
     * 특정 조건 큐의 추천 프로젝트 목록을 조회합니다.
     * 
     * [동작]
     * - 큐 상태가 INACTIVE면, 기존 프로젝트는 유지하되 새 추천 중단
     * - 최대 5개까지만 반환
     * 
     * @param queueId 큐 ID
     * @return 해당 큐의 프로젝트 목록 (최대 5개)
     */
    List<com.sanaiclub.domain.queue.model.ProjectQueueDTO> getQueueProjects(Long queueId);
    
    /**
     * ─────────────────────────────────────────────────────────────────
     * 큐에서 프로젝트 삭제
     * ─────────────────────────────────────────────────────────────────
     * 
     * 자동 추천 큐 또는 조건 큐에서 특정 프로젝트를 제거합니다.
     * 실제로는 queue_matchings 테이블의 해당 레코드를 soft delete합니다.
     * 
     * @param queueId 큐 ID (SYSTEM일 수도, CUSTOM일 수도 있음)
     * @param projectId 프로젝트 ID
     * @return 삭제 성공 여부
     */
    boolean removeProjectFromQueue(Long queueId, Long projectId);
    
    /**
     * ─────────────────────────────────────────────────────────────────
     * 조건 큐 상태 토글
     * ─────────────────────────────────────────────────────────────────
     * 
     * 조건 큐의 상태를 ACTIVE <-> INACTIVE로 변경합니다.
     * 
     * [동작]
     * - ACTIVE → INACTIVE: 신규 추천 중단, 기존 프로젝트는 유지
     * - INACTIVE → ACTIVE: 신규 추천 재개
     * 
     * @param queueId 큐 ID
     * @return 변경 후 상태 (ACTIVE 또는 INACTIVE)
     */
    String toggleQueueStatus(Long queueId);
}
