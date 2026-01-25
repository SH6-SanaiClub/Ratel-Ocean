package com.sanaiclub.payment.controller;

import com.sanaiclub.payment.model.dto.PaymentWebhookDTO;
import com.sanaiclub.payment.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;


@RestController
@RequestMapping("/payment")
@RequiredArgsConstructor
public class PaymentWebhookController {

    private static final Logger logger = LoggerFactory.getLogger(PaymentWebhookController.class);

    private final PaymentService paymentService;

    /**
     * 포트원 웹훅 수신
     *
     * [처리 흐름]
     * 1. 웹훅 데이터 수신
     * 2. 결제 정보 조회 및 검증
     * 3. 결제 상태 업데이트
     *
     * @param webhook 웹훅 데이터
     * @return HTTP 200 응답 (포트원에 성공 알림)
     */
    @PostMapping("/webhook")
    public ResponseEntity<Map<String, Object>> handleWebhook(@RequestBody PaymentWebhookDTO webhook) {
        logger.info("웹훅 수신: impUid={}, merchantUid={}, status={}",
                webhook.getImpUid(), webhook.getMerchantUid(), webhook.getStatus());

        Map<String, Object> response = new HashMap<>();

        try {
            // 웹훅 처리
            paymentService.handleWebhook(webhook);

            response.put("success", true);
            response.put("message", "웹훅 처리 완료");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("웹훅 처리 실패: impUid={}", webhook.getImpUid(), e);

            response.put("success", false);
            response.put("message", "웹훅 처리 실패: " + e.getMessage());

            // 포트원에는 200 응답을 보내야 재시도를 방지
            return ResponseEntity.status(HttpStatus.OK).body(response);
        }
    }
}