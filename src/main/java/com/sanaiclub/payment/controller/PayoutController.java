package com.sanaiclub.payment.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.payment.model.dto.PayoutRequestDTO;
import com.sanaiclub.payment.model.dto.PayoutResponseDTO;
import com.sanaiclub.payment.service.PayoutService;
import com.sanaiclub.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;


@RestController
@RequestMapping("/payout")
@RequiredArgsConstructor
public class PayoutController {

    private static final Logger logger = LoggerFactory.getLogger(PayoutController.class);

    private final PayoutService payoutService;
    private final UserService userService;

    /**
     * 마일스톤 지급 (클라이언트가 직접 지급)
     *
     * @param contractId 계약 ID
     * @param milestoneId 마일스톤 ID
     * @return 지급 결과 (JSON)
     */
    @PostMapping("/milestone/release")
    public ResponseEntity<PayoutResponseDTO> releaseMilestone(
            @RequestParam("contractId") Integer contractId,
            @RequestParam("milestoneId") Integer milestoneId,
            @RequestParam("password") String password) {

        logger.info("마일스톤 지급 요청: contractId={}, milestoneId={}", contractId, milestoneId);

        try {
            // 현재 로그인한 사용자 ID 확인
            Integer userId = AuthContext.getCurrentUserId();
            if (userId == null) {
                throw new IllegalStateException("로그인이 필요합니다.");
            }

            // 비밀번호 검증
            if (!userService.verifyPassword(userId, password)) {
                throw new IllegalArgumentException("비밀번호가 일치하지 않습니다.");
            }

            PayoutResponseDTO response = payoutService.releaseMilestone(contractId, milestoneId, userId);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("마일스톤 지급 실패: milestoneId={}", milestoneId, e);

            PayoutResponseDTO errorResponse = PayoutResponseDTO.builder()
                    .success(false)
                    .message("마일스톤 지급 실패: " + e.getMessage())
                    .build();

            return ResponseEntity.badRequest().body(errorResponse);
        }
    }

    /**
     * 마일스톤 지급 요청 (프리랜서가 승인 요청)
     *
     * @param request 지급 요청 DTO
     * @return 요청 결과 (JSON)
     */
    @PostMapping("/milestone/request")
    public ResponseEntity<Map<String, Object>> requestPayout(@RequestBody PayoutRequestDTO request) {
        logger.info("마일스톤 지급 요청: milestoneId={}", request.getMilestoneId());

        Map<String, Object> response = new HashMap<>();

        try {
            // 현재 로그인한 사용자 ID 확인
            Integer userId = AuthContext.getCurrentUserId();
            if (userId == null) {
                throw new IllegalStateException("로그인이 필요합니다.");
            }

            request.setRequestedBy(userId);

            payoutService.requestPayout(request);

            response.put("success", true);
            response.put("message", "지급 요청이 전송되었습니다.");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("마일스톤 지급 요청 실패: milestoneId={}", request.getMilestoneId(), e);

            response.put("success", false);
            response.put("message", "지급 요청 실패: " + e.getMessage());

            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * 마일스톤 지급 승인 (클라이언트가 승인)
     *
     * @param milestoneId 마일스톤 ID
     * @return 지급 결과 (JSON)
     */
    @PostMapping("/milestone/approve")
    public ResponseEntity<PayoutResponseDTO> approvePayout(@RequestParam("milestoneId") Integer milestoneId, @RequestParam("password") String password) {
        logger.info("마일스톤 지급 승인: milestoneId={}", milestoneId);

        try {
            // 현재 로그인한 사용자 ID 확인
            Integer userId = AuthContext.getCurrentUserId();
            if (userId == null) {
                throw new IllegalStateException("로그인이 필요합니다.");
            }

            // 비밀번호 검증
            if (!userService.verifyPassword(userId, password)) {
                throw new IllegalArgumentException("비밀번호가 일치하지 않습니다.");
            }

            PayoutResponseDTO response = payoutService.approvePayout(milestoneId, userId);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("마일스톤 지급 승인 실패: milestoneId={}", milestoneId, e);

            PayoutResponseDTO errorResponse = PayoutResponseDTO.builder()
                    .success(false)
                    .message("지급 승인 실패: " + e.getMessage())
                    .build();

            return ResponseEntity.badRequest().body(errorResponse);
        }
    }

    /**
     * FULL 방식 전액 지급
     *
     * @param contractId 계약 ID
     * @return 지급 결과 (JSON)
     */
    @PostMapping("/full")
    public ResponseEntity<PayoutResponseDTO> releaseFullAmount(@RequestParam("contractId") Integer contractId) {
        logger.info("전액 지급 요청: contractId={}", contractId);

        try {
            // 현재 로그인한 사용자 ID 확인
            Integer userId = AuthContext.getCurrentUserId();
            if (userId == null) {
                throw new IllegalStateException("로그인이 필요합니다.");
            }

            PayoutResponseDTO response = payoutService.releaseFullAmount(contractId, userId);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("전액 지급 실패: contractId={}", contractId, e);

            PayoutResponseDTO errorResponse = PayoutResponseDTO.builder()
                    .success(false)
                    .message("전액 지급 실패: " + e.getMessage())
                    .build();

            return ResponseEntity.badRequest().body(errorResponse);
        }
    }

    /**
     * 마일스톤 지급 요청 거부 (클라이언트가 거부)
     */
    @PostMapping("/milestone/reject")
    public ResponseEntity<PayoutResponseDTO> rejectPayout(
            @RequestParam("milestoneId") Integer milestoneId,
            @RequestParam("password") String password) {

        logger.info("마일스톤 지급 요청 거부: milestoneId={}", milestoneId);

        try {
            // 현재 로그인한 사용자 ID 확인
            Integer userId = AuthContext.getCurrentUserId();
            if (userId == null) {
                throw new IllegalStateException("로그인이 필요합니다.");
            }

            // 비밀번호 검증
            if (!userService.verifyPassword(userId, password)) {
                throw new IllegalArgumentException("비밀번호가 일치하지 않습니다.");
            }

            PayoutResponseDTO response = payoutService.rejectPayout(milestoneId, userId);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("마일스톤 지급 요청 거부 실패: milestoneId={}", milestoneId, e);

            PayoutResponseDTO errorResponse = PayoutResponseDTO.builder()
                    .success(false)
                    .message("지급 요청 거부 실패: " + e.getMessage())
                    .build();

            return ResponseEntity.badRequest().body(errorResponse);
        }
    }

    /**
     * 계약의 현재 활성화된 마일스톤 조회
     */
    @GetMapping("/milestone/actionable")
    public ResponseEntity<Map<String, Object>> getActionableMilestone(
            @RequestParam("contractId") Integer contractId) {

        logger.info("활성화된 마일스톤 조회: contractId={}", contractId);

        try {
            Integer actionableStep = payoutService.getActionableMilestoneStep(contractId);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("actionableStep", actionableStep);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("활성화된 마일스톤 조회 실패: contractId={}", contractId, e);

            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "조회 실패: " + e.getMessage());

            return ResponseEntity.badRequest().body(errorResponse);
        }
    }
}