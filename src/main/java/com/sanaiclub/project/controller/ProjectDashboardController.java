package com.sanaiclub.project.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.project.model.dto.DashboardPageDTO;
import com.sanaiclub.project.service.ProjectBookmarkService;
import com.sanaiclub.project.service.ProjectDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

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
            @RequestParam(required = false, defaultValue = "all") String summary,
            @RequestParam(required = false) Integer userId,
            Model model
    ) {
        boolean active = Boolean.TRUE.equals(onlyActive);

        DashboardPageDTO pageDTO =
                projectDashboardService.getDashboardProjects(keyword, active, page, size, summary, userId);

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
        model.addAttribute("summary", summary);

        // 요약 카운트
        int todayNewCount = projectDashboardService.countTodayNewProjects();
        int deadline7Count = projectDashboardService.countDeadlineWithinDays();

        model.addAttribute("todayNewCount", todayNewCount);
        model.addAttribute("deadline7Count", deadline7Count);

        return "project/projectDashboard";
    }

    @GetMapping("/detail")
    public String detail(@RequestParam("projectId") Integer projectId,
                         @RequestParam(value="page", required=false, defaultValue="1") int page,
                         @RequestParam(value="size", required=false, defaultValue="10") int size,
                         @RequestParam(value="onlyActive", required=false, defaultValue="false") boolean onlyActive,
                         @RequestParam(value="keyword", required=false, defaultValue="") String keyword,
                         Model model) {

        model.addAttribute("project", projectDashboardService.getProjectDetail(projectId));

        // 목록으로 돌아갈 때 쓰라고 다시 담아줌
        model.addAttribute("page", page);
        model.addAttribute("size", size);
        model.addAttribute("onlyActive", onlyActive);
        model.addAttribute("keyword", keyword);

        return "project/detail";
    }

    private final ProjectBookmarkService projectBookmarkService;

    @PostMapping("/bookmark/toggle")
    @ResponseBody
    public Map<String, Object> toggleBookmark(@RequestParam("projectId") Integer projectId) {

        Integer userId = AuthContext.getCurrentUserId();

        boolean bookmarked = projectBookmarkService.toggle(projectId, userId);
        return Map.of("ok", true, "bookmarked", bookmarked);
    }

}
