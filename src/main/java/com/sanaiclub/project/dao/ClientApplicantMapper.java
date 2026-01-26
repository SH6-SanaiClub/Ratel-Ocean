package com.sanaiclub.project.dao;

import com.sanaiclub.project.model.dto.ClientApplicantDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ClientApplicantMapper {
    List<ClientApplicantDTO> selectApplicantsByProjectId(@Param("projectId") Integer projectId);

    ClientApplicantDTO selectApplicantDetail(@Param("applicationId") Integer applicationId);

    void updateStatus(@Param("applicationId") Integer applicationId, @Param("status") String status);

    List<String> selectFreelancerSkills(@Param("freelancerId") Integer freelancerId);

    List<ClientApplicantDTO.CareerDTO> selectFreelancerCareers(@Param("freelancerId") Integer freelancerId);

    List<ClientApplicantDTO.ProjectExpDTO> selectFreelancerProjectExps(@Param("freelancerId") Integer freelancerId);
}