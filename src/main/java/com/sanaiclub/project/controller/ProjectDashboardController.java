package com.sanaiclub.project.controller;

import com.sanaiclub.project.model.dto.ProjectDashboardCardDTO;
import com.sanaiclub.project.service.ProjectDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
@RequiredArgsConstructor
@RequestMapping("/project")
public class ProjectDashboardController {

//    @GetMapping("/dashboard")
//    public String allProject(){
//        return "project/projectDashboard";
//    }


    private final ProjectDashboardService projectDashboardService;

    @GetMapping("/dashboard")
    public String dashboard(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            Model model
    ) {
        List<ProjectDashboardCardDTO> cards = projectDashboardService.getDashboardCards(keyword, page, size);
        model.addAttribute("projectList", cards);
        model.addAttribute("keyword", keyword);
        return "project/projectDashboard";
    }

}
