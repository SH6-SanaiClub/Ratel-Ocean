package com.sanaiclub.project.service;

import com.sanaiclub.project.dao.ClientProgressMapper;
import com.sanaiclub.project.model.dto.ClientMilestoneDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ClientProgressService {
    private final ClientProgressMapper clientProgressMapper;

    public List<ClientMilestoneDTO> getMilestones(Integer projectId) {
        return clientProgressMapper.selectMilestonesByProjectId(projectId);
    }

    @Transactional
    public void payMilestone(Integer milestoneId) {
        clientProgressMapper.updateMilestoneStatus(milestoneId, "PAID");
    }
}