package com.sanaiclub.domain.queue.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * QueueController
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [설명]
 * 기회 큐(매칭 알고리즘) 기능을 담당하는 컨트롤러입니다.
 * 프리랜서가 자신의 스킬과 경력에 맞는 프로젝트 기회를 제시받습니다.
 * 
 * [위치]
 * 패키지: com.sanaiclub.domain.queue.controller
 * 파일: QueueController.java
 * 
 * [라우팅]
 * - GET /queue : 기회 큐 목록 조회
 * 
 * [향후 기능 (미구현)]
 * - POST /queue/{id}/apply : 프로젝트 지원
 * - POST /queue/{id}/skip : 프로젝트 건너뛰기
 * - GET /queue/filters : 필터 설정
 * - POST /queue/filters : 필터 저장
 * 
 * @author Team SanaiClub (신한DS 금융 SW 아카데미)
 * @version 1.0
 * @since 2026-01-13
 */
@Controller
public class QueueController {

    /**
     * ─────────────────────────────────────────────────────────────────
     * [기회 큐]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /queue
     * 설명: 프리랜서가 매칭할 수 있는 프로젝트 기회를 제시받는 페이지입니다.
     *      사용자의 스킬과 경력에 맞는 프로젝트를 AI/알고리즘이 추천합니다.
     * 
     * [특징]
     * - 개인화된 추천 알고리즘 (스킬 매칭)
     * - 예산 필터링
     * - 기술스택 필터링
     * - 카드 기반 UI (좌우 스와이프 지원)
     * 
     * [카드 액션]
     * - 지원하기 : 프로젝트 지원
     * - 건너뛰기 : 다음 프로젝트 제시
     * - 상세보기 : 프로젝트 상세 정보 확인
     * 
     * @return "queue" - src/main/webapp/WEB-INF/views/queue/queue.jsp 렌더링
     */
    @GetMapping("/queue")
    public String queue() {
        return "queue";
    }
}
