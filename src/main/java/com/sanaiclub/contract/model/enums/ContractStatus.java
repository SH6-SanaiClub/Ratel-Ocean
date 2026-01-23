package com.sanaiclub.contract.model.enums;

/**
 * ContractStatus - 계약 상태 Enum
 */
public enum ContractStatus {
    WAITING,    // 대기(프리랜서 수락 전)
    SIGNED,     // 프리랜서 수락
    TERMINATED, // 거절/파기
    COMPLETED   // 완료
}
