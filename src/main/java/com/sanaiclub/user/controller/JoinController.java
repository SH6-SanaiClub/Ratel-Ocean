package com.sanaiclub.user.controller;

import com.sanaiclub.user.model.dto.AccountDTO;
import com.sanaiclub.user.model.dto.ClientProfileDTO;
import com.sanaiclub.user.model.dto.FreelancerProfileDTO;
import com.sanaiclub.user.model.dto.UserDefaultDTO;
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
    public String signupProcess(UserDefaultDTO userDto, HttpSession session) {
        // 세션의 역할 정보 DTO에 주입
        UserType userType = (UserType) session.getAttribute("joinUserType");
        userDto.setUserType(userType);

        // 공통 정보 세션 저장
        session.setAttribute("tempUser", userDto);

        // 역할에 따라 이동 경로 분기
        if (UserType.FREELANCER.equals(userType)) {
            return "redirect:/join/freelancer-profile";
        } else {
            return "redirect:/join/client-profile";
        }
    }

    @GetMapping("/freelancer-profile")
    public String freelancerProfilePage(HttpSession session) {
        if (session.getAttribute("tempUser") == null) return "redirect:/join/select-role";
        return "user/freelancer/freelancer_profile";
    }

    @PostMapping("/freelancer-profile")
    public String freelancerProfileProcess(FreelancerProfileDTO freeDto, HttpSession session) {
        session.setAttribute("tempFreeProfile", freeDto);
        return "redirect:/join/register-account";
    }

    @GetMapping("/client-profile")
    public String clientProfilePage(HttpSession session) {
        if (session.getAttribute("tempUser") == null) return "redirect:/join/select-role";
        return "user/client/client_profile";
    }

    @PostMapping("/client-profile")
    public String clientProfileProcess(ClientProfileDTO clientDto, HttpSession session) {
        session.setAttribute("tempClientProfile", clientDto);
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
    public String completeJoin(
            AccountDTO accountDto,
            HttpSession session,
            RedirectAttributes rttr) {

        try {
            UserDefaultDTO user = (UserDefaultDTO) session.getAttribute("tempUser");
            if (user == null) throw new IllegalStateException("세션 만료: 기본 정보 없음");

            // 역할에 따라 다른 서비스 메서드 호출 (깔끔!)
            if (UserType.FREELANCER.equals(user.getUserType())) {

                FreelancerProfileDTO freeProfile = (FreelancerProfileDTO) session.getAttribute("tempFreeProfile");
                if (freeProfile == null) throw new IllegalStateException("프리랜서 프로필 정보 없음");

                // 프리랜서 전용 메서드 호출
                joinService.signUpFreelancer(user, freeProfile, accountDto);

            } else if (UserType.CLIENT.equals(user.getUserType())) {

                ClientProfileDTO clientProfile = (ClientProfileDTO) session.getAttribute("tempClientProfile");
                if (clientProfile == null) throw new IllegalStateException("클라이언트 정보 없음");

                // 클라이언트 전용 메서드 호출
                joinService.signUpClient(user, clientProfile, accountDto);
            }

            session.invalidate();
            return "redirect:/login";

        } catch (Exception e) {
            e.printStackTrace(); // 로그 꼭 남기기
            rttr.addFlashAttribute("error", "회원가입 실패: " + e.getMessage());
            return "redirect:/join/select-role";
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