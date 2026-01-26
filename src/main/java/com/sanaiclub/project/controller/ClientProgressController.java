package com.sanaiclub.project.controller;

import com.sanaiclub.project.model.dto.ClientMilestoneDTO;
import com.sanaiclub.project.service.ClientProgressService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/client/api/progress")
@RequiredArgsConstructor
public class ClientProgressController {
    private final ClientProgressService clientProgressService;

    // 마일스톤 데이터 검색
    @GetMapping("/milestones")
    public List<ClientMilestoneDTO> getMilestones(@RequestParam Integer projectId) {
        return clientProgressService.getMilestones(projectId);
    }

    // 지급 완료 처리 메서드
    @PostMapping("/pay")
    public String payMilestone(@RequestParam Integer milestoneId) {
        clientProgressService.payMilestone(milestoneId);
        // AJAX 성공(success) 함수로 돌아감
        return "success";
    }
}