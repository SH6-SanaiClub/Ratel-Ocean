package com.sanaiclub.portfolio.dao;

import com.sanaiclub.portfolio.model.dto.CompletedPlatformProjectDTO;
import com.sanaiclub.portfolio.model.dto.CompletedProjectStackDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface FreelancerCompletedProjectMapper {

    List<CompletedPlatformProjectDTO> selectCompletedProjects(@Param("freelancerId") Integer freelancerId);

}
