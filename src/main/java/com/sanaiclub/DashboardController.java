package com.sanaiclub;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 프리랜서/클라이언트 대시보드 컨트롤러
 * 
 * 로그인 후 사용자 타입(FREELANCER/CLIENT)에 따라 다른 대시보드를 제공합니다.
 * 현재 프로토타입: 고정된 대시보드 제공 (향후 세션 기반 라우팅 예상)
 */
@Controller
public class DashboardController {

    /**
     * GET /dashboard
     * 프리랜서 대시보드
     * 
     * DB 테이블: freelancer_profiles, freelancer_skills, projects, contracts
     * 표시 정보:
     * - 내 프로필 요약 (경력, 경험도, 별점)
     * - 활성 계약 목록
     * - 기회큐(Queue) 추천
     * - 통계 (수주율, 만족도, 매출)
     */
    @GetMapping("/dashboard")
    public String dashboard() {
        // TODO: 세션에서 freelancer_id 가져오기
        // TODO: freelancer_profiles에서 기본 정보 로드
        // TODO: contracts에서 활성 계약 로드
        // TODO: queues에서 추천 기회 로드
        return "dashboard";
    }

    /**
     * GET /client-dashboard
     * 클라이언트 대시보드
     * 
     * DB 테이블: client_profiles, projects, contracts, project_applications
     * 표시 정보:
     * - 내 프로젝트 목록 (상태별 분류)
     * - 진행 중인 계약
     * - 지원자 현황
     * - 채팅 상태
     */
    @GetMapping("/client-dashboard")
    public String clientDashboard() {
        // TODO: 세션에서 client_id 가져오기
        // TODO: client_profiles에서 기본 정보 로드
        // TODO: projects에서 클라이언트 프로젝트 로드
        // TODO: contracts에서 진행 중인 계약 로드
        return "client_dashboard";
    }

}

