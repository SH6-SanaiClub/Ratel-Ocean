package com.sanaiclub.domain.user.controller;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.sanaiclub.domain.user.dto.User;
import com.sanaiclub.domain.user.mapper.UserMapper;
import com.sanaiclub.domain.user.service.UserService;

@Controller
public class UserController {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private UserService userService;

    /**
     * ─────────────────────────────────────────────────────────────────
     * [역할 선택 페이지]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /join/select-role.do
     * 설명: 사용자가 프리랜서 또는 클라이언트 중 역할을 선택하는 페이지를 표시합니다.
     *      이 페이지는 회원가입 프로세스의 첫 번째 단계입니다.
     * 
     * [화면 구성]
     * - 프리랜서 선택 카드: 프로젝트 기반 업무 수행
     * - 클라이언트 선택 카드: 프리랜서에게 일감 발주
     * - 각 역할에 대한 설명 및 장점
     * 
     * @return "user/selectRole" - src/main/webapp/WEB-INF/views/user/selectRole.jsp 렌더링
     */
    @GetMapping("/join/select-role.do")
    public String selectRolePage() {
        return "user/selectRole";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [역할 선택 처리]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: POST /join/select-role.do
     * 설명: 프론트엔드에서 선택한 역할(FREELANCER 또는 CLIENT)을 HttpSession에 저장합니다.
     *      FREELANCER 선택시: /join/freelancer.jsp로 직접 이동
     *      CLIENT 선택시: /join/client.jsp로 이동
     * 
     * [처리 과정]
     * 1. @RequestParam으로 선택한 역할(userType) 받기
     * 2. HttpSession에 'selectedRole'이라는 이름으로 저장
     * 3. 역할별로 다른 페이지로 리다이렉트
     * 
     * @param userType 선택한 역할 (예: "FREELANCER", "CLIENT")
     * @param session HttpSession 객체 - 역할 정보를 세션에 저장하기 위해 사용
     * @return FREELANCER면 /join/freelancer.jsp, CLIENT면 /join/client.jsp로 리다이렉트
     */
    @PostMapping("/join/select-role.do")
    @ResponseBody
    public org.springframework.web.servlet.view.json.MappingJackson2JsonView selectRole(
            @RequestParam("userType") String userType, 
            HttpSession session) {
        
        // 역할 저장 - 다음 단계(회원정보 입력)에서 참조
        session.setAttribute("selectedRole", userType);
        
        // JSON 응답 생성
        java.util.Map<String, Object> response = new java.util.HashMap<>();
        response.put("success", true);
        
        // 역할별로 다른 리다이렉트 URL
        if ("FREELANCER".equals(userType)) {
            response.put("redirectUrl", "/join/freelancer");
        } else {
            response.put("redirectUrl", "/join/client");
        }
        
        // JSON 응답 반환
        org.springframework.web.servlet.view.json.MappingJackson2JsonView jsonView = 
            new org.springframework.web.servlet.view.json.MappingJackson2JsonView();
        jsonView.setAttributesMap(response);
        return jsonView;
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [회원가입 정보 입력 페이지]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /join/signup, /join/signup.do
     * 설명: 사용자가 실제 회원가입 정보(이메일, 비밀번호, 전화번호 등)를 입력하는 페이지를 표시합니다.
     *      이전 단계에서 선택한 역할(FREELANCER 또는 CLIENT)에 따라 입력 필드가 달라집니다.
     * 
     * [입력 필드 - 공통]
     * - 이메일 (중복 확인 필수)
     * - 비밀번호 (보안 규칙 적용)
     * - 비밀번호 확인
     * - 이름 (실명)
     * - 전화번호 (인증 필수)
     * 
     * [입력 필드 - 프리랜서 추가]
     * - 주요 기술스택 선택
     * - 경력 연수
     * - 포트폴리오 URL (선택사항)
     * 
     * [입력 필드 - 클라이언트 추가]
     * - 회사명
     * - 담당 업무
     * - 회사 규모
     * 
     * @return "user/signup" - src/main/webapp/WEB-INF/views/user/signup.jsp 렌더링
     */
    @GetMapping({"/join/signup", "/join/signup.do"})
    public String signupPage() {
        return "user/signup";
    }
    /**
     * 프리랜서 기본정보 입력 페이지
     * GET /join/freelancer
     */
    @GetMapping("/join/freelancer")
    public String freelancerSignupPage() {
        return "user/signup-basic";
    }
    
    /**
     * ─────────────────────────────────────────────────────────────────
     * [기본 회원가입 처리 - 1단계]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: POST /join/signup-basic.do
     * 설명: DB에 저장하지 않고 세션에만 저장. 프리랜서는 프로필 완성 페이지로 이동
     */
    @PostMapping("/join/signup-basic.do")
    public String processBasicSignup(
            @RequestParam("loginId") String loginId,
            @RequestParam("email") String email,
            @RequestParam("password") String password,
            @RequestParam("fullName") String fullName,
            @RequestParam("phone") String phone,
            @RequestParam(value = "birth", required = false) String birth,
            HttpSession session,
            RedirectAttributes redirectAttributes) {
        
        System.out.println("=== processBasicSignup 시작 ===");
        System.out.println("loginId: " + loginId);
        System.out.println("email: " + email);
        System.out.println("fullName: " + fullName);
        System.out.println("phone: " + phone);
        System.out.println("birth: " + birth);
        
        try {
            // 중복 검증
            System.out.println("이메일 중복 검증 중...");
            int emailCount = userMapper.countByEmail(email);
            System.out.println("emailCount: " + emailCount);
            if (emailCount > 0) {
                System.out.println("이메일 중복!");
                redirectAttributes.addFlashAttribute("error", "이미 사용 중인 이메일입니다.");
                return "redirect:/join/signup.do";
            }
            
            System.out.println("loginId 중복 검증 중...");
            int loginIdCount = userMapper.countByLoginId(loginId);
            System.out.println("loginIdCount: " + loginIdCount);
            if (loginIdCount > 0) {
                System.out.println("loginId 중복!");
                redirectAttributes.addFlashAttribute("error", "이미 사용 중인 아이디입니다.");
                return "redirect:/join/signup.do";
            }
            
            // 세션에서 선택한 역할 가져오기
            String selectedRole = (String) session.getAttribute("selectedRole");
            System.out.println("selectedRole: " + selectedRole);
            if (selectedRole == null || selectedRole.isEmpty()) {
                selectedRole = "FREELANCER"; // 기본값
                System.out.println("기본값으로 FREELANCER 설정");
            }
            
            // User 객체 생성 (DB 저장 안 함, 세션에만 저장)
            System.out.println("User 객체 생성 중...");
            User tempUser = new User();
            tempUser.setLoginId(loginId);
            tempUser.setEmail(email);
            tempUser.setPassword(password); // 실제로는 암호화 필요
            tempUser.setName(fullName);
            tempUser.setPhone(phone);
            tempUser.setUserType(selectedRole); // setRole 대신 setUserType 사용
            
            if (birth != null && !birth.isEmpty()) {
                try {
                    LocalDate birthDate = LocalDate.parse(birth);
                    tempUser.setBirthDate(birthDate);
                    System.out.println("생년월일 설정: " + birthDate);
                } catch (Exception e) {
                    System.out.println("생년월일 파싱 실패: " + e.getMessage());
                }
            }
            
            // 세션에 임시 저장
            System.out.println("세션에 tempUser 저장 중...");
            session.setAttribute("tempUser", tempUser);
            System.out.println("세션 저장 완료!");
            
            // 프리랜서면 프로필 완성 페이지로, 클라이언트면 메인 페이지로
            if ("FREELANCER".equals(selectedRole)) {
                System.out.println("✅ 프리랜서 프로필 페이지로 리다이렉트: /freelancer/complete-profile");
                return "redirect:/freelancer/complete-profile";
            } else {
                System.out.println("✅ 클라이언트 메인 페이지로 리다이렉트: /client/main");
                return "redirect:/client/main";
            }
            
        } catch (Exception e) {
            System.out.println("❌ 예외 발생: " + e.getClass().getName());
            System.out.println("❌ 예외 메시지: " + e.getMessage());
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "회원가입 중 오류가 발생했습니다: " + e.getMessage());
            return "redirect:/join/signup.do";
        }
    }
    
    /**
     * ─────────────────────────────────────────────────────────────────
     * [프리랜서 프로필 완성 페이지]
     * ─────────────────────────────────────────────────────────────────
     */
    @GetMapping("/freelancer/complete-profile")
    public String freelancerProfilePage(HttpSession session, RedirectAttributes redirectAttributes) {
        System.out.println("=== freelancerProfilePage 호출됨 ===");
        User tempUser = (User) session.getAttribute("tempUser");
        System.out.println("tempUser: " + (tempUser != null ? tempUser.getLoginId() : "null"));
        if (tempUser == null) {
            System.out.println("❌ tempUser가 null - signup으로 리다이렉트");
            redirectAttributes.addFlashAttribute("error", "기본 정보를 먼저 입력해주세요.");
            return "redirect:/join/signup.do";
        }
        System.out.println("✅ complete-profile 페이지 표시");
        return "freelancer/complete-profile";
    }
    
    

    /**
     * ─────────────────────────────────────────────────────────────────
     * [회원가입 처리]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: POST /join/signup.do
     * 설명: 회원가입 정보를 받아서 DB에 저장하고 로그인 처리합니다.
     * 
     * @param loginId 로그인 ID
     * @param email 이메일
     * @param password 비밀번호
     * @param fullName 이름
     * @param phone 전화번호
     * @param birth 생년월일
     * @param nickname 닉네임 (프리랜서 필수)
     * @param introduction 자기소개 (프리랜서 선택)
     * @param githubUrl GitHub URL (프리랜서 선택)
     * @param websiteUrl 웹사이트 URL (프리랜서 선택)
     * @param bankName 은행명 (프리랜서 필수)
     * @param accountNumber 계좌번호 (프리랜서 필수)
     * @param accountHolder 예금주명 (프리랜서 필수)
     * @param session HttpSession - 역할 정보 조회 및 로그인 처리
     * @param redirectAttributes 리다이렉트 시 메시지 전달
     * @return 회원가입 완료 후 대시보드로 리다이렉트
     */
    @PostMapping("/join/signup.do")
    public String processSignup(
            @RequestParam("loginId") String loginId,
            @RequestParam("email") String email,
            @RequestParam("password") String password,
            @RequestParam("fullName") String fullName,
            @RequestParam("phone") String phone,
            @RequestParam(value = "birth", required = false) String birth,
            @RequestParam(value = "nickname", required = false) String nickname,
            @RequestParam(value = "introduction", required = false) String introduction,
            @RequestParam(value = "github_url", required = false) String githubUrl,
            @RequestParam(value = "website_url", required = false) String websiteUrl,
            @RequestParam(value = "bank_name", required = false) String bankName,
            @RequestParam(value = "account_number", required = false) String accountNumber,
            @RequestParam(value = "account_holder", required = false) String accountHolder,
            HttpSession session,
            RedirectAttributes redirectAttributes) {
        
        try {
            // 1. 세션에서 선택한 역할 가져오기
            String selectedRole = (String) session.getAttribute("selectedRole");
            if (selectedRole == null || selectedRole.isEmpty()) {
                selectedRole = "FREELANCER"; // 기본값: 프리랜서
            }
            
            User newUser = null;
            
            // 2. 역할별 회원가입 처리
            if ("FREELANCER".equals(selectedRole)) {
                // 프리랜서 회원가입 (프로필 + 계좌 + 지갑 포함)
                newUser = userService.registerFreelancer(
                    loginId, email, password, fullName, phone, birth,
                    nickname, introduction, githubUrl, websiteUrl,
                    bankName, accountNumber, accountHolder
                );
            } else {
                // 클라이언트 회원가입 (현재는 미구현)
                redirectAttributes.addFlashAttribute("error", "클라이언트 회원가입은 준비 중입니다.");
                return "redirect:/join/signup.do";
            }
            
            // 3. 세션에 임시 사용자 정보 저장
            session.setAttribute("tempUser", newUser);
            session.setAttribute("userId", newUser.getUserId());
            session.setAttribute("userType", newUser.getUserType());
            
            // 4. 프리랜서면 프로필 완성 페이지로, 클라이언트면 대시보드로
            if ("FREELANCER".equals(selectedRole)) {
                return "redirect:/freelancer/complete-profile";
            } else {
                return "redirect:/client/main";
            }
            
        } catch (IllegalArgumentException e) {
            // 중복 검증 실패 등
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/join/signup.do";
        } catch (Exception e) {
            // 기타 오류
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "회원가입 중 오류가 발생했습니다: " + e.getMessage());
            return "redirect:/join/signup.do";
        }
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [이메일 중복 확인 API]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /join/check-email
     * 설명: AJAX로 호출되며, 이메일 중복 여부를 확인합니다.
     * 
     * @param email 확인할 이메일
     * @return JSON - {"available": true/false}
     */
    @GetMapping("/join/check-email")
    @ResponseBody
    public String checkEmail(@RequestParam("email") String email) {
        boolean isDuplicate = userService.isEmailDuplicate(email);
        return "{\"available\":" + !isDuplicate + "}";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [로그인 ID 중복 확인 API]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /join/check-loginid
     * 설명: AJAX로 호출되며, 로그인 ID 중복 여부를 확인합니다.
     * 
     * @param loginId 확인할 로그인 ID
     * @return JSON - {"available": true/false}
     */
    @GetMapping("/join/check-loginid")
    @ResponseBody
    public String checkLoginId(@RequestParam("loginId") String loginId) {
        boolean isDuplicate = userService.isLoginIdDuplicate(loginId);
        return "{\"available\":" + !isDuplicate + "}";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [닉네임 중복 확인 API]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /join/check-nickname
     * 설명: AJAX로 호출되며, 닉네임 중복 여부를 확인합니다.
     * 
     * @param nickname 확인할 닉네임
     * @return JSON - {"available": true/false}
     */
    @GetMapping("/join/check-nickname")
    @ResponseBody
    public String checkNickname(@RequestParam("nickname") String nickname) {
        boolean isDuplicate = userService.isNicknameDuplicate(nickname);
        return "{\"available\":" + !isDuplicate + "}";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [로그인 페이지]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /login, /login.do
     * 설명: 사용자 로그인 페이지를 표시합니다.
     *      이메일과 비밀번호를 입력받아 로그인을 처리합니다.
     * 
     * [입력 필드]
     * - 이메일
     * - 비밀번호
     * 
     * [기능]
     * - 로그인 처리 (POST /login.do)
     * - 비밀번호 찾기 링크
     * - 회원가입 링크 (/join/select-role.do)
     * 
     * @return "user/login" - src/main/webapp/WEB-INF/views/user/login.jsp 렌더링
     */
    @GetMapping({"/login", "/login.do"})
    public String loginPage() {
        return "user/login";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [로그인 처리]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: POST /login
     * 설명: 사용자 로그인을 처리합니다.
     *      DB에서 이메일과 비밀번호를 확인하고, 
     *      사용자 타입(CLIENT/FREELANCER)에 따라 다른 대시보드로 리다이렉트합니다.
     * 
     * [로직]
     * 1. 이메일과 비밀번호로 DB 조회
     * 2. 사용자 정보 확인
     * 3. 세션에 사용자 정보 저장
     * 4. 사용자 타입에 따라 리다이렉트:
     *    - CLIENT: /client/main (클라이언트 메인 페이지)
     *    - FREELANCER: /freelancer/main (프리랜서 메인 페이지)
     * 
     * @param email 사용자 이메일
     * @param password 사용자 비밀번호
     * @param session HttpSession - 로그인 정보 저장
     * @param redirectAttributes 리다이렉트 시 메시지 전달
     * @return 사용자 타입에 따른 대시보드 리다이렉트
     */
    @PostMapping("/login")
    public String login(
            @RequestParam("email") String email,
            @RequestParam("password") String password,
            HttpSession session,
            RedirectAttributes redirectAttributes) {
        
        // 1. DB에서 사용자 조회
        User user = userMapper.findByEmailAndPassword(email, password);
        
        // 2. 사용자가 없거나 비밀번호가 틀린 경우
        if (user == null) {
            redirectAttributes.addFlashAttribute("error", "이메일 또는 비밀번호가 올바르지 않습니다.");
            return "redirect:/login";
        }
        
        // 3. 세션에 사용자 정보 저장
        session.setAttribute("loginUser", user);
        session.setAttribute("userId", user.getUserId());
        session.setAttribute("userType", user.getUserType());
        session.setAttribute("userName", user.getName());
        
        // 4. 사용자 타입에 따라 리다이렉트
        if ("CLIENT".equals(user.getUserType())) {
            // 클라이언트 → 클라이언트 메인 페이지
            return "redirect:/client/main";
        } else if ("FREELANCER".equals(user.getUserType())) {
            // 프리랜서 → 프리랜서 메인 페이지
            return "redirect:/freelancer/main";
        }
        
        // 기본 리다이렉트 (예외 케이스)
        return "redirect:/freelancer/main";
    }
}

