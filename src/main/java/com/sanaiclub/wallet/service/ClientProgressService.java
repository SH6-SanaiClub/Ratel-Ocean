package com.sanaiclub.wallet.service;

import com.sanaiclub.contracts.model.vo.MilestoneStatus;
import com.sanaiclub.wallet.dao.ClientProgressMapper;
import com.sanaiclub.project.model.dto.ClientProjectProgressDTO; // [수정] import 변경
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ClientProgressService {
    private final ClientProgressMapper clientProgressMapper;

    public ClientProjectProgressDTO getMilestones(Integer projectId) {
        return clientProgressMapper.selectMilestonesByProjectId(projectId);
    }

    @Transactional
    public void payMilestone(Integer milestoneId) {
        clientProgressMapper.updateMilestoneStatus(milestoneId, MilestoneStatus.PAID);
    }
}