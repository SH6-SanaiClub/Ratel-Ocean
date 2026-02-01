package com.sanaiclub.user.service;

import com.sanaiclub.contract.model.dto.ContractResponseDTO;
import com.sanaiclub.contract.model.vo.ContractStatus;
import com.sanaiclub.contract.service.ContractService;
import com.sanaiclub.user.dao.ClientDashboardMapper;
import com.sanaiclub.user.model.dto.ClientDashboardDTO;
import com.sanaiclub.user.model.dto.RecentApplicantDTO;
import com.sanaiclub.user.model.dto.RecentProjectDTO;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ClientDashboardService {

    private static final Logger logger = LoggerFactory.getLogger(ClientDashboardService.class);
    
    private final ContractService contractService;

    private final ClientDashboardMapper clientDashboardMapper;

    /**
     * 클라이언트 대시보드 상단 통계 데이터 조회
     */
    @Transactional(readOnly = true)
    public ClientDashboardDTO getDashboardSummary(Integer userId) {
        ClientDashboardDTO summary = clientDashboardMapper.selectDashboardSummary(userId);

        // 데이터가 없을 경우 0으로 초기화하여 반환 (NullPointerException 방지)
        if (summary == null) {
            summary = new ClientDashboardDTO();
            summary.setTotalProjects(0);
            summary.setActiveContracts(0);
            summary.setTotalApplicants(0);
            summary.setCompletedProjects(0);
        }
        return summary;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getMonthlyExpenditureData(Integer userId) {
        // 1. DB에서 데이터 조회
        List<Map<String, Object>> rawData = clientDashboardMapper.selectMonthlyExpenditure(userId);

        // 2. DB 결과를 Map으로 변환 (검색 속도 최적화)
        Map<String, Long> dataMap = new HashMap<>();
        for (Map<String, Object> row : rawData) {
            String month = (String) row.get("month");
            // Number로 받고 long으로 변환 (DB 타입 대응)
            Number amount = (Number) row.get("totalAmount");
            dataMap.put(month, amount.longValue());
        }

        // 3. 최근 6개월 라벨 생성 및 0원 채우기
        List<String> labels = new ArrayList<>();
        List<Long> values = new ArrayList<>();

        LocalDate today = LocalDate.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM");

        // 5달 전 ~ 현재까지 루프
        for (int i = 5; i >= 0; i--) {
            String monthKey = today.minusMonths(i).format(formatter);
            labels.add(monthKey);
            // 데이터가 있으면 넣고, 없으면 0
            values.add(dataMap.getOrDefault(monthKey, 0L));
        }

        Map<String, Object> result = new HashMap<>();
        result.put("labels", labels); // 차트 X축
        result.put("data", values);   // 차트 Y축 데이터
        return result;
    }

    @Transactional(readOnly = true)
    public List<RecentProjectDTO> getRecentProjects(Integer userId) {
        return clientDashboardMapper.selectRecentProjects(userId);
    }

    /**
     * [추가] 새로운 지원자 목록 조회
     */
    @Transactional(readOnly = true)
    public List<RecentApplicantDTO> getRecentApplicants(Integer userId) {
        return clientDashboardMapper.selectRecentApplicants(userId);
    }

    @Transactional(readOnly = true)
    public List<Integer> getProjectStatusData(Integer userId) {
        List<Map<String, Object>> statusCounts = clientDashboardMapper.selectProjectStatusCounts(userId);

        // 1. Map 변환 (대소문자 처리)
        Map<String, Integer> countMap = new HashMap<>();
        for (Map<String, Object> row : statusCounts) {
            String status = null;
            Object countObj = null;

            if (row.containsKey("status")) {
                status = (String) row.get("status");
                countObj = row.get("count");
            } else if (row.containsKey("STATUS")) {
                status = (String) row.get("STATUS");
                countObj = row.get("COUNT");
            }

            if (status != null && countObj instanceof Number) {
                countMap.put(status, ((Number) countObj).intValue());
            }
        }

        int completed = countMap.getOrDefault("CLOSED", 0);
        int ongoing = countMap.getOrDefault("IN_PROGRESS", 0);
        int recruiting = countMap.getOrDefault("READY", 0);

        List<Integer> result = new ArrayList<>();
        result.add(completed);
        result.add(ongoing);
        result.add(recruiting);

        return result;
    }


    /**
     * 클라이언트 대시보드 통계 데이터 조회
     */
    public ClientDashboardStatistics getClientDashboardStatistics(Integer userId) {
        List<ContractResponseDTO> clientContracts = contractService.getContractsByClientId(userId);

        long activeContracts = calculateActiveContracts(clientContracts);
        long completedContracts = calculateCompletedContracts(clientContracts);
        long totalExpenditure = calculateTotalExpenditure(clientContracts);
        long activeContractAmount = calculateActiveContractAmount(clientContracts);
        long settlementPending = calculateSettlementPending(clientContracts);
        List<ContractResponseDTO> paymentPendingContracts = getPaymentPendingContracts(clientContracts);
        Map<String, Long> monthlyExpenditure = calculateMonthlyExpenditure(clientContracts);
        Map<String, Long> statusDistribution = calculateStatusDistribution(clientContracts);
        List<ContractResponseDTO> recentContracts = getRecentContracts(clientContracts);

        return new ClientDashboardStatistics(
            activeContracts,
            completedContracts,
            totalExpenditure,
            activeContractAmount,
            settlementPending,
            paymentPendingContracts,
            monthlyExpenditure,
            statusDistribution,
            recentContracts
        );
    }

    private long calculateActiveContracts(List<ContractResponseDTO> contracts) {
        return contracts.stream()
            .filter(c -> {
                ContractStatus status = c.getContractStatus();
                return status != null && (status == ContractStatus.WAITING
                    || status == ContractStatus.SIGNED
                    || status == ContractStatus.PAID);
            })
            .count();
    }

    private long calculateCompletedContracts(List<ContractResponseDTO> contracts) {
        return contracts.stream()
            .filter(c -> {
                boolean isLumpSum = (c.getTotalMilestones() == null || c.getTotalMilestones() == 0)
                        && ("FIXED".equals(c.getPaymentMethod())
                            || "FULL".equals(c.getPaymentMethod())
                            || c.getPaymentMethod() == null);

                if (isLumpSum) {
                    return c.getContractStatus() == ContractStatus.COMPLETED;
                } else {
                    if (c.getTotalMilestones() != null && c.getTotalMilestones() > 0) {
                        return c.getPaidMilestones() != null
                                && c.getPaidMilestones().equals(c.getTotalMilestones());
                    }
                }
                return false;
            })
            .count();
    }

    private long calculateTotalExpenditure(List<ContractResponseDTO> contracts) {
        return contracts.stream()
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
    }

    private long calculateActiveContractAmount(List<ContractResponseDTO> contracts) {
        return contracts.stream()
            .filter(c -> {
                ContractStatus status = c.getContractStatus();
                return status != null && (status == ContractStatus.WAITING
                    || status == ContractStatus.SIGNED
                    || status == ContractStatus.PAID)
                        && c.getTotalBudget() != null;
            })
            .mapToLong(c -> c.getTotalBudget())
            .sum();
    }

    private long calculateSettlementPending(List<ContractResponseDTO> contracts) {
        return contracts.stream()
            .filter(c -> {
                ContractStatus status = c.getContractStatus();

                if (status == ContractStatus.PAID) {
                    boolean isLumpSum = (c.getTotalMilestones() == null || c.getTotalMilestones() == 0)
                            && ("FIXED".equals(c.getPaymentMethod())
                                || "FULL".equals(c.getPaymentMethod())
                                || c.getPaymentMethod() == null);
                    if (isLumpSum && "[지급요청]".equals(c.getCancelReason())) {
                        return true;
                    }
                }

                if (c.getRequestedMilestones() != null && c.getRequestedMilestones() > 0) {
                    return true;
                }

                return false;
            })
            .count();
    }

    private List<ContractResponseDTO> getPaymentPendingContracts(List<ContractResponseDTO> contracts) {
        return contracts.stream()
            .filter(c -> {
                ContractStatus status = c.getContractStatus();

                if (status == ContractStatus.PAID) {
                    boolean isLumpSum = (c.getTotalMilestones() == null || c.getTotalMilestones() == 0)
                            && ("FIXED".equals(c.getPaymentMethod())
                                || "FULL".equals(c.getPaymentMethod())
                                || c.getPaymentMethod() == null);
                    if (isLumpSum && "[지급요청]".equals(c.getCancelReason())) {
                        return true;
                    }
                }

                if (c.getRequestedMilestones() != null && c.getRequestedMilestones() > 0) {
                    return true;
                }

                return false;
            })
            .sorted((a, b) -> {
                String aDate = a.getContractedAt() != null ? a.getContractedAt() : "";
                String bDate = b.getContractedAt() != null ? b.getContractedAt() : "";
                return bDate.compareTo(aDate);
            })
            .limit(5)
            .collect(Collectors.toList());
    }

    private Map<String, Long> calculateMonthlyExpenditure(List<ContractResponseDTO> contracts) {
        LocalDate now = LocalDate.now();
        Map<String, Long> monthlyExpenditure = new LinkedHashMap<>();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM");

        for (int i = 5; i >= 0; i--) {
            LocalDate month = now.minusMonths(i);
            String monthKey = month.format(formatter);
            monthlyExpenditure.put(monthKey, 0L);
        }

        contracts.stream()
            .filter(c -> c.getTotalBudget() != null)
            .forEach(c -> {
                try {
                    String dateStr = null;
                    String monthKey = null;

                    if (c.getContractStatus() == ContractStatus.COMPLETED && c.getCompletedAt() != null) {
                        dateStr = c.getCompletedAt();
                    } else if (c.getContractedAt() != null) {
                        dateStr = c.getContractedAt();
                    }

                    if (dateStr != null && dateStr.length() >= 7) {
                        monthKey = dateStr.substring(0, 7);
                        if (monthlyExpenditure.containsKey(monthKey)) {
                            monthlyExpenditure.put(monthKey, monthlyExpenditure.get(monthKey) + c.getTotalBudget());
                        }
                    }
                } catch (Exception e) {
                    logger.warn("월별 지출 계산 중 오류 (contractId: {}): {}", c.getContractId(), e.getMessage());
                }
            });

        return monthlyExpenditure;
    }

    private Map<String, Long> calculateStatusDistribution(List<ContractResponseDTO> contracts) {
        return contracts.stream()
            .collect(Collectors.groupingBy(
                c -> c.getContractStatus() != null ? c.getContractStatus().name() : "UNKNOWN",
                Collectors.counting()
            ));
    }

    private List<ContractResponseDTO> getRecentContracts(List<ContractResponseDTO> contracts) {
        return contracts.stream()
            .sorted((a, b) -> {
                String aDate = a.getContractedAt() != null ? a.getContractedAt() : "";
                String bDate = b.getContractedAt() != null ? b.getContractedAt() : "";
                return bDate.compareTo(aDate);
            })
            .limit(10)
            .collect(Collectors.toList());
    }

    /**
     * 클라이언트 대시보드 통계 데이터 컨테이너
     */
    public static class ClientDashboardStatistics {
        private final long activeContracts;
        private final long completedContracts;
        private final long totalExpenditure;
        private final long activeContractAmount;
        private final long settlementPending;
        private final List<ContractResponseDTO> paymentPendingContracts;
        private final Map<String, Long> monthlyExpenditure;
        private final Map<String, Long> statusDistribution;
        private final List<ContractResponseDTO> recentContracts;

        public ClientDashboardStatistics(
                long activeContracts,
                long completedContracts,
                long totalExpenditure,
                long activeContractAmount,
                long settlementPending,
                List<ContractResponseDTO> paymentPendingContracts,
                Map<String, Long> monthlyExpenditure,
                Map<String, Long> statusDistribution,
                List<ContractResponseDTO> recentContracts) {
            this.activeContracts = activeContracts;
            this.completedContracts = completedContracts;
            this.totalExpenditure = totalExpenditure;
            this.activeContractAmount = activeContractAmount;
            this.settlementPending = settlementPending;
            this.paymentPendingContracts = paymentPendingContracts;
            this.monthlyExpenditure = monthlyExpenditure;
            this.statusDistribution = statusDistribution;
            this.recentContracts = recentContracts;
        }

        // Getters
        public long getActiveContracts() { return activeContracts; }
        public long getCompletedContracts() { return completedContracts; }
        public long getTotalExpenditure() { return totalExpenditure; }
        public long getActiveContractAmount() { return activeContractAmount; }
        public long getSettlementPending() { return settlementPending; }
        public List<ContractResponseDTO> getPaymentPendingContracts() { return paymentPendingContracts; }
        public Map<String, Long> getMonthlyExpenditure() { return monthlyExpenditure; }
        public Map<String, Long> getStatusDistribution() { return statusDistribution; }
        public List<ContractResponseDTO> getRecentContracts() { return recentContracts; }
    }
}
