package com.sanaiclub.user.controller;

import com.sanaiclub.user.model.dto.ClientMyPageDTO;
import com.sanaiclub.user.service.ClientMyPageService; // [필수] 인터페이스 임포트
// import com.sanaiclub.user.service.impl.ClientMyPageServiceImpl; // [삭제] 이거 있으면 500 에러 남!!

import com.sanaiclub.common.util.AuthContext;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/client")
@RequiredArgsConstructor
public class ClientMyPageController {

    private final ClientMyPageService clientMyPageService;

    @GetMapping("/mypage")
    public String myPageForm(Model model, RedirectAttributes rttr) {
        Integer userId = AuthContext.getCurrentUserId();
        if (userId == null) {
            rttr.addFlashAttribute("alertMsg", "로그인이 필요합니다.");
            return "redirect:/login";
        }

        ClientMyPageDTO profile = clientMyPageService.getClientProfile(userId);
        model.addAttribute("profile", profile);
        return "user/client/mypage";
    }

    @PostMapping("/mypage/update")
    public String updateProfile(@ModelAttribute ClientMyPageDTO dto,
                                @RequestParam(value = "profileFile", required = false) MultipartFile profileFile,
                                RedirectAttributes rttr) {
        Integer userId = AuthContext.getCurrentUserId();
        dto.setUserId(userId);

        try {
            clientMyPageService.updateProfile(dto, profileFile);
            rttr.addFlashAttribute("msg", "정보가 수정되었습니다.");
        } catch (Exception e) {
            e.printStackTrace();
            rttr.addFlashAttribute("msg", "수정 실패: 오류가 발생했습니다.");
        }
        return "redirect:/client/mypage";
    }

    @PostMapping("/mypage/pw-change")
    @ResponseBody
    public String changePassword(@RequestParam("currentPw") String currentPw,
                                 @RequestParam("newPw") String newPw) {
        Integer userId = AuthContext.getCurrentUserId();
        boolean result = clientMyPageService.updatePassword(userId, currentPw, newPw);
        return result ? "success" : "fail";
    }
}