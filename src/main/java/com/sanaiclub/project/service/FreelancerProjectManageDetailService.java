package com.sanaiclub.project.service;

import com.sanaiclub.project.model.dto.FreelancerBoardProjectDTO;
import com.sanaiclub.project.model.dto.FreelancerContractReviewViewDTO;
import com.sanaiclub.project.model.dto.MilestoneDTO;
import com.sanaiclub.project.model.dto.StackDTO;

import java.util.List;

public interface FreelancerProjectManageDetailService {

    List<FreelancerBoardProjectDTO> getInProgressProjects(Integer freelancerId);
    List<FreelancerBoardProjectDTO> getCompletedProjects(Integer freelancerId);
    List<FreelancerBoardProjectDTO> getReviewProjects(Integer freelancerId);

    FreelancerBoardProjectDTO getProjectHeader(Integer freelancerId, Integer contractId);

    List<MilestoneDTO> getMilestonesWithActionableFlag(Integer freelancerId, Integer contractId);

    /**
     * 가장 앞 WAITING/REQUESTED 단계만 토글 가능
     * 성공 시 변경된 status 반환, 실패 시 null
     */
    String toggleMilestoneRequest(Integer freelancerId, Integer milestoneId);

    /** 완료탭: contractId -> project 요구스택 목록 */
    List<StackDTO> getRequiredStacksForContract(Integer freelancerId, Integer contractId);

    /**
     * 완료 탭: 미리 선택되어야 하는 stackId 목록
     * 1) project_freelancer_stacks 값 있으면 우선
     * 2) 없으면 project_stacks 기본 선택
     */
    List<Integer> getPreselectedStackIdsForCompleted(Integer freelancerId, Integer contractId);

    void saveUsedStacks(Integer freelancerId, Integer contractId, List<Integer> stackIds);

    FreelancerContractReviewViewDTO getContractReviewView(Integer freelancerId, Integer contractId);

    void saveFreelancerReview(Integer freelancerId, Integer contractId, Integer rating, String experience);
}
