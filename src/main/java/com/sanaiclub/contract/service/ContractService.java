package com.sanaiclub.contract.service;

import com.sanaiclub.contract.model.vo.*;
import com.sanaiclub.contract.model.dto.*;
import com.sanaiclub.contract.model.enums.ContractStatus;
import com.sanaiclub.contract.dao.ContractMapper;
import com.sanaiclub.contract.dao.ContractMilestoneMapper;
import com.sanaiclub.common.util.AuthContext;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * ============================================================================
 * ContractService - 계약 비즈니스 로직 서비스
 * ============================================================================
 * 
 * [역할]
 * 계약 도메인의 모든 비즈니스 로직을 처리하는 서비스 계층입니다.
 * 계약 CRUD 작업, 상태 관리, 지급 요청/수락/거부 등을 담당하며,
 * DB 스키마 변경 없이 cancel_reason 컬럼을 재활용하여 일시지급 지급 요청 상태를 관리합니다.
 * 
 * [연관 파일]
 * 
 * Controller 계층:
 * - ClientContractManagementController: 클라이언트 계약 관리 (결제, 지급 수락/거부)
 * - FreelancerContractController: 프리랜서 계약 관리 (수락, 거절, 지급 요청)
 * - ContractFormController: 계약 생성/수정 폼 처리
 * - ContractApiController: REST API 엔드포인트
 * 
 * DAO 계층:
 * - ContractMapper: 계약 데이터 접근 (contracts 테이블)
 * - ContractMilestoneMapper: 마일스톤 데이터 접근 (contract_milestones 테이블)
 * 
 * Model 계층:
 * - ContractVO: 계약 엔티티 (DB 매핑)
 * - ContractMilestoneVO: 마일스톤 엔티티 (DB 매핑)
 * - ContractResponseDTO: 계약 응답 DTO (마일스톤 집계 포함)
 * - ContractDetailDTO: 계약 상세 정보 DTO (JOIN 결과)
 * - ContractStatus: 계약 상태 Enum
 * 
 * View 계층:
 * - contractManagement.jsp: 클라이언트 계약 관리 페이지
 * - freelancerContractList.jsp: 프리랜서 계약 목록 페이지
 * - includes/statusTitlePaid.jsp: PAID 상태 집계 (클라이언트용)
 * - includes/statusTitlePaidFreelancer.jsp: PAID 상태 집계 (프리랜서용)
 * - includes/statusTitleSettlementPending.jsp: SETTLEMENT_PENDING 상태 집계
 * 
 * [계약 상태 관리]
 * ContractStatus Enum을 사용하여 계약의 생명주기를 관리합니다.
 * 
 * - WAITING: 전송됨(검토 대기) - 프리랜서 수락/거절 전
 * - SIGNED: 수락됨(계약 성립) - 결제 전
 * - PAID: 결제 완료(에스크로 확보) - 마일스톤/정산 활성화
 * - COMPLETED: 정산 완료(모든 마일스톤 종료)
 * - TERMINATED: 종료(거절/취소/중도 종료 포함)
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
 * [주요 기능]
 * 
 * 1. 계약 생성/수정
 *    - createContract: 새 계약 생성 (INSERT) + 마일스톤 저장
 *    - updateContract: 기존 계약 수정 (UPDATE) + 마일스톤 삭제/추가
 * 
 * 2. 계약 조회
 *    - getContractById: 계약 ID로 단건 조회 (마일스톤 포함)
 *    - getContractByPathPattern: 경로 패턴으로 기존 계약 조회 (UPDATE vs INSERT 판단)
 *    - getContractsByClientPathPattern: 클라이언트의 계약 목록 조회
 *    - getAllContracts: 모든 계약 목록 조회 (마일스톤 집계 포함)
 * 
 * 3. 계약 상태 변경
 *    - acceptContract: 프리랜서 계약 수락 (WAITING → SIGNED)
 *    - rejectContract: 프리랜서 계약 거절 (WAITING → TERMINATED, cancel_reason에 "[거절] {사유}" 저장)
 *    - finalizeContract: 계약 결제 완료 (SIGNED → PAID, 에스크로 확보)
 *    - completeContract: 계약 정산 완료 (PAID → COMPLETED)
 *    - cancelContract: 계약 취소 (WAITING/SIGNED/PAID → TERMINATED, cancel_reason에 "[취소] {사유}" 저장)
 * 
 * 4. 지급 요청/수락/거부 (에스크로 시스템)
 *    - requestPayment: 프리랜서 지급 요청
 *      * 마일스톤: 마일스톤 상태 WAITING → REQUESTED
 *      * 일시지급: cancel_reason에 "[지급요청]" 저장 (DB 스키마 변경 없이 기존 컬럼 활용)
 *    - approvePayment: 클라이언트 지급 수락
 *      * 마일스톤: 마일스톤 상태 REQUESTED → DEPOSITED
 *      * 일시지급: 계약 상태 PAID → COMPLETED, cancel_reason을 null로 초기화
 *    - rejectPayment: 클라이언트 지급 거부
 *      * 마일스톤: 마일스톤 상태 REQUESTED → WAITING (재요청 가능)
 *      * 일시지급: cancel_reason을 null로 초기화 (재요청 가능)
 * 
 * 5. 마일스톤 관리
 *    - getMilestonesByContractId: 계약의 마일스톤 목록 조회
 * 
 * 6. 파일 경로 관리
 *    - updateOriginContractUrl: 원본 계약서 파일 경로 업데이트
 *    - getOriginContractUrlsByPathPattern: 경로 패턴으로 파일 경로 목록 조회
 * 
 * [특수 구현: cancel_reason 활용]
 * DB 스키마 변경 없이 일시지급 지급 요청 상태를 관리하기 위해 cancel_reason 컬럼을 재활용합니다.
 * 
 * - cancel_reason = null: 일시지급 계약에서 아직 지급 요청하지 않은 상태
 * - cancel_reason = "[지급요청]": 일시지급 계약에서 프리랜서가 지급 요청한 상태
 * - cancel_reason = "[거절] {사유}": 프리랜서가 계약을 거절한 상태
 * - cancel_reason = "[취소] {사유}": 클라이언트가 계약을 취소한 상태
 * 
 * 이는 requestPayment(), approvePayment(), rejectPayment() 메서드에서 활용됩니다.
 * 
 * [데이터 흐름]
 * Controller → Service → Mapper → DB
 * 
 * [계층별 책임]
 * - Controller: HTTP 요청/응답 처리, 파라미터 검증, 뷰 선택
 * - Service: 비즈니스 로직, 트랜잭션 관리, VO ↔ DTO 변환
 * - Mapper: SQL 쿼리 실행, DB 접근
 * 
 * [트랜잭션 처리]
 * - @Transactional 어노테이션으로 트랜잭션 관리
 * - createContract, updateContract: 여러 테이블 작업이 모두 성공해야 커밋
 * - requestPayment, approvePayment, rejectPayment: 상태 변경이 모두 성공해야 커밋
 * - 예외 발생 시 자동 롤백
 * 
 * [책임 분리 원칙]
 * ✅ 여러 Mapper 조합: ContractMapper + ContractMilestoneMapper
 * ✅ 상태 변경 및 트랜잭션 처리: @Transactional 사용
 * ✅ VO ↔ DTO 변환: Service 계층 책임
 * ✅ 비즈니스 로직: Service 계층에만 존재
 * ❌ SQL 직접 호출 금지: Mapper를 통해서만 DB 접근
 * ❌ 다른 도메인 내부 로직 침범 금지: contract 도메인만 담당
 * ❌ HTTP 관련 처리 금지: Controller 계층 책임
 * 
 * [의존성]
 * - ContractMapper: 계약 데이터 접근 (contracts 테이블)
 * - ContractMilestoneMapper: 마일스톤 데이터 접근 (contract_milestones 테이블)
 * 
 * ============================================================================
 */
@Service
public class ContractService {

    private static final Logger logger = LoggerFactory.getLogger(ContractService.class);

    private final ContractMapper contractMapper;
    private final ContractMilestoneMapper contractMilestoneMapper;

    /**
     * 생성자 주입 (Constructor Injection)
     * 
     * [의존성 주입 방식]
     * - Spring의 생성자 주입 방식 사용
     * - final 필드로 불변성 보장
     * - 테스트 시 Mock 객체 주입 용이
     * 
     * [의존성]
     * @param contractMapper 계약 Mapper (contracts 테이블 전용)
     *                       - 계약 CRUD 작업 담당
     * @param contractMilestoneMapper 마일스톤 Mapper (contract_milestones 테이블 전용)
     *                                 - 마일스톤 CRUD 작업 담당
     */
    public ContractService(
            ContractMapper contractMapper,
            ContractMilestoneMapper contractMilestoneMapper
    ) {
        this.contractMapper = contractMapper;
        this.contractMilestoneMapper = contractMilestoneMapper;
    }

    /**
     * 계약 생성 (INSERT)
     * 
     * [기능]
     * - 새로운 계약을 데이터베이스에 저장
     * - 계약 상태는 기본값 WAITING으로 설정
     * - contracted_at은 현재 시간으로 자동 설정
     * - 결제 방식이 MILESTONE인 경우 마일스톤 정보도 함께 저장
     * 
     * [처리 흐름]
     * 1. DTO → VO 변환
     *    - ContractCreateRequestDTO를 ContractVO로 변환
     *    - 계약 상태가 없으면 기본값 WAITING 설정
     *    - contracted_at은 현재 시간으로 설정
     * 
     * 2. 계약 정보 저장
     *    - MyBatis의 selectKey를 통해 contractId 자동 생성
     *    - resultMap에 생성된 contractId 저장
     * 
     * 3. 마일스톤 저장 (조건부)
     *    - milestones가 존재하고 비어있지 않을 때만 실행
     *    - 각 마일스톤을 순회하며 저장
     *    - 결제 방식이 FIXED인 경우 마일스톤 없음
     * 
     * [트랜잭션]
     * - @Transactional: 계약 저장과 마일스톤 저장이 모두 성공해야 커밋
     * - 중간에 예외 발생 시 모든 작업 롤백
     * - 데이터 일관성 보장
     * 
     * [주의사항]
     * - contractId는 AUTO_INCREMENT로 자동 생성됨
     * - 마일스톤의 amount 합계가 totalBudget과 일치해야 함 (비즈니스 로직 검증 필요)
     * - originContractUrl은 파일 업로드 후 별도로 업데이트 가능
     * 
     * [호출 위치]
     * - ContractFormController: 계약서 작성 완료 후 저장
     * - ContractApiController: API를 통한 계약 생성
     * 
     * @param dto 계약 생성 요청 DTO
     *            - contractStartDate, contractEndDate: 계약 기간
     *            - totalBudget: 총 예산
     *            - paymentMethod: 결제 방식 (MILESTONE 또는 FIXED)
     *            - milestones: 마일스톤 목록 (MILESTONE 타입일 때)
     * @return 생성된 계약 ID (Integer)
     *         - null이 될 수 없음 (INSERT 성공 시 항상 ID 반환)
     */
    @Transactional
    public Integer createContract(ContractCreateRequestDTO dto) {
        // ====================================================================
        // 1단계: DTO → VO 변환
        // ====================================================================
        
        // 계약 상태 설정: DTO에 상태가 없으면 기본값 WAITING 사용
        // WAITING은 계약 생성 직후의 기본 상태 (프리랜서 수락 대기)
        String contractStatus = dto.getContractStatus() != null 
            ? dto.getContractStatus() 
            : ContractStatus.WAITING.name();
        
        // 계약 체결 시각 설정: 현재 시간을 문자열로 변환
        // 형식: "YYYY-MM-DD HH:mm:ss" (예: "2024-01-01 12:00:00")
        // LocalDateTime을 문자열로 변환 후 'T'를 공백으로 치환
        String contractedAt = java.time.LocalDateTime.now()
            .toString()
            .substring(0, 19)
            .replace('T', ' ');
        
        // ContractVO 객체 생성 (Builder 패턴 사용)
        ContractVO contract = ContractVO.builder()
            .contractStartDate(dto.getContractStartDate())      // 계약 시작일
            .contractEndDate(dto.getContractEndDate())          // 계약 종료일
            .totalBudget(dto.getTotalBudget())                  // 총 예산
            .paymentMethod(dto.getPaymentMethod())              // 결제 방식
            .contractStatus(contractStatus)                      // 계약 상태 (기본값: WAITING)
            .originContractUrl(dto.getOriginContractUrl())      // 원본 계약서 경로 (선택)
            .contractedAt(contractedAt)                          // 계약 체결 시각
            .build();
        
        // ====================================================================
        // 2단계: 계약 정보 저장
        // ====================================================================
        
        // MyBatis의 selectKey를 통해 자동 생성된 contractId를 받기 위한 Map
        // insertContract 메서드가 실행되면 resultMap의 "contractId" 키에 생성된 ID가 저장됨
        java.util.Map<String, Object> resultMap = new java.util.HashMap<>();
        contractMapper.insertContract(contract, resultMap);
        
        // 생성된 계약 ID 추출
        // resultMap에서 "contractId" 키로 저장된 값을 가져옴
        Integer contractId = (Integer) resultMap.get("contractId");
        
        // ====================================================================
        // 3단계: 마일스톤 저장 (조건부)
        // ====================================================================
        
        // 마일스톤 저장 조건:
        // 1. milestones가 null이 아니고
        // 2. milestones가 비어있지 않고
        // 3. contractId가 정상적으로 생성되었을 때
        // 
        // 결제 방식이 MILESTONE인 경우에만 마일스톤이 존재함
        // 결제 방식이 FIXED인 경우 마일스톤 없음
        if (dto.getMilestones() != null && !dto.getMilestones().isEmpty() && contractId != null) {
            // 각 마일스톤을 순회하며 저장
            for (ContractMilestoneRequestDTO milestoneDto : dto.getMilestones()) {
                contractMilestoneMapper.insertMilestone(
                    contractId,                                 // 계약 ID (FK)
                    milestoneDto.getStep(),                    // 단계 순서 (1, 2, 3, ...)
                    milestoneDto.getTitle(),                   // 마일스톤 제목
                    milestoneDto.getDescription(),             // 작업 범위/설명
                    milestoneDto.getAmount()                   // 해당 마일스톤의 결제 금액
                );
            }
        }
        
        // 생성된 계약 ID 반환
        // Controller에서 이 ID를 사용하여 계약 상세 페이지로 리다이렉트하거나 응답
        return contractId;
    }

    /**
     * 계약 단건 조회
     * 
     * [기능]
     * - 계약 ID로 계약의 상세 정보를 조회
     * - 계약 정보와 함께 마일스톤 정보도 함께 조회
     * 
     * [처리 흐름]
     * 1. 계약 정보 조회 (contracts 테이블)
     * 2. 계약이 없으면 null 반환
     * 3. VO → DTO 변환
     * 4. 마일스톤 정보 조회 및 변환 (contract_milestones 테이블)
     * 5. 요구사항 빈 리스트로 초기화 (DB에 저장되지 않는 필드)
     * 
     * [반환 데이터]
     * - 계약 기본 정보 (기간, 예산, 상태 등)
     * - 마일스톤 목록 (결제 방식이 MILESTONE인 경우)
     * - 파일 경로 정보 (originContractUrl, platformContractUrl, aiReportUrl)
     * - 프로젝트 ID, 프리랜서 ID (originContractUrl에서 추출)
     * 
     * [주의사항]
     * - contractId가 존재하지 않으면 null 반환 (예외 발생하지 않음)
     * - 마일스톤이 없어도 계약 정보는 반환됨 (결제 방식이 FIXED인 경우)
     * - requirements 필드는 DB에 저장되지 않으므로 항상 빈 리스트
     * 
     * [호출 위치]
     * - ContractFormController: 계약 상세 페이지 로드
     * - ContractApiController: API로 계약 정보 요청
     * 
     * @param contractId 조회할 계약의 ID (PK)
     * @return ContractResponseDTO 객체 (계약 상세 정보)
     *         - 계약이 없으면 null 반환
     */
    public ContractResponseDTO getContractById(Integer contractId) {
        // ====================================================================
        // 1단계: 계약 정보 조회 (프로젝트 및 상대방 정보 포함)
        // ====================================================================
        
        java.util.Map<String, Object> contractWithDetails = contractMapper.selectContractWithDetailsById(contractId);
        if (contractWithDetails == null || contractWithDetails.get("contractId") == null) {
            // 계약이 존재하지 않으면 null 반환
            // Controller에서 404 에러 처리 또는 적절한 응답 반환
            return null;
        }
        
        // 날짜를 String으로 변환하는 헬퍼 메서드
        java.util.function.Function<Object, String> dateToString = (obj) -> {
            if (obj == null) return null;
            if (obj instanceof String) return (String) obj;
            if (obj instanceof java.sql.Date) return obj.toString();
            if (obj instanceof java.sql.Timestamp) return obj.toString();
            if (obj instanceof java.util.Date) {
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
                return sdf.format((java.util.Date) obj);
            }
            return obj.toString();
        };
        
        // ContractVO Builder로 생성
        ContractVO contract = ContractVO.builder()
            .contractId(contractWithDetails.get("contractId") != null ? ((Number) contractWithDetails.get("contractId")).intValue() : null)
            .contractStartDate(dateToString.apply(contractWithDetails.get("contractStartDate")))
            .contractEndDate(dateToString.apply(contractWithDetails.get("contractEndDate")))
            .totalBudget(contractWithDetails.get("totalBudget") != null ? ((Number) contractWithDetails.get("totalBudget")).longValue() : null)
            .paymentMethod((String) contractWithDetails.get("paymentMethod"))
            .contractStatus((String) contractWithDetails.get("contractStatus"))
            .originContractUrl((String) contractWithDetails.get("originContractUrl"))
            .platformContractUrl((String) contractWithDetails.get("platformContractUrl"))
            .aiReportUrl((String) contractWithDetails.get("aiReportUrl"))
            .contractedAt(dateToString.apply(contractWithDetails.get("contractedAt")))
            .completedAt(dateToString.apply(contractWithDetails.get("completedAt")))
            .cancelReason((String) contractWithDetails.get("cancelReason"))
            .clientRating(contractWithDetails.get("clientRating") != null ? ((Number) contractWithDetails.get("clientRating")).intValue() : null)
            .clientExperience((String) contractWithDetails.get("clientExperience"))
            .clientIsRenewalIntended((Boolean) contractWithDetails.get("clientIsRenewalIntended"))
            .freelancerRating(contractWithDetails.get("freelancerRating") != null ? ((Number) contractWithDetails.get("freelancerRating")).intValue() : null)
            .freelancerExperience((String) contractWithDetails.get("freelancerExperience"))
            .build();
        
        // ====================================================================
        // 2단계: VO → DTO 변환
        // ====================================================================
        
        // ContractVO를 ContractResponseDTO로 변환
        // originContractUrl에서 projectId와 freelancerId 추출 포함
        ContractResponseDTO dto = toResponseDTO(contract);
        
        // 프로젝트 및 상대방 정보 설정
        dto.setProjectTitle((String) contractWithDetails.get("projectTitle"));
        dto.setFreelancerName((String) contractWithDetails.get("freelancerName"));
        dto.setClientName((String) contractWithDetails.get("clientName"));
        
        // ====================================================================
        // 3단계: 마일스톤 정보 조회 및 변환
        // ====================================================================
        
        // 계약의 마일스톤 목록 조회
        // 결제 방식이 MILESTONE인 경우에만 마일스톤 존재
        List<ContractMilestoneVO> milestoneVOs = contractMilestoneMapper.selectMilestonesByContractId(contractId);
        
        // 마일스톤이 존재하면 DTO로 변환하여 설정
        if (milestoneVOs != null && !milestoneVOs.isEmpty()) {
            // Stream API를 사용하여 VO 리스트를 DTO 리스트로 변환
            List<ContractMilestoneResponseDTO> milestoneDTOs = milestoneVOs.stream()
                .map(this::toMilestoneResponseDTO)  // 각 VO를 DTO로 변환
                .collect(Collectors.toList());       // 리스트로 수집
            dto.setMilestones(milestoneDTOs);
        }
        
        // ====================================================================
        // 4단계: 요구사항 초기화
        // ====================================================================
        
        // requirements 필드는 DB에 저장되지 않는 필드
        // contractPurpose, workScope, deliverables 등은 계약서 생성 시에만 사용
        // 응답 DTO의 필수 필드이므로 빈 리스트로 초기화
        dto.setRequirements(new java.util.ArrayList<>());
        
        return dto;
    }

    /**
     * ============================================================================
     * 계약 수락
     * ============================================================================
     * 
     * [기능]
     * 프리랜서가 계약을 수락하여 상태를 SIGNED로 변경하는 메서드입니다.
     * 계약이 활성화되어 작업을 시작할 수 있는 상태가 됩니다.
     * 
     * [연관 파일]
     * - FreelancerContractController.acceptContract(): 프리랜서가 수락 버튼 클릭 시 호출
     * - ContractMapper.updateContractStatus(): 계약 상태를 SIGNED로 변경
     * - freelancerContractList.jsp: 프리랜서가 수락 버튼을 클릭하는 UI
     * - contractManagement.jsp: 클라이언트가 "✅ 프리랜서 승인 완료" 메시지를 보는 UI
     * 
     * [처리 흐름]
     * 1. 계약 상태를 SIGNED로 변경
     * 2. cancel_reason은 null 유지 (수락이므로 취소 사유 없음)
     * 3. 클라이언트가 결제할 수 있는 상태로 전환
     * 
     * [상태 전이]
     * - WAITING → SIGNED
     * - WAITING: 프리랜서가 계약서를 검토 중인 상태
     * - SIGNED: 프리랜서가 계약을 수락한 상태 (클라이언트 결제 대기)
     * 
     * [비즈니스 규칙]
     * - WAITING 상태의 계약만 수락 가능
     * - SIGNED 상태로 변경되면 클라이언트가 결제할 수 있음
     * - 클라이언트가 결제하면 finalizeContract()로 PAID로 변경
     * 
     * [주의사항]
     * - freelancerId 파라미터는 현재 미사용 (향후 권한 검증에 사용 예정)
     * - contractId가 존재하지 않으면 업데이트되지 않음 (에러 없음)
     * 
     * [호출 위치]
     * - FreelancerContractController.acceptContract(): 프리랜서 계약 목록 페이지
     * - ContractApiController: REST API를 통한 계약 수락
     * 
     * @param contractId 수락할 계약의 ID
     * @param freelancerId 프리랜서 ID (현재는 미사용, 향후 권한 검증에 사용 예정)
     * 
     * ============================================================================
     */
    public void acceptContract(Integer contractId, Integer freelancerId) {
        // 계약 상태를 SIGNED로 변경
        // rejectReason은 null (수락이므로 취소 사유 없음)
        contractMapper.updateContractStatus(contractId, ContractStatus.SIGNED.name(), null);
    }

    /**
     * ============================================================================
     * 계약 거절
     * ============================================================================
     * 
     * [기능]
     * 프리랜서가 계약을 거절하여 상태를 TERMINATED로 변경하는 메서드입니다.
     * 거절 사유를 cancel_reason에 "[거절] " prefix와 함께 저장하여
     * 클라이언트 취소와 구분합니다.
     * 
     * [연관 파일]
     * - FreelancerContractController.rejectContract(): 프리랜서가 거절 버튼 클릭 시 호출
     * - ContractMapper.updateContractStatus(): 계약 상태를 TERMINATED로 변경
     * - freelancerContractList.jsp: 프리랜서가 거절 버튼을 클릭하는 UI
     * - contractManagement.jsp: 클라이언트가 "🚫 프리랜서가 거절함" 메시지를 보는 UI
     * 
     * [처리 흐름]
     * 1. 거절 사유에 "[거절] " prefix 추가 (클라이언트 취소와 구분)
     * 2. 계약 상태를 TERMINATED로 변경
     * 3. cancel_reason에 거절 사유 저장
     * 
     * [상태 전이]
     * - WAITING → TERMINATED
     * - 더 이상 진행할 수 없는 상태 (복구 불가)
     * 
     * [cancel_reason 활용]
     * cancel_reason에 "[거절] {사유}" 형식으로 저장하여:
     * - 클라이언트 취소("[취소] {사유}")와 구분
     * - UI에서 "🚫 프리랜서가 거절함" 메시지 표시
     * - 통계 및 분석에 활용 가능
     * 
     * [비즈니스 규칙]
     * - WAITING 상태의 계약만 거절 가능
     * - 거절 사유는 필수 (사용자에게 거절 이유를 입력받아야 함)
     * - TERMINATED 상태로 변경되면 더 이상 수정 불가
     * 
     * [주의사항]
     * - freelancerId 파라미터는 현재 미사용 (향후 권한 검증에 사용 예정)
     * - reason이 null이어도 저장 가능 (하지만 비즈니스 로직상 필수 권장)
     * - 거절된 계약은 복구 불가 (새 계약 생성 필요)
     * 
     * [호출 위치]
     * - FreelancerContractController.rejectContract(): 프리랜서 계약 목록 페이지
     * - ContractApiController: REST API를 통한 계약 거절
     * 
     * @param contractId 거절할 계약의 ID
     * @param freelancerId 프리랜서 ID (현재는 미사용, 향후 권한 검증에 사용 예정)
     * @param reason 거절 사유 (사용자가 입력한 거절 이유)
     * 
     * ============================================================================
     */
    public void rejectContract(Integer contractId, Integer freelancerId, String reason) {
        // 계약 상태를 TERMINATED로 변경하고 거절 사유 저장
        // "[거절] " prefix 추가하여 클라이언트 취소와 구분
        String prefixedReason = (reason != null && !reason.trim().isEmpty()) 
            ? (reason.startsWith("[거절] ") ? reason : "[거절] " + reason)
            : "[거절] 사유 없음";
        contractMapper.updateContractStatus(contractId, ContractStatus.TERMINATED.name(), prefixedReason);
    }
    
    /**
     * ============================================================================
     * 계약의 마일스톤 목록 조회
     * ============================================================================
     * 
     * [기능]
     * 특정 계약의 모든 마일스톤을 조회하여 DTO 리스트로 반환하는 메서드입니다.
     * 마일스톤 방식 결제에서 단계별 작업 계획과 지급 진행 상황을 확인하는 데 사용됩니다.
     * 
     * [연관 파일]
     * - ContractMilestoneMapper.selectMilestonesByContractId(): 마일스톤 목록 조회
     * - ContractService.toMilestoneResponseDTO(): VO → DTO 변환
     * - ContractService.getContractById(): 계약 조회 시 마일스톤 포함
     * 
     * [처리 흐름]
     * 1. ContractMilestoneMapper.selectMilestonesByContractId()로 마일스톤 VO 리스트 조회
     * 2. step 오름차순 정렬 (1단계, 2단계, 3단계...)
     * 3. Stream API를 사용하여 VO 리스트를 DTO 리스트로 변환
     * 4. ContractMilestoneResponseDTO 리스트 반환
     * 
     * [반환 데이터]
     * 
     * 각 마일스톤 정보:
     * - step: 마일스톤 단계 순서 (1, 2, 3, ...)
     * - title: 마일스톤 제목 (예: "1단계: 기획 및 설계")
     * - description: 작업 범위/설명
     * - amount: 해당 마일스톤의 지급 금액 (원 단위)
     * - status: 마일스톤 상태
     *   * "WAITING": 대기 중
     *   * "REQUESTED": 지급 요청됨
     *   * "DEPOSITED": 입금 완료
     *   * "PAID": 지급 완료
     * 
     * [정렬]
     * - step 오름차순 정렬 (1단계, 2단계, 3단계...)
     * - DB 쿼리에서 ORDER BY step ASC로 정렬
     * 
     * [사용 시나리오]
     * 
     * 1. 계약 상세 페이지에서 마일스톤 목록 표시
     *    - 계약서 작성/수정 화면에서 단계별 작업 계획 확인
     *    - 각 마일스톤의 상태와 금액 표시
     * 
     * 2. 결제 진행 상황 확인
     *    - 클라이언트/프리랜서가 각 마일스톤의 지급 진행 상황 확인
     *    - WAITING, REQUESTED, DEPOSITED, PAID 상태 표시
     * 
     * 3. 계약 수정 시 기존 마일스톤 정보 조회
     *    - 기존 마일스톤 정보를 폼에 표시
     *    - 사용자가 수정 후 전체 교체
     * 
     * [주의사항]
     * 
     * - contractId가 존재하지 않거나 마일스톤이 없으면 빈 리스트 반환 (예외 없음)
     * - 결제 방식이 FIXED/FULL인 계약은 마일스톤이 없을 수 있음 (빈 리스트 반환)
     * - 결제 방식이 MILESTONE인 계약은 반드시 마일스톤 존재 (1개 이상)
     * - 마일스톤의 amount 합계가 계약의 totalBudget과 일치해야 함 (비즈니스 로직 검증 필요)
     * 
     * [데이터 변환]
     * 
     * ContractMilestoneVO → ContractMilestoneResponseDTO:
     * - step, title, description, amount, status 필드 그대로 복사
     * - VO는 불변 객체이므로 DTO로 변환하여 전달
     * 
     * [호출 위치]
     * - ContractService.getContractById(): 계약 조회 시 마일스톤 포함
     * - ContractFormController: 계약 상세 페이지
     * - ContractApiController: API로 마일스톤 목록 요청
     * - ClientContractManagementController: 계약 관리 페이지에서 마일스톤 표시
     * - FreelancerContractController: 프리랜서 계약 목록 페이지에서 마일스톤 표시
     * 
     * @param contractId 조회할 계약의 ID (PK)
     * @return 마일스톤 목록 (List<ContractMilestoneResponseDTO>)
     *         - 마일스톤이 없으면 빈 리스트 반환 (null 아님)
     *         - step 오름차순 정렬
     * 
     * ============================================================================
     */
    public List<ContractMilestoneResponseDTO> getMilestonesByContractId(Integer contractId) {
        // 마일스톤 VO 리스트 조회 (단계 순서대로 정렬됨)
        List<ContractMilestoneVO> milestoneVOs = contractMilestoneMapper.selectMilestonesByContractId(contractId);
        
        // VO 리스트를 DTO 리스트로 변환
        return milestoneVOs.stream()
            .map(this::toMilestoneResponseDTO)  // 각 VO를 DTO로 변환
            .collect(Collectors.toList());       // 리스트로 수집
    }

    /**
     * 원본 계약서 파일 경로 업데이트
     * 
     * [기능]
     * - 계약서 PDF 파일이 업로드된 후, 해당 파일의 경로를 contracts 테이블에 저장
     * - origin_contract_url 컬럼 업데이트
     * 
     * [사용 시나리오]
     * 1. 클라이언트가 계약서 PDF를 업로드
     * 2. 파일이 서버에 저장되고 경로가 생성됨
     * 3. 이 메서드로 해당 경로를 contracts 테이블에 업데이트
     * 
     * [경로 형식]
     * - originContractUrl: "contracts/{clientId}/{projectId}/{freelancerId}/{filename}"
     * - 예) "contracts/1/100/50/contract_20240101.pdf"
     * 
     * [트랜잭션]
     * - @Transactional: 단일 UPDATE 작업이지만 트랜잭션 보장
     * 
     * [주의사항]
     * - contractId가 존재하지 않으면 업데이트되지 않음 (에러 없음)
     * - originContractUrl은 NULL이 될 수 있지만, 일반적으로는 유효한 경로여야 함
     * - 파일 업로드와 경로 업데이트는 별도 작업 (파일 업로드는 ContractFileService에서 처리)
     * 
     * [호출 위치]
     * - ContractFileController: 파일 업로드 후 경로 저장
     * - ContractFileService: 파일 저장 후 경로 업데이트
     * 
     * @param contractId 업데이트할 계약의 ID
     * @param originContractUrl 원본 계약서 파일의 저장 경로
     */
    @Transactional
    public void updateOriginContractUrl(Integer contractId, String originContractUrl) {
        contractMapper.updateOriginContractUrl(contractId, originContractUrl);
    }
    
    /**
     * 경로 패턴으로 계약서 파일 경로 목록 조회
     * 
     * [기능]
     * - 특정 경로 패턴과 일치하는 계약서 파일 경로들을 조회
     * - 주로 특정 프로젝트나 클라이언트의 계약서 파일 목록을 가져올 때 사용
     * - 확정된 계약(TERMINATED 제외)의 파일만 조회
     * 
     * [사용 시나리오]
     * 1. 프로젝트 폴더에 있는 계약서 파일 목록 확인
     * 2. 중복 파일 업로드 방지 (기존 파일 경로 확인)
     * 3. 특정 클라이언트의 모든 계약서 경로 조회
     * 4. 파일 정리 작업 시 사용
     * 
     * [경로 패턴 예시]
     * - "contracts/1/100/%" → 클라이언트 1, 프로젝트 100의 모든 계약서
     * - "contracts/1/%" → 클라이언트 1의 모든 계약서
     * 
     * [반환값]
     * - origin_contract_url 목록 (List<String>)
     * - TERMINATED 상태의 계약은 제외
     * 
     * [주의사항]
     * - LIKE 패턴은 와일드카드(%) 사용 가능
     * - 패턴이 일치하는 계약이 없으면 빈 리스트 반환
     * - TERMINATED 상태의 계약은 제외되므로, 취소된 계약의 파일은 조회되지 않음
     * 
     * [호출 위치]
     * - ContractService.getContractByPathPattern(): 기존 계약 확인 시
     * - ContractFileService: 파일 중복 체크 시
     * 
     * @param pathPattern LIKE 패턴 문자열
     *                    예) "contracts/1/100/%"
     * @return origin_contract_url 목록 (List<String>)
     */
    public List<String> getOriginContractUrlsByPathPattern(String pathPattern) {
        return contractMapper.selectOriginContractUrlsByPathPattern(pathPattern);
    }
    
    /**
     * ============================================================================
     * 같은 프로젝트/프리랜서 조합의 기존 계약 조회
     * ============================================================================
     * 
     * [기능]
     * 특정 클라이언트/프로젝트/프리랜서 조합의 기존 계약을 조회하는 메서드입니다.
     * 계약 생성 시 UPDATE vs INSERT를 판단하기 위해 사용되며, 같은 조합의 계약이
     * 이미 존재하면 UPDATE, 없으면 INSERT를 수행합니다.
     * 
     * [연관 파일]
     * - ContractMapper.selectContractByPathPattern(): 경로 패턴으로 기존 계약 조회
     * - ContractService.createContract(): 계약 생성 (INSERT)
     * - ContractService.updateContract(): 계약 수정 (UPDATE)
     * - ContractFormController.confirmContract(): 계약 확정 시 호출
     * 
     * [처리 흐름]
     * 1. ContractMapper.selectContractByPathPattern() 호출
     * 2. origin_contract_url 패턴으로 기존 계약 조회
     * 3. 기존 계약이 있으면 ContractVO 반환, 없으면 null 반환
     * 4. VO → DTO 변환하여 반환
     * 
     * [경로 패턴]
     * 
     * origin_contract_url 형식: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
     * 
     * 조회 패턴: contracts/{clientId}/{projectId}/{freelancerId}/%
     * - clientId, projectId, freelancerId가 모두 일치하는 계약 조회
     * - 파일명은 무시 (와일드카드 % 사용)
     * 
     * [조회 조건]
     * 
     * - 같은 clientId + projectId + freelancerId 조합
     * - contract_status != 'TERMINATED' (TERMINATED는 새 계약 생성 가능)
     *   * TERMINATED 상태의 계약은 무시하여 새 계약 생성 가능
     *   * 거절/취소된 계약은 새로 생성 가능
     * - 가장 최근 계약 1개만 반환 (ORDER BY contract_id DESC LIMIT 1)
     * 
     * [사용 시나리오]
     * 
     * 1. 계약 생성 시 중복 확인
     *    - ContractFormController.confirmContract()에서 호출
     *    - 기존 계약이 있으면 UPDATE, 없으면 INSERT
     *    - 같은 프로젝트에 같은 프리랜서와 계약을 여러 번 수정할 수 있음
     * 
     * 2. 계약 수정 시 기존 계약 확인
     *    - 기존 계약 정보를 조회하여 수정 폼에 표시
     *    - 사용자가 수정 후 UPDATE 수행
     * 
     * [UPDATE vs INSERT 판단 로직]
     * 
     * ContractFormController.confirmContract()에서:
     * 
     * ```java
     * ContractResponseDTO existingContract = contractService.getContractByPathPattern(
     *     clientId, projectId, freelancerId
     * );
     * 
     * if (existingContract != null) {
     *     // 기존 계약이 있으면 UPDATE
     *     contractService.updateContract(dto);
     * } else {
     *     // 기존 계약이 없으면 INSERT
     *     contractService.createContract(dto);
     * }
     * ```
     * 
     * [주의사항]
     * 
     * - TERMINATED 상태의 계약은 조회되지 않음 (새 계약 생성 가능)
     * - 같은 조합의 계약이 여러 개 있어도 가장 최근 것만 반환
     * - origin_contract_url이 null이거나 형식이 맞지 않으면 조회되지 않음
     * - 기존 계약이 없으면 null 반환 (예외 없음)
     * 
     * [데이터 변환]
     * 
     * ContractVO → ContractResponseDTO:
     * - toResponseDTO() 메서드를 사용하여 변환
     * - originContractUrl에서 projectId와 freelancerId 추출 포함
     * 
     * [호출 위치]
     * - ContractFormController.confirmContract(): 계약 확정 시 UPDATE vs INSERT 판단
     * - ContractService.createContract(): 계약 생성 전 중복 확인 (선택적)
     * - ContractService.updateContract(): 계약 수정 전 기존 계약 조회 (선택적)
     * 
     * @param clientId 클라이언트 ID (필수)
     * @param projectId 프로젝트 ID (필수)
     * @param freelancerId 프리랜서 ID (필수)
     * @return 기존 계약 정보 (ContractResponseDTO)
     *         - 기존 계약이 있으면 ContractResponseDTO 반환
     *         - 기존 계약이 없으면 null 반환
     *         - TERMINATED 상태의 계약은 조회되지 않음
     * 
     * ============================================================================
     */
    public ContractResponseDTO getContractByPathPattern(Integer clientId, Integer projectId, Integer freelancerId) {
        ContractVO contract = contractMapper.selectContractByPathPattern(clientId, projectId, freelancerId);
        if (contract == null) {
            return null;
        }
        return toResponseDTO(contract);
    }
    
    /**
     * 계약 정보 업데이트 (기존 계약 수정)
     * 
     * [기능]
     * - 기존 계약 정보를 수정
     * - 같은 clientId + projectId + freelancerId 조합의 계약을 수정할 때 사용
     * - 계약 수정 시 기존 마일스톤을 모두 삭제하고 새로운 마일스톤으로 교체
     * 
     * [처리 흐름]
     * 1. 계약 상태 설정 (기본값: WAITING)
     * 2. 기존 계약 조회 (기존 값 유지를 위해)
     * 3. DTO → VO 변환 (기존 값 유지)
     * 4. 기존 마일스톤 삭제 (새로운 마일스톤으로 교체하기 위해)
     * 5. 계약 정보 업데이트
     * 6. 새로운 마일스톤 추가 (있는 경우)
     * 
     * [기존 값 유지 전략]
     * - contracted_at: 기존 값 유지 (수정 시점이 아니라 계약 체결 시점)
     * - platformContractUrl: 기존 값 유지 (플랫폼 생성 계약서는 별도 업데이트)
     * - aiReportUrl: 기존 값 유지 (AI 리포트는 별도 업데이트)
     * - completedAt: 기존 값 유지 (완료 시각은 finalizeContract에서만 변경)
     * - cancelReason: 기존 값 유지 (취소 사유는 cancelContract에서만 변경)
     * - 평가 관련 필드: 기존 값 유지 (평가는 완료 후에만 입력)
     *   * clientRating, freelancerRating
     *   * clientExperience, freelancerExperience
     *   * clientIsRenewalIntended
     * 
     * [마일스톤 처리]
     * - 기존 마일스톤을 모두 삭제하고 새로운 마일스톤으로 교체
     * - 부분 수정 불가 (전체 교체만 가능)
     * - 마일스톤이 없으면 삭제만 수행 (새로 추가하지 않음)
     * 
     * [트랜잭션]
     * - @Transactional: 마일스톤 삭제, 계약 업데이트, 마일스톤 추가가 모두 성공해야 커밋
     * - 중간에 예외 발생 시 모든 작업 롤백
     * - 데이터 일관성 보장
     * 
     * [주의사항]
     * - contractId가 존재하지 않으면 IllegalStateException 발생
     * - 계약 상태가 TERMINATED 또는 COMPLETED인 경우 수정 불가 (비즈니스 로직 검증 필요)
     * - 마일스톤의 amount 합계가 totalBudget과 일치해야 함 (비즈니스 로직 검증 필요)
     * 
     * [호출 위치]
     * - ContractFormController: 계약서 수정 후 저장
     * - ContractApiController: API를 통한 계약 수정
     * 
     * @param dto 계약 수정 요청 DTO
     *            - contractId: 수정할 계약의 ID (필수)
     *            - contractStartDate, contractEndDate: 수정할 계약 기간
     *            - totalBudget: 수정할 총 예산
     *            - paymentMethod: 수정할 결제 방식
     *            - milestones: 새로운 마일스톤 목록 (전체 교체)
     * @throws IllegalStateException 계약을 찾을 수 없을 때
     */
    @Transactional
    public void updateContract(ContractUpdateRequestDTO dto) {
        // ====================================================================
        // 1단계: 계약 상태 설정
        // ====================================================================
        
        // 계약 상태가 설정되지 않았으면 기본값 WAITING으로 설정
        // WAITING은 계약 수정 후에도 기본 상태로 유지
        String contractStatus = dto.getContractStatus() != null && !dto.getContractStatus().isEmpty() 
            ? dto.getContractStatus() 
            : ContractStatus.WAITING.name();
        
        // ====================================================================
        // 2단계: 기존 계약 조회
        // ====================================================================
        
        // 기존 계약 정보를 조회하여 기존 값 유지
        // contracted_at, platformContractUrl, aiReportUrl 등은 수정하지 않고 기존 값 유지
        ContractVO existingContract = contractMapper.selectContractById(dto.getContractId());
        if (existingContract == null) {
            throw new IllegalStateException("계약을 찾을 수 없습니다: " + dto.getContractId());
        }
        
        // ====================================================================
        // 3단계: DTO → VO 변환 (기존 값 유지)
        // ====================================================================
        
        // DTO의 값으로 업데이트하되, 일부 필드는 기존 값 유지
        ContractVO contract = ContractVO.builder()
            .contractId(dto.getContractId())                                    // 계약 ID (수정 불가)
            .contractStartDate(dto.getContractStartDate())                      // 계약 시작일 (수정)
            .contractEndDate(dto.getContractEndDate())                          // 계약 종료일 (수정)
            .totalBudget(dto.getTotalBudget())                                  // 총 예산 (수정)
            .paymentMethod(dto.getPaymentMethod())                              // 결제 방식 (수정)
            .contractStatus(contractStatus)                                      // 계약 상태 (수정 또는 기본값)
            .originContractUrl(dto.getOriginContractUrl())                      // 원본 계약서 경로 (수정)
            .platformContractUrl(existingContract.getPlatformContractUrl())     // 플랫폼 계약서 경로 (기존 값 유지)
            .aiReportUrl(existingContract.getAiReportUrl())                      // AI 리포트 경로 (기존 값 유지)
            .contractedAt(existingContract.getContractedAt())                    // 계약 체결 시각 (기존 값 유지)
            .completedAt(existingContract.getCompletedAt())                     // 계약 완료 시각 (기존 값 유지)
            .cancelReason(existingContract.getCancelReason())                    // 취소 사유 (기존 값 유지)
            .clientRating(existingContract.getClientRating())                   // 클라이언트 평점 (기존 값 유지)
            .clientExperience(existingContract.getClientExperience())            // 클라이언트 경험 평가 (기존 값 유지)
            .clientIsRenewalIntended(existingContract.getClientIsRenewalIntended()) // 재계약 의향 (기존 값 유지)
            .freelancerRating(existingContract.getFreelancerRating())            // 프리랜서 평점 (기존 값 유지)
            .freelancerExperience(existingContract.getFreelancerExperience())    // 프리랜서 경험 평가 (기존 값 유지)
            .build();
        
        // ====================================================================
        // 4단계: 기존 마일스톤 삭제
        // ====================================================================
        
        // 기존 마일스톤을 모두 삭제
        // 새로운 마일스톤으로 전체 교체하기 위한 작업
        // 부분 수정이 아닌 전체 교체 방식 사용
        contractMilestoneMapper.deleteMilestonesByContractId(dto.getContractId());
        
        // ====================================================================
        // 5단계: 계약 정보 업데이트
        // ====================================================================
        
        // 계약 정보를 업데이트
        // 모든 컬럼을 업데이트하지만, 일부는 기존 값으로 유지됨
        contractMapper.updateContract(contract);
        
        // ====================================================================
        // 6단계: 새로운 마일스톤 추가
        // ====================================================================
        
        // 새로운 마일스톤이 있으면 추가
        // 마일스톤이 없으면 삭제만 수행 (새로 추가하지 않음)
        if (dto.getMilestones() != null && !dto.getMilestones().isEmpty()) {
            // 각 마일스톤을 순회하며 저장
            for (ContractMilestoneRequestDTO milestoneDto : dto.getMilestones()) {
                contractMilestoneMapper.insertMilestone(
                    dto.getContractId(),                    // 계약 ID (FK)
                    milestoneDto.getStep(),                 // 단계 순서
                    milestoneDto.getTitle(),                // 마일스톤 제목
                    milestoneDto.getDescription(),           // 작업 범위/설명
                    milestoneDto.getAmount()                // 결제 금액
                );
            }
        }
    }
    
    /**
     * 클라이언트의 계약 목록 조회
     * 
     * [기능]
     * - 특정 클라이언트의 모든 계약 목록을 조회
     * - origin_contract_url 패턴을 통해 클라이언트의 계약들을 필터링
     * 
     * [경로 패턴]
     * - pathPattern: "contracts/{clientId}/%"
     * - 예) "contracts/1/%" → 클라이언트 ID가 1인 모든 계약
     * 
     * [반환 데이터]
     * - 클라이언트의 계약 목록 (최신순 정렬)
     * - 각 계약의 기본 정보 및 마일스톤 정보는 포함되지 않음
     *   (마일스톤은 getContractById로 개별 조회 필요)
     * 
     * [정렬]
     * - 계약 ID 내림차순 (최신 계약이 먼저)
     * 
     * [주의사항]
     * - 패턴이 일치하는 계약이 없으면 빈 리스트 반환
     * - TERMINATED 상태의 계약도 포함 (필터링 없음)
     * - origin_contract_url이 NULL이거나 패턴과 맞지 않으면 조회되지 않음
     * 
     * [호출 위치]
     * - ClientContractManagementController: 클라이언트 계약 목록 페이지
     * - ContractService: 클라이언트별 계약 통계 조회
     * 
     * @param pathPattern LIKE 패턴 문자열
     *                    예) "contracts/1/%"
     * @return 계약 목록 (List<ContractResponseDTO>), 최신순 정렬
     */
    public List<ContractResponseDTO> getContractsByClientPathPattern(String pathPattern) {
        // 경로 패턴으로 계약 목록 조회
        List<ContractVO> contracts = contractMapper.selectContractsByClientPathPattern(pathPattern);
        
        // VO 리스트를 DTO 리스트로 변환
        return contracts.stream()
            .map(this::toResponseDTO)  // 각 VO를 DTO로 변환
            .collect(Collectors.toList());  // 리스트로 수집
    }
    
    /**
     * ============================================================================
     * 계약 결제 완료 (에스크로 확보)
     * ============================================================================
     * 
     * [기능]
     * 클라이언트가 계약 결제를 완료하여 상태를 PAID로 변경하는 메서드입니다.
     * 일시지급과 마일스톤 방식 모두 전체 예산을 에스크로에 확보합니다.
     * 
     * [연관 파일]
     * - ClientContractManagementController.finalizeContract(): 클라이언트가 결제 완료 버튼 클릭 시 호출
     * - ContractMapper.updateContractStatus(): 계약 상태를 PAID로 변경
     * - contractManagement.jsp: 클라이언트가 결제 완료 버튼을 클릭하는 UI
     * 
     * [에스크로 시스템]
     * 이 메서드는 에스크로 기반 결제 시스템의 핵심입니다:
     * 
     * 1. 클라이언트가 전체 예산을 에스크로에 입금
     *    - 일시지급: 전체 금액을 한 번에 입금
     *    - 마일스톤: 전체 금액을 한 번에 입금 (단계별 지급은 나중에)
     * 
     * 2. 계약 상태를 PAID로 변경
     *    - SIGNED → PAID
     *    - 프리랜서가 지급 요청할 수 있는 상태로 활성화
     * 
     * 3. 이후 지급 흐름:
     *    - 일시지급: 프리랜서 요청 → 클라이언트 수락 → COMPLETED
     *    - 마일스톤: 프리랜서 단계별 요청 → 클라이언트 수락 → 단계별 지급
     * 
     * [상태 전이]
     * - SIGNED → PAID
     * - 계약 상태만 변경 (마일스톤 상태는 변경하지 않음)
     * 
     * [비즈니스 규칙]
     * - SIGNED 상태의 계약만 결제 완료 처리 가능
     * - 일시지급과 마일스톤 방식 모두 동일하게 처리 (전체 금액 에스크로 확보)
     * - PAID 상태로 변경되면 마일스톤/정산이 활성화됨
     * 
     * [주의사항]
     * - 실제 결제 시스템 연동은 별도로 필요 (이 메서드는 상태 변경만 담당)
     * - contractId가 존재하지 않으면 업데이트되지 않음 (에러 없음)
     * - 결제 완료 후에만 호출되어야 함
     * 
     * [호출 위치]
     * - ClientContractManagementController.finalizeContract(): 클라이언트 계약 관리 페이지
     * - ContractApiController: REST API를 통한 계약 결제 완료 처리
     * 
     * @param contractId 결제 완료 처리할 계약의 ID
     * 
     * ============================================================================
     */
    @Transactional
    public void finalizeContract(Integer contractId) {
        // 모든 결제 방식이 PAID로 통일 (에스크로에 전체 금액 확보)
        // 일시지급도 프리랜서가 지급 요청을 할 수 있어야 하므로 PAID 상태로 변경
        contractMapper.updateContractStatus(contractId, ContractStatus.PAID.name(), null);
    }
    
    /**
     * 계약 정산 완료 (모든 마일스톤 종료)
     * 
     * [기능]
     * - 모든 마일스톤이 완료되어 계약 상태를 COMPLETED로 변경
     * - 정산 완료 후 호출되는 메서드
     * - 계약이 성공적으로 종료되었음을 의미
     * 
     * [상태 변경]
     * - PAID → COMPLETED
     * - PAID: 결제 완료(에스크로 확보) - 마일스톤/정산 활성화
     * - COMPLETED: 정산 완료(모든 마일스톤 종료)
     * 
     * [비즈니스 규칙]
     * - 클라이언트 또는 시스템이 정산 완료 처리할 수 있음 (권한 검증 필요)
     * - PAID 상태의 계약만 정산 완료 처리 가능
     * - 모든 마일스톤이 완료된 후에만 호출되어야 함
     * - COMPLETED 상태로 변경되면 더 이상 수정 불가
     * 
     * [후속 작업]
     * - 계약 완료 후 평가 입력 가능 (clientRating, freelancerRating 등)
     * - 재계약 의향 조사 가능 (clientIsRenewalIntended)
     * 
     * [주의사항]
     * - contractId가 존재하지 않으면 업데이트되지 않음 (에러 없음)
     * - 모든 마일스톤이 완료되지 않았으면 호출되면 안 됨 (비즈니스 로직 검증 필요)
     * 
     * [호출 위치]
     * - ClientContractManagementController: 클라이언트가 정산 완료 후 처리
     * - ContractApiController: API를 통한 계약 정산 완료 처리
     * - 시스템 자동 처리: 모든 마일스톤 완료 시 자동 호출
     * 
     * @param contractId 정산 완료 처리할 계약의 ID
     */
    public void completeContract(Integer contractId) {
        // 계약 상태를 COMPLETED로 변경
        // 정산 완료 처리이므로 취소 사유 없음 (null)
        contractMapper.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);
    }

    /**
     * 계약 취소
     * 
     * [기능]
     * - 클라이언트가 계약을 취소하여 상태를 TERMINATED로 변경
     * - 취소 사유를 cancel_reason에 저장
     * 
     * [상태 변경]
     * - WAITING → TERMINATED (계약 대기 중 취소)
     * - SIGNED → TERMINATED (작업 진행 중 취소)
     * - PAID → TERMINATED (결제 완료 후 중도 종료)
     * 
     * [비즈니스 규칙]
     * - 클라이언트만 계약을 취소할 수 있음 (권한 검증 필요)
     * - WAITING, SIGNED, 또는 PAID 상태의 계약만 취소 가능
     * - 취소 사유는 필수 (사용자에게 취소 이유를 입력받아야 함)
     * - TERMINATED 상태로 변경되면 더 이상 수정 불가
     * 
     * [주의사항]
     * - reason이 null이어도 저장 가능 (하지만 비즈니스 로직상 필수 권장)
     * - 취소된 계약은 복구 불가
     * - 취소 사유는 향후 통계 및 분석에 사용될 수 있음
     * 
     * [호출 위치]
     * - ClientContractManagementController: 클라이언트가 계약 취소 버튼 클릭 시
     * - ContractApiController: API를 통한 계약 취소
     * 
     * @param contractId 취소할 계약의 ID
     * @param reason 취소 사유 (사용자가 입력한 취소 이유)
     */
    public void cancelContract(Integer contractId, String reason) {
        // 계약 상태를 TERMINATED로 변경하고 취소 사유 저장
        // "[취소] " prefix 추가하여 프리랜서 거절과 구분
        String prefixedReason = (reason != null && !reason.trim().isEmpty()) 
            ? (reason.startsWith("[취소] ") ? reason : "[취소] " + reason)
            : "[취소] 사유 없음";
        contractMapper.updateContractStatus(contractId, ContractStatus.TERMINATED.name(), prefixedReason);
    }
    
    /**
     * 모든 계약 목록 조회 (프리랜서용)
     * 
     * [기능]
     * - 시스템의 모든 계약 목록을 조회
     * - 주로 프리랜서가 자신과 관련된 모든 계약을 볼 때 사용
     * - 관리자 페이지에서 전체 계약 조회 시에도 사용 가능
     * 
     * [반환 데이터]
     * - 모든 계약 목록 (최신순 정렬)
     * - 각 계약의 기본 정보 (마일스톤 정보는 포함되지 않음)
     * 
     * [정렬]
     * - 계약 ID 내림차순 (최신 계약이 먼저)
     * 
     * [주의사항]
     * - 계약이 없으면 빈 리스트 반환
     * - 모든 상태의 계약 포함 (TERMINATED 포함)
     * - 대량의 데이터가 있을 경우 성능 고려 필요 (페이징 고려)
     * - 프리랜서별 필터링은 클라이언트 측에서 처리하거나 별도 메서드 필요
     * 
     * [호출 위치]
     * - FreelancerContractController: 프리랜서 계약 목록 페이지
     * - 관리자 페이지: 전체 계약 조회
     * 
     * @return 모든 계약 목록 (List<ContractResponseDTO>), 최신순 정렬
     */
    public List<ContractResponseDTO> getAllContracts() {
        // 모든 계약 조회 (프로젝트 및 상대방 정보 포함)
        List<java.util.Map<String, Object>> contractsWithDetails = contractMapper.selectAllContractsWithDetails();
        
        // Map 리스트를 DTO 리스트로 변환
        return contractsWithDetails.stream()
            .map(map -> {
                // 날짜를 String으로 변환하는 헬퍼 메서드
                java.util.function.Function<Object, String> dateToString = (obj) -> {
                    if (obj == null) return null;
                    if (obj instanceof String) return (String) obj;
                    if (obj instanceof java.sql.Date) return obj.toString();
                    if (obj instanceof java.sql.Timestamp) return obj.toString();
                    if (obj instanceof java.util.Date) {
                        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
                        return sdf.format((java.util.Date) obj);
                    }
                    return obj.toString();
                };
                
                // Number를 Integer로 변환하는 헬퍼 메서드
                java.util.function.Function<Object, Integer> getIntegerValue = (obj) -> {
                    if (obj == null) return null;
                    if (obj instanceof Number) return ((Number) obj).intValue();
                    if (obj instanceof String) {
                        try {
                            return Integer.valueOf((String) obj);
                        } catch (NumberFormatException e) {
                            return null;
                        }
                    }
                    return null;
                };
                
                // ContractVO Builder로 생성
                ContractVO vo = ContractVO.builder()
                    .contractId(map.get("contractId") != null ? ((Number) map.get("contractId")).intValue() : null)
                    .contractStartDate(dateToString.apply(map.get("contractStartDate")))
                    .contractEndDate(dateToString.apply(map.get("contractEndDate")))
                    .totalBudget(map.get("totalBudget") != null ? ((Number) map.get("totalBudget")).longValue() : null)
                    .paymentMethod((String) map.get("paymentMethod"))
                    .contractStatus((String) map.get("contractStatus"))
                    .originContractUrl((String) map.get("originContractUrl"))
                    .platformContractUrl((String) map.get("platformContractUrl"))
                    .aiReportUrl((String) map.get("aiReportUrl"))
                    .contractedAt(dateToString.apply(map.get("contractedAt")))
                    .completedAt(dateToString.apply(map.get("completedAt")))
                    .cancelReason((String) map.get("cancelReason"))
                    .clientRating(map.get("clientRating") != null ? ((Number) map.get("clientRating")).intValue() : null)
                    .clientExperience((String) map.get("clientExperience"))
                    .clientIsRenewalIntended((Boolean) map.get("clientIsRenewalIntended"))
                    .freelancerRating(map.get("freelancerRating") != null ? ((Number) map.get("freelancerRating")).intValue() : null)
                    .freelancerExperience((String) map.get("freelancerExperience"))
                    .build();
                
                // DTO로 변환
                ContractResponseDTO dto = toResponseDTO(vo);
                
                // 프로젝트 및 상대방 정보 설정
                dto.setProjectTitle((String) map.get("projectTitle"));
                dto.setFreelancerName((String) map.get("freelancerName"));
                dto.setClientName((String) map.get("clientName"));
                
                // 마일스톤 상태 집계 정보 설정 (새로 추가)
                dto.setTotalMilestones(getIntegerValue.apply(map.get("totalMilestones")));
                dto.setPaidMilestones(getIntegerValue.apply(map.get("paidMilestones")));
                dto.setRequestedMilestones(getIntegerValue.apply(map.get("requestedMilestones")));
                dto.setDepositedMilestones(getIntegerValue.apply(map.get("depositedMilestones")));
                dto.setWaitingMilestones(getIntegerValue.apply(map.get("waitingMilestones")));
                
                return dto;
            })
            .collect(Collectors.toList());
    }
    
    // =========================================================
    // VO ↔ DTO 변환 메서드
    // =========================================================
    
    /**
     * ============================================================================
     * ContractVO → ContractResponseDTO 변환 (헬퍼 메서드)
     * ============================================================================
     * 
     * [역할]
     * DB 엔티티(ContractVO)를 응답 DTO(ContractResponseDTO)로 변환하는 private 헬퍼 메서드입니다.
     * Service 계층에서 VO를 DTO로 변환하여 Controller에 전달할 때 사용됩니다.
     * 
     * [사용 위치]
     * - ContractService.getContractById(): 계약 단건 조회 시
     * - ContractService.getContractByPathPattern(): 기존 계약 조회 시
     * - ContractService.getContractsByClientPathPattern(): 클라이언트 계약 목록 조회 시
     * - ContractService.getAllContracts(): 모든 계약 목록 조회 시
     * 
     * [처리 흐름]
     * 1. ContractResponseDTO 객체 생성
     * 2. ContractVO의 모든 필드를 DTO에 복사
     * 3. originContractUrl에서 projectId와 freelancerId 추출
     * 4. DTO 반환
     * 
     * [경로 파싱]
     * 
     * originContractUrl 형식: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
     * 
     * 경로 분리:
     * - pathParts[0] = "contracts"
     * - pathParts[1] = clientId (사용하지 않음)
     * - pathParts[2] = projectId (추출하여 DTO에 설정)
     * - pathParts[3] = freelancerId (추출하여 DTO에 설정)
     * - pathParts[4+] = fileName (사용하지 않음)
     * 
     * [변환 필드]
     * 
     * 기본 계약 정보:
     * - contractId: 계약 ID
     * - contractStartDate: 계약 시작일
     * - contractEndDate: 계약 종료일
     * - totalBudget: 총 예산
     * - paymentMethod: 결제 방식
     * - contractStatus: 계약 상태
     * - originContractUrl: 원본 계약서 파일 경로
     * - platformContractUrl: 플랫폼 생성 계약서 경로
     * - aiReportUrl: AI 분석 리포트 경로
     * - contractedAt: 계약 체결 시각
     * - completedAt: 계약 완료 시각
     * - cancelReason: 취소/거절 사유
     * 
     * 추출된 정보:
     * - projectId: originContractUrl에서 추출 (pathParts[2])
     * - freelancerId: originContractUrl에서 추출 (pathParts[3])
     * 
     * [주의사항]
     * 
     * - originContractUrl이 null이거나 형식이 맞지 않으면 projectId와 freelancerId는 null
     * - 경로 파싱 실패 시 NumberFormatException을 무시하고 계속 진행
     * - pathParts.length가 3보다 작으면 projectId만 추출, 4보다 작으면 freelancerId는 null
     * - VO는 불변 객체이므로 DTO로 변환하여 전달
     * 
     * [에러 처리]
     * 
     * - originContractUrl이 null: projectId와 freelancerId는 null로 설정
     * - originContractUrl이 "contracts/"로 시작하지 않음: projectId와 freelancerId는 null로 설정
     * - 경로 파싱 실패 (NumberFormatException): 해당 필드만 null로 설정하고 계속 진행
     * 
     * @param vo 계약 VO (DB 엔티티, 불변 객체)
     * @return 계약 응답 DTO (ContractResponseDTO)
     *         - 모든 필드가 설정됨
     *         - projectId와 freelancerId는 originContractUrl에서 추출 (실패 시 null)
     * 
     * ============================================================================
     */
    private ContractResponseDTO toResponseDTO(ContractVO vo) {
        ContractResponseDTO dto = new ContractResponseDTO();
        dto.setContractId(vo.getContractId());
        dto.setContractStartDate(vo.getContractStartDate());
        dto.setContractEndDate(vo.getContractEndDate());
        dto.setTotalBudget(vo.getTotalBudget());
        dto.setPaymentMethod(vo.getPaymentMethod());
        dto.setContractStatus(vo.getContractStatus());
        dto.setOriginContractUrl(vo.getOriginContractUrl());
        dto.setPlatformContractUrl(vo.getPlatformContractUrl());
        dto.setAiReportUrl(vo.getAiReportUrl());
        dto.setContractedAt(vo.getContractedAt());
        dto.setCompletedAt(vo.getCompletedAt());
        dto.setCancelReason(vo.getCancelReason());
        
        // originContractUrl에서 projectId와 freelancerId 추출
        // 형식: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
        if (vo.getOriginContractUrl() != null && vo.getOriginContractUrl().startsWith("contracts/")) {
            String[] pathParts = vo.getOriginContractUrl().split("/");
            if (pathParts.length >= 3) {
                try {
                    dto.setProjectId(Integer.valueOf(pathParts[2]));
                } catch (NumberFormatException e) {
                    // 무시
                }
            }
            if (pathParts.length >= 4) {
                try {
                    dto.setFreelancerId(Integer.valueOf(pathParts[3]));
                } catch (NumberFormatException e) {
                    // 무시
                }
            }
        }
        
        return dto;
    }
    
    /**
     * ============================================================================
     * ContractMilestoneVO → ContractMilestoneResponseDTO 변환 (헬퍼 메서드)
     * ============================================================================
     * 
     * [역할]
     * DB 엔티티(ContractMilestoneVO)를 응답 DTO(ContractMilestoneResponseDTO)로 변환하는
     * private 헬퍼 메서드입니다. Service 계층에서 VO를 DTO로 변환하여 Controller에 전달할 때 사용됩니다.
     * 
     * [사용 위치]
     * - ContractService.getContractById(): 계약 조회 시 마일스톤 포함
     * - ContractService.getMilestonesByContractId(): 마일스톤 목록 조회
     * 
     * [처리 흐름]
     * 1. ContractMilestoneResponseDTO 객체 생성
     * 2. ContractMilestoneVO의 모든 필드를 DTO에 복사
     * 3. DTO 반환
     * 
     * [변환 필드]
     * 
     * - step: 마일스톤 단계 순서 (1, 2, 3, ...)
     *   * 계약 내에서 고유
     *   * 오름차순 정렬 기준
     * 
     * - title: 마일스톤 제목
     *   * 예: "1단계: 기획 및 설계"
     *   * null 가능
     * 
     * - description: 작업 범위/설명
     *   * 해당 마일스톤에서 수행할 작업의 상세 설명
     *   * null 가능
     * 
     * - amount: 해당 마일스톤의 결제 금액 (원 단위)
     *   * Long 타입 (큰 금액 처리)
     *   * 모든 마일스톤의 amount 합계 = 계약의 totalBudget
     * 
     * - status: 마일스톤 상태
     *   * "WAITING": 대기 중 (아직 지급 요청하지 않음)
     *   * "REQUESTED": 지급 요청됨 (프리랜서가 요청, 클라이언트 수락 대기)
     *   * "DEPOSITED": 입금 완료 (클라이언트가 수락, 에스크로에서 출금 대기)
     *   * "PAID": 지급 완료 (프리랜서에게 실제 지급 완료)
     * 
     * [주의사항]
     * 
     * - VO는 불변 객체이므로 DTO로 변환하여 전달
     * - 모든 필드를 그대로 복사 (추가 변환 없음)
     * - null 필드는 그대로 null로 설정
     * 
     * [데이터 타입]
     * 
     * - step: Integer (1부터 시작)
     * - title: String (null 가능)
     * - description: String (null 가능)
     * - amount: Long (원 단위)
     * - status: String (마일스톤 상태)
     * 
     * @param vo 마일스톤 VO (DB 엔티티, 불변 객체)
     * @return 마일스톤 응답 DTO (ContractMilestoneResponseDTO)
     *         - 모든 필드가 설정됨
     *         - null 필드는 그대로 null로 설정
     * 
     * ============================================================================
     */
    private ContractMilestoneResponseDTO toMilestoneResponseDTO(ContractMilestoneVO vo) {
        ContractMilestoneResponseDTO dto = new ContractMilestoneResponseDTO();
        dto.setStep(vo.getStep());                    // 단계 순서
        dto.setTitle(vo.getTitle());                  // 마일스톤 제목
        dto.setDescription(vo.getDescription());       // 작업 범위/설명
        dto.setAmount(vo.getAmount());                // 결제 금액
        dto.setStatus(vo.getStatus());                // 마일스톤 상태
        return dto;
    }
    
    /**
     * ============================================================================
     * 프리랜서 지급 요청
     * ============================================================================
     * 
     * [기능]
     * 프리랜서가 작업 완료 후 클라이언트에게 지급을 요청하는 메서드입니다.
     * 마일스톤 방식과 일시지급 방식을 모두 지원하며, 일시지급의 경우 DB 스키마 변경 없이
     * cancel_reason 컬럼을 재활용하여 지급 요청 상태를 관리합니다.
     * 
     * [연관 파일]
     * - FreelancerContractController.requestPayment(): 프리랜서가 지급 요청 버튼 클릭 시 호출
     * - ContractMapper.updateContractStatus(): 일시지급 요청 시 cancel_reason 업데이트
     * - ContractMilestoneMapper.updateMilestoneStatus(): 마일스톤 요청 시 상태 업데이트
     * - contractManagement.jsp: 클라이언트가 지급 요청을 확인하고 수락/거부할 수 있는 UI
     * - freelancerContractList.jsp: 프리랜서가 지급 요청 버튼을 클릭하는 UI
     * 
     * [처리 흐름]
     * 1. 계약 상태 검증 (PAID 또는 COMPLETED여야 함)
     * 2. 결제 방식 확인:
     *    a) 일시지급 (FIXED/FULL/null) + 마일스톤 없음
     *       → cancel_reason에 "[지급요청]" 저장 (DB 스키마 변경 없이 기존 컬럼 활용)
     *       → 클라이언트가 수락하면 approvePayment()에서 COMPLETED로 변경
     *    b) 마일스톤 방식
     *       → 마일스톤 상태를 WAITING → REQUESTED로 변경
     *       → 클라이언트가 수락하면 approvePayment()에서 DEPOSITED로 변경
     * 
     * [일시지급 지급 요청 구현 방식]
     * DB 스키마 변경 없이 일시지급 지급 요청 상태를 관리하기 위해 cancel_reason 컬럼을 재활용합니다.
     * 
     * - cancel_reason = null: 아직 지급 요청하지 않은 상태
     * - cancel_reason = "[지급요청]": 프리랜서가 지급 요청한 상태
     * 
     * 이 방식의 장점:
     * 1. DB 스키마 변경 불필요 (기존 컬럼 재활용)
     * 2. 일시지급과 마일스톤 방식을 동일한 로직으로 처리 가능
     * 3. 클라이언트가 수락/거부할 수 있는 상호작용 구현 가능
     * 
     * [상태 전이]
     * 마일스톤 방식:
     *   - 마일스톤 상태: WAITING → REQUESTED
     *   - 계약 상태: PAID (변경 없음)
     * 
     * 일시지급 방식:
     *   - cancel_reason: null → "[지급요청]"
     *   - 계약 상태: PAID (변경 없음)
     * 
     * [비즈니스 규칙]
     * - 계약 상태가 PAID 또는 COMPLETED여야 함
     * - 마일스톤 방식: step이 지정되면 해당 마일스톤만, null이면 모든 WAITING 마일스톤
     * - 일시지급 방식: 마일스톤이 없어야 함 (totalMilestones == 0)
     * - 이미 REQUESTED, DEPOSITED, PAID인 마일스톤은 변경하지 않음
     * 
     * [트랜잭션]
     * - @Transactional: 상태 변경이 모두 성공해야 커밋
     * - 예외 발생 시 자동 롤백
     * 
     * [호출 위치]
     * - FreelancerContractController.requestPayment(): 프리랜서 계약 목록 페이지
     * - ContractApiController: REST API를 통한 지급 요청
     * 
     * @param contractId 계약 ID
     * @param step 마일스톤 단계 (null이면 모든 WAITING 마일스톤, 일시지급은 항상 null)
     * @return 업데이트된 마일스톤 개수 (일시지급은 항상 1)
     * 
     * ============================================================================
     */
    @Transactional
    public int requestPayment(Integer contractId, Integer step) {
        // 계약 상태 확인 (PAID 또는 COMPLETED여야 함)
        ContractVO contract = contractMapper.selectContractById(contractId);
        if (contract == null) {
            throw new IllegalArgumentException("계약을 찾을 수 없습니다: " + contractId);
        }
        if (!ContractStatus.PAID.name().equals(contract.getContractStatus()) 
                && !ContractStatus.COMPLETED.name().equals(contract.getContractStatus())) {
            throw new IllegalStateException("결제 완료 또는 정산 완료된 계약만 지급 요청할 수 있습니다. 현재 상태: " + contract.getContractStatus());
        }
        
        // 일시지급인 경우: cancel_reason에 "[지급요청]" 저장 (DB 변경 없이 기존 컬럼 활용)
        if ("FIXED".equals(contract.getPaymentMethod()) || "FULL".equals(contract.getPaymentMethod()) || contract.getPaymentMethod() == null) {
            List<ContractMilestoneVO> milestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
            if (milestones == null || milestones.isEmpty()) {
                // 일시지급: cancel_reason에 "[지급요청]" 저장
                contractMapper.updateContractStatus(contractId, ContractStatus.PAID.name(), "[지급요청]");
                logger.info("일시지급 요청: contractId={}", contractId);
                return 1;
            }
        }
        
        // 마일스톤 방식: 마일스톤 상태 업데이트: WAITING → REQUESTED
        return contractMilestoneMapper.updateMilestoneStatus(contractId, step, "REQUESTED");
    }
    
    /**
     * ============================================================================
     * 클라이언트 지급 수락
     * ============================================================================
     * 
     * [기능]
     * 클라이언트가 프리랜서의 지급 요청을 수락하는 메서드입니다.
     * 마일스톤 방식과 일시지급 방식을 모두 지원하며, 일시지급의 경우 cancel_reason을
     * 확인하여 지급 요청 상태를 관리합니다.
     * 
     * [연관 파일]
     * - ClientContractManagementController.approvePayment(): 클라이언트가 지급 수락 버튼 클릭 시 호출
     * - ContractMapper.updateContractStatus(): 일시지급 수락 시 COMPLETED로 변경
     * - ContractMapper.updateCancelReason(): cancel_reason을 null로 초기화
     * - ContractMilestoneMapper.updateMilestoneStatus(): 마일스톤 수락 시 DEPOSITED로 변경
     * - contractManagement.jsp: 클라이언트가 지급 수락 버튼을 클릭하는 UI
     * 
     * [처리 흐름]
     * 1. 계약 상태 검증 (PAID 또는 COMPLETED여야 함)
     * 2. 결제 방식 확인:
     *    a) 일시지급 (FIXED/FULL/null) + cancel_reason = "[지급요청]"
     *       → 계약 상태를 COMPLETED로 변경
     *       → cancel_reason을 null로 초기화 (명시적으로)
     *       → 프리랜서와 클라이언트 모두 "완료 내역"으로 이동
     *    b) 마일스톤 방식
     *       → 마일스톤 상태를 REQUESTED → DEPOSITED로 변경
     *       → 모든 마일스톤이 DEPOSITED 또는 PAID면 계약 상태를 COMPLETED로 변경
     * 
     * [일시지급 지급 수락 구현 방식]
     * cancel_reason = "[지급요청]"인 일시지급 계약을 수락하면:
     * 1. 계약 상태를 COMPLETED로 변경 (최종 완료)
     * 2. cancel_reason을 null로 초기화 (명시적으로 updateCancelReason() 호출)
     * 3. 프리랜서가 재요청할 수 없도록 상태를 완전히 종료
     * 
     * [상태 전이]
     * 마일스톤 방식:
     *   - 마일스톤 상태: REQUESTED → DEPOSITED
     *   - 계약 상태: 모든 마일스톤이 DEPOSITED 또는 PAID면 PAID → COMPLETED
     * 
     * 일시지급 방식:
     *   - cancel_reason: "[지급요청]" → null
     *   - 계약 상태: PAID → COMPLETED
     * 
     * [비즈니스 규칙]
     * - 계약 상태가 PAID 또는 COMPLETED여야 함
     * - 마일스톤 방식: step이 지정되면 해당 마일스톤만, null이면 모든 REQUESTED 마일스톤
     * - 일시지급 방식: cancel_reason이 "[지급요청]"이어야 함
     * - 모든 마일스톤이 DEPOSITED 또는 PAID면 자동으로 COMPLETED로 변경
     * 
     * [트랜잭션]
     * - @Transactional: 상태 변경이 모두 성공해야 커밋
     * - 예외 발생 시 자동 롤백
     * 
     * [호출 위치]
     * - ClientContractManagementController.approvePayment(): 클라이언트 계약 관리 페이지
     * - ContractApiController: REST API를 통한 지급 수락
     * 
     * @param contractId 계약 ID
     * @param step 마일스톤 단계 (null이면 모든 REQUESTED 마일스톤, 일시지급은 항상 null)
     * @return 업데이트된 마일스톤 개수 (일시지급은 항상 1)
     * 
     * ============================================================================
     */
    @Transactional
    public int approvePayment(Integer contractId, Integer step) {
        // 계약 상태 확인 (PAID 또는 COMPLETED여야 함)
        ContractVO contract = contractMapper.selectContractById(contractId);
        if (contract == null) {
            throw new IllegalArgumentException("계약을 찾을 수 없습니다: " + contractId);
        }
        if (!ContractStatus.PAID.name().equals(contract.getContractStatus()) 
                && !ContractStatus.COMPLETED.name().equals(contract.getContractStatus())) {
            throw new IllegalStateException("결제 완료 또는 정산 완료된 계약만 지급 수락할 수 있습니다. 현재 상태: " + contract.getContractStatus());
        }
        
        // 일시지급이고 cancel_reason이 "[지급요청]"인 경우
        if (("FIXED".equals(contract.getPaymentMethod()) || "FULL".equals(contract.getPaymentMethod()) || contract.getPaymentMethod() == null)
                && "[지급요청]".equals(contract.getCancelReason())) {
            // 일시지급 수락: COMPLETED로 변경하고 cancel_reason 초기화
            contractMapper.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);
            // cancel_reason을 명시적으로 null로 설정
            contractMapper.updateCancelReason(contractId, null);
            logger.info("일시지급 수락: contractId={}", contractId);
            return 1;
        }
        
        // 마일스톤 상태 업데이트: REQUESTED → DEPOSITED (입금 완료)
        // step이 null이면 모든 REQUESTED 마일스톤을 DEPOSITED로 변경 (전체 수락)
        if (step == null) {
            // 모든 REQUESTED 마일스톤을 DEPOSITED로 변경
            List<ContractMilestoneVO> milestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
            int count = 0;
            
            // 마일스톤이 있는 경우
            for (ContractMilestoneVO milestone : milestones) {
                if ("REQUESTED".equals(milestone.getStatus())) {
                    contractMilestoneMapper.updateMilestoneStatus(contractId, milestone.getStep(), "DEPOSITED");
                    count++;
                }
            }
            
            // 모든 마일스톤이 DEPOSITED 또는 PAID인지 확인
            boolean allDepositedOrPaid = true;
            for (ContractMilestoneVO milestone : milestones) {
                String status = milestone.getStatus();
                if (!"DEPOSITED".equals(status) && !"PAID".equals(status)) {
                    allDepositedOrPaid = false;
                    break;
                }
            }
            
            // 모든 마일스톤이 DEPOSITED 또는 PAID면 COMPLETED로 변경
            if (allDepositedOrPaid && !milestones.isEmpty()) {
                contractMapper.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);
            }
            
            return count;
        } else {
            // 특정 마일스톤만 DEPOSITED로 변경
            int updated = contractMilestoneMapper.updateMilestoneStatus(contractId, step, "DEPOSITED");
            
            // 모든 마일스톤이 DEPOSITED 또는 PAID인지 확인
            List<ContractMilestoneVO> allMilestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
            boolean allDepositedOrPaid = true;
            for (ContractMilestoneVO milestone : allMilestones) {
                String status = milestone.getStatus();
                if (!"DEPOSITED".equals(status) && !"PAID".equals(status)) {
                    allDepositedOrPaid = false;
                    break;
                }
            }
            
            // 모든 마일스톤이 DEPOSITED 또는 PAID면 COMPLETED로 변경
            if (allDepositedOrPaid && !allMilestones.isEmpty()) {
                contractMapper.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);
            }
            
            return updated;
        }
    }
    
    /**
     * ============================================================================
     * 클라이언트 지급 거부
     * ============================================================================
     * 
     * [기능]
     * 클라이언트가 프리랜서의 지급 요청을 거부하는 메서드입니다.
     * 프리랜서가 재요청할 수 있도록 상태를 되돌립니다.
     * 마일스톤 방식과 일시지급 방식을 모두 지원하며, 일시지급의 경우 cancel_reason을
     * null로 초기화하여 재요청 가능 상태로 만듭니다.
     * 
     * [연관 파일]
     * - ClientContractManagementController.rejectPayment(): 클라이언트가 지급 거부 버튼 클릭 시 호출
     * - ContractMapper.updateCancelReason(): 일시지급 거부 시 cancel_reason을 null로 초기화
     * - ContractMilestoneMapper.updateMilestoneStatus(): 마일스톤 거부 시 WAITING으로 되돌림
     * - contractManagement.jsp: 클라이언트가 지급 거부 버튼을 클릭하는 UI
     * 
     * [처리 흐름]
     * 1. 계약 상태 검증 (PAID 또는 COMPLETED여야 함)
     * 2. 결제 방식 확인:
     *    a) 일시지급 (FIXED/FULL/null) + cancel_reason = "[지급요청]"
     *       → cancel_reason을 null로 초기화 (재요청 가능 상태로 복구)
     *       → 계약 상태는 PAID 유지 (정산 대기 상태 유지)
     *       → 프리랜서가 다시 requestPayment()를 호출할 수 있음
     *    b) 마일스톤 방식
     *       → 마일스톤 상태를 REQUESTED → WAITING으로 되돌림
     *       → 프리랜서가 다시 requestPayment()를 호출할 수 있음
     * 
     * [일시지급 지급 거부 구현 방식]
     * cancel_reason = "[지급요청]"인 일시지급 계약을 거부하면:
     * 1. cancel_reason을 null로 초기화 (명시적으로 updateCancelReason() 호출)
     * 2. 계약 상태는 PAID 유지 (정산 대기 상태 유지)
     * 3. 프리랜서가 다시 requestPayment()를 호출하여 재요청 가능
     * 
     * [상태 전이]
     * 마일스톤 방식:
     *   - 마일스톤 상태: REQUESTED → WAITING
     *   - 계약 상태: PAID (변경 없음)
     * 
     * 일시지급 방식:
     *   - cancel_reason: "[지급요청]" → null
     *   - 계약 상태: PAID (변경 없음)
     * 
     * [비즈니스 규칙]
     * - 계약 상태가 PAID 또는 COMPLETED여야 함
     * - 마일스톤 방식: step이 지정되면 해당 마일스톤만, null이면 모든 REQUESTED 마일스톤
     * - 일시지급 방식: cancel_reason이 "[지급요청]"이어야 함
     * - 거부 후에도 프리랜서가 재요청할 수 있어야 함 (상호작용 가능)
     * 
     * [트랜잭션]
     * - @Transactional: 상태 변경이 모두 성공해야 커밋
     * - 예외 발생 시 자동 롤백
     * 
     * [호출 위치]
     * - ClientContractManagementController.rejectPayment(): 클라이언트 계약 관리 페이지
     * - ContractApiController: REST API를 통한 지급 거부
     * 
     * @param contractId 계약 ID
     * @param step 마일스톤 단계 (null이면 모든 REQUESTED 마일스톤, 일시지급은 항상 null)
     * @return 업데이트된 마일스톤 개수 (일시지급은 항상 1)
     * 
     * ============================================================================
     */
    @Transactional
    public int rejectPayment(Integer contractId, Integer step) {
        // 계약 상태 확인 (PAID 또는 COMPLETED여야 함)
        ContractVO contract = contractMapper.selectContractById(contractId);
        if (contract == null) {
            throw new IllegalArgumentException("계약을 찾을 수 없습니다: " + contractId);
        }
        if (!ContractStatus.PAID.name().equals(contract.getContractStatus()) 
                && !ContractStatus.COMPLETED.name().equals(contract.getContractStatus())) {
            throw new IllegalStateException("결제 완료 또는 정산 완료된 계약만 지급 거부할 수 있습니다. 현재 상태: " + contract.getContractStatus());
        }
        
        // 일시지급이고 cancel_reason이 "[지급요청]"인 경우
        if (("FIXED".equals(contract.getPaymentMethod()) || "FULL".equals(contract.getPaymentMethod()) || contract.getPaymentMethod() == null)
                && "[지급요청]".equals(contract.getCancelReason())) {
            // 일시지급 거부: cancel_reason을 null로 변경 (다시 요청 가능)
            contractMapper.updateCancelReason(contractId, null);
            logger.info("일시지급 거부: contractId={}, cancel_reason을 null로 설정", contractId);
            return 1;
        }
        
        // 마일스톤 상태 업데이트: REQUESTED → WAITING
        // step이 null이면 모든 REQUESTED 마일스톤을 WAITING으로 변경
        if (step == null) {
            // 모든 REQUESTED 마일스톤을 WAITING으로 변경
            List<ContractMilestoneVO> milestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
            int count = 0;
            
            for (ContractMilestoneVO milestone : milestones) {
                if ("REQUESTED".equals(milestone.getStatus())) {
                    contractMilestoneMapper.updateMilestoneStatus(contractId, milestone.getStep(), "WAITING");
                    count++;
                }
            }
            
            return count;
        } else {
            // 특정 마일스톤만 WAITING으로 변경
            return contractMilestoneMapper.updateMilestoneStatus(contractId, step, "WAITING");
        }
    }
    
    /**
     * ============================================================================
     * 마일스톤 지급 완료 처리 (플랫폼에서 실제 지급 완료 시)
     * ============================================================================
     * 
     * [기능]
     * 플랫폼에서 실제 지급이 완료되면 마일스톤 상태를 PAID로 변경하고,
     * 모든 마일스톤이 PAID가 되면 계약 상태를 COMPLETED로 변경하는 메서드입니다.
     * 이는 에스크로 시스템에서 실제 지급이 완료된 후 호출되는 최종 단계입니다.
     * 
     * [연관 파일]
     * - ContractMilestoneMapper.updateMilestoneStatus(): 마일스톤 상태 업데이트
     * - ContractMapper.updateContractStatus(): 계약 상태 업데이트
     * - contractManagement.jsp: 클라이언트가 지급 완료 처리하는 UI
     * - freelancerContractList.jsp: 프리랜서가 지급 완료 확인하는 UI
     * 
     * [처리 흐름]
     * 1. 마일스톤 상태 업데이트: DEPOSITED → PAID
     *    - step이 null이면 모든 DEPOSITED 마일스톤을 PAID로 변경
     *    - step이 지정되면 해당 마일스톤만 PAID로 변경
     * 2. 모든 마일스톤 상태 확인
     *    - 계약의 모든 마일스톤을 조회하여 상태 확인
     *    - 모든 마일스톤이 PAID인지 검증
     * 3. 계약 상태 업데이트 (조건부)
     *    - 모든 마일스톤이 PAID이고 마일스톤이 존재하면
     *    - 계약 상태를 COMPLETED로 변경
     * 
     * [상태 전이]
     * 
     * 마일스톤 상태:
     * - DEPOSITED → PAID
     *   * 에스크로에서 출금하여 프리랜서에게 실제 지급 완료
     *   * 최종 완료 상태 (더 이상 변경 불가)
     * 
     * 계약 상태 (조건부):
     * - 모든 마일스톤이 PAID면: PAID → COMPLETED
     *   * 모든 지급이 완료되어 계약이 성공적으로 종료
     *   * 계약 완료 후 평가 입력 가능
     * 
     * [비즈니스 규칙]
     * - 마일스톤 상태가 DEPOSITED여야만 PAID로 변경 가능
     * - step이 null이면 모든 DEPOSITED 마일스톤을 일괄 처리
     * - step이 지정되면 해당 마일스톤만 처리
     * - 모든 마일스톤이 PAID가 되면 자동으로 계약 상태를 COMPLETED로 변경
     * - 마일스톤이 없는 계약(일시지급)은 이 메서드를 사용하지 않음
     * 
     * [에스크로 시스템 흐름]
     * 
     * 1. 클라이언트가 전체 예산을 에스크로에 입금 (finalizeContract)
     *    - 계약 상태: SIGNED → PAID
     * 
     * 2. 프리랜서가 작업 완료 후 지급 요청 (requestPayment)
     *    - 마일스톤 상태: WAITING → REQUESTED
     * 
     * 3. 클라이언트가 지급 수락 (approvePayment)
     *    - 마일스톤 상태: REQUESTED → DEPOSITED
     *    - 에스크로에서 출금 준비 완료
     * 
     * 4. 플랫폼에서 실제 지급 완료 (completeMilestonePayment) ← 이 메서드
     *    - 마일스톤 상태: DEPOSITED → PAID
     *    - 프리랜서에게 실제 지급 완료
     *    - 모든 마일스톤이 PAID면 계약 상태: PAID → COMPLETED
     * 
     * [트랜잭션]
     * - @Transactional: 마일스톤 상태 변경과 계약 상태 변경이 모두 성공해야 커밋
     * - 예외 발생 시 자동 롤백
     * 
     * [주의사항]
     * - 마일스톤이 없는 계약(일시지급)은 이 메서드를 사용하지 않음
     * - 일시지급은 approvePayment()에서 바로 COMPLETED로 변경
     * - step이 null이면 모든 DEPOSITED 마일스톤을 처리 (일괄 처리)
     * - 모든 마일스톤이 PAID가 되면 자동으로 COMPLETED로 변경 (수동 호출 불필요)
     * 
     * [호출 위치]
     * - 외부 결제 시스템 연동: 실제 지급 완료 후 호출
     * - 관리자 페이지: 수동으로 지급 완료 처리
     * - ContractApiController: REST API를 통한 지급 완료 처리
     * 
     * @param contractId 계약 ID (필수)
     * @param step 마일스톤 단계 (선택, null이면 모든 DEPOSITED 마일스톤 처리)
     *             - null: 모든 DEPOSITED 마일스톤을 PAID로 변경
     *             - 지정: 해당 마일스톤만 PAID로 변경
     * @return 업데이트된 마일스톤 개수
     *         - step이 null이면 업데이트된 마일스톤 개수
     *         - step이 지정되면 0 또는 1
     * 
     * ============================================================================
     */
    @Transactional
    public int completeMilestonePayment(Integer contractId, Integer step) {
        // 마일스톤 상태 업데이트: DEPOSITED → PAID
        int updatedCount;
        if (step == null) {
            // 모든 DEPOSITED 마일스톤을 PAID로 변경
            List<ContractMilestoneVO> milestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
            updatedCount = 0;
            for (ContractMilestoneVO milestone : milestones) {
                if ("DEPOSITED".equals(milestone.getStatus())) {
                    contractMilestoneMapper.updateMilestoneStatus(contractId, milestone.getStep(), "PAID");
                    updatedCount++;
                }
            }
        } else {
            updatedCount = contractMilestoneMapper.updateMilestoneStatus(contractId, step, "PAID");
        }
        
        // 모든 마일스톤이 PAID인지 확인
        List<ContractMilestoneVO> allMilestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
        boolean allPaid = true;
        for (ContractMilestoneVO milestone : allMilestones) {
            if (!"PAID".equals(milestone.getStatus())) {
                allPaid = false;
                break;
            }
        }
        
        // 모든 마일스톤이 PAID면 계약 상태를 COMPLETED로 변경
        if (allPaid && !allMilestones.isEmpty()) {
            contractMapper.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);
        }
        
        return updatedCount;
    }
}
