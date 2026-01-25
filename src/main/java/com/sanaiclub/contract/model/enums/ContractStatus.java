package com.sanaiclub.contract.model.enums;

/**
 * ============================================================================
 * ContractStatus - 계약 상태 Enum
 * ============================================================================
 * 
 * [역할]
 * 계약의 생명주기를 관리하는 핵심 Enum입니다.
 * DB에는 문자열로 저장되지만, Java 코드에서는 타입 안전성을 보장합니다.
 * 
 * [연관 파일]
 * - ContractService: 상태 변경 로직 (acceptContract, rejectContract, finalizeContract 등)
 * - ContractVO: contractStatus 필드에 이 Enum의 name() 값 저장
 * - ClientContractManagementController: 상태별 계약 분류 및 UI 표시
 * - FreelancerContractController: 상태별 계약 분류 및 UI 표시
 * - contractMapper.xml: 상태별 조회 쿼리
 * 
 * [상태 전이 흐름]
 * ┌─────────────────────────────────────────────────────────────┐
 * │ 정상 흐름:                                                  │
 * │ WAITING → SIGNED → PAID → COMPLETED                        │
 * │                                                             │
 * │ 비정상 종료 (각 단계에서 가능):                             │
 * │ WAITING → TERMINATED (프리랜서 거절)                       │
 * │ SIGNED → TERMINATED (클라이언트 취소)                      │
 * │ PAID → TERMINATED (중도 종료)                              │
 * └─────────────────────────────────────────────────────────────┘
 * 
 * [상태별 상세 설명]
 * 
 * 1. WAITING (전송됨, 검토 대기)
 *    - 계약 생성 직후의 기본 상태
 *    - 프리랜서가 계약서를 검토 중인 상태
 *    - 프리랜서가 수락하면 → SIGNED
 *    - 프리랜서가 거절하면 → TERMINATED (cancel_reason에 "[거절] {사유}" 저장)
 *    - 관련 메서드: ContractService.acceptContract(), rejectContract()
 * 
 * 2. SIGNED (수락됨, 계약 성립)
 *    - 프리랜서가 계약을 수락한 상태
 *    - 클라이언트가 결제하기 전 상태
 *    - 클라이언트가 결제하면 → PAID
 *    - 클라이언트가 취소하면 → TERMINATED (cancel_reason에 "[취소] {사유}" 저장)
 *    - 관련 메서드: ContractService.finalizeContract(), cancelContract()
 * 
 * 3. PAID (결제 완료, 에스크로 확보)
 *    - 클라이언트가 전체 예산을 에스크로에 입금한 상태
 *    - 마일스톤/일시지급 지급 요청이 활성화된 상태
 *    - 프리랜서가 지급 요청 → 마일스톤 상태 변경 또는 cancel_reason에 "[지급요청]" 저장
 *    - 클라이언트가 지급 수락 → 마일스톤 DEPOSITED 또는 계약 COMPLETED
 *    - 모든 마일스톤 완료 시 → COMPLETED
 *    - 중도 종료 시 → TERMINATED
 *    - 관련 메서드: ContractService.requestPayment(), approvePayment(), rejectPayment()
 * 
 * 4. COMPLETED (정산 완료)
 *    - 모든 마일스톤이 완료되고 정산이 완료된 상태
 *    - 계약이 성공적으로 종료된 상태
 *    - 더 이상 상태 변경 불가 (최종 상태)
 *    - 평가 입력 가능 (clientRating, freelancerRating 등)
 *    - 재계약 의향 조사 가능 (clientIsRenewalIntended)
 *    - 관련 메서드: ContractService.completeContract(), approvePayment() (일시지급)
 * 
 * 5. TERMINATED (종료)
 *    - 거절/취소/중도 종료된 상태
 *    - 더 이상 진행할 수 없는 상태 (복구 불가)
 *    - cancel_reason에 종료 사유 저장:
 *      * "[거절] {사유}": 프리랜서가 거절
 *      * "[취소] {사유}": 클라이언트가 취소
 *      * 기타: 중도 종료
 *    - 관련 메서드: ContractService.rejectContract(), cancelContract()
 * 
 * [특수 케이스: cancel_reason 활용]
 * DB 스키마 변경 없이 일시지급 지급 요청 상태를 관리하기 위해 cancel_reason 컬럼을 재활용합니다.
 * 
 * - cancel_reason = "[지급요청]": 일시지급 계약에서 프리랜서가 지급 요청한 상태
 * - cancel_reason = null: 일시지급 계약에서 아직 지급 요청하지 않은 상태
 * - cancel_reason = "[거절] {사유}": 프리랜서가 계약을 거절한 상태
 * - cancel_reason = "[취소] {사유}": 클라이언트가 계약을 취소한 상태
 * 
 * 이는 ContractService.requestPayment(), approvePayment(), rejectPayment()에서 활용됩니다.
 * 
 * [주의사항]
 * - DB에는 name() 값(문자열)으로 저장됨: "WAITING", "SIGNED", "PAID", "COMPLETED", "TERMINATED"
 * - DB에서 조회할 때는 문자열을 enum으로 변환 필요
 * - 상태 변경은 비즈니스 규칙에 따라 제한됨 (ContractService에서 검증)
 * - 상태 전이는 단방향이며, 이전 상태로 되돌릴 수 없음 (TERMINATED 제외)
 * 
 * ============================================================================
 */
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
