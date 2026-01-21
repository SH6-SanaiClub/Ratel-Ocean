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

import javax.servlet.http.HttpSession;

@Controller
@RequestMapping("/project")
public class ProjectCreateController {

    @Autowired
    private ProjectCreateService projectCreateService;

    // 프로젝트 등록 페이지 보여주기
    @GetMapping("/create")
    public String createForm(Model model,  RedirectAttributes rttr) {

        // 현재 로그인한 사용자의 ID 및 권한 확인
        Integer userId = AuthContext.getCurrentUserId();
        boolean isClient = AuthContext.isClient();

        // 클라이언트가 아니거나 로그인이 안 된 경우 차단
        if (userId == null || !isClient) {
            rttr.addFlashAttribute("alertMsg", "클라이언트 전용 메뉴입니다. 프로젝트 등록은 클라이언트 계정으로만 가능합니다.");
            return "redirect:/project/dashboard";
        }

        // 스택 목록을 담기 위한 서비스 호출
        projectCreateService.setStackListToModel(model);

        return "project/create";
    }

    // 프로젝트 등록
    @PostMapping("/create")
    public String createProcess(@ModelAttribute ProjectCreateRequestDTO request,
                                @RequestParam("planFile") MultipartFile planFile,
                                HttpSession session, RedirectAttributes rttr) {

        // 현재 로그인한 사용자의 ID 가져오기
        Integer clientId = AuthContext.getCurrentUserId();

        try {
            projectCreateService.createProject(request, clientId, planFile);
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/project/create?error=true";
        }
        // 등록 성공 시
        return "redirect:/project/success";
    }

    // 등록 완료 페이지 이동
    @GetMapping("/success")
    public String successPage() {
        return "project/success";
    }
}