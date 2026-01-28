package com.sanaiclub.project.service.impl;

import com.sanaiclub.project.dao.FreelancerProjectManageDetailMapper;
import com.sanaiclub.project.model.dto.FreelancerBoardProjectDTO;
import com.sanaiclub.project.model.dto.FreelancerContractReviewViewDTO;
import com.sanaiclub.project.model.dto.MilestoneDTO;
import com.sanaiclub.project.service.FreelancerProjectManageDetailService;
import com.sanaiclub.project.model.dto.StackDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
@RequiredArgsConstructor
public class FreelancerProjectManageDetailServiceImpl implements FreelancerProjectManageDetailService {

    private final FreelancerProjectManageDetailMapper freelancerProjectManageDetailMapper;

    @Override
    public List<FreelancerBoardProjectDTO> getInProgressProjects(Integer freelancerId) {
        return freelancerProjectManageDetailMapper.selectInProgressProjects(freelancerId);
    }

    @Override
    public List<FreelancerBoardProjectDTO> getCompletedProjects(Integer freelancerId) {
        return freelancerProjectManageDetailMapper.selectCompletedProjects(freelancerId);
    }

    @Override
    public List<FreelancerBoardProjectDTO> getReviewProjects(Integer freelancerId) {
        return freelancerProjectManageDetailMapper.selectReviewProjects(freelancerId);
    }

    @Override
    public FreelancerBoardProjectDTO getProjectHeader(Integer freelancerId, Integer contractId) {
        return freelancerProjectManageDetailMapper.selectProjectHeader(freelancerId, contractId);
    }

    @Override
    public List<MilestoneDTO> getMilestonesWithActionableFlag(Integer freelancerId, Integer contractId) {
        if (!freelancerProjectManageDetailMapper.existsContractForFreelancer(freelancerId, contractId)) {
            return Collections.emptyList();
        }

        Integer actionableStep = freelancerProjectManageDetailMapper.selectActionableStepOrder(contractId);
        List<MilestoneDTO> list = freelancerProjectManageDetailMapper.selectMilestones(contractId);

        for (MilestoneDTO m : list) {
            boolean ok = actionableStep != null
                    && actionableStep.equals(m.getStepOrder())
                    && ("WAITING".equals(m.getStatus()) || "REQUESTED".equals(m.getStatus()));
            m.setActionable(ok);
        }
        return list;
    }

    @Override
    @Transactional
    public String toggleMilestoneRequest(Integer freelancerId, Integer milestoneId) {
        Integer contractId = freelancerProjectManageDetailMapper.selectContractIdByMilestone(milestoneId);
        if (contractId == null) return null;

        if (!freelancerProjectManageDetailMapper.existsContractForFreelancer(freelancerId, contractId)) return null;

        Integer stepOrder = freelancerProjectManageDetailMapper.selectStepOrderByMilestone(milestoneId);
        if (stepOrder == null) return null;

        Integer actionableStep = freelancerProjectManageDetailMapper.selectActionableStepOrder(contractId);
        if (actionableStep == null || !actionableStep.equals(stepOrder)) return null;

        String prev = freelancerProjectManageDetailMapper.selectMilestoneStatus(milestoneId);
        if (prev == null) return null;
        if (!("WAITING".equals(prev) || "REQUESTED".equals(prev))) return null;

        int updated = freelancerProjectManageDetailMapper.toggleMilestoneRequest(milestoneId);
        if (updated == 0) return null;

        String curr = freelancerProjectManageDetailMapper.selectMilestoneStatus(milestoneId);
        freelancerProjectManageDetailMapper.insertMilestoneHistory(milestoneId, "FREELANCER_TOGGLE_REQUEST", prev, curr);

        return curr;
    }

    @Override
    public List<StackDTO> getRequiredStacksForContract(Integer freelancerId, Integer contractId) {
        Integer projectId = freelancerProjectManageDetailMapper.selectProjectIdByContract(freelancerId, contractId);
        if (projectId == null) return Collections.emptyList();
        return freelancerProjectManageDetailMapper.selectRequiredStacksByProject(projectId);
    }

    @Override
    public List<Integer> getPreselectedStackIdsForCompleted(Integer freelancerId, Integer contractId) {
        Integer applicationId = freelancerProjectManageDetailMapper.selectApplicationIdByContract(freelancerId, contractId);
        if (applicationId == null) return Collections.emptyList();

        List<Integer> saved = freelancerProjectManageDetailMapper.selectSelectedStackIds(applicationId);
        if (saved != null && !saved.isEmpty()) return saved;

        Integer projectId = freelancerProjectManageDetailMapper.selectProjectIdByContract(freelancerId, contractId);
        if (projectId == null) return Collections.emptyList();

        return freelancerProjectManageDetailMapper.selectRequiredStackIdsByProject(projectId);
    }

    @Override
    @Transactional
    public void saveUsedStacks(Integer freelancerId, Integer contractId, List<Integer> stackIds) {
        Integer applicationId = freelancerProjectManageDetailMapper.selectApplicationIdByContract(freelancerId, contractId);
        if (applicationId == null) return;

        // 소유 검증
        if (!freelancerProjectManageDetailMapper.existsContractForFreelancer(freelancerId, contractId)) return;

        List<Integer> safe = (stackIds == null) ? Collections.emptyList() : stackIds;
        List<Integer> finalList = new ArrayList<>(new LinkedHashSet<>(safe));

        freelancerProjectManageDetailMapper.deleteProjectFreelancerStacks(applicationId);
        if (!finalList.isEmpty()) {
            freelancerProjectManageDetailMapper.insertProjectFreelancerStacks(applicationId, finalList);
        }
    }

    @Override
    public FreelancerContractReviewViewDTO getContractReviewView(Integer freelancerId, Integer contractId) {
        if (!freelancerProjectManageDetailMapper.existsContractForFreelancer(freelancerId, contractId)) return null;
        return freelancerProjectManageDetailMapper.selectContractReviewView(contractId);
    }

    @Override
    @Transactional
    public void saveFreelancerReview(Integer freelancerId, Integer contractId, Integer rating, String experience) {
        if (!freelancerProjectManageDetailMapper.existsContractForFreelancer(freelancerId, contractId)) return;
        freelancerProjectManageDetailMapper.updateFreelancerReview(contractId, rating, experience);
    }
}
