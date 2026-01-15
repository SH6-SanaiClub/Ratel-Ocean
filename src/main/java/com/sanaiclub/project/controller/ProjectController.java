package com.sanaiclub.project.controller;

import com.sanaiclub.project.dao.StackMapper;
import com.sanaiclub.project.model.dto.ProjectCreateRequestDTO;
import com.sanaiclub.project.model.dto.StackDto;
import com.sanaiclub.project.service.ProjectService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/project")
public class ProjectController {

    @Autowired
    private ProjectService projectService;

    // 프로젝트 등록 페이지 보여주기
    @GetMapping("/create")
    public String createForm(Model model) {
        // 스택 목록을 담기 위한 서비스 호출
        projectService.setStackListToModel(model);

        return "project/create";
    }

    @PostMapping("/create")
    public String createProcess(@ModelAttribute ProjectCreateRequestDTO request, @RequestParam("planFile") MultipartFile planFile, HttpSession session) {
        // 실제 운영시에는 세션 아이디 사용: (Long) session.getAttribute("userId");
        Integer clientId = 1;

        try {
            projectService.createProject(request, clientId, planFile);
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/project/create?error=true";
        }
        return "redirect:/project/create";
    }
}