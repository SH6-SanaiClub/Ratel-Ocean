package com.sanaiclub.user.controller;

import com.sanaiclub.user.model.dto.UserSignupRequestDTO;
import com.sanaiclub.user.model.vo.UserType;
import com.sanaiclub.user.service.JoinService; // 1. 타입 변경
import com.sanaiclub.user.service.JoinServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpSession;

@Controller
@RequestMapping("/join")
public class JoinController {

    @Autowired
    private JoinServiceImpl joinService; // 2. 변수명 및 타입 변경 (JoinService로 교체)

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
    public String signupProcess(@ModelAttribute UserSignupRequestDTO signupDTO, HttpSession session) {
        // 이전 단계에서 선택한 유저 타입 세팅
        UserType userType = (UserType) session.getAttribute("joinUserType");
        signupDTO.setUserType(userType);

        // 핵심: DB에 저장하지 않고 세션에 객체 저장
        session.setAttribute("tempUser", signupDTO);

        // 계좌 등록 페이지로 이동
        return "redirect:/join/register-account";
    }

    @GetMapping("/register-account")
    public String registerAccountPage(HttpSession session, Model model) {
        if (session.getAttribute("tempUser") == null) {
            return "redirect:/join/select-role";
        }
        return "user/registerAccount"; // registerAccount.jsp 경로 확인 필요
    }

    @PostMapping("/complete")
    public String completeSignup(@RequestParam("bankName") String bankName,
                                 @RequestParam("accountNumber") String accountNumber,
                                 @RequestParam("accountHolder") String accountHolder,
                                 HttpSession session, RedirectAttributes rttr) {

        UserSignupRequestDTO tempUser = (UserSignupRequestDTO) session.getAttribute("tempUser");

        if (tempUser == null) {
            return "redirect:/join/select-role";
        }

        // DTO에 계좌 정보 추가
        tempUser.setBankName(bankName);
        tempUser.setAccountNumber(accountNumber);
        tempUser.setAccountHolder(accountHolder);

        // 최종 DB 저장 서비스 호출
        boolean isSuccess = joinService.signUp(tempUser);

        if (isSuccess) {
            session.invalidate(); // 회원가입 완료 후 세션 초기화
            return "redirect:/user/login";
        } else {
            rttr.addFlashAttribute("error", "회원가입 처리 중 오류가 발생했습니다.");
            return "redirect:/join/register-account";
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