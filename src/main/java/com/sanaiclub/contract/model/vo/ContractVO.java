package com.sanaiclub.contract.model.vo;

import lombok.Builder;
import lombok.Getter;

/**
 * ============================================================================
 * ContractVO - 계약 Value Object (DB 엔티티)
 * ============================================================================
 * 
 * [역할]
 * contracts 테이블과 1:1 매핑되는 불변 객체입니다.
 * DB에서 조회한 계약 데이터를 Java 객체로 표현하며, Builder 패턴을 사용하여
 * 불변성을 보장합니다. 모든 필드는 final로 선언되어 한 번 생성되면 변경할 수 없습니다.
 * 
 * [연관 파일]
 * 
 * DAO 계층:
 * - ContractMapper: contracts 테이블 CRUD 작업
 * - ContractMapper.selectContractById(): 계약 단건 조회
 * - ContractMapper.insertContract(): 계약 생성
 * - ContractMapper.updateContract(): 계약 수정
 * - ContractMapper.updateContractStatus(): 계약 상태 변경
 * 
 * Service 계층:
 * - ContractService: ContractVO를 사용하여 비즈니스 로직 처리
 * - ContractService.createContract(): DTO → VO 변환 후 저장
 * - ContractService.getContractById(): VO → DTO 변환
 * 
 * DTO 계층:
 * - ContractResponseDTO: Service → Controller 전달용 DTO
 * - ContractDetailDTO: JOIN 결과를 담는 DTO (ContractVO 포함)
 * 
 * [DB 테이블 구조]
 * 테이블명: contracts
 * 
 * 주요 컬럼:
 * - contract_id (PK, AUTO_INCREMENT): 계약 고유 ID
 * - contract_start_date (DATE): 계약 시작일
 * - contract_end_date (DATE): 계약 종료일
 * - total_budget (BIGINT): 총 예산 (원 단위)
 * - payment_method (VARCHAR): 결제 방식 ("MILESTONE" 또는 "FIXED"/"FULL")
 * - contract_status (VARCHAR): 계약 상태 (ContractStatus enum의 name() 값)
 * - origin_contract_url (VARCHAR): 원본 계약서 파일 경로
 *   * 형식: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
 *   * 예: "contracts/1/100/50/contract_20240101.pdf"
 * - platform_contract_url (VARCHAR): 플랫폼 생성 계약서 경로
 * - ai_report_url (VARCHAR): AI 분석 리포트 경로
 * - contracted_at (DATETIME): 계약 체결 시각
 * - completed_at (DATETIME): 계약 완료 시각
 * - cancel_reason (VARCHAR): 취소/거절 사유 (특수 용도: 일시지급 지급 요청 상태)
 * - client_rating (INT): 클라이언트 평점 (1~5)
 * - client_experience (TEXT): 클라이언트 경험 평가
 * - client_is_renewal_intended (BOOLEAN): 재계약 의향
 * - freelancer_rating (INT): 프리랜서 평점 (1~5)
 * - freelancer_experience (TEXT): 프리랜서 경험 평가
 * 
 * [특수 필드: cancel_reason 활용]
 * 
 * DB 스키마 변경 없이 일시지급 지급 요청 상태를 관리하기 위해 cancel_reason 컬럼을
 * 재활용합니다. 이는 기존 컬럼을 활용하여 새로운 기능을 구현하는 효율적인 방법입니다.
 * 
 * cancel_reason 값에 따른 의미:
 * 
 * 1. null: 기본 상태
 *    - 일시지급 계약: 아직 지급 요청하지 않은 상태
 *    - 일반 계약: 취소/거절되지 않은 정상 상태
 * 
 * 2. "[지급요청]": 일시지급 지급 요청 상태
 *    - 일시지급 계약에서만 사용
 *    - 프리랜서가 지급 요청한 상태
 *    - 클라이언트가 수락/거부할 수 있음
 *    - ContractService.requestPayment()에서 설정
 *    - ContractService.approvePayment()에서 null로 초기화
 *    - ContractService.rejectPayment()에서 null로 초기화 (재요청 가능)
 * 
 * 3. "[거절] {사유}": 프리랜서 거절 상태
 *    - 프리랜서가 계약을 거절한 상태
 *    - ContractService.rejectContract()에서 설정
 *    - 계약 상태: TERMINATED
 * 
 * 4. "[취소] {사유}": 클라이언트 취소 상태
 *    - 클라이언트가 계약을 취소한 상태
 *    - ContractService.cancelContract()에서 설정
 *    - 계약 상태: TERMINATED
 * 
 * [불변성 보장]
 * 
 * - 모든 필드는 final로 선언되어 한 번 생성되면 변경할 수 없음
 * - Builder 패턴을 사용하여 객체 생성
 * - setter 메서드 없음 (불변 객체)
 * - 데이터 일관성 보장
 * 
 * [사용 패턴]
 * 
 * 1. DB 조회 시:
 *    - ContractMapper에서 조회한 데이터를 ContractVO.builder()로 생성
 *    - MyBatis resultMap을 통해 자동 매핑
 * 
 * 2. DB 저장 시:
 *    - ContractService에서 DTO → VO 변환
 *    - ContractMapper.insertContract() 또는 updateContract() 호출
 * 
 * 3. Service 계층에서:
 *    - ContractVO를 사용하여 비즈니스 로직 처리
 *    - VO → DTO 변환하여 Controller에 전달
 * 
 * [주의사항]
 * 
 * - contractId는 AUTO_INCREMENT로 자동 생성됨 (INSERT 시)
 * - contractStatus는 ContractStatus enum의 name() 값 (문자열)으로 저장
 * - originContractUrl은 파일 경로 패턴을 따름 (필터링 및 권한 검증에 사용)
 * - cancel_reason은 여러 용도로 사용되므로 값 확인 시 주의 필요
 * - 모든 날짜/시간 필드는 문자열로 저장 (DB에서 문자열로 조회)
 * 
 * [데이터 타입]
 * 
 * - contractId: Integer (PK, null 불가)
 * - 날짜 필드: String (DB에서 문자열로 조회, "YYYY-MM-DD" 형식)
 * - 시간 필드: String (DB에서 문자열로 조회, "YYYY-MM-DD HH:mm:ss" 형식)
 * - totalBudget: Long (원 단위, 큰 금액 처리)
 * - 평점 필드: Integer (1~5 범위)
 * - 불린 필드: Boolean (null 가능)
 * 
 * ============================================================================
 */
@Getter
@Builder
public class ContractVO {
    private final Integer contractId;
    private final String contractStartDate;
    private final String contractEndDate;
    private final Long totalBudget;
    private final String paymentMethod;
    private final String contractStatus;
    private final String originContractUrl;
    private final String platformContractUrl;
    private final String aiReportUrl;
    private final String contractedAt;
    private final String completedAt;
    private final String cancelReason;
    private final Integer clientRating;
    private final String clientExperience;
    private final Boolean clientIsRenewalIntended;
    private final Integer freelancerRating;
    private final String freelancerExperience;
}
