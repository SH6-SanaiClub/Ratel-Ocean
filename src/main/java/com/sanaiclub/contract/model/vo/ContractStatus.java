package com.sanaiclub.contract.model.vo;

/** 계약 상태 Enum. 상태 전이: WAITING → SIGNED → PAID → COMPLETED. 각 단계에서 TERMINATED 가능. */
public enum ContractStatus {
    /** 전송됨(검토 대기) - 프리랜서 수락/거절 전 */
    WAITING,
    
    /** 수락됨(계약 성립) - 결제 전 */
    SIGNED,
    
    /** 결제 완료(에스크로 확보) - 마일스톤/정산 활성화 */
    PAID,
    
    /** 정산 완료(모든 마일스톤 종료) - 최종 완료 상태 */
    COMPLETED,
    
    /** 종료(거절/취소/중도 종료 포함) - 복구 불가 */
    TERMINATED
}
