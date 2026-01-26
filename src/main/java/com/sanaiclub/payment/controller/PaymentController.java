package com.sanaiclub.payment.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.contract.dao.ContractMapper;
import com.sanaiclub.contract.model.vo.ContractVO;
import com.sanaiclub.payment.model.dto.*;
import com.sanaiclub.payment.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;


@Controller
@RequestMapping("/payment")
@RequiredArgsConstructor
public class PaymentController {

    private static final Logger logger = LoggerFactory.getLogger(PaymentController.class);

    private final PaymentService paymentService;
    private final ContractMapper contractMapper;

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
            Integer userId = AuthContext.getCurrentUserId();
            if (userId == null) {
                return "redirect:/user/login"; // 로그인 안되어있으면 로그인 페이지로
            }

            // 1. 계약 정보 조회 (결제 금액 표시용)
            ContractVO contract = contractMapper.selectContractById(contractId);
            if (contract == null) {
                throw new IllegalArgumentException("존재하지 않는 계약입니다.");
            }

            // 2. JSP로 데이터 전달
            model.addAttribute("contract", contract); // 계약 정보 (금액, 기간 등)
            model.addAttribute("impCode", impCode);   // 포트원 식별코드
            model.addAttribute("userId", userId);

            return "payment/paymentRequest";

        } catch (Exception e) {
            logger.error("결제 페이지 로드 실패: contractId={}", contractId, e);
            model.addAttribute("error", e.getMessage());
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
    public PaymentPrepareDTO preparePayment(@RequestBody PaymentRequestDTO request) {
        logger.info("결제 준비 요청: contractId={}", request.getContractId());

        try {
            return paymentService.preparePayment(request);

        } catch (Exception e) {
            logger.error("결제 준비 실패: contractId={}", request.getContractId(), e);
            throw new RuntimeException("결제 준비 중 오류가 발생했습니다: " + e.getMessage());
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
    public PaymentResponseDTO completePayment(@RequestBody PaymentCompleteDTO request) {
        logger.info("결제 완료 검증: impUid={}", request.getImpUid());

        try {
            return paymentService.completePayment(request);

        } catch (Exception e) {
            logger.error("결제 완료 처리 실패: impUid={}", request.getImpUid(), e);
            throw new RuntimeException("결제 완료 처리 중 오류가 발생했습니다: " + e.getMessage());
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

        model.addAttribute("contractId", contractId);

        return "payment/paymentSuccess";
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