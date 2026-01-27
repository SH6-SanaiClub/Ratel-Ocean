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
        // URL 검증
        if (apiUrl == null || apiUrl.trim().isEmpty()) {
            logger.error("포트원 API URL이 설정되지 않았습니다. portone-api.properties 파일을 확인하세요.");
            throw new IllegalStateException("포트원 API URL 없음: portone.api.url 속성이 설정되지 않았습니다.");
        }

        String url = apiUrl.trim() + "/users/getToken";

        // API Key/Secret 검증
        if (apiKey == null || apiKey.trim().isEmpty() || apiSecret == null || apiSecret.trim().isEmpty()) {
            logger.error("포트원 API 인증 정보가 설정되지 않았습니다. portone-api.properties 파일을 확인하세요.");
            throw new IllegalStateException("포트원 API 인증 정보 없음");
        }

        Map<String, String> params = new HashMap<>();
        params.put("imp_key", apiKey.trim());
        params.put("imp_secret", apiSecret.trim());

        String requestBody = objectMapper.writeValueAsString(params);

        logger.info("포트원 액세스 토큰 발급 요청: url={}", url);

        String response = sendPostRequest(url, requestBody, null);

        JsonNode jsonNode = objectMapper.readTree(response);
        int code = jsonNode.get("code").asInt();

        if (code != 0) {
            String message = jsonNode.has("message") ? jsonNode.get("message").asText() : "Unknown error";
            logger.error("포트원 토큰 발급 실패: code={}, message={}, response={}", code, message, response);
            
            // 포트원 API 에러 코드별 상세 메시지
            String detailedMessage = String.format("포트원 토큰 발급 실패 (code=%d): %s", code, message);
            if (code == -1) {
                detailedMessage += " - API Key 또는 Secret이 잘못되었습니다. portone-api.properties 파일을 확인하세요.";
            }
            
            throw new Exception(detailedMessage);
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
        int maxRetries = 3;
        int retryDelay = 2000; // 2초

        Exception lastException = new Exception("알 수 없는 오류");

        for (int attempt = 1; attempt <= maxRetries; attempt++) {
            try {
                // URL 검증
                if (apiUrl == null || apiUrl.trim().isEmpty()) {
                    logger.error("포트원 API URL이 설정되지 않았습니다. portone-api.properties 파일을 확인하세요.");
                    throw new IllegalStateException("포트원 API URL 없음: portone.api.url 속성이 설정되지 않았습니다.");
                }

                String accessToken = getAccessToken();
                String url = apiUrl.trim() + "/payments/" + impUid + "?include_sandbox=true";

                logger.info("결제 정보 조회 시도 {}/{}: imp_uid={}, url={}", attempt, maxRetries, impUid, url);

                String response = sendGetRequest(url, accessToken);

                JsonNode jsonNode = objectMapper.readTree(response);
                int code = jsonNode.get("code").asInt();

                if (code != 0) {
                    String message = jsonNode.has("message") ?
                            jsonNode.get("message").asText() : "Unknown error";
                    logger.error("결제 정보 조회 실패: code={}, message={}", code, message);
                    throw new Exception("결제 정보 조회 실패: " + message);
                }

                JsonNode paymentInfo = jsonNode.get("response");
                String status = paymentInfo.has("status") ? paymentInfo.get("status").asText() : "unknown";
                logger.info("✅ 결제 정보 조회 성공 (시도 {}): imp_uid={}, status={}",
                        attempt, impUid, status);

                return paymentInfo;

            } catch (Exception e) {
                lastException = e;
                logger.warn("❌ 결제 정보 조회 실패 (시도 {}/{}): {}",
                        attempt, maxRetries, e.getMessage());

                // 마지막 시도가 아니면 재시도
                if (attempt < maxRetries) {
                    logger.info("⏳ {}ms 후 재시도...", retryDelay);
                    try {
                        Thread.sleep(retryDelay);
                    } catch (InterruptedException ie) {
                        Thread.currentThread().interrupt();
                        throw new Exception("재시도 중 인터럽트 발생", ie);
                    }
                }
            }
        }
        logger.error("💥 결제 정보 조회 최종 실패 ({}회 시도): impUid={}", maxRetries, impUid);
        throw new Exception("결제 정보 조회 실패 (모든 재시도 실패): " + lastException.getMessage(), lastException);
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
        params.put("checksum", checksum);

        if (refundAmount != null) {
            params.put("amount", refundAmount);
        }

        if (reason != null && !reason.isEmpty()) {
            params.put("reason", reason);
        }

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
                // ✅ 에러 응답 본문 읽기
                String errorBody = readErrorResponse(conn);
                logger.error("🚨 HTTP GET 요청 실패: responseCode={}, url={}", responseCode, urlString);
                logger.error("🚨 에러 응답 본문: {}", errorBody);
                throw new Exception("HTTP 요청 실패: " + responseCode + " - " + errorBody);
            }
        } finally {
            conn.disconnect();
        }
    }

    /**
     * HTTP POST 요청 전송
     */
    private String sendPostRequest(String urlString, String requestBody, String accessToken) throws Exception {
        // URL 검증
        if (urlString == null || urlString.trim().isEmpty()) {
            throw new IllegalArgumentException("URL이 비어있습니다.");
        }

        // URL 형식 검증 (프로토콜 포함 여부)
        if (!urlString.trim().startsWith("http://") && !urlString.trim().startsWith("https://")) {
            logger.error("잘못된 URL 형식: 프로토콜이 없습니다. url={}", urlString);
            throw new IllegalArgumentException("URL 형식 오류: 프로토콜(http:// 또는 https://)이 필요합니다. url=" + urlString);
        }

        URL url;
        try {
            url = new URL(urlString.trim());
        } catch (java.net.MalformedURLException e) {
            logger.error("잘못된 URL 형식: {}", urlString, e);
            throw new IllegalArgumentException("URL 형식 오류: " + e.getMessage() + ", url=" + urlString, e);
        }

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
                // 에러 응답 본문 읽기
                String errorBody = readErrorResponse(conn);
                logger.error("HTTP POST 요청 실패: responseCode={}, url={}", responseCode, urlString);
                logger.error("에러 응답 본문: {}", errorBody);
                
                // 401 Unauthorized 오류인 경우 더 명확한 메시지 제공
                if (responseCode == HttpURLConnection.HTTP_UNAUTHORIZED) {
                    String errorMessage = "포트원 API 인증 실패 (401)";
                    try {
                        // JSON 응답 파싱 시도
                        if (errorBody != null && !errorBody.trim().isEmpty()) {
                            JsonNode errorJson = objectMapper.readTree(errorBody);
                            if (errorJson.has("message")) {
                                errorMessage = "포트원 API 인증 실패: " + errorJson.get("message").asText();
                            } else if (errorJson.has("code")) {
                                errorMessage = "포트원 API 인증 실패: code=" + errorJson.get("code").asInt();
                            }
                        }
                    } catch (Exception e) {
                        // JSON 파싱 실패 시 원본 에러 본문 사용
                        logger.debug("에러 응답 JSON 파싱 실패: {}", e.getMessage());
                    }
                    throw new Exception(errorMessage + " (responseCode: " + responseCode + ", errorBody: " + errorBody + ")");
                }
                
                throw new Exception("HTTP 요청 실패: " + responseCode + " - " + errorBody);
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

    /**
     * HTTP 에러 응답 읽기 (실패 시)
     * ✅ 새로 추가된 메서드
     */
    private String readErrorResponse(HttpURLConnection conn) {
        try {
            // 에러 스트림이 없으면 일반 응답 스트림 시도
            if (conn.getErrorStream() == null) {
                logger.warn("에러 스트림이 없습니다. 일반 응답 스트림을 시도합니다.");
                try (BufferedReader br = new BufferedReader(
                        new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                    StringBuilder response = new StringBuilder();
                    String line;
                    while ((line = br.readLine()) != null) {
                        response.append(line);
                    }
                    return response.toString();
                } catch (Exception e) {
                    return "No error stream available and failed to read input stream";
                }
            }

            // 에러 스트림에서 응답 읽기
            try (BufferedReader br = new BufferedReader(
                    new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8))) {
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) {
                    response.append(line);
                }
                return response.toString();
            }
        } catch (Exception e) {
            logger.error("에러 응답 읽기 실패: {}", e.getMessage());
            return "에러 응답 읽기 실패: " + e.getMessage();
        }
    }
}