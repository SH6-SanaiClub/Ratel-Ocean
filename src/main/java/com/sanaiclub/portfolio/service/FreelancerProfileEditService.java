package com.sanaiclub.portfolio.service;

import com.sanaiclub.portfolio.model.vo.FreelancerCareerVO;
import com.sanaiclub.portfolio.model.vo.FreelancerProjectExperienceVO;

import java.util.List;

public interface FreelancerProfileEditService {

    List<FreelancerCareerVO> getCareers(Integer freelancerId);
    List<FreelancerProjectExperienceVO> getExperiences(Integer freelancerId);

    void addCareer(FreelancerCareerVO vo);
    void updateCareer(FreelancerCareerVO vo);
    void deleteCareer(Long careerId, Integer freelancerId);

    void addExperience(FreelancerProjectExperienceVO vo);
    void updateExperience(FreelancerProjectExperienceVO vo);
    void deleteExperience(Long experienceId, Integer freelancerId);
}
