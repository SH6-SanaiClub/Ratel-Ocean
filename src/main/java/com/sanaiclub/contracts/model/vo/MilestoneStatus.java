package com.sanaiclub.contracts.model.vo;

public enum MilestoneStatus {
    WAITING,    // 대기중
    DEPOSITED,  // 결제 완료 (예치됨)
    REQUESTED,  // 지급 요청함
    PAID,       // 지급 완료
    CANCELED    // 취소된 단계
}