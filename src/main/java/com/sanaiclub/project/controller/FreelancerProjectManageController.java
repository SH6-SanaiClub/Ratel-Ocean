package com.sanaiclub.project.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.project.model.dto.CalendarEventDTO;
import com.sanaiclub.project.model.dto.FreelancerProjectCardDTO;
import com.sanaiclub.project.model.dto.FreelancerProjectSummaryDTO;
import com.sanaiclub.project.service.FreelancerProjectManageService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@RequestMapping("/freelancer/project")
public class FreelancerProjectManageController {

    private final FreelancerProjectManageService freelancerProjectManageService;

    @GetMapping("/manage")
    public String manage(
            @RequestParam(required = false) String ym,
            @RequestParam(required = false, defaultValue = "inProgress") String tab,
            Model model
    ) {
        Integer freelancerId = AuthContext.requireCurrentUserId();

        YearMonth yearMonth = (ym == null || ym.isBlank()) ? YearMonth.now() : YearMonth.parse(ym);

        FreelancerProjectSummaryDTO summary = freelancerProjectManageService.getSummary(freelancerId);
        List<FreelancerProjectCardDTO> inProgress = freelancerProjectManageService.getInProgressProjects(freelancerId);
        List<FreelancerProjectCardDTO> applied = freelancerProjectManageService.getAppliedProjects(freelancerId);
        List<FreelancerProjectCardDTO> completed = freelancerProjectManageService.getCompletedProjects(freelancerId);

        LocalDate start = yearMonth.atDay(1);
        LocalDate end = yearMonth.atEndOfMonth();
        List<CalendarEventDTO> events = freelancerProjectManageService.getCalendarEvents(freelancerId, start, end);

        model.addAttribute("tab", tab);
        model.addAttribute("ym", yearMonth.toString()); // "2026-01"
        model.addAttribute("summary", summary);

        model.addAttribute("inProgressList", inProgress);
        model.addAttribute("appliedList", applied);
        model.addAttribute("completedList", completed);

        model.addAttribute("events", events);

        return "project/freelancer/freelancerProjectManage";
    }

    // 캘린더 AJAX용 JSON
    @GetMapping("/events")
    @ResponseBody
    public Map<String, Object> events(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate start,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate end
    ) {
        Integer freelancerId = AuthContext.requireCurrentUserId();
        List<CalendarEventDTO> events = freelancerProjectManageService.getCalendarEvents(freelancerId, start, end);
        return Map.of("ok", true, "events", events);
    }
}