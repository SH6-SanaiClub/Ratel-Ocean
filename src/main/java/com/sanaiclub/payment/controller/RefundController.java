package com.sanaiclub.payment.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.payment.model.dto.RefundRequestDTO;
import com.sanaiclub.payment.model.dto.RefundResponseDTO;
import com.sanaiclub.payment.service.RefundService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;


@RestController
@RequestMapping("/refund")
@RequiredArgsConstructor
public class RefundController {

    private static final Logger logger = LoggerFactory.getLogger(RefundController.class);

    private final RefundService refundService;

    /**
     * 환불 요청
     *
     * [처리 흐름]
     * 1. 환불 가능 금액 계산
     * 2. 포트원 API로 환불 요청
     * 3. 환불 정보 저장
     * 4. 에스크로 업데이트
     * 5. 계약 상태 업데이트
     * 6. 미지급 마일스톤 취소
     *
     * @param request 환불 요청 DTO
     * @return 환불 결과 (JSON)
     */
    @PostMapping("/request")
    public ResponseEntity<RefundResponseDTO> requestRefund(@RequestBody RefundRequestDTO request) {
        logger.info("환불 요청: contractId={}, reason={}", request.getContractId(), request.getReason());

        try {
            // 현재 로그인한 사용자 ID 확인
            Integer userId = AuthContext.getCurrentUserId();
            if (userId == null) {
                throw new IllegalStateException("로그인이 필요합니다.");
            }

            request.setRequestedBy(userId);

            RefundResponseDTO response = refundService.requestRefund(request);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("환불 요청 실패: contractId={}", request.getContractId(), e);

            RefundResponseDTO errorResponse = RefundResponseDTO.builder()
                    .success(false)
                    .message("환불 처리 실패: " + e.getMessage())
                    .build();

            return ResponseEntity.badRequest().body(errorResponse);
        }
    }

    /**
     * 환불 가능 금액 조회
     *
     * @param contractId 계약 ID
     * @return 환불 가능 금액 (JSON)
     */
    @GetMapping("/amount")
    public ResponseEntity<Map<String, Object>> getRefundableAmount(@RequestParam("contractId") Integer contractId) {
        logger.info("환불 가능 금액 조회: contractId={}", contractId);

        Map<String, Object> response = new HashMap<>();

        try {
            Long refundableAmount = refundService.getRefundableAmount(contractId);

            response.put("success", true);
            response.put("contractId", contractId);
            response.put("refundableAmount", refundableAmount);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("환불 가능 금액 조회 실패: contractId={}", contractId, e);

            response.put("success", false);
            response.put("message", "조회 실패: " + e.getMessage());

            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * 환불 상태 조회
     *
     * @param refundId 환불 ID
     * @return 환불 정보 (JSON)
     */
    @GetMapping("/status/{refundId}")
    public ResponseEntity<RefundResponseDTO> getRefundStatus(@PathVariable("refundId") Integer refundId) {
        logger.info("환불 상태 조회: refundId={}", refundId);

        try {
            RefundResponseDTO response = refundService.getRefundStatus(refundId);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("환불 상태 조회 실패: refundId={}", refundId, e);

            RefundResponseDTO errorResponse = RefundResponseDTO.builder()
                    .success(false)
                    .message("조회 실패: " + e.getMessage())
                    .build();

            return ResponseEntity.badRequest().body(errorResponse);
        }
    }
}