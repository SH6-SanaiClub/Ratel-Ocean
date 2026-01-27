package com.sanaiclub.user.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.contract.model.dto.ContractResponseDTO;
import com.sanaiclub.contract.model.enums.ContractStatus;
import com.sanaiclub.contract.service.ContractService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

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
    
    private final ContractService contractService;

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
            // 클라이언트의 계약 목록 조회 (쿼리에서 필터링)
            List<ContractResponseDTO> clientContracts = contractService.getContractsByClientId(userId);

            // 통계 계산
            long activeContracts = clientContracts.stream()
                .filter(c -> {
                    ContractStatus status = c.getContractStatus();
                    return status != null && (status == ContractStatus.WAITING 
                        || status == ContractStatus.SIGNED 
                        || status == ContractStatus.PAID);
                })
                .count();

            // 완료된 계약 계산 (정확한 로직)
            // 일시지급: COMPLETED 상태이면 완료
            // 마일스톤: 모든 마일스톤이 완료되어야 완료 (paidMilestones == totalMilestones)
            long completedContracts = clientContracts.stream()
                .filter(c -> {
                    // 일시지급 계약인지 확인
                    boolean isLumpSum = (c.getTotalMilestones() == null || c.getTotalMilestones() == 0)
                            && ("FIXED".equals(c.getPaymentMethod()) 
                                || "FULL".equals(c.getPaymentMethod()) 
                                || c.getPaymentMethod() == null);
                    
                    if (isLumpSum) {
                        // 일시지급: COMPLETED 상태이면 완료
                        return c.getContractStatus() == ContractStatus.COMPLETED;
                    } else {
                        // 마일스톤 계약: 모든 마일스톤이 완료되어야 함
                        if (c.getTotalMilestones() != null && c.getTotalMilestones() > 0) {
                            return c.getPaidMilestones() != null 
                                    && c.getPaidMilestones().equals(c.getTotalMilestones());
                        }
                    }
                    return false;
                })
                .count();

            // 총 지출금: 완료된 계약의 총 계약금액 (위와 동일한 로직 사용)
            long totalExpenditure = clientContracts.stream()
                .filter(c -> {
                    boolean isLumpSum = (c.getTotalMilestones() == null || c.getTotalMilestones() == 0)
                            && ("FIXED".equals(c.getPaymentMethod()) 
                                || "FULL".equals(c.getPaymentMethod()) 
                                || c.getPaymentMethod() == null);
                    
                    if (isLumpSum) {
                        return c.getContractStatus() == ContractStatus.COMPLETED && c.getTotalBudget() != null;
                    } else {
                        if (c.getTotalMilestones() != null && c.getTotalMilestones() > 0) {
                            boolean isFullyCompleted = c.getPaidMilestones() != null 
                                    && c.getPaidMilestones().equals(c.getTotalMilestones());
                            return isFullyCompleted && c.getTotalBudget() != null;
                        }
                    }
                    return false;
                })
                .mapToLong(c -> c.getTotalBudget())
                .sum();

            // 진행중인 계약 금액: WAITING, SIGNED, PAID 상태 계약의 총 계약금액
            long activeContractAmount = clientContracts.stream()
                .filter(c -> {
                    ContractStatus status = c.getContractStatus();
                    return status != null && (status == ContractStatus.WAITING 
                        || status == ContractStatus.SIGNED 
                        || status == ContractStatus.PAID)
                            && c.getTotalBudget() != null;
                })
                .mapToLong(c -> c.getTotalBudget())
                .sum();

            // SETTLEMENT_PENDING 계산 수정: 실제 지급 요청이 있는 경우만 카운트
            // paymentPendingContracts와 동일한 로직 사용
            long settlementPending = clientContracts.stream()
                .filter(c -> {
                    ContractStatus status = c.getContractStatus();
                    
                    // 일시지급: PAID 상태이고 cancel_reason이 "[지급요청]"인 경우만
                    if (status == ContractStatus.PAID) {
                        boolean isLumpSum = (c.getTotalMilestones() == null || c.getTotalMilestones() == 0)
                                && ("FIXED".equals(c.getPaymentMethod()) 
                                    || "FULL".equals(c.getPaymentMethod()) 
                                    || c.getPaymentMethod() == null);
                        // 실제로 지급 요청이 있는 경우만
                        if (isLumpSum && "[지급요청]".equals(c.getCancelReason())) {
                            return true;
                        }
                    }
                    
                    // 마일스톤: REQUESTED 상태인 마일스톤이 있는 경우만
                    if (c.getRequestedMilestones() != null && c.getRequestedMilestones() > 0) {
                        return true;
                    }
                    
                    return false;
                })
                .count();

            // 지급 대기 계약 목록 (상세 정보 포함)
            // 일시지급: PAID 상태이고 cancel_reason이 "[지급요청]"인 경우
            // 마일스톤: REQUESTED 상태인 마일스톤이 있는 경우
            List<ContractResponseDTO> paymentPendingContracts = clientContracts.stream()
                .filter(c -> {
                    ContractStatus status = c.getContractStatus();
                    
                    // 일시지급: PAID 상태이고 cancel_reason이 "[지급요청]"인 경우
                    if (status == ContractStatus.PAID) {
                        boolean isLumpSum = (c.getTotalMilestones() == null || c.getTotalMilestones() == 0)
                                && ("FIXED".equals(c.getPaymentMethod()) 
                                    || "FULL".equals(c.getPaymentMethod()) 
                                    || c.getPaymentMethod() == null);
                        if (isLumpSum && "[지급요청]".equals(c.getCancelReason())) {
                            return true;
                        }
                    }
                    
                    // 마일스톤: REQUESTED 상태인 마일스톤이 있는 경우
                    if (c.getRequestedMilestones() != null && c.getRequestedMilestones() > 0) {
                        return true;
                    }
                    
                    return false;
                })
                .sorted((a, b) -> {
                    // 최근 요청일 기준 정렬 (contractedAt 기준, 추후 마일스톤 요청일 추가 시 활용)
                    String aDate = a.getContractedAt() != null ? a.getContractedAt() : "";
                    String bDate = b.getContractedAt() != null ? b.getContractedAt() : "";
                    return bDate.compareTo(aDate);
                })
                .limit(5) // 최대 5개만 표시
                .collect(Collectors.toList());

            // 최근 6개월 지출 데이터 계산
            LocalDate now = LocalDate.now();
            Map<String, Long> monthlyExpenditure = new LinkedHashMap<>();
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM");
            
            // 최근 6개월 키 생성 (현재 월 포함)
            for (int i = 5; i >= 0; i--) {
                LocalDate month = now.minusMonths(i);
                String monthKey = month.format(formatter);
                monthlyExpenditure.put(monthKey, 0L);
            }

            // 계약 체결일 기준으로 월별 지출 집계 (모든 계약 포함)
            // 완료일이 없는 경우도 체결일 기준으로 집계하여 더 정확한 데이터 제공
            clientContracts.stream()
                .filter(c -> c.getTotalBudget() != null)
                .forEach(c -> {
                    try {
                        String dateStr = null;
                        String monthKey = null;
                        
                        // 완료된 계약은 완료일 기준, 그 외는 체결일 기준
                        if (c.getContractStatus() == ContractStatus.COMPLETED && c.getCompletedAt() != null) {
                            dateStr = c.getCompletedAt();
                        } else if (c.getContractedAt() != null) {
                            dateStr = c.getContractedAt();
                        }
                        
                        if (dateStr != null && dateStr.length() >= 7) {
                            monthKey = dateStr.substring(0, 7); // "yyyy-MM"
                            // 해당 월이 최근 6개월에 포함되어 있으면 집계
                            if (monthlyExpenditure.containsKey(monthKey)) {
                                monthlyExpenditure.put(monthKey, monthlyExpenditure.get(monthKey) + c.getTotalBudget());
                            }
                        }
                    } catch (Exception e) {
                        logger.warn("월별 지출 계산 중 오류 (contractId: {}): {}", c.getContractId(), e.getMessage());
                    }
                });

            // 계약 상태별 분포 계산
            Map<String, Long> statusDistribution = clientContracts.stream()
                .collect(Collectors.groupingBy(
                    c -> c.getContractStatus() != null ? c.getContractStatus().name() : "UNKNOWN",
                    Collectors.counting()
                ));

            // 최근 계약 목록 (최신순, 최대 10개)
            List<ContractResponseDTO> recentContracts = clientContracts.stream()
                .sorted((a, b) -> {
                    String aDate = a.getContractedAt() != null ? a.getContractedAt() : "";
                    String bDate = b.getContractedAt() != null ? b.getContractedAt() : "";
                    return bDate.compareTo(aDate); // 내림차순
                })
                .limit(10)
                .collect(Collectors.toList());

            // Model에 데이터 전달
            model.addAttribute("userId", userId);
            model.addAttribute("loginId", loginId);
            model.addAttribute("activeContracts", activeContracts);
            model.addAttribute("completedContracts", completedContracts);
            model.addAttribute("totalExpenditure", totalExpenditure);
            model.addAttribute("activeContractAmount", activeContractAmount);
            model.addAttribute("settlementPending", settlementPending);
            model.addAttribute("paymentPendingContracts", paymentPendingContracts);
            model.addAttribute("monthlyExpenditure", monthlyExpenditure);
            model.addAttribute("statusDistribution", statusDistribution);
            model.addAttribute("recentContracts", recentContracts);

        } catch (Exception e) {
            logger.error("계약 데이터 조회 중 오류 발생: {}", e.getMessage(), e);
            model.addAttribute("errorMessage", "계약 정보를 조회하는 중 오류가 발생했습니다: " + e.getMessage());
        }

        return "contract/clientContracts";
    }

}