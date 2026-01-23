package com.sanaiclub.user.controller;

import com.sanaiclub.user.model.dto.*;
import com.sanaiclub.user.model.vo.ClientType;
import com.sanaiclub.user.model.vo.UserType;
import com.sanaiclub.user.service.BizNoVerificationService;
import com.sanaiclub.user.service.JoinService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/join")
public class JoinController {

    private static final Logger logger = LoggerFactory.getLogger(JoinController.class);

    // 세션 키 상수
    private static final String SESSION_USER_DATA = "userSignupData";
    private static final String SESSION_FREELANCER_PROFILE = "freelancerProfileData";
    private static final String SESSION_CLIENT_TYPE = "clientType";
    private static final String SESSION_COMPANY_DATA = "companyData";
    private static final String SESSION_VERIFIED_COMPANY = "verifiedCompanyData";

    private final JoinService joinService;
    private final BizNoVerificationService bizNoVerificationService;

    public JoinController(JoinService joinService, BizNoVerificationService bizNoVerificationService) {
        this.joinService = joinService;
        this.bizNoVerificationService = bizNoVerificationService;
    }

    // ═══════════════════════════════════════════════════════════════
    // Step 1: 유저 타입 선택
    // ═══════════════════════════════════════════════════════════════

    @GetMapping("/select-role")
    public String selectRolePage() {
        return "user/selectRole";
    }

    @PostMapping("/select-role")
    public String selectRoleProcess(@RequestParam("userType") UserType userType, HttpSession session) {
        session.setAttribute("selectedUserType", userType);
        logger.info("유저 타입 선택: {}", userType);
        return "redirect:/join/signup";
    }

    // ═══════════════════════════════════════════════════════════════
    // Step 2: 공통 정보 입력
    // ═══════════════════════════════════════════════════════════════

    @GetMapping("/signup")
    public String signupPage(HttpSession session, Model model) {

        UserType userType = (UserType) session.getAttribute("selectedUserType");

        // 유저 타입 선택 안 했으면 처음부터
        if (userType == null) {
            return "redirect:/join/select-role";
        }

        model.addAttribute("userType", userType);

        return "user/signup";
    }

    @PostMapping("/signup")
    public String signupProcess(@ModelAttribute UserSignupRequestDTO userDto, HttpSession session) {

        UserType userType = (UserType) session.getAttribute("selectedUserType");

        // 유저 타입 확인
        if (userType == null) {
            return "redirect:/join/select-role";
        }

        // DTO에 유저 타입 설정
        userDto.setUserType(userType);

        // 비밀번호 일치 확인
        if (!userDto.isPasswordMatching()) {
            session.setAttribute("error", "비밀번호가 일치하지 않습니다.");
            return "redirect:/join/signup";
        }

        // 세션에 저장
        session.setAttribute(SESSION_USER_DATA, userDto);
        logger.info("공통 정보 저장: {}", userDto.getLoginId());

        // 역할에 따라 이동 경로 분기
        if (userDto.isFreelancer()) {
            return "redirect:/join/freelancer/signup";
        } else {
            return "redirect:/join/client/select-type";
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // Step 3-A: 프리랜서 프로필 입력
    // ═══════════════════════════════════════════════════════════════

    @GetMapping("/freelancer/signup")
    public String freelancerProfilePage(HttpSession session, Model model) {

        UserSignupRequestDTO userDto = (UserSignupRequestDTO) session.getAttribute(SESSION_USER_DATA);

        if (userDto == null || !userDto.isFreelancer()) {
            return "redirect:/join/select-role";
        }

        model.addAttribute("userDto", userDto);

        return "user/freelancer/freelancerSignup";
    }

    @PostMapping("/freelancer/signup")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> freelancerProfileProcess(
            @ModelAttribute FreelancerProfileDTO freeDto,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();
        // 공통 정보 확인
        UserSignupRequestDTO userDto = (UserSignupRequestDTO) session.getAttribute(SESSION_USER_DATA);

        if (userDto == null) {
            response.put("success", false);
            response.put("message", "세션이 만료되었습니다.");
            return ResponseEntity.ok(response);
        }

        try {
            // 프리랜서 프로필 세션 저장
            session.setAttribute(SESSION_FREELANCER_PROFILE, freeDto);
            logger.info("프리랜서 프로필 저장 완료: {}", userDto.getLoginId());
            response.put("success", true);
            response.put("redirect", "/join/register-account");
        } catch (Exception e) {
            logger.error("프리랜서 프로필 저장 실패", e);
            response.put("success", false);
            response.put("message", "오류가 발생했습니다.");
        }

        return ResponseEntity.ok(response);
    }

    // ═══════════════════════════════════════════════════════════════
    // Step 3-B: 클라이언트 타입 선택
    // ═══════════════════════════════════════════════════════════════

    @GetMapping("/client/select-type")
    public String clientSelectTypePage(HttpSession session, Model model) {

        UserSignupRequestDTO userDto = (UserSignupRequestDTO) session.getAttribute(SESSION_USER_DATA);

        if (userDto == null || !userDto.isClient()) {
            return "redirect:/join/select-role";
        }

        model.addAttribute("userDto", userDto);

        return "user/client/selectType";
    }

    @PostMapping("/client/select-type")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> clientSelectTypeProcess(
            @RequestParam("clientType") ClientType clientType,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        UserSignupRequestDTO userDto = (UserSignupRequestDTO) session.getAttribute(SESSION_USER_DATA);

        if (userDto == null) {
            response.put("success", false);
            response.put("message", "세션이 만료되었습니다.");
            return ResponseEntity.ok(response);
        }

        try {
            session.setAttribute(SESSION_CLIENT_TYPE, clientType);
            logger.info("클라이언트 타입 선택: {}", clientType);
            response.put("success", true);

            // 개인 → 계좌 입력
            if (clientType.PERSONAL.equals(clientType)) {
                response.put("redirect", "/join/register-account");
            }
            // 법인 → 회사 정보 입력
            else {
                response.put("redirect", "/join/client/company-signup");
            }
        } catch (Exception e) {
            logger.error("클라이언트 타입 저장 실패", e);
            response.put("success", false);
            response.put("message", "오류가 발생했습니다.");
        }

        return ResponseEntity.ok(response);
    }

    // ═══════════════════════════════════════════════════════════════
    // Step 3-C: 법인 회사 정보 입력
    // ═══════════════════════════════════════════════════════════════

    // 법인 회사 정보 입력 페이지
    @GetMapping("/client/company-signup")
    public String clientCompanyPage(HttpSession session, Model model) {

        UserSignupRequestDTO userDto = (UserSignupRequestDTO) session.getAttribute(SESSION_USER_DATA);

        if (userDto == null || !userDto.isClient()) {
            return "redirect:/join/select-role";
        }

        ClientType clientType = (ClientType) session.getAttribute(SESSION_CLIENT_TYPE);

        if (!ClientType.CORPORATION.equals(clientType)) {
            return "redirect:/join/client/select-type";
        }

        model.addAttribute("userDto", userDto);

        return "user/client/companySignup";
    }

    // 사업자번호 중복 확인
    @GetMapping("/client/check-business-number")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> checkBusinessNumber(
            @RequestParam("businessNumber") String businessNumber) {

        Map<String, Object> response = new HashMap<>();
        boolean isDuplicate = joinService.isBusinessNumberDuplicate(businessNumber);

        response.put("isDuplicate", isDuplicate);

        return ResponseEntity.ok(response);
    }

    // 사업자번호 진위확인
    @PostMapping("/client/verify-business")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> verifyBusiness(
            @RequestParam("businessNumber") String businessNumber,
            @RequestParam("ceoName") String ceoName,
            @RequestParam("openingDate") String openingDate,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            // 하이픈 제거
            String cleanNumber = businessNumber.replaceAll("-", "");

            // YYYY-MM-DD → YYYYMMDD 변환
            String formattedDate = openingDate.replaceAll("-", "");

            // 국세청 API 호출
            boolean isValid = bizNoVerificationService.isValidBusinessNumber(
                    cleanNumber,
                    ceoName,
                    formattedDate
            );

            if (isValid) {
                // 진위확인 데이터 세션 저장
                Map<String, String> verifiedData = new HashMap<>();
                verifiedData.put("businessNumber", businessNumber);
                verifiedData.put("ceoName", ceoName);
                verifiedData.put("openingDate", openingDate);

                session.setAttribute(SESSION_VERIFIED_COMPANY, verifiedData);

                response.put("success", true);
                response.put("verified", true);
                response.put("message", "사업자 진위확인이 완료되었습니다.");
            } else {
                response.put("success", false);
                response.put("verified", false);
                response.put("message", "진위확인에 실패했습니다.");
            }

        } catch (Exception e) {
            logger.error("사업자 진위확인 실패", e);
            session.removeAttribute(SESSION_VERIFIED_COMPANY);

            response.put("success", false);
            response.put("verified", false);
            response.put("message", "오류가 발생했습니다.");
        }

        return ResponseEntity.ok(response);
    }

    // 법인 회사 정보 제출
    @PostMapping("/client/company-signup")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> clientCompanyProcess(
            @ModelAttribute CompanyRegistrationDTO companyDto,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        UserSignupRequestDTO userDto = (UserSignupRequestDTO) session.getAttribute(SESSION_USER_DATA);

        if (userDto == null) {
            response.put("success", false);
            response.put("message", "세션이 만료되었습니다.");
            return ResponseEntity.ok(response);
        }

        try {
            // 클라이언트 타입 확인
            ClientType clientType =
                    (ClientType) session.getAttribute(SESSION_CLIENT_TYPE);

            if (clientType == null || !ClientType.CORPORATION.equals(clientType)) {
                response.put("success", false);
                response.put("message", "클라이언트 타입이 올바르지 않습니다.");
                return ResponseEntity.ok(response);
            }

            // 세션에서 진위확인된 사업자 정보 가져오기
            @SuppressWarnings("unchecked")
            Map<String, String> verifiedData =
                    (Map<String, String>) session.getAttribute(SESSION_VERIFIED_COMPANY);

            if (verifiedData == null) {
                response.put("success", false);
                response.put("message", "사업자 진위확인이 완료되지 않았습니다.");
                return ResponseEntity.ok(response);
            }

            // 검증된 데이터로 DTO 재구성 (위조 방지)
            CompanyRegistrationDTO securedDto = CompanyRegistrationDTO.builder()
                    // ===== 필수 정보: 세션의 검증된 데이터 사용 (위조 불가) =====
                    .businessNumber(verifiedData.get("businessNumber"))  // 진위확인된 사업자번호
                    .ceoName(verifiedData.get("ceoName"))                // 진위확인된 대표자명
                    .openingDate(verifiedData.get("openingDate"))        // 진위확인된 개업일자
                    .businessVerified(true)                              // 진위확인 완료

                    // ===== 선택 정보: 프론트에서 전송된 데이터 사용 =====
                    .companyName(companyDto.getCompanyName())
                    .ceoEmail(companyDto.getCeoEmail())
                    .industry(companyDto.getIndustry())
                    .address(companyDto.getAddress())
                    .companySize(companyDto.getCompanySize())
                    .websiteUrl(companyDto.getWebsiteUrl())
                    .build();

            session.setAttribute(SESSION_COMPANY_DATA, securedDto);
            response.put("success", true);
            response.put("redirect", "/join/register-account");
        } catch (Exception e) {
            logger.error("회사 정보 저장 실패", e);
            response.put("success", false);
            response.put("message", "오류가 발생했습니다.");
        }

        return ResponseEntity.ok(response);
    }

    // ═══════════════════════════════════════════════════════════════
    // Step 4: 계좌 정보 입력 (공통)
    // ═══════════════════════════════════════════════════════════════

    @GetMapping("/register-account")
    public String registerAccountPage(HttpSession session, Model model) {

        UserSignupRequestDTO userDto = (UserSignupRequestDTO) session.getAttribute(SESSION_USER_DATA);

        if (userDto == null) {
            return "redirect:/join/select-role";
        }

        // 프리랜서: 프로필 확인
        if (userDto.isFreelancer()) {
            FreelancerProfileDTO freeProfile =
                    (FreelancerProfileDTO) session.getAttribute(SESSION_FREELANCER_PROFILE);

            if (freeProfile == null) {
                return "redirect:/join/freelancer/signup";
            }
        }
        // 클라이언트: 클라이언트 타입 확인
        else {
            ClientType clientType = (ClientType) session.getAttribute(SESSION_CLIENT_TYPE);

            if (clientType == null) {
                return "redirect:/join/client/select-type";
            }
        }

        model.addAttribute("userDto", userDto);

        return "user/registerAccount";
    }

    // ═══════════════════════════════════════════════════════════════
    // Step 5: 회원가입 완료 (공통)
    // ═══════════════════════════════════════════════════════════════

    // 계좌 정보 입력 -> 회원가입 완료 (/register-account 페이지에서의 POST 요청)
    @PostMapping("/complete")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> completeJoin(
            AccountDTO accountDto,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            UserSignupRequestDTO userDto = (UserSignupRequestDTO) session.getAttribute(SESSION_USER_DATA);

            if (userDto == null) {
                throw new IllegalStateException("세션 만료");
            }

            // ═══════════════════════════════════════════════════════
            // 프리랜서 회원가입
            // ═══════════════════════════════════════════════════════

            if (userDto.isFreelancer()) {

                FreelancerProfileDTO freeProfile = (FreelancerProfileDTO) session.getAttribute(SESSION_FREELANCER_PROFILE);

                if (freeProfile == null) throw new IllegalStateException("프리랜서 프로필 정보 없음");

                // 프리랜서 회원가입 메서드
                joinService.signUpFreelancer(userDto, freeProfile, accountDto);

            }

            // ═══════════════════════════════════════════════════════
            // 클라이언트 회원가입
            // ═══════════════════════════════════════════════════════

            else {

                ClientType clientType = (ClientType) session.getAttribute(SESSION_CLIENT_TYPE);

                if (clientType == null) {
                    throw new IllegalStateException("클라이언트 타입 정보 없음");
                }

                // 개인
                if (ClientType.PERSONAL.equals(clientType)) {
                    joinService.signUpClientPersonal(userDto, accountDto);
                }
                // 법인
                else {
                    CompanyRegistrationDTO companyDto =
                            (CompanyRegistrationDTO) session.getAttribute(SESSION_COMPANY_DATA);

                    if (companyDto == null) {
                        throw new IllegalStateException("회사 정보 없음");
                    }

                    joinService.signUpClientCorporation(userDto, companyDto, accountDto);
                }
            }

            // 세션 정리
            session.invalidate();
            logger.info("회원가입 완료: {}", userDto.getLoginId());

            response.put("success", true);
            response.put("message", "회원가입이 완료되었습니다!");
            response.put("redirectUrl", "/login");

        } catch (Exception e) {
            logger.error("회원가입 실패", e);
            response.put("success", false);
            response.put("message", "회원가입 실패: " + e.getMessage());
        }

        return ResponseEntity.ok(response);
    }

    // ═══════════════════════════════════════════════════════════════
    // 중복 확인 API
    // ═══════════════════════════════════════════════════════════════

    @GetMapping("/check-id")
    @ResponseBody
    public ResponseEntity<String> checkId(@RequestParam("loginId") String loginId) {
        boolean isDuplicate = joinService.isIdDuplicate(loginId);
        return isDuplicate ? ResponseEntity.ok("DUPLICATE") : ResponseEntity.ok("AVAILABLE");
    }

    @GetMapping("/check-email")
    @ResponseBody
    public ResponseEntity<String> checkEmail(@RequestParam("email") String email) {
        boolean isDuplicate = joinService.isEmailDuplicate(email);
        return isDuplicate ? ResponseEntity.ok("DUPLICATE") : ResponseEntity.ok("AVAILABLE");
    }
}