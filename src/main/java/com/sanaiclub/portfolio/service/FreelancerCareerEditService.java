package com.sanaiclub.portfolio.service;

import com.sanaiclub.portfolio.model.vo.FreelancerCareerVO;
import com.sanaiclub.portfolio.model.vo.FreelancerProjectExperienceVO;

import java.util.List;

public interface FreelancerCareerEditService {

    List<FreelancerCareerVO> getCareers(Integer freelancerId);

    void addCareer(FreelancerCareerVO vo);
    void updateCareer(FreelancerCareerVO vo);
    void deleteCareer(Integer careerId, Integer freelancerId);

}
