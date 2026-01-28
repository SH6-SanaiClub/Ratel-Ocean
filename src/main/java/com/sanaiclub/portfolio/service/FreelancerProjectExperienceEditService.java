package com.sanaiclub.portfolio.service;

import com.sanaiclub.portfolio.model.vo.FreelancerProjectExperienceVO;

import java.util.List;

public interface FreelancerProjectExperienceEditService {

    List<FreelancerProjectExperienceVO> getExperiences(Integer freelancerId);

    void addExperience(FreelancerProjectExperienceVO vo);
    void updateExperience(FreelancerProjectExperienceVO vo);
    void deleteExperience(Integer experienceId, Integer freelancerId);
}
