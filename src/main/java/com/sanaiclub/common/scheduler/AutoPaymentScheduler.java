package com.sanaiclub.common.scheduler;

import com.sanaiclub.wallet.dao.ClientProgressMapper;
import com.sanaiclub.wallet.service.ClientProgressService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j; // 로그용 (없으면 지우고 System.out.println 쓰셔도 됨)
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class AutoPaymentScheduler {

    private final ClientProgressMapper clientProgressMapper;
    private final ClientProgressService clientProgressService;

    // 매일 자정(00:00:00)에 실행
    @Scheduled(cron = "0 0 0 * * *")
    public void autoPayOverdueMilestones() {
        // 로그: 시작 알림
        log.info("[스케줄러 시작] 7일 경과된 미승인 건 자동 지급 처리...");

        // 1. 대상 조회 (XML에서 만든 쿼리 실행)
        List<Integer> targetIds = clientProgressMapper.selectAutoPaymentTargets();

        int count = 0;
        // 2. 하나씩 꺼내서 지급 처리 (Service의 payMilestone 재사용)
        for (Integer milestoneId : targetIds) {
            try {
                clientProgressService.payMilestone(milestoneId);
                count++;
            } catch (Exception e) {
                log.error("자동 지급 실패 - milestoneId: " + milestoneId, e);
            }
        }

        // 로그: 결과 알림
        log.info("[스케줄러 종료] 총 {}건 자동 지급 완료", count);
    }
}