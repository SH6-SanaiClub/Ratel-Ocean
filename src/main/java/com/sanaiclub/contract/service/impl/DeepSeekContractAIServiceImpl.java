package com.sanaiclub.contract.service.impl;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.sanaiclub.contract.service.ContractAIService;

import java.util.*;

/** DeepSeek AI 서비스 구현체. DeepSeek Chat API를 사용한 계약서 초안 생성. */
@Service
public class DeepSeekContractAIServiceImpl implements ContractAIService {

    private static final Logger logger = LoggerFactory.getLogger(DeepSeekContractAIServiceImpl.class);

    /** DeepSeek API 엔드포인트 URL (deepseek-api.properties에서 주입) */
    @Value("${deepseek.api.url}")
    private String apiUrl;

    /** DeepSeek API 인증 토큰 (deepseek-api.properties에서 주입) */
    @Value("${deepseek.api.token}")
    private String apiToken;

    /** API 호출 타임아웃 (밀리초, 기본값: 30000ms) */
    @Value("${deepseek.api.timeout:30000}")
    private int timeout;

    /** HTTP API 호출을 위한 RestTemplate 인스턴스 */
    private final RestTemplate restTemplate = new RestTemplate();

    public DeepSeekContractAIServiceImpl() {
    }

    /** 계약서 초안 생성을 위해 DeepSeek AI API 호출. deepseek-chat 모델 사용. */
    @Override
    public String requestContractDraft(String prompt) {
        // 토큰 검증
        if (apiToken == null || apiToken.trim().isEmpty()) {
            logger.error("DeepSeek API 토큰이 설정되지 않았습니다. deepseek-api.properties 파일을 확인하세요.");
            throw new IllegalStateException("DeepSeek API 토큰 없음");
        }

        // Bearer 토큰 형식으로 변환
        String token = "Bearer " + apiToken.trim();

        // HTTP 요청 헤더 구성
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("Authorization", token);

        // 메시지 구성 (DeepSeek API 형식)
        Map<String, Object> message = new HashMap<String, Object>();
        message.put("role", "user");
        message.put("content", prompt);

        List<Map<String, Object>> messages = new ArrayList<Map<String, Object>>();
        messages.add(message);

        // 요청 바디 구성
        Map<String, Object> body = new HashMap<String, Object>();
        body.put("model", "deepseek-chat");
        body.put("messages", messages);
        body.put("temperature", 0.2);  // 낮은 값으로 일관된 응답 생성
        body.put("max_tokens", 1200);  // 최대 토큰 수 제한

        HttpEntity<Map<String, Object>> request =
                new HttpEntity<Map<String, Object>>(body, headers);

        // DeepSeek API 호출
        ResponseEntity<Map> response = restTemplate.exchange(
                apiUrl,
                HttpMethod.POST,
                request,
                Map.class
        );

        // HTTP 상태 코드 확인
        if (!response.getStatusCode().is2xxSuccessful()) {
            throw new IllegalStateException("DeepSeek API 호출 실패");
        }

        // 응답에서 AI 생성 내용 추출
        Map responseBody = response.getBody();
        List choices = (List) responseBody.get("choices");

        if (choices == null || choices.isEmpty()) {
            throw new IllegalStateException("AI 응답 없음");
        }

        Map choice = (Map) choices.get(0);
        Map messageMap = (Map) choice.get("message");

        return (String) messageMap.get("content");
    }

    /** DeepSeek AI 서비스 상태 반환. */
    @Override
    public String getServiceStatus() {
        return "deepseek-live";
    }
}
