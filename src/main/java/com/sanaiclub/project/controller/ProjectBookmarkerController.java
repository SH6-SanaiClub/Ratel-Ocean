package com.sanaiclub.project.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.project.model.dto.DashboardPageDTO;
import com.sanaiclub.project.service.ProjectBookmarkService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequiredArgsConstructor
@RequestMapping("/project")
public class ProjectBookmarkerController {

    private final ProjectBookmarkService projectBookmarkService;

    @GetMapping("/bookmark")
    public String bookmarkPage(
            @RequestParam(required = false) String keyword,
            Model model
    ) {

        Integer userId = AuthContext.getCurrentUserId();

        // 북마크 목록 조회
        DashboardPageDTO result = projectBookmarkService.getBookmarkedDashboardPage(
                keyword, userId
        );

        // 화면에 필요한 값들
        model.addAttribute("projectList", result.getProjectList());
        model.addAttribute("keyword", keyword);

        return "project/projectBookmarker";
    }
}
