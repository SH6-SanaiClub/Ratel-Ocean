package com.sanaiclub.project.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.project.model.dto.ProjectCreateRequestDTO;
import com.sanaiclub.project.service.ProjectCreateService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/project")
public class ProjectCreateController {

    @Autowired
    private ProjectCreateService projectCreateService;

    // 프로젝트 등록 페이지
    @GetMapping("/create")
    public String createForm(Model model, RedirectAttributes rttr) {
        Integer userId = AuthContext.getCurrentUserId();
        if (userId == null || !AuthContext.isClient()) {
            rttr.addFlashAttribute("alertMsg", "클라이언트 계정으로 로그인해주세요.");
            return "redirect:/";
        }

        projectCreateService.setStackListToModel(model);
        return "project/client/create";
    }

    // 프로젝트 등록 처리
    @PostMapping("/create")
    public String createProcess(@ModelAttribute ProjectCreateRequestDTO request,
                                @RequestParam("planFile") MultipartFile planFile) {
        Integer clientId = AuthContext.getCurrentUserId();
        try {
            projectCreateService.createProject(request, clientId, planFile);
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/project/create?error=true";
        }
        return "redirect:/project/success";
    }

    // 수정 페이지 이동
    @GetMapping("/edit/{projectId}")
    public String editForm(@PathVariable("projectId") Integer projectId, Model model, RedirectAttributes rttr) {
        ProjectCreateRequestDTO project = projectCreateService.getProjectDetailForEdit(projectId);

        if (project == null) {
            rttr.addFlashAttribute("alertMsg", "존재하지 않는 프로젝트입니다.");
            return "redirect:/client/manage";
        }

        model.addAttribute("project", project); // 기존 데이터
        model.addAttribute("isEdit", true);     // 수정 모드

        projectCreateService.setStackListToModel(model); // 공통 코드
        return "project/client/create";
    }

    // 수정 완료 처리
    @PostMapping("/update")
    public String updateProcess(@ModelAttribute ProjectCreateRequestDTO request,
                                @RequestParam(value = "planFile", required = false) MultipartFile planFile,
                                RedirectAttributes rttr) {
        try {
            projectCreateService.updateProject(request, planFile);
            rttr.addFlashAttribute("msg", "수정이 완료되었습니다.");
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/project/edit/" + request.getProjectId() + "?error=true";
        }
        return "redirect:/client/manage";
    }

    // 삭제
    @PostMapping("/delete")
    @ResponseBody
    public String deleteProcess(@RequestParam("projectId") Integer projectId) {
        try {
            projectCreateService.deleteProject(projectId);
            return "success";
        } catch (Exception e) {
            e.printStackTrace();
            return "fail";
        }
    }

    // 프로젝트 등록 성공 페이지
    @GetMapping("/success")
    public String success() {
        return "project/client/success";
    }
}