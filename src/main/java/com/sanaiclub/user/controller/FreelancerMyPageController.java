package com.sanaiclub.user.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.user.model.dto.ClientMyPageDTO;
import com.sanaiclub.user.model.vo.UserVO;
import com.sanaiclub.user.service.FreelancerMyPageService;
import com.sanaiclub.wallet.model.dto.FreelancerWalletDTO;
import com.sanaiclub.wallet.model.dto.WalletHistoryDTO;
import com.sanaiclub.wallet.service.FreelancerWalletService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Collections;
import java.util.List;

@Controller
@RequestMapping("/freelancer")
@RequiredArgsConstructor
public class FreelancerMyPageController {

    private final FreelancerMyPageService freelancerMyPageService;
    private final FreelancerWalletService freelancerWalletService;

    @GetMapping("/mypage")
    public String myPageForm(Model model, RedirectAttributes rttr) {
        Integer userId = AuthContext.getCurrentUserId();
        if (userId == null) {
            rttr.addFlashAttribute("msg", "로그인이 필요합니다.");
            return "redirect:/login";
        }

        UserVO profile = freelancerMyPageService.getFreelancerProfile(userId);
        model.addAttribute("profile", profile);

        FreelancerWalletDTO wallet = freelancerWalletService.getWallet(userId);
        model.addAttribute("wallet", wallet);

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

    @GetMapping("/mypage/wallet/history")
    @ResponseBody
    public List<WalletHistoryDTO> walletHistory(@RequestParam(defaultValue = "0") int offset,
                                                @RequestParam(defaultValue = "10") int limit) {
        Integer userId = AuthContext.getCurrentUserId();
        if (userId == null) return Collections.emptyList();

        // userId == freelancerId 전제 (너 테이블 fk가 users(user_id)라서 OK)
        return freelancerWalletService.getHistories(userId, offset, limit);
    }
}