package com.sanaiclub.user.controller;

import com.sanaiclub.common.util.AuthContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * 클라이언트 대시보드
 *
 * [담당 기능]
 * - 클라이언트 대시보드 페이지 렌더링
 * - 클라이언트 전용 통계 데이터 제공 (추후 구현)
 *
 */
@Controller
@RequestMapping("/client")
public class ClientDashboardController {

    private static final Logger logger = LoggerFactory.getLogger(ClientDashboardController.class);

    /**
     * 클라이언트 대시보드 메인
     *
     * @param model Spring Model
     * @return 대시보드 JSP 경로
     */
    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        // AuthContext에서 현재 사용자 정보 추출
        Integer userId = AuthContext.getCurrentUserId();
        String loginId = AuthContext.getCurrentLoginId();

        logger.info("클라이언트 대시보드 접근: userId={}, loginId={}", userId, loginId);

        // Mock 데이터 (추후 Service에서 실제 데이터 조회)
        model.addAttribute("userId", userId);
        model.addAttribute("loginId", loginId);
        model.addAttribute("totalProjects", 8);
        model.addAttribute("activeContracts", 2);
        model.addAttribute("totalApplicants", 23);
        model.addAttribute("completedProjects", 4);

        return "user/client/dashboard";
    }

    /**
     * 프로젝트 등록 페이지
     * TODO: 추후 구현
     */
    @GetMapping("/projects/create")
    public String createProject() {
        logger.info("프로젝트 등록 페이지 접근");
        return "redirect:/client/dashboard";
    }

    /**
     * 내 프로젝트 목록
     * TODO: 추후 구현
     */
    @GetMapping("/projects")
    public String myProjects() {
        logger.info("내 프로젝트 목록 페이지 접근");
        return "redirect:/client/dashboard";
    }

    /**
     * 전체 프로젝트 탐색 (시장 조사용)
     * TODO: 추후 구현
     */
    @GetMapping("/projects/explore")
    public String exploreProjects() {
        logger.info("전체 프로젝트 탐색 페이지 접근");
        return "redirect:/client/dashboard";
    }

    /**
     * 지원자 관리 페이지
     * TODO: 추후 구현
     */
    @GetMapping("/applicants")
    public String applicants() {
        logger.info("지원자 관리 페이지 접근");
        return "redirect:/client/dashboard";
    }

    /**
     * 계약 관리 페이지
     * TODO: 추후 구현
     */
    @GetMapping("/contracts")
    public String contracts() {
        logger.info("계약 관리 페이지 접근");
        return "redirect:/client/dashboard";
    }

    /**
     * 관심 프리랜서 목록
     * TODO: 추후 구현
     */
    @GetMapping("/freelancers/favorites")
    public String favoriteFreelancers() {
        logger.info("관심 프리랜서 목록 페이지 접근");
        return "redirect:/client/dashboard";
    }

    /**
     * 마이 페이지
     * TODO: 추후 구현
     */
    @GetMapping("/mypage")
    public String mypage() {
        logger.info("마이 페이지 접근");
        return "redirect:/client/dashboard";
    }

    /**
     * 회사 정보 관리 (법인 클라이언트)
     * TODO: 추후 구현
     */
    @GetMapping("/company")
    public String companyInfo() {
        logger.info("회사 정보 관리 페이지 접근");
        return "redirect:/client/dashboard";
    }
}