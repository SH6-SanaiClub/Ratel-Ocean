package com.sanaiclub.portfolio.dao;

import com.sanaiclub.portfolio.model.vo.FreelancerProjectExperienceVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface FreelancerProjectExperienceMapper {
    List<FreelancerProjectExperienceVO> selectByFreelancerId(@Param("freelancerId") Integer freelancerId);

    int insertExperience(FreelancerProjectExperienceVO vo);

    int updateExperience(FreelancerProjectExperienceVO vo);

    int deleteExperience(@Param("experienceId") Long experienceId,
                         @Param("freelancerId") Integer freelancerId);
}
