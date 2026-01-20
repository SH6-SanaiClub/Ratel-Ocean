package com.sanaiclub.user.controller;

import com.sanaiclub.user.dao.UserMapper;
import com.sanaiclub.user.model.dto.CompanyRegistrationDTO;
import com.sanaiclub.user.model.dto.SignupSessionDTO;
import com.sanaiclub.user.model.dto.UserSignupRequestDTO;
import com.sanaiclub.user.model.vo.ClientType;
import com.sanaiclub.user.model.vo.UserType;
import com.sanaiclub.user.model.vo.UserVO;
import com.sanaiclub.user.service.ClientJoinService;
import com.sanaiclub.user.service.JoinService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * 클라이언트 회원가입 컨트롤러
 * ═══════════════════════════════════════════════════════════════════════
 *
 * [담당 기능]
 * - 클라이언트 회원가입 전체 플로우 관리
 * - 단계별 데이터 세션 저장
 * - 사업자번호 진위확인 (AJAX)
 * - 최종 회원가입 처리 (트랜잭션)
 *
 */
@Controller
@RequestMapping("/join/client")
public class ClientJoinController {

    private static final Logger logger = LoggerFactory.getLogger(ClientJoinController.class);
    private static final String SESSION_KEY = "signupSession";

    private final JoinService joinService;
    private final ClientJoinService clientJoinService;
    private final UserMapper userMapper;

    public ClientJoinController(JoinService joinService, ClientJoinService clientJoinService, UserMapper userMapper) {
        this.joinService = joinService;
        this.clientJoinService = clientJoinService;
        this.userMapper = userMapper;
    }

    // Step 1: 유저 타입 선택 (기존 JoinController에서 처리됨)

    // Step 2: 공통 정보 입력 페이지

    /**
     * 클라이언트 회원가입 페이지
     */
    @GetMapping("/signup")
    public String clientSignupPage(HttpSession session, Model model) {
        // 세션에서 SignupSessionDTO 가져오기 (없으면 새로 생성)
        SignupSessionDTO signupSession = getOrCreateSession(session);

        // 유저 타입이 CLIENT가 아니면 처음으로
        if (!UserType.CLIENT.equals(signupSession.getUserType())) {
            logger.warn("잘못된 접근: userType={}", signupSession.getUserType());
            return "redirect:/join/select-role";
        }

        model.addAttribute("userType", signupSession.getUserType());
        return "user/client/clientSignup";
    }

    /**
     * Step 2: 공통 정보 저장 (AJAX)
     */
    @PostMapping("/save-common-info")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> saveCommonInfo(
            @RequestBody UserSignupRequestDTO dto,
            HttpSession session
    ) {
        Map<String, Object> response = new HashMap<>();

        try {
            SignupSessionDTO signupSession = getOrCreateSession(session);

            // 세션에 공통 정보 저장
            signupSession.setLoginId(dto.getLoginId());
            signupSession.setEmail(dto.getEmail());
            signupSession.setPassword(dto.getPassword());
            signupSession.setName(dto.getName());
            signupSession.setPhone(dto.getPhone());
            signupSession.setBirthDate(dto.getBirth());

            session.setAttribute(SESSION_KEY, signupSession);

            logger.info("공통 정보 저장 완료: loginId={}", dto.getLoginId());

            response.put("success", true);
            response.put("message", "정보가 저장되었습니다.");
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("공통 정보 저장 실패", e);
            response.put("success", false);
            response.put("message", "정보 저장에 실패했습니다.");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Step 3: 클라이언트 타입 선택

    /**
     * Step 3: 클라이언트 타입 저장 (AJAX)
     */
    @PostMapping("/save-client-type")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> saveClientType(
            @RequestParam("clientType") ClientType clientType,
            HttpSession session
    ) {
        Map<String, Object> response = new HashMap<>();

        try {
            SignupSessionDTO signupSession = getOrCreateSession(session);

            // Step 2 완료 확인
            if (!signupSession.isStep2Complete()) {
                response.put("success", false);
                response.put("message", "공통 정보를 먼저 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }

            // 클라이언트 타입 저장
            signupSession.setClientType(clientType);
            session.setAttribute(SESSION_KEY, signupSession);

            logger.info("클라이언트 타입 저장 완료: clientType={}", clientType);

            response.put("success", true);
            response.put("clientType", clientType.name());
            response.put("needCompanyInfo", ClientType.CORPORATION.equals(clientType));
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("클라이언트 타입 저장 실패", e);
            response.put("success", false);
            response.put("message", "클라이언트 타입 저장에 실패했습니다.");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Step 4: 회사 정보 입력 및 사업자 진위확인 (법인만)

    /**
     * 사업자번호 중복 확인 (AJAX)
     */
    @GetMapping("/check-business-number")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> checkBusinessNumber(
            @RequestParam("businessNumber") String businessNumber
    ) {
        Map<String, Object> response = new HashMap<>();

        try {
            boolean isDuplicate = clientJoinService.isBusinessNumberDuplicate(businessNumber);

            response.put("success", true);
            response.put("isDuplicate", isDuplicate);
            response.put("message", isDuplicate ? "이미 등록된 사업자번호입니다." : "사용 가능한 사업자번호입니다.");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("사업자번호 중복 확인 실패", e);
            response.put("success", false);
            response.put("message", "중복 확인 중 오류가 발생했습니다.");
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * 사업자번호 진위확인 (AJAX)
     */
    @PostMapping("/verify-business")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> verifyBusiness(
            @RequestBody CompanyRegistrationDTO dto
    ) {
        Map<String, Object> response = new HashMap<>();

        try {
            // 필수 정보 확인
            if (dto.getBusinessNumber() == null || dto.getCeoName() == null || dto.getOpeningDate() == null) {
                response.put("success", false);
                response.put("message", "사업자번호, 대표자명, 개업일자를 모두 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }

            // 사업자번호 진위확인
            boolean isValid = clientJoinService.verifyBusinessNumber(
                    dto.getBusinessNumber(),
                    dto.getCeoName(),
                    dto.getOpeningDateAsString()
            );

            if (!isValid) {
                response.put("success", false);
                response.put("message", "입력하신 정보가 국세청 등록 정보와 일치하지 않습니다.");
                return ResponseEntity.badRequest().body(response);
            }

            logger.info("사업자번호 진위확인 성공: businessNumber={}", dto.getBusinessNumber());

            response.put("success", true);
            response.put("message", "사업자 인증이 완료되었습니다.");
            return ResponseEntity.ok(response);

        } catch (IllegalArgumentException e) {
            logger.warn("사업자번호 진위확인 실패: {}", e.getMessage());
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(response);

        } catch (Exception e) {
            logger.error("사업자번호 진위확인 중 오류", e);
            response.put("success", false);
            response.put("message", "인증 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * Step 4: 회사 정보 저장 (AJAX)
     */
    @PostMapping("/save-company-info")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> saveCompanyInfo(
            @RequestBody CompanyRegistrationDTO dto,
            HttpSession session
    ) {
        Map<String, Object> response = new HashMap<>();

        try {
            SignupSessionDTO signupSession = getOrCreateSession(session);

            // Step 3 완료 확인
            if (!signupSession.isStep3Complete()) {
                response.put("success", false);
                response.put("message", "클라이언트 타입을 먼저 선택해주세요.");
                return ResponseEntity.badRequest().body(response);
            }

            // 회사 정보 저장
            dto.setBusinessVerified(true);  // 진위확인 완료 표시
            signupSession.setCompanyInfo(dto);
            session.setAttribute(SESSION_KEY, signupSession);

            logger.info("회사 정보 저장 완료: companyName={}", dto.getCompanyName());

            response.put("success", true);
            response.put("message", "회사 정보가 저장되었습니다.");
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("회사 정보 저장 실패", e);
            response.put("success", false);
            response.put("message", "회사 정보 저장에 실패했습니다.");
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Step 5: 최종 회원가입 완료

    /**
     * 최종 회원가입 처리
     */
    @PostMapping("/complete")
    public String completeSignup(
            HttpSession session,
            RedirectAttributes rttr
    ) {
        try {
            SignupSessionDTO signupSession = getOrCreateSession(session);

            // 모든 단계 완료 확인
            if (!signupSession.isAllStepsComplete()) {
                logger.warn("회원가입 미완료: {}", signupSession);
                rttr.addFlashAttribute("error", "모든 정보를 입력해주세요.");
                return "redirect:/join/client/signup";
            }

            // 1. users 테이블 INSERT
            UserSignupRequestDTO userDTO = UserSignupRequestDTO.builder()
                    .loginId(signupSession.getLoginId())
                    .email(signupSession.getEmail())
                    .password(signupSession.getPassword())
                    .name(signupSession.getName())
                    .phone(signupSession.getPhone())
                    .birth(signupSession.getBirthDate())
                    .userType(UserType.CLIENT)
                    .build();

            boolean userCreated = joinService.signUp(userDTO);

            if (!userCreated) {
                logger.error("사용자 등록 실패: loginId={}", signupSession.getLoginId());
                rttr.addFlashAttribute("error", "회원가입 중 오류가 발생했습니다.");
                return "redirect:/join/client/signup";
            }

            // 2. 방금 생성된 userId 조회
            Integer userId = getUserIdByLoginId(signupSession.getLoginId());

            if (userId == null) {
                logger.error("사용자 ID 조회 실패: loginId={}", signupSession.getLoginId());
                rttr.addFlashAttribute("error", "회원가입 중 오류가 발생했습니다.");
                return "redirect:/join/client/signup";
            }

            // 3. client_profiles 및 companies 테이블 INSERT
            if (signupSession.isCorporationClient()) {
                // 법인 클라이언트
                clientJoinService.registerClientProfileWithCompany(
                        userId,
                        signupSession.getCompanyInfo()
                );
            } else {
                // 개인 클라이언트
                clientJoinService.registerClientProfile(
                        userId,
                        signupSession.getClientType()
                );
            }

            // 4. 세션 정리
            session.removeAttribute(SESSION_KEY);

            logger.info("클라이언트 회원가입 완료: userId={}, loginId={}, clientType={}",
                    userId, signupSession.getLoginId(), signupSession.getClientType());

            rttr.addFlashAttribute("success", "회원가입이 완료되었습니다. 로그인해주세요.");
            return "redirect:/login";

        } catch (Exception e) {
            logger.error("회원가입 완료 처리 중 오류", e);
            rttr.addFlashAttribute("error", "회원가입 중 오류가 발생했습니다.");
            return "redirect:/join/client/signup";
        }
    }

    // 헬퍼 메서드

    /**
     * 세션에서 SignupSessionDTO 가져오기 (없으면 새로 생성)
     */
    private SignupSessionDTO getOrCreateSession(HttpSession session) {
        SignupSessionDTO signupSession = (SignupSessionDTO) session.getAttribute(SESSION_KEY);

        if (signupSession == null) {
            signupSession = SignupSessionDTO.builder()
                    .userType(UserType.CLIENT)  // 기본값
                    .build();
            session.setAttribute(SESSION_KEY, signupSession);
        }

        return signupSession;
    }

    /**
     * loginId로 userId 조회
     */
    private Integer getUserIdByLoginId(String loginId) {
        try {
            UserVO user = userMapper.findByLoginId(loginId);
            return user != null ? user.getUserId() : null;
        } catch (Exception e) {
            logger.error("userId 조회 실패: loginId={}", loginId, e);
            return null;
        }
    }
}