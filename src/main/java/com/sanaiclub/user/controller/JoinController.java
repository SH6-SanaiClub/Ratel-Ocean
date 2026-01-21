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

import javax.servlet.http.HttpSession;

@Controller
@RequestMapping("/join")
public class JoinController {

    // 세션 키 상수
    private static final String SESSION_USER_TYPE = "selectedUserType";
    private static final String SESSION_USER_DATA = "userSignupData";

    private final JoinService joinService;

    // 생성자 주입
    public JoinController(JoinService joinService){
        this.joinService = joinService;
    }

    /**
     * 유저 타입 선택 페이지
     * GET /join/select-role
     */
    @GetMapping("/select-role")
    public String selectRolePage() {
        return "user/selectRole";
    }

    /**
     * 유저 타입 선택 처리
     * POST /join/select-role
     *
     * @param userType FREELANCER 또는 CLIENT
     */
    @PostMapping("/select-role")
    public String selectRoleProcess(@RequestParam("userType") UserType userType, HttpSession session) {
        session.setAttribute(SESSION_USER_TYPE, userType);
        return "redirect:/join/signup";
    }

    /**
     * 공통 정보 입력 페이지
     * GET /join/signup
     */
    @GetMapping("/signup")
    public String signupPage(HttpSession session, Model model) {
        UserType userType = (UserType) session.getAttribute(SESSION_USER_TYPE);

        // 유저 타입 선택 안 했으면 처음부터
        if (userType == null) {
            return "redirect:/join/select-role";
        }

        model.addAttribute("userType", userType);
        return "user/signup";
    }

    /**
     * 공통 정보 제출 처리
     * POST /join/signup
     *
     * 플로우:
     * - FREELANCER: 세션 저장 → /join/freelancer/signup (미구현)
     * - CLIENT: 세션 저장 → /join/client/signup
     */
    @PostMapping("/signup")
    public String signupProcess(@ModelAttribute UserSignupRequestDTO dto, HttpSession session) {
        UserType userType = (UserType) session.getAttribute(SESSION_USER_TYPE);

        // 유저 타입 확인
        if (userType == null) {
            return "redirect:/join/select-role";
        }

        // DTO에 유저 타입 설정
        dto.setUserType(userType);

        // 비밀번호 일치 확인
        if (!dto.isPasswordMatching()) {
            session.setAttribute("error", "비밀번호가 일치하지 않습니다.");
            return "redirect:/join/signup";
          
        // 공통 정보를 세션에 저장
        session.setAttribute(SESSION_USER_DATA, dto);
          
        // 역할에 따라 이동 경로 분기
        if (UserType.FREELANCER.equals(userType)) {
            return "redirect:/join/freelancer-profile";
        } else if (UserType.CLIENT.equals(userType)) {
            return "redirect:/join/client/signup";
        }
          
        // 예외 처리
        return "redirect:/join/select-role";
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

            // 역할에 따라 다른 서비스 메서드 호출
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

    /**
     * 아이디 중복 확인
     */
    @GetMapping("/check-id")
    @ResponseBody
    public ResponseEntity<String> checkId(@RequestParam("loginId") String loginId) {
        boolean isDuplicate = joinService.isIdDuplicate(loginId);
        return isDuplicate ? ResponseEntity.ok("DUPLICATE") : ResponseEntity.ok("AVAILABLE");
    }

    /**
     * 이메일 중복 확인
     */
    @GetMapping("/check-email")
    @ResponseBody
    public ResponseEntity<String> checkEmail(@RequestParam("email") String email) {
        boolean isDuplicate = joinService.isEmailDuplicate(email);
        return isDuplicate ? ResponseEntity.ok("DUPLICATE") : ResponseEntity.ok("AVAILABLE");
    }
}