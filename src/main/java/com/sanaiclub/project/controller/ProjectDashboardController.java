package com.sanaiclub.project.controller;

import com.sanaiclub.project.model.dto.DashboardPageDTO;
import com.sanaiclub.project.model.dto.ProjectDashboardCardDTO;
import com.sanaiclub.project.model.vo.ProjectsVO;
import com.sanaiclub.project.service.ProjectDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequiredArgsConstructor
@RequestMapping("/project")
public class ProjectDashboardController {

    private final ProjectDashboardService projectDashboardService;

    @GetMapping("/dashboard")
    public String dashboard(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Boolean onlyActive,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            Model model
    ) {
        boolean active = Boolean.TRUE.equals(onlyActive);

        DashboardPageDTO pageDTO =
                projectDashboardService.getDashboardProjects(keyword, active, page, size);

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
        model.addAttribute("keyword", keyword);
        model.addAttribute("onlyActive", active);

        // ✅ 추가: 요약 카운트
        int todayNewCount = projectDashboardService.countTodayNewProjects();
        int deadline7Count = projectDashboardService.countDeadlineWithinDays();

        model.addAttribute("todayNewCount", todayNewCount);
        model.addAttribute("deadline7Count", deadline7Count);

        return "project/projectDashboard";
    }

    @GetMapping("/detail")
    public String detail(@RequestParam("projectId") long projectId,
                         @RequestParam(value="page", required=false, defaultValue="1") int page,
                         @RequestParam(value="size", required=false, defaultValue="10") int size,
                         @RequestParam(value="onlyActive", required=false, defaultValue="false") boolean onlyActive,
                         @RequestParam(value="keyword", required=false, defaultValue="") String keyword,
                         Model model) {

        model.addAttribute("project", projectDashboardService.getProjectDetail(projectId));

        // (선택) 목록으로 돌아갈 때 쓰라고 다시 담아줌
        model.addAttribute("page", page);
        model.addAttribute("size", size);
        model.addAttribute("onlyActive", onlyActive);
        model.addAttribute("keyword", keyword);

        return "project/projectDetailTest";
    }
}
