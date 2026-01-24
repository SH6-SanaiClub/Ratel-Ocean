package com.sanaiclub.project.service;

import com.sanaiclub.project.dao.ClientApplicantMapper;
import com.sanaiclub.project.model.dto.ClientApplicantDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ClientApplicantService {

    private final ClientApplicantMapper clientApplicantMapper;

    public List<ClientApplicantDTO> getApplicants(Integer projectId) {
        return clientApplicantMapper.selectApplicantsByProjectId(projectId);
    }

    @Transactional
    public ClientApplicantDTO getApplicantDetail(Long applicationId) {
        ClientApplicantDTO detail = clientApplicantMapper.selectApplicantDetail(applicationId);
        if (detail != null) {
            // 미열람 -> 열람함 자동 전환
            if ("PENDING".equals(detail.getApplicationStatus())) {
                updateStatus(applicationId, "VIEWED");
                detail.setApplicationStatus("VIEWED");
            }
            Long fId = detail.getFreelancerId();
            detail.setSkills(clientApplicantMapper.selectFreelancerSkills(fId));
            detail.setCareers(clientApplicantMapper.selectFreelancerCareers(fId));
            detail.setProjects(clientApplicantMapper.selectFreelancerProjectExps(fId));
        }
        return detail;
    }

    // 상태 변경 메서드
    public void updateStatus(Long applicationId, String status) {
        clientApplicantMapper.updateStatus(applicationId, status);
    }
}