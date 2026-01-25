package com.sanaiclub.contract.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;

/**
 * DeepSeek AI 서비스 구현체
 * 
 * [파일 역할]
 * 이 파일은 ContractAIService 인터페이스의 DeepSeek AI API 구현체입니다.
 * DeepSeek AI API를 사용하여 계약서 초안 생성을 위한 AI 호출을 수행합니다.
 * 
 * [인터페이스 vs 구현체]
 * - ContractAIService (인터페이스): "무엇을" 해야 하는지 정의 (What)
 * - 이 파일 (DeepSeekContractAIServiceImpl): "어떻게" DeepSeek API로 구현할지 정의 (How)
 * 
 * [주요 특징]
 * - @Service 어노테이션으로 Spring 빈으로 등록되어 의존성 주입 가능
 * - @Value로 deepseek-api.properties에서 설정값 주입
 * - RestTemplate을 사용한 HTTP API 호출
 * - DeepSeek Chat API (deepseek-chat 모델) 사용
 * 
 * [설정 파일]
 * - deepseek-api.properties에 다음 설정 필요:
 *   - deepseek.api.url: DeepSeek API 엔드포인트 URL
 *   - deepseek.api.token: DeepSeek API 인증 토큰
 *   - deepseek.api.timeout: API 호출 타임아웃 (기본값: 30000ms)
 * 
 * [설계 패턴]
 * 인터페이스와 구현체를 분리함으로써:
 * - 다른 AI 서비스로 교체 가능 (예: OpenAI, Claude 등)
 * - 단위 테스트 시 Mock 객체 주입 용이
 * - 코드의 유연성과 확장성 향상
 * 
 * [사용 위치]
 * - ContractAutoFillServiceImpl: 계약서 자동 초안 생성 시 호출
 * 
 * @see ContractAIService 이 클래스가 구현하는 인터페이스
 */
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

    /**
     * 기본 생성자
     */
    public DeepSeekContractAIServiceImpl() {
    }

    /**
     * 계약서 초안 생성을 위해 DeepSeek AI API를 호출합니다.
     * 
     * [처리 흐름]
     * 1. API 토큰 검증
     * 2. HTTP 요청 헤더 구성 (Authorization, Content-Type)
     * 3. 요청 바디 구성 (모델, 메시지, 파라미터)
     * 4. DeepSeek API 호출
     * 5. 응답에서 AI 생성 내용 추출
     * 
     * [API 파라미터]
     * - model: "deepseek-chat" (DeepSeek Chat 모델)
     * - temperature: 0.2 (낮은 값으로 일관된 응답 생성)
     * - max_tokens: 1200 (최대 토큰 수 제한)
     * 
     * [응답 구조]
     * {
     *   "choices": [
     *     {
     *       "message": {
     *         "content": "AI가 생성한 계약서 초안 (JSON 문자열)"
     *       }
     *     }
     *   ]
     * }
     * 
     * @param prompt AI에게 전달할 프롬프트
     *               - ContractAutoFillServiceImpl에서 생성한 최종 프롬프트
     *               - 프로젝트 정보, 프리랜서 정보, PDF 텍스트, 사용자 입력 포함
     * @return AI가 생성한 계약서 초안 (JSON 문자열)
     *         - ContractAutoFillDTO 형식의 JSON
     *         - 마크다운 코드블록 포함 가능 (```json ... ```)
     * @throws IllegalStateException API 토큰이 없거나, API 호출 실패, 또는 응답이 비어있을 때
     */
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

    /**
     * DeepSeek AI 서비스의 현재 상태를 반환합니다.
     * 
     * [기능]
     * - 서비스의 가용성 상태를 문자열로 반환
     * - 현재는 "deepseek-live" 고정값 반환
     * 
     * [향후 개선]
     * - 실제 API 헬스체크 호출로 확장 가능
     * - API 키 유효성 검증 추가 가능
     * 
     * @return 서비스 상태 문자열 ("deepseek-live")
     */
    @Override
    public String getServiceStatus() {
        return "deepseek-live";
    }
}
