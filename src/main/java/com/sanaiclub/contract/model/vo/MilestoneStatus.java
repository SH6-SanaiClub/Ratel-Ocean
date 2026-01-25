package com.sanaiclub.contract.model.vo;

public enum MilestoneStatus {

    /** 대기 중 (결제 전) */
    WAITING,

    /** 에스크로에 입금됨 (아직 지급 전) */
    DEPOSITED,

    /** 프리랜서가 지급 요청함 */
    REQUESTED,

    /** 프리랜서에게 지급 완료 */
    PAID,

    /** 취소됨 */
    CANCELED

}