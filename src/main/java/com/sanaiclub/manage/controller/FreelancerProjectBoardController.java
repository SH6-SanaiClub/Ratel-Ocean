package com.sanaiclub.manage.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.manage.model.dto.FreelancerBoardProjectDTO;
import com.sanaiclub.manage.model.dto.FreelancerContractReviewViewDTO;
import com.sanaiclub.manage.model.dto.MilestoneDTO;
import com.sanaiclub.manage.model.dto.SaveReviewRequestDTO;
import com.sanaiclub.manage.model.dto.SaveStacksRequestDTO;
import com.sanaiclub.manage.service.FreelancerProjectBoardService;
import com.sanaiclub.project.model.dto.StackDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@Controller
@RequiredArgsConstructor
@RequestMapping("/freelancer/projects")
public class FreelancerProjectBoardController {

    private final FreelancerProjectBoardService boardService;

    /**
     * tab = inProgress | completed | reviews
     */
    @GetMapping("/board")
    public String board(
            @RequestParam(value = "tab", defaultValue = "inProgress") String tab,
            @RequestParam(value = "contractId", required = false) Integer contractId,
            Model model
    ) {
        Integer freelancerId = AuthContext.requireCurrentUserId();

        List<FreelancerBoardProjectDTO> inProgressList = boardService.getInProgressProjects(freelancerId);
        List<FreelancerBoardProjectDTO> completedList = boardService.getCompletedProjects(freelancerId);
        List<FreelancerBoardProjectDTO> reviewList = boardService.getReviewProjects(freelancerId);

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
            return "manage/freelancer/freelancerProjectBoard";
        }

        FreelancerBoardProjectDTO selected = boardService.getProjectHeader(freelancerId, selectedContractId);
        model.addAttribute("selected", selected);

        if ("inProgress".equals(tab)) {
            List<MilestoneDTO> milestones = boardService.getMilestonesWithActionableFlag(freelancerId, selectedContractId);
            model.addAttribute("milestones", milestones);
            // 오른쪽 패널 리뷰(기존 작성값 표시용)
            model.addAttribute("reviewView", boardService.getContractReviewView(freelancerId, selectedContractId));

        } else if ("completed".equals(tab)) {
            List<StackDTO> requiredStacks = boardService.getRequiredStacksForContract(freelancerId, selectedContractId);
//            List<Integer> preSelected = boardService.getPreselectedStackIdsForCompleted(freelancerId, selectedContractId);
//
            model.addAttribute("requiredStacks", requiredStacks);

            List<Integer> preSelected = boardService.getPreselectedStackIdsForCompleted(freelancerId, selectedContractId);
            model.addAttribute("preSelectedIds", new HashSet<>(preSelected));

            // JSTL contains용 csv
            String preSelectedCsv = preSelected.stream()
                    .map(String::valueOf)
                    .collect(Collectors.joining(",", ",", ","));

            if (preSelected.isEmpty()) preSelectedCsv = ","; // contains 체크용 안전 처리
            model.addAttribute("preSelectedCsv", preSelectedCsv);

            model.addAttribute("reviewView", boardService.getContractReviewView(freelancerId, selectedContractId));

        } else { // reviews
            model.addAttribute("reviewView", boardService.getContractReviewView(freelancerId, selectedContractId));
        }

        return "manage/freelancer/freelancerProjectBoard";
    }

    /** 마일스톤 승인요청(REQUESTED) ↔ 요청취소(WAITING) 토글 (가장 앞단계만 가능) */
    @PostMapping("/board/milestones/{milestoneId}/toggle")
    @ResponseBody
    public Map<String, Object> toggleMilestoneRequest(@PathVariable("milestoneId") Integer milestoneId) {
        Integer freelancerId = AuthContext.requireCurrentUserId();
        String status = boardService.toggleMilestoneRequest(freelancerId, milestoneId);
        Map<String, Object> res = new HashMap<>();
        res.put("ok", status != null);
        res.put("status", status);
        return res;
    }

    /** 완료 프로젝트: 사용 스택 저장 (project_freelancer_stacks) */
    @PostMapping("/board/stacks/save")
    @ResponseBody
    public Map<String, Object> saveUsedStacks(@RequestBody SaveStacksRequestDTO req) {
        Integer freelancerId = AuthContext.requireCurrentUserId();
        boardService.saveUsedStacks(freelancerId, req.getContractId(), req.getStackIds());
        return Collections.<String, Object>singletonMap("ok", true);
    }

    /** 프리랜서 → 클라이언트 리뷰 저장 (contracts.freelancer_rating/experience) */
    @PostMapping("/board/review/save")
    @ResponseBody
    public Map<String, Object> saveFreelancerReview(@RequestBody SaveReviewRequestDTO req) {
        Integer freelancerId = AuthContext.requireCurrentUserId();
        boardService.saveFreelancerReview(freelancerId, req.getContractId(), req.getRating(), req.getExperience());
        return Collections.<String, Object>singletonMap("ok", true);
    }


}
