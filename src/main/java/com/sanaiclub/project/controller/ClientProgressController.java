package com.sanaiclub.project.controller;

import com.sanaiclub.project.model.dto.ClientProjectProgressDTO; // [수정] import 변경
import com.sanaiclub.project.service.ClientProgressService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/client/api/progress")
@RequiredArgsConstructor
public class ClientProgressController {
    private final ClientProgressService clientProgressService;

    @GetMapping("/milestones")
    public ClientProjectProgressDTO getMilestones(@RequestParam Integer projectId) {
        return clientProgressService.getMilestones(projectId);
    }

    @PostMapping("/pay")
    public String payMilestone(@RequestParam Integer milestoneId) {
        clientProgressService.payMilestone(milestoneId);
        return "success";
    }
}