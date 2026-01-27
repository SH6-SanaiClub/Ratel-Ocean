package com.sanaiclub.manage.dao;

import com.sanaiclub.manage.model.dto.CalendarEventDTO;
import com.sanaiclub.manage.model.dto.FreelancerProjectCardDTO;
import com.sanaiclub.manage.model.dto.FreelancerProjectSummaryDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.util.List;

@Mapper
public interface FreelancerProjectManageMapper {

    FreelancerProjectSummaryDTO selectSummary(@Param("freelancerId") Integer freelancerId);

    List<FreelancerProjectCardDTO> selectInProgressProjects(@Param("freelancerId") Integer freelancerId);

    List<FreelancerProjectCardDTO> selectAppliedProjects(@Param("freelancerId") Integer freelancerId);

    List<FreelancerProjectCardDTO> selectCompletedProjects(@Param("freelancerId") Integer freelancerId);

    List<CalendarEventDTO> selectCalendarEvents(
            @Param("freelancerId") Integer freelancerId,
            @Param("start") LocalDate start,
            @Param("end") LocalDate end
    );
}
