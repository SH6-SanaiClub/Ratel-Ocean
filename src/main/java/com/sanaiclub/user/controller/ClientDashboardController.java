package com.sanaiclub.user.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.user.service.ClientDashboardService;
import lombok.RequiredArgsConstructor;
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
 * - 클라이언트 계약 관리 페이지 렌더링
 *
 */
@Controller
@RequestMapping("/client")
@RequiredArgsConstructor
public class ClientDashboardController {

    private static final Logger logger = LoggerFactory.getLogger(ClientDashboardController.class);
    
    private final ClientDashboardService clientDashboardService;

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
     * 클라이언트 계약 관리 페이지
     *
     * @param model Spring Model
     * @return 계약 관리 JSP 경로
     */
    @GetMapping("/contracts")
    public String contracts(Model model) {
        Integer userId = AuthContext.getCurrentUserId();
        String loginId = AuthContext.getCurrentLoginId();

        logger.info("클라이언트 계약 관리 페이지 접근: userId={}, loginId={}", userId, loginId);

        if (userId == null) {
            model.addAttribute("errorMessage", "로그인이 필요합니다.");
            return "contract/clientContracts";
        }

        try {
            // Service에서 통계 데이터 조회
            ClientDashboardService.ClientDashboardStatistics statistics = 
                clientDashboardService.getClientDashboardStatistics(userId);

            // Model에 데이터 전달
            model.addAttribute("userId", userId);
            model.addAttribute("loginId", loginId);
            model.addAttribute("activeContracts", statistics.getActiveContracts());
            model.addAttribute("completedContracts", statistics.getCompletedContracts());
            model.addAttribute("totalExpenditure", statistics.getTotalExpenditure());
            model.addAttribute("activeContractAmount", statistics.getActiveContractAmount());
            model.addAttribute("settlementPending", statistics.getSettlementPending());
            model.addAttribute("paymentPendingContracts", statistics.getPaymentPendingContracts());
            model.addAttribute("monthlyExpenditure", statistics.getMonthlyExpenditure());
            model.addAttribute("statusDistribution", statistics.getStatusDistribution());
            model.addAttribute("recentContracts", statistics.getRecentContracts());

        } catch (Exception e) {
            logger.error("계약 데이터 조회 중 오류 발생: {}", e.getMessage(), e);
            model.addAttribute("errorMessage", "계약 정보를 조회하는 중 오류가 발생했습니다: " + e.getMessage());
        }

        return "contract/clientContracts";
    }

}