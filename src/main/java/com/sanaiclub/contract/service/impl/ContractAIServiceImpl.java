package com.sanaiclub.contract.service.impl;

import com.sanaiclub.contract.service.ContractAIService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;

@Service
@RequiredArgsConstructor
public class ContractAIServiceImpl implements ContractAIService {

    private static final Logger logger = LoggerFactory.getLogger(ContractAIServiceImpl.class);

    @Value("${deepseek.api.url}")
    private String apiUrl;

    @Value("${deepseek.api.token}")
    private String apiToken;

    @Value("${deepseek.api.timeout:30000}")
    private int timeout;

    private final RestTemplate restTemplate;

    @Override
    public String requestContractDraft(String prompt) {
        // 토큰 검증
        if (apiToken == null || apiToken.trim().isEmpty()) {
            logger.error("DeepSeek API 토큰이 설정되지 않았습니다. deepseek-api.properties 파일을 확인하세요.");
            throw new IllegalStateException("DeepSeek API 토큰 없음");
        }

        // Bearer 토큰 형식으로 변환
        String token = "Bearer " + apiToken.trim();

        // Header
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("Authorization", token);

        // messages 구성 (Java 11 방식)
        Map<String, Object> message = new HashMap<String, Object>();
        message.put("role", "user");
        message.put("content", prompt);

        List<Map<String, Object>> messages = new ArrayList<Map<String, Object>>();
        messages.add(message);

        Map<String, Object> body = new HashMap<String, Object>();
        body.put("model", "deepseek-chat");
        body.put("messages", messages);
        body.put("temperature", 0.2);
        body.put("max_tokens", 1200);

        HttpEntity<Map<String, Object>> request =
                new HttpEntity<Map<String, Object>>(body, headers);

        //  API 호출
        ResponseEntity<Map> response = restTemplate.exchange(
                apiUrl,
                HttpMethod.POST,
                request,
                Map.class
        );

        if (!response.getStatusCode().is2xxSuccessful()) {
            throw new IllegalStateException("DeepSeek API 호출 실패");
        }

        //  content 추출
        Map responseBody = response.getBody();
        List choices = (List) responseBody.get("choices");

        if (choices == null || choices.isEmpty()) {
            throw new IllegalStateException("AI 응답 없음");
        }

        Map choice = (Map) choices.get(0);
        Map messageMap = (Map) choice.get("message");

        return (String) messageMap.get("content");
    }

    @Override
    public String getServiceStatus() {
        return "deepseek-live";
    }
}
