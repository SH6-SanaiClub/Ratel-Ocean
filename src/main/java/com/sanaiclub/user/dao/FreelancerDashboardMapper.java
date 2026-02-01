package com.sanaiclub.user.dao;

import com.sanaiclub.user.model.dto.FreelancerProjectDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

@Mapper
public interface FreelancerDashboardMapper {
    // 상단 카드
    int countOngoingContracts(@Param("userId") Integer userId);
    Long selectTotalEarned(@Param("userId") Integer userId);
    int countPendingApplications(@Param("userId") Integer userId);
    Long selectWalletBalance(@Param("userId") Integer userId);

    // 월별 수익 (최근 6개월)
    List<Map<String, Object>> selectMonthlyEarnings(@Param("userId") Integer userId);

    // 프로젝트 상태별 카운트 (완료율 차트용)
    List<Map<String, Object>> selectContractStatusCounts(@Param("userId") Integer userId);

    // 최근 지원한 프로젝트 목록
    List<FreelancerProjectDTO> selectRecentAppliedProjects(@Param("userId") Integer userId);
}