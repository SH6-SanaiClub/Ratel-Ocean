package com.sanaiclub.portfolio.service.impl;

import com.sanaiclub.portfolio.dao.FreelancerCareerMapper;
import com.sanaiclub.portfolio.dao.FreelancerProjectExperienceMapper;
import com.sanaiclub.portfolio.model.vo.FreelancerCareerVO;
import com.sanaiclub.portfolio.model.vo.FreelancerProjectExperienceVO;
import com.sanaiclub.portfolio.service.FreelancerCareerEditService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FreelancerCareerEditServiceImpl implements FreelancerCareerEditService {

    private final FreelancerCareerMapper freelancerCareerMapper;

    @Override
    @Transactional(readOnly = true)
    public List<FreelancerCareerVO> getCareers(Integer freelancerId) {
        return freelancerCareerMapper.selectByFreelancerId(freelancerId);
    }

    @Override
    @Transactional
    public void addCareer(FreelancerCareerVO vo) {
        normalize(vo);
        if (freelancerCareerMapper.insertCareer(vo) != 1) throw new IllegalStateException("insertCareer failed");
    }

    @Override
    @Transactional
    public void updateCareer(FreelancerCareerVO vo) {
        normalize(vo);
        if (freelancerCareerMapper.updateCareer(vo) != 1) throw new IllegalStateException("updateCareer failed");
    }

    @Override
    @Transactional
    public void deleteCareer(Integer careerId, Integer freelancerId) {
        if (freelancerCareerMapper.deleteCareer(careerId, freelancerId) != 1) throw new IllegalStateException("deleteCareer failed");
    }

    private void normalize(Object vo) {
        if (vo instanceof FreelancerCareerVO) {
            FreelancerCareerVO c = (FreelancerCareerVO) vo;
            if (c.getDescription() != null && c.getDescription().isBlank()) {
                c.setDescription(null);
            }
        }
    }
}
