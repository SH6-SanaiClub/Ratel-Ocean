package com.sanaiclub.manage.service.impl;

import com.sanaiclub.manage.dao.FreelancerProjectBoardMapper;
import com.sanaiclub.manage.model.dto.FreelancerBoardProjectDTO;
import com.sanaiclub.manage.model.dto.FreelancerContractReviewViewDTO;
import com.sanaiclub.manage.model.dto.MilestoneDTO;
import com.sanaiclub.manage.service.FreelancerProjectBoardService;
import com.sanaiclub.project.model.dto.StackDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
@RequiredArgsConstructor
public class FreelancerProjectBoardServiceImpl implements FreelancerProjectBoardService {

    private final FreelancerProjectBoardMapper mapper;

    @Override
    public List<FreelancerBoardProjectDTO> getInProgressProjects(Integer freelancerId) {
        return mapper.selectInProgressProjects(freelancerId);
    }

    @Override
    public List<FreelancerBoardProjectDTO> getCompletedProjects(Integer freelancerId) {
        return mapper.selectCompletedProjects(freelancerId);
    }

    @Override
    public List<FreelancerBoardProjectDTO> getReviewProjects(Integer freelancerId) {
        return mapper.selectReviewProjects(freelancerId);
    }

    @Override
    public FreelancerBoardProjectDTO getProjectHeader(Integer freelancerId, Integer contractId) {
        return mapper.selectProjectHeader(freelancerId, contractId);
    }

    @Override
    public List<MilestoneDTO> getMilestonesWithActionableFlag(Integer freelancerId, Integer contractId) {
        if (!mapper.existsContractForFreelancer(freelancerId, contractId)) {
            return Collections.emptyList();
        }

        Integer actionableStep = mapper.selectActionableStepOrder(contractId);
        List<MilestoneDTO> list = mapper.selectMilestones(contractId);

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
        Integer contractId = mapper.selectContractIdByMilestone(milestoneId);
        if (contractId == null) return null;

        if (!mapper.existsContractForFreelancer(freelancerId, contractId)) return null;

        Integer stepOrder = mapper.selectStepOrderByMilestone(milestoneId);
        if (stepOrder == null) return null;

        Integer actionableStep = mapper.selectActionableStepOrder(contractId);
        if (actionableStep == null || !actionableStep.equals(stepOrder)) return null;

        String prev = mapper.selectMilestoneStatus(milestoneId);
        if (prev == null) return null;
        if (!("WAITING".equals(prev) || "REQUESTED".equals(prev))) return null;

        int updated = mapper.toggleMilestoneRequest(milestoneId);
        if (updated == 0) return null;

        String curr = mapper.selectMilestoneStatus(milestoneId);
        mapper.insertMilestoneHistory(milestoneId, "FREELANCER_TOGGLE_REQUEST", prev, curr);

        return curr;
    }

    @Override
    public List<StackDTO> getRequiredStacksForContract(Integer freelancerId, Integer contractId) {
        Integer projectId = mapper.selectProjectIdByContract(freelancerId, contractId);
        if (projectId == null) return Collections.emptyList();
        return mapper.selectRequiredStacksByProject(projectId);
    }

    @Override
    public List<Integer> getPreselectedStackIdsForCompleted(Integer freelancerId, Integer contractId) {
        Integer applicationId = mapper.selectApplicationIdByContract(freelancerId, contractId);
        if (applicationId == null) return Collections.emptyList();

        List<Integer> saved = mapper.selectSelectedStackIds(applicationId);
        if (saved != null && !saved.isEmpty()) return saved;

        Integer projectId = mapper.selectProjectIdByContract(freelancerId, contractId);
        if (projectId == null) return Collections.emptyList();

        return mapper.selectRequiredStackIdsByProject(projectId);
    }

    @Override
    @Transactional
    public void saveUsedStacks(Integer freelancerId, Integer contractId, List<Integer> stackIds) {
        Integer applicationId = mapper.selectApplicationIdByContract(freelancerId, contractId);
        if (applicationId == null) return;

        // 소유 검증
        if (!mapper.existsContractForFreelancer(freelancerId, contractId)) return;

        List<Integer> safe = (stackIds == null) ? Collections.emptyList() : stackIds;
        List<Integer> finalList = new ArrayList<>(new LinkedHashSet<>(safe));

        mapper.deleteProjectFreelancerStacks(applicationId);
        if (!finalList.isEmpty()) {
            mapper.insertProjectFreelancerStacks(applicationId, finalList);
        }
    }

    @Override
    public FreelancerContractReviewViewDTO getContractReviewView(Integer freelancerId, Integer contractId) {
        if (!mapper.existsContractForFreelancer(freelancerId, contractId)) return null;
        return mapper.selectContractReviewView(contractId);
    }

    @Override
    @Transactional
    public void saveFreelancerReview(Integer freelancerId, Integer contractId, Integer rating, String experience) {
        if (!mapper.existsContractForFreelancer(freelancerId, contractId)) return;
        mapper.updateFreelancerReview(contractId, rating, experience);
    }
}
