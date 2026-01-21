package com.sanaiclub.project.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.project.model.dto.DashboardPageDTO;
import com.sanaiclub.project.service.ProjectDashboardService;
import com.sanaiclub.project.service.ProjectCreateService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequiredArgsConstructor
@RequestMapping("/project")
public class ProjectDashboardController {

    private final ProjectDashboardService projectDashboardService;
    private final ProjectCreateService projectCreateService;

    @GetMapping("/dashboard")
    public String dashboard(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Boolean onlyActive,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false, defaultValue = "all") String summary,
            @RequestParam(required = false) String sort,
            @RequestParam(required = false) List<Integer> positionIds,
            @RequestParam(required = false) List<Integer> stackIds,
            @RequestParam(required = false) Integer minBudget,
            @RequestParam(required = false) Integer maxBudget,
            Model model
    ) {
        boolean active = Boolean.TRUE.equals(onlyActive);

        // 쿠키에서 현재 사용자 ID 가져오기
        Integer userId = AuthContext.getCurrentUserId() != null ? AuthContext.getCurrentUserId() : null;

        DashboardPageDTO pageDTO = projectDashboardService.getDashboardProjects(
                keyword, active, page, size, summary, sort, positionIds, stackIds, minBudget, maxBudget, userId
        );

        // 필터 패널에 보여줄 포지션/스킬 목록 가져오기
        projectCreateService.setStackListToModel(model);

        model.addAttribute("projectList", pageDTO.getProjectList());

        // pagination
        model.addAttribute("page", pageDTO.getPage());
        model.addAttribute("size", pageDTO.getSize());
        model.addAttribute("totalPages", pageDTO.getTotalPages());
        model.addAttribute("startPage", pageDTO.getStartPage());
        model.addAttribute("endPage", pageDTO.getEndPage());
        model.addAttribute("hasPrevBlock", pageDTO.isHasPrevBlock());
        model.addAttribute("hasNextBlock", pageDTO.isHasNextBlock());
        model.addAttribute("prevBlockPage", pageDTO.getPrevBlockPage());
        model.addAttribute("nextBlockPage", pageDTO.getNextBlockPage());

        // keep params
        model.addAttribute("sort", sort);
        model.addAttribute("keyword", keyword);
        model.addAttribute("onlyActive", active);
        model.addAttribute("summary", summary);

        model.addAttribute("minBudget", minBudget);
        model.addAttribute("maxBudget", maxBudget);

        // 요약 카운트
        int todayNewCount = projectDashboardService.countTodayNewProjects();
        int deadline7Count = projectDashboardService.countDeadlineWithinDays();

        model.addAttribute("todayNewCount", todayNewCount);
        model.addAttribute("deadline7Count", deadline7Count);
        model.addAttribute("isClient", AuthContext.isClient());

        return "project/projectDashboard";
    }
}
