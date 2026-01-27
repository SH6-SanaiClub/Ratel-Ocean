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

}