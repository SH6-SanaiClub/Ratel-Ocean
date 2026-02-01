package com.sanaiclub.user.dao;

import com.sanaiclub.user.model.dto.ClientDashboardDTO;
import com.sanaiclub.user.model.dto.RecentApplicantDTO;
import com.sanaiclub.user.model.dto.RecentProjectDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface ClientDashboardMapper {
    // 클라이언트 대시보드 상단 통계 데이터 조회
    ClientDashboardDTO selectDashboardSummary(@Param("userId") Integer userId);

    // 월별 지출 현황 (최근 6개월, PAID 상태 마일스톤 합계)
    List<Map<String, Object>> selectMonthlyExpenditure(@Param("userId") Integer userId);

    // 최근 등록한 프로젝트 (최대 3건)
    List<RecentProjectDTO> selectRecentProjects(@Param("userId") Integer userId);

    // 새로운 지원자 (최대 3명)
    List<RecentApplicantDTO> selectRecentApplicants(@Param("userId") Integer userId);

    // 프로젝트 상태별 카운트 조회 (GROUP BY)
    List<Map<String, Object>> selectProjectStatusCounts(@Param("userId") Integer userId);
}