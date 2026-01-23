package com.sanaiclub.user.controller;

import com.sanaiclub.common.util.AuthContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * 프리랜서 대시보드
 *
 * [담당 기능]
 * - 프리랜서 대시보드 페이지 렌더링
 * - 프리랜서 전용 통계 데이터 제공 (추후 구현)
 *
 */
@Controller
@RequestMapping("/freelancer")
public class FreelancerDashboardController {

    private static final Logger logger = LoggerFactory.getLogger(FreelancerDashboardController.class);

    /**
     * 프리랜서 대시보드 메인
     *
     * @param model Spring Model
     * @return 대시보드 JSP 경로
     */
    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        // AuthContext에서 현재 사용자 정보 추출
        Integer userId = AuthContext.getCurrentUserId();
        String loginId = AuthContext.getCurrentLoginId();

        logger.info("프리랜서 대시보드 접근: userId={}, loginId={}", userId, loginId);

        // Mock 데이터 (추후 Service에서 실제 데이터 조회)
        model.addAttribute("userId", userId);
        model.addAttribute("loginId", loginId);
        model.addAttribute("ongoingProjects", 3);
        model.addAttribute("totalEarnings", "12,450,000");
        model.addAttribute("pendingApplications", 5);
        model.addAttribute("profileCompletion", 85);

        return "user/freelancer/dashboard";
    }

}