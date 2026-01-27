package com.sanaiclub.wallet.dao;

import com.sanaiclub.contracts.model.vo.MilestoneStatus;
import com.sanaiclub.project.model.dto.ClientProjectProgressDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ClientProgressMapper {
    ClientProjectProgressDTO selectMilestonesByProjectId(@Param("projectId") Integer projectId);

    void updateMilestoneStatus(@Param("milestoneId") Integer milestoneId, @Param("status") MilestoneStatus status);

    List<Integer> selectAutoPaymentTargets();
}