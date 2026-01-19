package com.sanaiclub.domain.queue.controller;

import com.sanaiclub.domain.queue.model.QueuePageData;
import com.sanaiclub.domain.queue.service.QueueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * QueueController - 프로젝트 추천 큐 관리 페이지
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [역할]
 * 프리랜서가 자신에게 추천되는 프로젝트를 관리하는 페이지를 담당합니다.
 * 
 * [두 가지 큐 타입]
 * 1. 자동 추천 큐 (SYSTEM QUEUE)
 *    - 시스템이 프리랜서 정보를 바탕으로 자동 추천
 *    - 최대 5개 프로젝트 표시
 *    - 수정 불가, 개별 삭제만 가능
 * 
 * 2. 조건 기반 큐 (CUSTOM QUEUE)
 *    - 사용자가 직접 조건(기술, 예산, 기간 등)을 설정
 *    - 최대 2개 큐 생성 가능
 *    - 각 큐에 최대 5개 프로젝트 표시
 *    - 큐 ON/OFF 토글, 조건 수정, 개별 프로젝트 삭제 가능
 * 
 * [데이터 흐름]
 * 1. GET /ratelocean/queue 요청 수신
 * 2. QueueService를 통해 데이터 조회
 *    - 현재 로그인 사용자(프리랜서) 기준
 * 3. 자동 추천 큐 & 조건 큐 데이터 조합
 * 4. QueuePageData로 패킹하여 JSP에 전달
 * 5. queue.jsp에서 렌더링
 * 
 * [기존 DB 활용]
 * - queues: 큐 정보 저장소
 * - queue_stacks: 큐의 기술 스택
 * - queue_matchings: 큐와 프로젝트 매칭 기록
 * - projects, project_stacks: 프로젝트 정보
 * - stacks: 기술 스택 마스터
 * - freelancer_profile: 프리랜서 프로필
 * 
 * [URL 라우팅]
 * - GET /ratelocean/queue : 큐 페이지 조회
 * 
 * @author Team SanaiClub (신한DS 금융 SW 아카데미)
 * @version 2.0
 * @since 2026-01-15
 */
@Controller
@RequestMapping("/queue")
public class QueueController {
    
    @Autowired
    private QueueService queueService;
    
    /**
     * ─────────────────────────────────────────────────────────────────
     * [핵심 요청]
     * GET /ratelocean/queue
     * ─────────────────────────────────────────────────────────────────
     * 
     * 프리랜서의 프로젝트 추천 큐 메인 페이지를 로드합니다.
     * 
     * [처리 단계]
     * 
     * ① 현재 사용자(프리랜서) 파악
     *    - 실제 운영 환경: Session 또는 SecurityContext에서 추출
     *    - 테스트 환경: @RequestParam으로 freelancerId 받음
     *    - 예시: GET /queue?freelancerId=1
     * 
     * ② QueueService로부터 데이터 조회
     *    - getQueuePageData(freelancerId) 호출
     *    - 반환: 자동 추천 큐 + 조건 큐 + 각 큐의 프로젝트
     * 
     * ③ Model에 데이터 담기
     *    - "queuePageData" 속성으로 JSP에 전달
     * 
     * ④ 뷰 렌더링
     *    - queue.jsp 응답
     *    - JSP에서 JSTL을 이용해 동적 마크업 생성
     * 
     * [Model 속성]
     * - queuePageData: QueuePageData 객체
     *   ├─ freelancerId
     *   ├─ systemQueueProjects (자동 추천, 최대 5개)
     *   └─ customQueues (조건 큐, 최대 2개)
     *      └─ [각 큐]
     *         ├─ queueId, queueName, queueStatus (ON/OFF)
     *         ├─ minBudget, maxBudget
     *         ├─ expectedDuration
     *         ├─ category
     *         ├─ techStacks
     *         └─ projects (최대 5개)
     * 
     * [반환]
     * - "queue" : src/main/webapp/WEB-INF/views/queue/queue.jsp로 포워딩
     */
    @GetMapping
    public String queue(
            @RequestParam(value = "freelancerId", required = false) Long freelancerId,
            Model model) {
        
        // ① 프리랜서 ID 결정
        if (freelancerId == null) {
            // 실제 운영 환경에서는 여기서 Session/SecurityContext에서 추출
            // Long freelancerId = (Long) session.getAttribute("userId");
            freelancerId = 1L;  // 테스트용 더미 ID
        }
        
        // ② 큐 페이지 데이터 조회
        // QueueService 호출
        // → 자동 추천 큐 프로젝트 5개 조회
        // → 조건 큐 최대 2개 조회
        // → 각 큐의 프로젝트 조회 (최대 5개)
        // → 모두 QueuePageData에 담아서 반환
        QueuePageData pageData = queueService.getQueuePageData(freelancerId);
        
        // ③ Model에 데이터 저장
        model.addAttribute("queuePageData", pageData);
        
        // ④ 뷰 렌더링
        return "queue/queue";
    }
}

