package com.sanaiclub.wallet.dao;

import com.sanaiclub.contracts.model.vo.MilestoneStatus;
import com.sanaiclub.project.model.dto.ClientProjectProgressDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ClientProgressMapper {
    ClientProjectProgressDTO selectMilestonesByProjectId(@Param("projectId") Integer projectId);

    void updateMilestoneStatus(@Param("milestoneId") Integer milestoneId, @Param("status") MilestoneStatus status);
}