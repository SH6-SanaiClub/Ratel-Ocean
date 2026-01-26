package com.sanaiclub.project.dao;

import com.sanaiclub.project.model.dto.ClientMilestoneDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ClientProgressMapper {
    List<ClientMilestoneDTO> selectMilestonesByProjectId(@Param("projectId") Integer projectId);

    void updateMilestoneStatus(@Param("milestoneId") Integer milestoneId, @Param("status") String status);
}