package com.sanaiclub.user.controller;

import com.sanaiclub.user.model.dto.UserSignupRequestDTO;
import com.sanaiclub.user.model.vo.UserType;
import com.sanaiclub.user.service.JoinService;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpSession;

@Controller
@RequestMapping("/join")
public class JoinController {

    private final JoinService joinService;

    // 생성자 주입
    public JoinController(JoinService joinService){
        this.joinService = joinService;
    }

    @GetMapping("/select-role")
    public String selectRolePage() {
        return "user/selectRole";
    }

    @PostMapping("/select-role")
    public String selectRoleProcess(@RequestParam("userType") UserType userType, HttpSession session) {
        session.setAttribute("joinUserType", userType);
        return "redirect:/join/signup";
    }

    @GetMapping("/signup")
    public String signupPage(HttpSession session, Model model) {
        UserType userType = (UserType) session.getAttribute("joinUserType");

        if (userType == null) {
            return "redirect:/join/select-role";
        }

        model.addAttribute("userType", userType);
        return "user/signup";
    }

    @PostMapping("/signup")
    public String signupProcess(@ModelAttribute UserSignupRequestDTO signupDTO, HttpSession session, RedirectAttributes rttr) {
        UserType sessionType = (UserType) session.getAttribute("joinUserType");
        if (sessionType == null) {
            return "redirect:/join/select-role";
        }
        signupDTO.setUserType(sessionType);

        if (!signupDTO.isPasswordMatching()) {
            rttr.addFlashAttribute("error", "비밀번호가 일치하지 않습니다.");
            return "redirect:/join/signup";
        }

        // 3. 서비스 호출부 변수명 수정
        boolean isSuccess = joinService.signUp(signupDTO);

        if (isSuccess) {
            session.removeAttribute("joinUserType");
            return "redirect:/user/login";
        } else {
            rttr.addFlashAttribute("error", "회원가입 중 오류가 발생했습니다.");
            return "redirect:/join/signup";
        }
    }

    @GetMapping("/check-id")
    @ResponseBody
    public ResponseEntity<String> checkId(@RequestParam("loginId") String loginId) {
        // 4. 아이디 중복체크 호출부 수정
        boolean isDuplicate = joinService.isIdDuplicate(loginId);
        return isDuplicate ? ResponseEntity.ok("DUPLICATE") : ResponseEntity.ok("AVAILABLE");
    }

    @GetMapping("/check-email")
    @ResponseBody
    public ResponseEntity<String> checkEmail(@RequestParam("email") String email) {
        // 5. 이메일 중복체크 호출부 수정
        boolean isDuplicate = joinService.isEmailDuplicate(email);
        return isDuplicate ? ResponseEntity.ok("DUPLICATE") : ResponseEntity.ok("AVAILABLE");
    }
}