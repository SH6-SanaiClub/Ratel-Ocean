package com.sanaiclub.project.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.project.service.ClientProjectManageService;
import com.sanaiclub.project.model.dto.ClientProjectManageDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@Controller
@RequestMapping("/client")
@RequiredArgsConstructor
public class ClientProjectManageController {

    private final ClientProjectManageService clientProjectManageService;

    // 프로젝트 관리 페이지 진입
    @GetMapping("/manage")
    public String managePage(Model model) {

        // 1. 로그인된 클라이언트 ID 가져오기
        Integer userId = AuthContext.getCurrentUserId();
        if (userId == null) {
            return "redirect:/login";
        }

        // 2. 상태별 프로젝트 리스트 조회
        List<ClientProjectManageDTO> recruiting = clientProjectManageService.getMyProjects(userId, "RECRUITING");
        List<ClientProjectManageDTO> ongoing = clientProjectManageService.getMyProjects(userId, "ONGOING");
        List<ClientProjectManageDTO> completed = clientProjectManageService.getMyProjects(userId, "COMPLETED");

        // 3. JSP로 데이터 전달
        model.addAttribute("recruitingProjects", recruiting);
        model.addAttribute("ongoingProjects", ongoing);
        model.addAttribute("completedProjects", completed);

        return "project/client/manage";
    }
}