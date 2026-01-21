package com.sanaiclub.contract.service;

import com.sanaiclub.contract.dao.ApiTokenDao;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;

@Service
public class DeepSeekContractAIServiceImpl implements ContractAIService {

    private static final String API_URL =
            "https://api.deepseek.com/v1/chat/completions";

    private static final String SERVICE_NAME = "DEEPSEEK";

    private final RestTemplate restTemplate = new RestTemplate();
    private final ApiTokenDao apiTokenDao;

    public DeepSeekContractAIServiceImpl(ApiTokenDao apiTokenDao) {
        this.apiTokenDao = apiTokenDao;
    }

    @Override
    public String requestContractDraft(String prompt) {

        // 1️⃣ 토큰 조회
        String token = apiTokenDao.findActiveTokenByServiceName(SERVICE_NAME);
        if (token == null || token.trim().isEmpty()) {
            throw new IllegalStateException("DeepSeek API 토큰 없음");
        }

        // 2️⃣ Header
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("Authorization", token);

        // 3️⃣ messages 구성 (Java 11 방식)
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

        // 4️⃣ API 호출
        ResponseEntity<Map> response = restTemplate.exchange(
                API_URL,
                HttpMethod.POST,
                request,
                Map.class
        );

        if (!response.getStatusCode().is2xxSuccessful()) {
            throw new IllegalStateException("DeepSeek API 호출 실패");
        }

        // 5️⃣ content 추출
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
