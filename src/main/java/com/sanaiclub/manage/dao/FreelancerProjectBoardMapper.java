package com.sanaiclub.manage.dao;

import com.sanaiclub.manage.model.dto.FreelancerBoardProjectDTO;
import com.sanaiclub.manage.model.dto.FreelancerContractReviewViewDTO;
import com.sanaiclub.manage.model.dto.MilestoneDTO;
import com.sanaiclub.project.model.dto.StackDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface FreelancerProjectBoardMapper {

    List<FreelancerBoardProjectDTO> selectInProgressProjects(@Param("freelancerId") Integer freelancerId);

    List<FreelancerBoardProjectDTO> selectCompletedProjects(@Param("freelancerId") Integer freelancerId);

    List<FreelancerBoardProjectDTO> selectReviewProjects(@Param("freelancerId") Integer freelancerId);

    FreelancerBoardProjectDTO selectProjectHeader(@Param("freelancerId") Integer freelancerId,
                                                  @Param("contractId") Integer contractId);

    boolean existsContractForFreelancer(@Param("freelancerId") Integer freelancerId,
                                        @Param("contractId") Integer contractId);

    List<MilestoneDTO> selectMilestones(@Param("contractId") Integer contractId);

    /**
     * "WAITING or REQUESTED" 중 가장 앞단계(step_order MIN)
     * - 요청보낸 상태(REQUESTED)도 취소 가능해야 하니까 포함
     */
    Integer selectActionableStepOrder(@Param("contractId") Integer contractId);

    Integer selectContractIdByMilestone(@Param("milestoneId") Integer milestoneId);

    Integer selectStepOrderByMilestone(@Param("milestoneId") Integer milestoneId);

    String selectMilestoneStatus(@Param("milestoneId") Integer milestoneId);

    int toggleMilestoneRequest(@Param("milestoneId") Integer milestoneId);

    int insertMilestoneHistory(@Param("milestoneId") Integer milestoneId,
                               @Param("actionType") String actionType,
                               @Param("prevValue") String prevValue,
                               @Param("currValue") String currValue);

    Integer selectApplicationIdByContract(@Param("freelancerId") Integer freelancerId,
                                          @Param("contractId") Integer contractId);

    Integer selectProjectIdByContract(@Param("freelancerId") Integer freelancerId,
                                      @Param("contractId") Integer contractId);

    List<Integer> selectSelectedStackIds(@Param("applicationId") Integer applicationId);

    List<Integer> selectRequiredStackIdsByProject(@Param("projectId") Integer projectId);

    List<StackDTO> selectRequiredStacksByProject(@Param("projectId") Integer projectId);

    int deleteProjectFreelancerStacks(@Param("applicationId") Integer applicationId);

    int insertProjectFreelancerStacks(@Param("applicationId") Integer applicationId,
                                      @Param("stackIds") List<Integer> stackIds);

    FreelancerContractReviewViewDTO selectContractReviewView(@Param("contractId") Integer contractId);

    int updateFreelancerReview(@Param("contractId") Integer contractId,
                               @Param("rating") Integer rating,
                               @Param("experience") String experience);
}
