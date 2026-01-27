package com.sanaiclub.portfolio.service;

import com.sanaiclub.portfolio.model.dto.MyStackItemDTO;
import com.sanaiclub.portfolio.model.dto.FreelancerStackSaveRequestDTO;
import com.sanaiclub.project.model.dto.StackDTO;

import java.util.List;

public interface FreelancerStackProfileService {

    List<StackDTO> getSkillOptions();
    List<StackDTO> getPositionOptions();

    List<MyStackItemDTO> getMySkills(Integer freelancerId);
    List<MyStackItemDTO> getMyPositions(Integer freelancerId);

    void save(
            Integer freelancerId,
            String category,
            List<MyStackItemDTO> stacks
    );
}
