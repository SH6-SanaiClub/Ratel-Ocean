package com.sanaiclub.contract.model.enums;

/**
 * ============================================================================
 * ContractStatus - 계약 상태 Enum
 * ============================================================================
 * 
 * [역할]
 * - 계약의 상태를 나타내는 열거형 상수
 * - 계약 생명주기를 관리하는 데 사용
 * - DB에는 문자열로 저장되지만, Java 코드에서는 타입 안전성 보장
 * 
 * [상태 설명]
 * - WAITING: 계약 대기 중
 *   * 계약 생성 직후의 기본 상태
 *   * 프리랜서가 계약을 검토 중인 상태
 *   * 프리랜서가 수락하면 SIGNED로 변경
 *   * 프리랜서가 거절하면 TERMINATED로 변경
 * 
 * - SIGNED: 계약 서명 완료
 *   * 프리랜서가 계약을 수락한 상태
 *   * 작업을 시작할 수 있는 상태
 *   * 클라이언트가 최종 수락하면 COMPLETED로 변경
 *   * 클라이언트가 취소하면 TERMINATED로 변경
 * 
 * - TERMINATED: 계약 취소/거절
 *   * 프리랜서가 거절하거나 클라이언트가 취소한 상태
 *   * 더 이상 진행할 수 없는 상태
 *   * cancel_reason에 취소/거절 사유 저장
 *   * 복구 불가 (새 계약 생성 필요)
 * 
 * - COMPLETED: 계약 완료
 *   * 결제 완료 및 모든 작업이 완료된 상태
 *   * 계약이 성공적으로 종료된 상태
 *   * 평가 입력 가능 (clientRating, freelancerRating 등)
 *   * 재계약 의향 조사 가능 (clientIsRenewalIntended)
 * 
 * [상태 전이 흐름]
 * WAITING → SIGNED → COMPLETED
 *    ↓         ↓
 * TERMINATED TERMINATED
 * 
 * [사용 위치]
 * - ContractService: 계약 상태 변경 메서드
 * - ContractMapper: 계약 상태 조회 및 업데이트
 * - ContractVO: contractStatus 필드 (문자열로 저장)
 * 
 * [주의사항]
 * - DB에는 name() 값(문자열)으로 저장됨
 * - DB에서 조회할 때는 문자열을 enum으로 변환 필요
 * - 상태 변경은 비즈니스 규칙에 따라 제한됨
 * 
 * ============================================================================
 */
public enum ContractStatus {
    /** 계약 대기 중 (프리랜서 수락 전) */
    WAITING,
    
    /** 계약 서명 완료 (프리랜서 수락) */
    SIGNED,
    
    /** 계약 취소/거절 */
    TERMINATED,
    
    /** 계약 완료 (결제 완료) */
    COMPLETED
}
