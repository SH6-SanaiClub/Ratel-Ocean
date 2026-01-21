package com.sanaiclub.user.controller;

import com.sanaiclub.user.dao.UserMapper;
import com.sanaiclub.user.model.dto.CompanyRegistrationDTO;
import com.sanaiclub.user.model.dto.UserSignupRequestDTO;
import com.sanaiclub.user.model.vo.ClientType;
import com.sanaiclub.user.model.vo.UserType;
import com.sanaiclub.user.model.vo.UserVO;
import com.sanaiclub.user.service.BizNoVerificationService;
import com.sanaiclub.user.service.ClientJoinService;
import com.sanaiclub.user.service.JoinService;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

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

    // 세션 키 상수
    private static final String SESSION_USER_TYPE = "selectedUserType";
    private static final String SESSION_USER_DATA = "userSignupData";
    private static final String SESSION_CLIENT_TYPE = "clientType";

    private final JoinService joinService;
    private final ClientJoinService clientJoinService;
    private final BizNoVerificationService bizNoVerificationService;
    private final UserMapper userMapper;

    public ClientJoinController(JoinService joinService, ClientJoinService clientJoinService, BizNoVerificationService bizNoVerificationService, UserMapper userMapper) {
        this.joinService = joinService;
        this.clientJoinService = clientJoinService;
        this.bizNoVerificationService = bizNoVerificationService;
        this.userMapper = userMapper;
    }


    /**
     * 클라이언트 회원가입 페이지
     */
    @GetMapping("/signup")
    public String clientSignupPage(HttpSession session, Model model) {
        // 공통 정보 확인
        UserSignupRequestDTO commonData =
                (UserSignupRequestDTO) session.getAttribute(SESSION_USER_DATA);

        if (commonData == null) {
            return "redirect:/join/select-role";
        }

        // CLIENT 타입 확인
        if (!UserType.CLIENT.equals(commonData.getUserType())) {
            return "redirect:/join/select-role";
        }

        model.addAttribute("commonData", commonData);

        return "user/client/clientSignup";
    }

    // ═══════════════════════════════════════════════════════════════
    // API: 클라이언트 타입 선택
    // ═══════════════════════════════════════════════════════════════

    /**
     * 클라이언트 타입 선택 처리
     * POST /join/client/save-client-type
     *
     * @param clientType PERSONAL 또는 CORPORATION
     */
    @PostMapping("/save-client-type")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> saveClientType(
            @RequestParam("clientType") ClientType clientType,
            HttpSession session
    ) {
        Map<String, Object> response = new HashMap<>();

        try {
            // 공통 정보 확인
            UserSignupRequestDTO commonData =
                    (UserSignupRequestDTO) session.getAttribute(SESSION_USER_DATA);

            if (commonData == null) {
                response.put("success", false);
                response.put("message", "세션이 만료되었습니다. 다시 시도해주세요.");
                return ResponseEntity.ok(response);
            }

            // 세션에 클라이언트 타입 저장
            session.setAttribute(SESSION_CLIENT_TYPE, clientType);

            response.put("success", true);
            response.put("clientType", clientType.name());
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.ok(response);
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // API: 사업자번호 중복 확인
    // ═══════════════════════════════════════════════════════════════

    /**
     * 사업자번호 중복 확인
     * GET /join/client/check-business-number?businessNumber=1234567890
     */
    @GetMapping("/check-business-number")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> checkBusinessNumber(
            @RequestParam("businessNumber") String businessNumber
    ) {
        Map<String, Object> response = new HashMap<>();

        // 하이픈 제거
        String cleanNumber = businessNumber.replaceAll("-", "");

        boolean isDuplicate = clientJoinService.isBusinessNumberDuplicate(cleanNumber);

        response.put("success", true);
        response.put("isDuplicate", isDuplicate);
        response.put("message", isDuplicate
                ? "이미 등록된 사업자번호입니다."
                : "사용 가능한 사업자번호입니다.");

        return ResponseEntity.ok(response);
    }

    // ═══════════════════════════════════════════════════════════════
    // API: 사업자 진위확인
    // ═══════════════════════════════════════════════════════════════

    /**
     * 사업자 진위확인 (국세청 API)
     * POST /join/client/verify-business
     *
     * @param businessNumber 사업자번호 (하이픈 포함 가능)
     * @param ceoName 대표자명
     * @param openingDate 개업일자 (YYYY-MM-DD)
     */
    @PostMapping("/verify-business")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> verifyBusiness(
            @RequestParam("businessNumber") String businessNumber,
            @RequestParam("ceoName") String ceoName,
            @RequestParam("openingDate") String openingDate
    ) {
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
                response.put("success", true);
                response.put("verified", true);
                response.put("message", "사업자 인증이 완료되었습니다.");
            } else {
                response.put("success", true);
                response.put("verified", false);
                response.put("message", "입력하신 정보가 국세청 등록 정보와 일치하지 않습니다.");
            }

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("verified", false);
            response.put("message", "인증 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
            return ResponseEntity.ok(response);
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // API: 회원가입 완료
    // ═══════════════════════════════════════════════════════════════

    /**
     * 개인 클라이언트 회원가입 완료
     * POST /join/client/complete-personal
     */
    @PostMapping("/complete-personal")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> completePersonal(HttpSession session) {
        Map<String, Object> response = new HashMap<>();

        try {
            // 세션에서 공통 정보 가져오기
            UserSignupRequestDTO commonData =
                    (UserSignupRequestDTO) session.getAttribute(SESSION_USER_DATA);

            if (commonData == null) {
                response.put("success", false);
                response.put("message", "세션이 만료되었습니다.");
                return ResponseEntity.ok(response);
            }

            // 클라이언트 타입 확인
            ClientType clientType =
                    (ClientType) session.getAttribute(SESSION_CLIENT_TYPE);

            if (clientType == null || !ClientType.PERSONAL.equals(clientType)) {
                response.put("success", false);
                response.put("message", "클라이언트 타입이 올바르지 않습니다.");
                return ResponseEntity.ok(response);
            }

            // 1. users 테이블 INSERT
            boolean userCreated = joinService.signUp(commonData);

            if (!userCreated) {
                response.put("success", false);
                response.put("message", "회원가입 중 오류가 발생했습니다.");
                return ResponseEntity.ok(response);
            }

            // 2. userId 조회
            UserVO user = userMapper.findByLoginId(commonData.getLoginId());
            if (user == null) {
                response.put("success", false);
                response.put("message", "사용자 정보를 찾을 수 없습니다.");
                return ResponseEntity.ok(response);
            }
            Integer userId = user.getUserId();

            // 3. client_profiles INSERT (개인)
            boolean profileCreated = clientJoinService.registerClientProfile(userId, ClientType.PERSONAL);

            if (!profileCreated) {
                response.put("success", false);
                response.put("message", "클라이언트 프로필 등록 중 오류가 발생했습니다.");
                return ResponseEntity.ok(response);
            }

            // 4. 세션 정리
            session.removeAttribute(SESSION_USER_TYPE);
            session.removeAttribute(SESSION_USER_DATA);
            session.removeAttribute(SESSION_CLIENT_TYPE);

            response.put("success", true);
            response.put("message", "회원가입이 완료되었습니다.");
            response.put("redirectUrl", "/client/dashboard");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "회원가입 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.ok(response);
        }
    }

    /**
     * 법인 클라이언트 회원가입 완료
     * POST /join/client/complete-corporation
     */
    @PostMapping("/complete-corporation")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> completeCorporation(
            @ModelAttribute CompanyRegistrationDTO companyDto,
            HttpSession session
    ) {
        Map<String, Object> response = new HashMap<>();

        try {
            // 세션에서 공통 정보 가져오기
            UserSignupRequestDTO commonData =
                    (UserSignupRequestDTO) session.getAttribute(SESSION_USER_DATA);

            if (commonData == null) {
                response.put("success", false);
                response.put("message", "세션이 만료되었습니다.");
                return ResponseEntity.ok(response);
            }

            // 클라이언트 타입 확인
            ClientType clientType =
                    (ClientType) session.getAttribute(SESSION_CLIENT_TYPE);

            if (clientType == null || !ClientType.CORPORATION.equals(clientType)) {
                response.put("success", false);
                response.put("message", "클라이언트 타입이 올바르지 않습니다.");
                return ResponseEntity.ok(response);
            }

            // 1. users 테이블 INSERT
            boolean userCreated = joinService.signUp(commonData);

            if (!userCreated) {
                response.put("success", false);
                response.put("message", "회원가입 중 오류가 발생했습니다.");
                return ResponseEntity.ok(response);
            }

            // 2. userId 조회
            UserVO user = userMapper.findByLoginId(commonData.getLoginId());
            if (user == null) {
                response.put("success", false);
                response.put("message", "사용자 정보를 찾을 수 없습니다.");
                return ResponseEntity.ok(response);
            }
            Integer userId = user.getUserId();

            // 3. companies + client_profiles INSERT (법인)
            boolean profileCreated = clientJoinService.registerClientProfileWithCompany(
                    userId, companyDto);

            if (!profileCreated) {
                response.put("success", false);
                response.put("message", "회사 정보 등록 중 오류가 발생했습니다.");
                return ResponseEntity.ok(response);
            }

            // 4. 세션 정리
            session.removeAttribute(SESSION_USER_TYPE);
            session.removeAttribute(SESSION_USER_DATA);
            session.removeAttribute(SESSION_CLIENT_TYPE);

            response.put("success", true);
            response.put("message", "회원가입이 완료되었습니다.");
            response.put("redirectUrl", "/client/dashboard");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "회원가입 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.ok(response);
        }
    }
}