package com.sanaiclub.user.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.user.model.dto.FreelancerDashboardDTO;
import com.sanaiclub.user.service.FreelancerDashboardService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/freelancer")
@RequiredArgsConstructor
public class FreelancerDashboardController {

    private static final Logger logger = LoggerFactory.getLogger(FreelancerDashboardController.class);

    private final FreelancerDashboardService freelancerDashboardService;

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        Integer userId = AuthContext.getCurrentUserId();
        String loginId = AuthContext.getCurrentLoginId();

        logger.info("프리랜서 대시보드 접근: userId={}, loginId={}", userId, loginId);

        // DTO로 데이터 조회
        FreelancerDashboardDTO stat = freelancerDashboardService.getDashboardStats(userId);

        // [디버깅] 값 확인용 로그
        logger.info("조회된 통계 - 지갑: {}, 수익: {}", stat.getWalletBalance(), stat.getTotalEarnings());

        model.addAttribute("userId", userId);
        model.addAttribute("loginId", loginId);

        model.addAttribute("stat", stat);

        return "user/freelancer/dashboard";
    }
}