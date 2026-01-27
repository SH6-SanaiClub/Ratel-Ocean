package com.sanaiclub.contract.model.enums;

/** 마일스톤 상태 Enum. 상태 전이: WAITING → REQUESTED → DEPOSITED → PAID. REQUESTED → WAITING (거부 시 재요청 가능). */
public enum MilestoneStatus {
    /** 대기 중 - 아직 지급 요청하지 않음 */
    WAITING,
    
    /** 지급 요청됨 - 프리랜서가 요청, 클라이언트 수락 대기 */
    REQUESTED,
    
    /** 입금 완료 - 클라이언트가 수락, 에스크로에서 출금 대기 */
    DEPOSITED,
    
    /** 지급 완료 - 프리랜서에게 실제 지급 완료 */
    PAID,
    
    /** 취소됨 - 거부 또는 중도 취소 */
    CANCELED
}
