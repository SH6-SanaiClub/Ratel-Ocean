package com.sanaiclub.common.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

/**
 * WebSocket 및 STOMP 메시지 브로커 설정
 */
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // 클라이언트에서 연결할 엔드포인트: /ws-stomp
        // withSockJS()를 통해 WebSocket 미지원 브라우저에서도 폴백 지원
        registry.addEndpoint("/ws-stomp")
                .setAllowedOriginPatterns("*") // 개발 편의상 전체 허용 (배포 시 도메인 지정 권장)
                .withSockJS();
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        // 메시지 구독 요청 prefix (받기): /sub
        registry.enableSimpleBroker("/sub");

        // 메시지 발행 요청 prefix (보내기): /pub
        registry.setApplicationDestinationPrefixes("/pub");
    }
}