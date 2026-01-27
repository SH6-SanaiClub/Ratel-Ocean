package com.sanaiclub.portfolio.service.impl;

import com.sanaiclub.portfolio.dao.FreelancerProjectExperienceMapper;
import com.sanaiclub.portfolio.model.vo.FreelancerProjectExperienceVO;
import com.sanaiclub.portfolio.service.FreelancerProjectExperienceEditService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FreelancerProjectExperienceEditServiceImpl implements FreelancerProjectExperienceEditService {

    private final FreelancerProjectExperienceMapper experienceMapper;

    @Override
    @Transactional(readOnly = true)
    public List<FreelancerProjectExperienceVO> getExperiences(Integer freelancerId) {
        return experienceMapper.selectByFreelancerId(freelancerId);
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
    public void deleteExperience(Integer experienceId, Integer freelancerId) {
        if (experienceMapper.deleteExperience(experienceId, freelancerId) != 1) throw new IllegalStateException("deleteExperience failed");
    }

    private void normalize(Object vo) {

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
