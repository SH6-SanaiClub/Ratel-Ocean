package com.sanaiclub.project.dao;

import com.sanaiclub.project.model.dto.ClientProjectProgressDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ClientProgressMapper {
    ClientProjectProgressDTO selectMilestonesByProjectId(@Param("projectId") Integer projectId);

    void updateMilestoneStatus(@Param("milestoneId") Integer milestoneId, @Param("status") String status);
}