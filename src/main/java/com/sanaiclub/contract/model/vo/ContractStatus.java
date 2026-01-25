package com.sanaiclub.contract.model.vo;


public enum ContractStatus {
    /** 계약 대기 중 (프리랜서 수락 전) */
    WAITING,
    
    /** 계약 서명 완료 (프리랜서 수락) */
    SIGNED,

    /** 클라이언트 결제 완료 (프로젝트 시작 시점) */
    PAID,
    
    /** 계약 취소/거절 */
    TERMINATED,
    
    /** 계약 완료 (결제 완료) */
    COMPLETED,

    // null이나 예외 처리를 위한 상수 추가 - Controller 단에서 오류 해결하기위함
    UNKNOWN
}
