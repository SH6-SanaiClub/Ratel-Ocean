package com.sanaiclub.user.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.user.model.dto.ClientMyPageDTO;
import com.sanaiclub.user.model.vo.UserVO;
import com.sanaiclub.user.service.FreelancerMyPageService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/freelancer")
@RequiredArgsConstructor
public class FreelancerMyPageController {

    private final FreelancerMyPageService freelancerMyPageService;

    @GetMapping("/mypage")
    public String myPageForm(Model model, RedirectAttributes rttr) {
        Integer userId = AuthContext.getCurrentUserId();
        if (userId == null) {
            rttr.addFlashAttribute("msg", "로그인이 필요합니다.");
            return "redirect:/login";
        }

        UserVO profile = freelancerMyPageService.getFreelancerProfile(userId);
        model.addAttribute("profile", profile);
        return "user/freelancer/freelancerMyPage";
    }


    @PostMapping("/mypage/update")
    public String updateProfile(@ModelAttribute UserVO userVO,
                                RedirectAttributes rttr) {
        Integer userId = AuthContext.getCurrentUserId();
        userVO.setUserId(userId);

        try {
            freelancerMyPageService.updateProfile(userVO);
            rttr.addFlashAttribute("msg", "정보가 수정되었습니다.");
        } catch (Exception e) {
            e.printStackTrace();
            rttr.addFlashAttribute("msg", "수정 실패: 오류가 발생했습니다.");
        }
        return "redirect:/freelancer/mypage";
    }

    @PostMapping("/mypage/pw-change")
    @ResponseBody
    public String changePassword(@RequestParam("currentPw") String currentPw,
                                 @RequestParam("newPw") String newPw) {
        Integer userId = AuthContext.getCurrentUserId();
        boolean result = freelancerMyPageService.updatePassword(userId, currentPw, newPw);
        return result ? "success" : "fail";
    }

}