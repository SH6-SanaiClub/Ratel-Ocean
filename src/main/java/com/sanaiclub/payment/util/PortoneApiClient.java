package com.sanaiclub.payment.util;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

/**
 * ============================================================================
 * PortoneApiClient - 포트원 API 클라이언트
 * ============================================================================
 *
 * [역할]
 * - 포트원(iamport) REST API 호출 유틸리티
 * - 액세스 토큰 발급, 결제 정보 조회, 환불 처리 등
 *
 * [주요 기능]
 * 1. getAccessToken(): API 인증 토큰 발급
 * 2. getPaymentInfo(): 결제 정보 조회 (imp_uid 기반)
 * 3. cancelPayment(): 결제 취소/환불 처리
 *
 * [API 문서]
 * - https://api.iamport.kr/#!/authenticate
 * - https://api.iamport.kr/#!/payments
 *
 * ============================================================================
 */
@Component
public class PortoneApiClient {

    private static final Logger logger = LoggerFactory.getLogger(PortoneApiClient.class);

    @Value("${portone.api.url}")
    private String apiUrl;

    @Value("${portone.api.key}")
    private String apiKey;

    @Value("${portone.api.secret}")
    private String apiSecret;

    @Value("${portone.api.connect.timeout:5000}")
    private int connectTimeout;

    @Value("${portone.api.read.timeout:10000}")
    private int readTimeout;

    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * 포트원 API 액세스 토큰 발급
     *
     * [API]
     * POST /users/getToken
     *
     * [요청]
     * {
     *   "imp_key": "API Key",
     *   "imp_secret": "API Secret"
     * }
     *
     * [응답]
     * {
     *   "code": 0,
     *   "message": null,
     *   "response": {
     *     "access_token": "...",
     *     "expired_at": 1234567890,
     *     "now": 1234567890
     *   }
     * }
     *
     * @return 액세스 토큰
     * @throws Exception 토큰 발급 실패 시
     */
    public String getAccessToken() throws Exception {
        String url = apiUrl + "/users/getToken";

        Map<String, String> params = new HashMap<>();
        params.put("imp_key", apiKey);
        params.put("imp_secret", apiSecret);

        String requestBody = objectMapper.writeValueAsString(params);

        logger.info("포트원 액세스 토큰 발급 요청");

        String response = sendPostRequest(url, requestBody, null);

        JsonNode jsonNode = objectMapper.readTree(response);
        int code = jsonNode.get("code").asInt();

        if (code != 0) {
            String message = jsonNode.has("message") ? jsonNode.get("message").asText() : "Unknown error";
            logger.error("포트원 토큰 발급 실패: code={}, message={}", code, message);
            throw new Exception("포트원 토큰 발급 실패: " + message);
        }

        String accessToken = jsonNode.get("response").get("access_token").asText();
        logger.info("포트원 액세스 토큰 발급 성공");

        return accessToken;
    }

    /**
     * 결제 정보 조회
     *
     * [API]
     * GET /payments/{imp_uid}
     *
     * [응답]
     * {
     *   "code": 0,
     *   "message": null,
     *   "response": {
     *     "imp_uid": "...",
     *     "merchant_uid": "...",
     *     "amount": 10000,
     *     "status": "paid",
     *     "paid_at": 1234567890,
     *     "receipt_url": "...",
     *     "pay_method": "card",
     *     "pg_provider": "html5_inicis",
     *     "pg_tid": "...",
     *     "card_name": "신한카드",
     *     "card_number": "1234-****-****-5678",
     *     ...
     *   }
     * }
     *
     * @param impUid 포트원 결제 고유번호
     * @return 결제 정보 JSON
     * @throws Exception 조회 실패 시
     */
    public JsonNode getPaymentInfo(String impUid) throws Exception {
        String accessToken = getAccessToken();
        String url = apiUrl + "/payments/" + impUid;

        logger.info("결제 정보 조회 요청: imp_uid={}", impUid);

        String response = sendGetRequest(url, accessToken);

        JsonNode jsonNode = objectMapper.readTree(response);
        int code = jsonNode.get("code").asInt();

        if (code != 0) {
            String message = jsonNode.has("message") ? jsonNode.get("message").asText() : "Unknown error";
            logger.error("결제 정보 조회 실패: code={}, message={}", code, message);
            throw new Exception("결제 정보 조회 실패: " + message);
        }

        JsonNode paymentInfo = jsonNode.get("response");
        logger.info("결제 정보 조회 성공: imp_uid={}, amount={}", impUid, paymentInfo.get("amount").asLong());

        return paymentInfo;
    }

    /**
     * 결제 취소/환불 처리
     *
     * [API]
     * POST /payments/cancel
     *
     * [요청]
     * {
     *   "imp_uid": "...",           // 포트원 결제 고유번호
     *   "amount": 10000,            // 환불 금액 (부분 환불 가능)
     *   "checksum": 10000,          // 환불 가능 금액 (위변조 방지)
     *   "reason": "고객 요청"        // 환불 사유
     * }
     *
     * [응답]
     * {
     *   "code": 0,
     *   "message": null,
     *   "response": {
     *     "imp_uid": "...",
     *     "merchant_uid": "...",
     *     "amount": 10000,
     *     "cancel_amount": 5000,     // 취소된 금액
     *     "status": "cancelled",      // 상태: cancelled (전액), partial_cancelled (부분)
     *     ...
     *   }
     * }
     *
     * @param impUid 포트원 결제 고유번호
     * @param refundAmount 환불 금액 (부분 환불 가능)
     * @param checksum 환불 가능 금액 (위변조 방지)
     * @param reason 환불 사유
     * @return 환불 결과 JSON
     * @throws Exception 환불 실패 시
     */
    public JsonNode cancelPayment(String impUid, Long refundAmount, Long checksum, String reason) throws Exception {
        String accessToken = getAccessToken();
        String url = apiUrl + "/payments/cancel";

        Map<String, Object> params = new HashMap<>();
        params.put("imp_uid", impUid);
        params.put("amount", refundAmount);
        params.put("checksum", checksum);
        params.put("reason", reason);

        String requestBody = objectMapper.writeValueAsString(params);

        logger.info("결제 취소 요청: imp_uid={}, amount={}, reason={}", impUid, refundAmount, reason);

        String response = sendPostRequest(url, requestBody, accessToken);

        JsonNode jsonNode = objectMapper.readTree(response);
        int code = jsonNode.get("code").asInt();

        if (code != 0) {
            String message = jsonNode.has("message") ? jsonNode.get("message").asText() : "Unknown error";
            logger.error("결제 취소 실패: code={}, message={}", code, message);
            throw new Exception("결제 취소 실패: " + message);
        }

        JsonNode cancelInfo = jsonNode.get("response");
        logger.info("결제 취소 성공: imp_uid={}, cancel_amount={}", impUid, cancelInfo.get("cancel_amount").asLong());

        return cancelInfo;
    }

    /**
     * HTTP GET 요청 전송
     */
    private String sendGetRequest(String urlString, String accessToken) throws Exception {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();

        try {
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            conn.setRequestProperty("Authorization", "Bearer " + accessToken);
            conn.setConnectTimeout(connectTimeout);
            conn.setReadTimeout(readTimeout);

            int responseCode = conn.getResponseCode();

            if (responseCode == HttpURLConnection.HTTP_OK) {
                return readResponse(conn);
            } else {
                logger.error("HTTP 요청 실패: responseCode={}", responseCode);
                throw new Exception("HTTP 요청 실패: " + responseCode);
            }
        } finally {
            conn.disconnect();
        }
    }

    /**
     * HTTP POST 요청 전송
     */
    private String sendPostRequest(String urlString, String requestBody, String accessToken) throws Exception {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();

        try {
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");

            if (accessToken != null) {
                conn.setRequestProperty("Authorization", "Bearer " + accessToken);
            }

            conn.setConnectTimeout(connectTimeout);
            conn.setReadTimeout(readTimeout);
            conn.setDoOutput(true);

            // 요청 본문 전송
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = requestBody.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }

            int responseCode = conn.getResponseCode();

            if (responseCode == HttpURLConnection.HTTP_OK) {
                return readResponse(conn);
            } else {
                logger.error("HTTP 요청 실패: responseCode={}, requestBody={}", responseCode, requestBody);
                throw new Exception("HTTP 요청 실패: " + responseCode);
            }
        } finally {
            conn.disconnect();
        }
    }

    /**
     * HTTP 응답 읽기
     */
    private String readResponse(HttpURLConnection conn) throws Exception {
        try (BufferedReader br = new BufferedReader(
                new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {

            StringBuilder response = new StringBuilder();
            String line;

            while ((line = br.readLine()) != null) {
                response.append(line);
            }

            return response.toString();
        }
    }
}