package com.sanaiclub.domain.queue.service.impl;

import com.sanaiclub.domain.queue.model.ProjectQueueDTO;
import com.sanaiclub.domain.queue.model.QueueDTO;
import com.sanaiclub.domain.queue.model.QueuePageData;
import com.sanaiclub.domain.queue.service.QueueService;
import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.Collectors;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * QueueServiceImpl - 큐 관련 비즈니스 로직 구현
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [구현 전략]
 * 현재 단계에서는 더미 데이터를 반환하는 형태로 구현합니다.
 * 향후 DAO/Repository 연동 시 실제 데이터 조회로 변경할 수 있습니다.
 * [사용 테이블]
 * - queues: 큐의 기본 정보 (이름, 예산, 기간, 상태)
 * - queue_stacks: 큐에 포함된 기술 스택
 * - stacks: 기술 스택 정보
 * - projects: 프로젝트 정보
 * - project_stacks: 프로젝트의 기술 스택
 * - queue_matchings: 큐와 프로젝트의 매칭 기록 (또는 임시 저장)
 * - freelancer_profile: 프리랜서 프로필 정보
 */
@Service
public class QueueServiceImpl implements QueueService {
    
    /**
     * 프리랜서의 전체 큐 페이지 데이터 조회
     * 
     * [작업 순서]
     * 1. 프리랜서 정보 조회 (freelancer_id 기준)
     * 2. 자동 추천 큐 프로젝트 조회 (5개 제한)
     * 3. 조건 큐 목록 조회 (2개 제한)
     * 4. 각 조건 큐의 프로젝트 조회 (5개 제한)
     * 5. QueuePageData에 모두 담아서 반환
     */
    @Override
    public QueuePageData getQueuePageData(Long freelancerId) {
        // TODO: DAO를 통해 프리랜서 정보 조회
        QueuePageData data = new QueuePageData();
        data.setFreelancerId(freelancerId);
        data.setFreelancerName("임시 프리랜서 " + freelancerId);  // 더미
        
        // TODO: 자동 추천 큐 조회 (getSystemQueueProjects 호출)
        List<ProjectQueueDTO> systemQueue = getSystemQueueProjects(freelancerId);
        data.setSystemQueueProjects(systemQueue);
        
        // TODO: 조건 큐 조회 (getCustomQueues 호출)
        List<QueueDTO> customQueues = getCustomQueues(freelancerId);
        data.setCustomQueues(customQueues);
        
        return data;
    }
    
    /**
     * 
     * [쿼리 로직]
     * SELECT q.* FROM queues q
     * WHERE q.freelancer_id = ? AND q.queue_type = 'CUSTOM'
     * LIMIT 2;
     * 
     * [각 큐에 대해]
     * - 기술 스택 조회 (queue_stacks + stacks 조인)
     * - 추천 프로젝트 조회 (getQueueProjects 호출)
     */
    @Override
    public List<QueueDTO> getCustomQueues(Long freelancerId) {
        List<QueueDTO> queues = new ArrayList<>();
        
        // TODO: DB에서 조건 큐 조회 (최대 2개)
        // 더미 데이터 예시
        QueueDTO queue1 = new QueueDTO(
            1L,
            "백엔드 스타트업 프로젝트",
            "ACTIVE",
            5000000L,
            15000000L
        );
        queue1.setCategory("개발");
        queue1.setExpectedDuration("1개월 이상");
        queue1.setTechStacks(Arrays.asList("Java", "Spring", "MySQL"));
        queue1.setProjects(getQueueProjects(1L));
        
        queues.add(queue1);
        
        return queues;
    }
    
    /**
     * 자동 추천 큐 프로젝트 조회 (최대 5개)
     * 
     * [쿼리 로직]
     * 1. freelancer의 기술 스택 조회
     * 2. 활성 프로젝트(status=ACTIVE)에서 기술 스택 매칭
     * 4. 상위 5개 반환
     * 
     * [매칭 알고리즘]
     * - 프리랜서의 스킬과 프로젝트 요구 스킬의 교집합 비율
     * - 예산 범위 매칭
     * - 경력 수준 고려
     * (현재: 더미 데이터)
     */
    @Override
    public List<ProjectQueueDTO> getSystemQueueProjects(Long freelancerId) {
        List<ProjectQueueDTO> projects = new ArrayList<>();
        
        // TODO: DB에서 자동 추천 프로젝트 조회 (최대 5개)
        // 더미 데이터 예시
        projects.add(new ProjectQueueDTO(
            101L,
            "[긴급] Node.js 백엔드 개발 - 모바일 앱 지원",
            3000000L,
            8000000L,
            "개발",
            85
        ));
        
        projects.add(new ProjectQueueDTO(
            102L,
            "React + Spring Boot 풀스택 프로젝트",
            5000000L,
            12000000L,
            "개발",
            78
        ));
        
        // 최대 5개까지만
        return projects.stream().limit(5).collect(Collectors.toList());
    }
    
    /**
     * 특정 조건 큐의 프로젝트 조회 (최대 5개)
     * 
     * [쿼리 로직]
     * SELECT p.* FROM projects p
     * JOIN queue_matchings qm ON p.project_id = qm.project_id
     * WHERE qm.queue_id = ? 
     * AND p.project_status = 'ACTIVE'
     * LIMIT 5;
     * 
     * [주의]
     * - 큐 상태가 INACTIVE여도 기존 프로젝트는 유지
     */
    @Override
    public List<ProjectQueueDTO> getQueueProjects(Long queueId) {
        List<ProjectQueueDTO> projects = new ArrayList<>();
        
        // TODO: DB에서 조건 큐의 프로젝트 조회 (최대 5개)
        // 더미 데이터 예시
        projects.add(new ProjectQueueDTO(
            201L,
            "전자상거래 플랫폼 백엔드 개발",
            5000000L,
            10000000L,
            "개발",
            92
        ));
        
        projects.add(new ProjectQueueDTO(
            202L,
            "API 서버 최적화 및 리팩토링",
            3000000L,
            7000000L,
            "개발",
            88
        ));
        
        return projects.stream().limit(5).collect(Collectors.toList());
    }
    
    /**
     * 큐에서 프로젝트 삭제
     * 
     * [동작]
     * - queue_matchings 테이블에서 해당 레코드를 soft delete
     * - 실제 DELETE보다는 is_deleted flag 설정 권장
     * 
     * @param queueId 큐 ID
     * @param projectId 프로젝트 ID
     * @return 삭제 성공 여부
     */
    @Override
    public boolean removeProjectFromQueue(Long queueId, Long projectId) {
        // TODO: DB에서 해당 매칭 제거
        // DELETE FROM queue_matchings 
        // WHERE queue_id = ? AND project_id = ?;
        
        System.out.println("프로젝트 제거: queueId=" + queueId + ", projectId=" + projectId);
        return true;  // 더미 구현
    }
    
    /**
     * 조건 큐 상태 토글
     * 
     * [동작]
     * - ACTIVE ↔ INACTIVE 변경
     * - 상태 변경 후 new status 반환
     * 
     * @param queueId 큐 ID
     * @return 변경 후 상태 (ACTIVE 또는 INACTIVE)
     */
    @Override
    public String toggleQueueStatus(Long queueId) {
        // TODO: DB에서 현재 상태 조회 후 토글
        // UPDATE queues SET queue_status = ? WHERE queue_id = ?;
        
        System.out.println("큐 상태 토글: queueId=" + queueId);
        return "ACTIVE";  // 더미 구현
    }
}
