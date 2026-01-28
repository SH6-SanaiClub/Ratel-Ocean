package com.sanaiclub.project.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.project.model.dto.FreelancerBoardProjectDTO;
import com.sanaiclub.project.model.dto.MilestoneDTO;
import com.sanaiclub.project.model.dto.SaveReviewRequestDTO;
import com.sanaiclub.project.model.dto.SaveStacksRequestDTO;
import com.sanaiclub.project.service.FreelancerProjectManageDetailService;
import com.sanaiclub.portfolio.dao.StackOptionMapper;
import com.sanaiclub.project.model.dto.StackDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@Controller
@RequiredArgsConstructor
@RequestMapping("/freelancer/project")
public class FreelancerProjectManageDetailController {

    private final FreelancerProjectManageDetailService freelancerProjectManageDetailService;
    private final StackOptionMapper stackOptionMapper;

    /**
     * tab = inProgress | completed | reviews
     */
    @GetMapping("/detail")
    public String board(
            @RequestParam(value = "tab", defaultValue = "inProgress") String tab,
            @RequestParam(value = "contractId", required = false) Integer contractId,
            Model model
    ) {
        Integer freelancerId = AuthContext.requireCurrentUserId();

        List<FreelancerBoardProjectDTO> inProgressList = freelancerProjectManageDetailService.getInProgressProjects(freelancerId);
        List<FreelancerBoardProjectDTO> completedList = freelancerProjectManageDetailService.getCompletedProjects(freelancerId);
        List<FreelancerBoardProjectDTO> reviewList = freelancerProjectManageDetailService.getReviewProjects(freelancerId);

        Integer selectedContractId = contractId;
        if (selectedContractId == null) {
            List<FreelancerBoardProjectDTO> base =
                    "completed".equals(tab) ? completedList :
                            "reviews".equals(tab) ? reviewList :
                                    inProgressList;

            if (base != null && !base.isEmpty()) selectedContractId = base.get(0).getContractId();
        }

        model.addAttribute("tab", tab);
        model.addAttribute("inProgressList", inProgressList);
        model.addAttribute("completedList", completedList);
        model.addAttribute("reviewList", reviewList);
        model.addAttribute("selectedContractId", selectedContractId);

        if (selectedContractId == null) {
            model.addAttribute("selected", null);
            model.addAttribute("milestones", Collections.emptyList());
            model.addAttribute("requiredStacks", Collections.emptyList());
            model.addAttribute("preSelectedCsv", "");
            model.addAttribute("reviewView", null);
            return "project/freelancer/freelancerProjectManageDetail";
        }

        FreelancerBoardProjectDTO selected = freelancerProjectManageDetailService.getProjectHeader(freelancerId, selectedContractId);
        model.addAttribute("selected", selected);

        if ("inProgress".equals(tab)) {
            List<MilestoneDTO> milestones = freelancerProjectManageDetailService.getMilestonesWithActionableFlag(freelancerId, selectedContractId);
            model.addAttribute("milestones", milestones);
            // 오른쪽 패널 리뷰(
            model.addAttribute("reviewView", freelancerProjectManageDetailService.getContractReviewView(freelancerId, selectedContractId));

        } else if ("completed".equals(tab)) {
            List<StackDTO> requiredStacks = freelancerProjectManageDetailService.getRequiredStacksForContract(freelancerId, selectedContractId);

            model.addAttribute("requiredStacks", requiredStacks);

            List<StackDTO> positionStacks =
                    stackOptionMapper.findByCategory("POSITION");

            List<StackDTO> skillStacks =
                    stackOptionMapper.findByCategory("SKILL");

            model.addAttribute("positionStacks", positionStacks);
            model.addAttribute("skillStacks", skillStacks);


            List<Integer> preSelected = freelancerProjectManageDetailService.getPreselectedStackIdsForCompleted(freelancerId, selectedContractId);
            model.addAttribute("preSelectedIds", new HashSet<>(preSelected));

            // JSTL contains용 csv
            String preSelectedCsv = preSelected.stream()
                    .map(String::valueOf)
                    .collect(Collectors.joining(",", ",", ","));

            if (preSelected.isEmpty()) preSelectedCsv = ","; // contains 체크용 안전 처리
            model.addAttribute("preSelectedCsv", preSelectedCsv);

            model.addAttribute("reviewView", freelancerProjectManageDetailService.getContractReviewView(freelancerId, selectedContractId));

        } else { // reviews
            model.addAttribute("reviewView", freelancerProjectManageDetailService.getContractReviewView(freelancerId, selectedContractId));
        }

        return "project/freelancer/freelancerProjectManageDetail";
    }

    /** 마일스톤 승인요청(REQUESTED) ↔ 요청취소(WAITING) 토글 (가장 앞단계만 가능) */
    @PostMapping("/detail/milestones/{milestoneId}/toggle")
    @ResponseBody
    public Map<String, Object> toggleMilestoneRequest(@PathVariable("milestoneId") Integer milestoneId) {
        Integer freelancerId = AuthContext.requireCurrentUserId();
        String status = freelancerProjectManageDetailService.toggleMilestoneRequest(freelancerId, milestoneId);
        Map<String, Object> res = new HashMap<>();
        res.put("ok", status != null);
        res.put("status", status);
        return res;
    }

    /** 완료 프로젝트: 사용 스택 저장 (project_freelancer_stacks) */
    @PostMapping("/detail/stacks/save")
    @ResponseBody
    public Map<String, Object> saveUsedStacks(@RequestBody SaveStacksRequestDTO req) {
        Integer freelancerId = AuthContext.requireCurrentUserId();
        freelancerProjectManageDetailService.saveUsedStacks(freelancerId, req.getContractId(), req.getStackIds());
        return Collections.<String, Object>singletonMap("ok", true);
    }

    /** 프리랜서 → 클라이언트 리뷰 저장 (contracts.freelancer_rating/experience) */
    @PostMapping("/detail/review/save")
    @ResponseBody
    public Map<String, Object> saveFreelancerReview(@RequestBody SaveReviewRequestDTO req) {
        Integer freelancerId = AuthContext.requireCurrentUserId();
        freelancerProjectManageDetailService.saveFreelancerReview(freelancerId, req.getContractId(), req.getRating(), req.getExperience());
        return Collections.<String, Object>singletonMap("ok", true);
    }


}
