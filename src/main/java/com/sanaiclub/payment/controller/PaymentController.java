package com.sanaiclub.payment.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.contract.model.vo.ContractVO;
import com.sanaiclub.payment.model.dto.*;
import com.sanaiclub.payment.service.PaymentService;
import com.sanaiclub.user.model.dto.UserInfoDTO;
import com.sanaiclub.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.Map;


@Controller
@RequestMapping("/payment")
@RequiredArgsConstructor
public class PaymentController {

    private static final Logger logger = LoggerFactory.getLogger(PaymentController.class);

    private final PaymentService paymentService;
    private final UserService userService;

    // 포트원 식별코드 (properties에서 주입)
    @Value("${portone.imp.code}")
    private String impCode;

    /**
     * 결제 페이지 요청
     */
    @GetMapping("/request")
    public String paymentPage(@RequestParam("contractId") Integer contractId, Model model) {
        logger.info("결제 페이지 요청: contractId={}", contractId);

        try {
            // 1. 현재 로그인한 사용자 ID 확인
            Integer userId = AuthContext.getCurrentUserId();
            if (userId == null) {
                return "redirect:/user/login";
            }

            // 2. Service를 통해 계약 정보 조회 및 검증
            ContractVO contract = paymentService.getContractForPayment(contractId);

            // 3. 클라이언트(구매자) 정보 조회
            UserInfoDTO buyer = userService.getUserInfo(userId);
            if (buyer == null) {
                throw new IllegalArgumentException("사용자 정보를 찾을 수 없습니다.");
            }

            // 4. Model에 데이터 전달
            model.addAttribute("contract", contract);
            model.addAttribute("buyer", buyer);
            model.addAttribute("impCode", impCode);

            return "payment/paymentRequest";

        } catch (Exception e) {
            logger.error("결제 페이지 로드 실패: contractId={}", contractId, e);
            model.addAttribute("error", "결제 페이지를 불러오는데 실패했습니다.");
            return "error/error";
        }
    }

    /**
     * 결제 사전 검증
     * - merchant_uid 생성
     * - 계약 정보 검증
     * - 결제창 호출에 필요한 정보 반환
     */
    @PostMapping("/prepare")
    @ResponseBody
    public ResponseEntity<?> preparePayment(@RequestBody PaymentRequestDTO request) {
        logger.info("결제 준비 요청: contractId={}", request.getContractId());

        try {
            PaymentPrepareDTO result = paymentService.preparePayment(request);
            return ResponseEntity.ok(result);

        } catch (IllegalArgumentException e) {
            logger.error("결제 준비 실패: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(Map.of("error", e.getMessage()));

        } catch (IllegalStateException e) {
            logger.error("결제 준비 실패: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(Map.of("error", e.getMessage()));

        } catch (Exception e) {
            logger.error("결제 준비 실패: contractId={}", request.getContractId(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "결제 준비 중 오류가 발생했습니다."));
        }
    }

    /**
     * 결제 완료 검증
     * - 포트원 API로 결제 정보 조회 및 검증
     * - 결제 정보 DB 저장
     * - 에스크로 생성
     * - 계약 상태 업데이트
     */
    @PostMapping("/complete")
    @ResponseBody
    public ResponseEntity<?> completePayment(@RequestBody PaymentCompleteDTO request) {
        logger.info("결제 완료 검증: impUid={}", request.getImpUid());

        try {
            PaymentResponseDTO result = paymentService.completePayment(request);
            return ResponseEntity.ok(result);

        } catch (Exception e) {
            logger.error("결제 완료 처리 실패: impUid={}", request.getImpUid(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(PaymentResponseDTO.builder()
                            .success(false)
                            .message("결제 완료 처리 중 오류가 발생했습니다: " + e.getMessage())
                            .build());
        }
    }

    /**
     * 결제 성공 페이지
     *
     * @param contractId 계약 ID
     * @param model 뷰 모델
     * @return 결제 성공 페이지 JSP
     */
    @GetMapping("/success")
    public String paymentSuccess(@RequestParam("contractId") Integer contractId, Model model) {

        try {
            // 1. 계약 정보 조회
            ContractVO contract = paymentService.getContractById(contractId);
            if (contract == null) {
                throw new IllegalArgumentException("계약을 찾을 수 없습니다.");
            }

            // 2. 결제 정보 조회
            PaymentResponseDTO payment = paymentService.getPaymentByContractId(contractId);

            // 3. Model에 전달
            model.addAttribute("contract", contract);
            model.addAttribute("payment", payment);

            return "payment/paymentSuccess";

        } catch (Exception e) {
            logger.error("결제 성공 페이지 로드 실패: contractId={}", contractId, e);
            model.addAttribute("errorMsg", "결제 정보를 불러오는데 실패했습니다.");
            return "payment/paymentFail";
        }
    }

    /**
     * 결제 실패 페이지
     *
     * @param errorMsg 오류 메시지
     * @param model 뷰 모델
     * @return 결제 실패 페이지 JSP
     */
    @GetMapping("/fail")
    public String paymentFail(@RequestParam(value = "errorMsg", required = false) String errorMsg,
                              Model model) {

        model.addAttribute("errorMsg", errorMsg != null ? errorMsg : "결제 처리 중 오류가 발생했습니다.");

        return "payment/paymentFail";
    }
}