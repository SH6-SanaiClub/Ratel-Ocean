package com.sanaiclub.domain.project.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * ProjectController
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [설명]
 * 프로젝트 관리 기능을 담당하는 컨트롤러입니다.
 * 프리랜서의 진행 프로젝트와 클라이언트의 등록 프로젝트를 관리합니다.
 * 
 * [위치]
 * 패키지: com.sanaiclub.domain.project.controller
 * 파일: ProjectController.java
 * 
 * [라우팅]
 * - GET /projects : 프로젝트 목록 및 관리 페이지
 * - GET /dashboard : 메인 대시보드 (프로젝트 요약 표시)
 * 
 * [향후 기능 (미구현)]
 * - GET /projects/{id} : 프로젝트 상세 조회
 * - POST /projects : 프로젝트 생성
 * - PUT /projects/{id} : 프로젝트 수정
 * - DELETE /projects/{id} : 프로젝트 삭제
 * - POST /projects/{id}/apply : 프로젝트 지원 (프리랜서)
 * 
 * @author Team SanaiClub (신한DS 금융 SW 아카데미)
 * @version 1.0
 * @since 2026-01-13
 */
@Controller
public class ProjectController {

    /**
     * ─────────────────────────────────────────────────────────────────
     * [메인 대시보드]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /dashboard
     * 설명: 사용자가 로그인 후 처음 보게 되는 개인맞춤형 메인 페이지입니다.
     *      대시보드에는 사용자의 주요 정보와 빠른 접근 메뉴가 표시됩니다.
     *      - 활성 프로젝트 수
     *      - 최근 제안
     *      - 빠른 메뉴 버튼
     * 
     * @return "dashboard" - src/main/webapp/WEB-INF/views/project/dashboard.jsp 렌더링
     */
    @GetMapping("/dashboard")
    public String dashboard() {
        return "dashboard";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [프로젝트 관리]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /projects
     * 설명: 사용자가 진행 중인 프로젝트들을 관리하는 페이지입니다.
     *      - 프리랜서: 수락한 프로젝트 목록, 진행 상황 조회
     *      - 클라이언트: 등록한 프로젝트 목록, 지원자 관리
     * 
     * [표시 정보]
     * - 프로젝트 명
     * - 상태 (진행중/완료/취소)
     * - 진행률
     * - 예산
     * - 마감일
     * - 최종 수정일
     * 
     * @return "project/projects" - src/main/webapp/WEB-INF/views/project/projects.jsp 렌더링
     */
    @GetMapping("/projects")
    public String projects() {
        return "project/projects";
    }
}
