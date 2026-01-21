package com.sanaiclub.portfolio.service.impl;

import com.sanaiclub.portfolio.dao.FreelancerCareerMapper;
import com.sanaiclub.portfolio.dao.FreelancerProjectExperienceMapper;
import com.sanaiclub.portfolio.model.vo.FreelancerCareerVO;
import com.sanaiclub.portfolio.model.vo.FreelancerProjectExperienceVO;
import com.sanaiclub.portfolio.service.FreelancerProfileEditService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class FreelancerProfileEditServiceImpl implements FreelancerProfileEditService {

    private final FreelancerCareerMapper careerMapper;
    private final FreelancerProjectExperienceMapper experienceMapper;

    public FreelancerProfileEditServiceImpl(FreelancerCareerMapper careerMapper,
                                            FreelancerProjectExperienceMapper experienceMapper) {
        this.careerMapper = careerMapper;
        this.experienceMapper = experienceMapper;
    }

    @Override
    @Transactional(readOnly = true)
    public List<FreelancerCareerVO> getCareers(Integer freelancerId) {
        return careerMapper.selectByFreelancerId(freelancerId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<FreelancerProjectExperienceVO> getExperiences(Integer freelancerId) {
        return experienceMapper.selectByFreelancerId(freelancerId);
    }

    @Override
    @Transactional
    public void addCareer(FreelancerCareerVO vo) {
        normalize(vo);
        if (careerMapper.insertCareer(vo) != 1) throw new IllegalStateException("insertCareer failed");
    }

    @Override
    @Transactional
    public void updateCareer(FreelancerCareerVO vo) {
        normalize(vo);
        if (careerMapper.updateCareer(vo) != 1) throw new IllegalStateException("updateCareer failed");
    }

    @Override
    @Transactional
    public void deleteCareer(Long careerId, Integer freelancerId) {
        if (careerMapper.deleteCareer(careerId, freelancerId) != 1) throw new IllegalStateException("deleteCareer failed");
    }

    @Override
    @Transactional
    public void addExperience(FreelancerProjectExperienceVO vo) {
        normalize(vo);
        if (experienceMapper.insertExperience(vo) != 1) throw new IllegalStateException("insertExperience failed");
    }

    @Override
    @Transactional
    public void updateExperience(FreelancerProjectExperienceVO vo) {
        normalize(vo);
        if (experienceMapper.updateExperience(vo) != 1) throw new IllegalStateException("updateExperience failed");
    }

    @Override
    @Transactional
    public void deleteExperience(Long experienceId, Integer freelancerId) {
        if (experienceMapper.deleteExperience(experienceId, freelancerId) != 1) throw new IllegalStateException("deleteExperience failed");
    }

    private void normalize(Object vo) {
        if (vo instanceof FreelancerCareerVO) {
            FreelancerCareerVO c = (FreelancerCareerVO) vo;
            if (c.getDescription() != null && c.getDescription().isBlank()) {
                c.setDescription(null);
            }
            return;
        }

        if (vo instanceof FreelancerProjectExperienceVO) {
            FreelancerProjectExperienceVO e = (FreelancerProjectExperienceVO) vo;
            if (e.getClientName() != null && e.getClientName().isBlank()) {
                e.setClientName(null);
            }
            if (e.getDescription() != null && e.getDescription().isBlank()) {
                e.setDescription(null);
            }
        }
    }

}
