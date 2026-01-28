package com.sanaiclub.project.model.vo;

import lombok.Getter;

@Getter
public enum ApplicationStatus {
    PENDING("미열람"),      // 지원 완료 (대기중)
    VIEWED("열람함"),       // 클라이언트가 확인
    CHATTING("대화중"),     // 채팅 진행 중
    OFFERED("계약제안"),    // 계약 제안 받음
    CONTRACTED("계약완료"), // 최종 계약 성사
    REJECTED("불합격"),     // 거절됨
    CANCELED("지원취소");   // 지원 취소

    private final String description;

    ApplicationStatus(String description) {
        this.description = description;
    }
}