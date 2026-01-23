package com.sanaiclub.project.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.project.model.dto.ProjectDetailDTO;
import com.sanaiclub.project.service.ProjectDetailService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Controller
@RequestMapping("/project")
@RequiredArgsConstructor
public class ProjectDetailController {

    private final ProjectDetailService projectDetailService;

    @GetMapping("/detail")
    public String detail(@RequestParam("projectId") Integer projectId,
                         @RequestParam(value = "page", required = false, defaultValue = "1") int page,
                         @RequestParam(value = "size", required = false, defaultValue = "10") int size,
                         @RequestParam(value = "onlyActive", required = false, defaultValue = "false") boolean onlyActive,
                         @RequestParam(value = "keyword", required = false, defaultValue = "") String keyword,
                         Model model) {

        // 로그인 사용자 ID 가져오기
        Integer userId = AuthContext.getCurrentUserId() != null ? AuthContext.getCurrentUserId() : null;

        //  Model에 유저 정보 담기
        model.addAttribute("loginUserId", userId);

        if (userId != null) {
            // 유저 타입 넘기기
            String userType = projectDetailService.getUserType(userId);
            model.addAttribute("loginUserType", userType);
        }

        // 프로젝트 상세 조회 (지원여부, 찜여부 포함)
        ProjectDetailDTO projectDetail = projectDetailService.getProjectDetail(projectId, userId);
        model.addAttribute("project", projectDetail);

        // JSP 편의용 플래그
        model.addAttribute("isApplied", projectDetail.isApplied());
        model.addAttribute("isWishlisted", projectDetail.isWishlisted());

        // 목록 돌아가기용 파라미터 유지
        model.addAttribute("page", page);
        model.addAttribute("size", size);
        model.addAttribute("onlyActive", onlyActive);
        model.addAttribute("keyword", keyword);

        return "project/detail";
    }

    // 지원하기 토글
    @PostMapping("/apply/toggle")
    @ResponseBody
    public Map<String, Object> toggleApply(@RequestParam("projectId") Integer projectId) {

        // 로그인 유저 ID 확인
        Integer userId = AuthContext.getCurrentUserId();
        if (userId == null) {
            return Map.of("result", "FAIL", "message", "로그인이 필요합니다.");
        }

        // 서비스 호출
        String status = projectDetailService.toggleApply(projectId, userId);

        // 결과 리턴
        return Map.of("result", "SUCCESS", "status", status);
    }
}
