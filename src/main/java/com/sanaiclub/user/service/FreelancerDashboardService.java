package com.sanaiclub.user.service;

import com.sanaiclub.user.dao.FreelancerDashboardMapper;
import com.sanaiclub.user.model.dto.FreelancerDashboardDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
@RequiredArgsConstructor
public class FreelancerDashboardService {

    private final FreelancerDashboardMapper freelancerDashboardMapper;

    @Transactional(readOnly = true)
    public FreelancerDashboardDTO getDashboardStats(Integer userId) {
        FreelancerDashboardDTO dto = new FreelancerDashboardDTO();

        // 1. 상단 카드 데이터
        dto.setOngoingProjects(freelancerDashboardMapper.countOngoingContracts(userId));
        Long totalEarned = freelancerDashboardMapper.selectTotalEarned(userId);
        dto.setTotalEarnings(totalEarned != null ? totalEarned : 0L);
        dto.setPendingApplications(freelancerDashboardMapper.countPendingApplications(userId));
        Long balance = freelancerDashboardMapper.selectWalletBalance(userId);
        dto.setWalletBalance(balance != null ? balance : 0L);

        // 2. 월별 수익 차트 데이터 가공 (빈 달 0원 채우기)
        List<Map<String, Object>> earningsRaw = freelancerDashboardMapper.selectMonthlyEarnings(userId);
        Map<String, Long> earningsMap = new HashMap<>();
        for (Map<String, Object> row : earningsRaw) {
            String month = (String) row.get("month");
            Number amount = (Number) row.get("totalAmount");
            earningsMap.put(month, amount.longValue());
        }

        List<String> labels = new ArrayList<>();
        List<Long> values = new ArrayList<>();
        LocalDate today = LocalDate.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM");

        for (int i = 5; i >= 0; i--) {
            String monthKey = today.minusMonths(i).format(formatter);
            labels.add(monthKey);
            values.add(earningsMap.getOrDefault(monthKey, 0L));
        }
        dto.setMonthlyLabels(labels);
        dto.setMonthlyData(values);

        // 3. 프로젝트 완료율 데이터 가공 [완료, 진행, 취소]
        List<Map<String, Object>> statusRaw = freelancerDashboardMapper.selectContractStatusCounts(userId);
        Map<String, Integer> statusMap = new HashMap<>();
        for (Map<String, Object> row : statusRaw) {
            // 키값 대소문자 방어 코드
            String status = row.containsKey("status") ? (String) row.get("status") : (String) row.get("STATUS");
            Object countObj = row.containsKey("count") ? row.get("count") : row.get("COUNT");
            if (status != null && countObj instanceof Number) {
                statusMap.put(status, ((Number) countObj).intValue());
            }
        }

        List<Integer> statusData = new ArrayList<>();
        statusData.add(statusMap.getOrDefault("COMPLETED", 0)); // 완료
        statusData.add(statusMap.getOrDefault("SIGNED", 0) + statusMap.getOrDefault("PAID", 0)); // 진행중
        statusData.add(statusMap.getOrDefault("TERMINATED", 0)); // 취소/종료
        dto.setStatusCounts(statusData);

        // 4. 최근 지원한 프로젝트 리스트
        dto.setRecentProjects(freelancerDashboardMapper.selectRecentAppliedProjects(userId));

        return dto;
    }
}