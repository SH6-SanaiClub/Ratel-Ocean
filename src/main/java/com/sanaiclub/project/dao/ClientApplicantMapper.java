package com.sanaiclub.project.dao;

import com.sanaiclub.project.model.dto.ClientApplicantDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ClientApplicantMapper {
    List<ClientApplicantDTO> selectApplicantsByProjectId(@Param("projectId") Integer projectId);

    ClientApplicantDTO selectApplicantDetail(@Param("applicationId") Long applicationId);

    void updateStatus(@Param("applicationId") Long applicationId, @Param("status") String status);

    List<String> selectFreelancerSkills(@Param("freelancerId") Long freelancerId);

    List<ClientApplicantDTO.CareerDTO> selectFreelancerCareers(@Param("freelancerId") Long freelancerId);

    List<ClientApplicantDTO.ProjectExpDTO> selectFreelancerProjectExps(@Param("freelancerId") Long freelancerId);
}