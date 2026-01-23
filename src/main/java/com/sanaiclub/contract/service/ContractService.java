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
 * - 계약 도메인의 모든 비즈니스 로직을 처리하는 서비스 계층
 * - 계약 CRUD 작업 및 상태 관리
 * - 여러 Mapper를 조합하여 복잡한 비즈니스 로직 구현
 * - 트랜잭션 관리 및 데이터 일관성 보장
 * - VO(Value Object) ↔ DTO(Data Transfer Object) 변환
 * 
 * [계약 상태 관리]
 * - WAITING: 계약 대기 중 (생성 직후 기본 상태)
 * - SIGNED: 계약 서명 완료 (프리랜서 수락)
 * - TERMINATED: 계약 취소/거절
 * - COMPLETED: 계약 완료 (결제 완료 후)
 * 
 * [상태 전이 흐름]
 * WAITING → SIGNED → COMPLETED
 *    ↓         ↓
 * TERMINATED TERMINATED
 * 
 * [주요 기능]
 * 1. 계약 생성/수정
 *    - createContract: 새 계약 생성 (INSERT) + 마일스톤 저장
 *    - updateContract: 기존 계약 수정 (UPDATE) + 마일스톤 삭제/추가
 * 
 * 2. 계약 조회
 *    - getContractById: 계약 ID로 단건 조회
 *    - getContractByPathPattern: 경로 패턴으로 기존 계약 조회 (UPDATE vs INSERT 판단)
 *    - getContractsByClientPathPattern: 클라이언트의 계약 목록 조회
 *    - getAllContracts: 모든 계약 목록 조회 (프리랜서용)
 * 
 * 3. 계약 상태 변경
 *    - acceptContract: 프리랜서 계약 수락 (WAITING → SIGNED)
 *    - rejectContract: 프리랜서 계약 거절 (WAITING → TERMINATED)
 *    - finalizeContract: 계약 최종 완료 (SIGNED → COMPLETED)
 *    - cancelContract: 계약 취소 (WAITING/SIGNED → TERMINATED)
 * 
 * 4. 마일스톤 관리
 *    - getMilestonesByContractId: 계약의 마일스톤 목록 조회
 * 
 * 5. 파일 경로 관리
 *    - updateOriginContractUrl: 원본 계약서 파일 경로 업데이트
 *    - getOriginContractUrlsByPathPattern: 경로 패턴으로 파일 경로 목록 조회
 * 
 * [데이터 흐름]
 * Controller → Service → Mapper → DB
 * 
 * [계층별 책임]
 * - Controller: HTTP 요청/응답 처리, 파라미터 검증
 * - Service: 비즈니스 로직, 트랜잭션 관리, VO ↔ DTO 변환
 * - Mapper: SQL 쿼리 실행, DB 접근
 * 
 * [트랜잭션 처리]
 * - @Transactional 어노테이션으로 트랜잭션 관리
 * - createContract, updateContract: 여러 테이블 작업이 모두 성공해야 커밋
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
 * - ContractMapper: 계약 데이터 접근
 * - ContractMilestoneMapper: 마일스톤 데이터 접근
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
        // 1단계: 계약 정보 조회
        // ====================================================================
        
        ContractVO contract = contractMapper.selectContractById(contractId);
        if (contract == null) {
            // 계약이 존재하지 않으면 null 반환
            // Controller에서 404 에러 처리 또는 적절한 응답 반환
            return null;
        }
        
        // ====================================================================
        // 2단계: VO → DTO 변환
        // ====================================================================
        
        // ContractVO를 ContractResponseDTO로 변환
        // originContractUrl에서 projectId와 freelancerId 추출 포함
        ContractResponseDTO dto = toResponseDTO(contract);
        
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
     * 계약 수락
     * 
     * [기능]
     * - 프리랜서가 계약을 수락하여 상태를 SIGNED로 변경
     * - 계약이 활성화되어 작업을 시작할 수 있는 상태가 됨
     * 
     * [상태 변경]
     * - WAITING → SIGNED
     * - WAITING: 계약 대기 중 (프리랜서 검토 중)
     * - SIGNED: 계약 서명 완료 (프리랜서 수락, 작업 시작 가능)
     * 
     * [비즈니스 규칙]
     * - 프리랜서만 계약을 수락할 수 있음 (권한 검증 필요)
     * - WAITING 상태의 계약만 수락 가능
     * - SIGNED 상태로 변경되면 작업을 시작할 수 있음
     * 
     * [주의사항]
     * - freelancerId 파라미터는 현재 미사용
     * - 향후 권한 검증 로직 추가 예정 (해당 프리랜서가 계약을 수락할 권한이 있는지 확인)
     * - contractId가 존재하지 않으면 업데이트되지 않음 (에러 없음)
     * 
     * [호출 위치]
     * - FreelancerContractController: 프리랜서가 계약 수락 버튼 클릭 시
     * - ContractApiController: API를 통한 계약 수락
     * 
     * @param contractId 수락할 계약의 ID
     * @param freelancerId 프리랜서 ID (현재는 미사용, 향후 권한 검증에 사용 예정)
     */
    public void acceptContract(Integer contractId, Integer freelancerId) {
        // 계약 상태를 SIGNED로 변경
        // rejectReason은 null (수락이므로 취소 사유 없음)
        contractMapper.updateContractStatus(contractId, ContractStatus.SIGNED.name(), null);
    }

    /**
     * 계약 거절
     * 
     * [기능]
     * - 프리랜서가 계약을 거절하여 상태를 TERMINATED로 변경
     * - 거절 사유를 cancel_reason에 저장
     * 
     * [상태 변경]
     * - WAITING → TERMINATED
     * - WAITING: 계약 대기 중
     * - TERMINATED: 계약 취소/거절 (더 이상 진행 불가)
     * 
     * [비즈니스 규칙]
     * - 프리랜서만 계약을 거절할 수 있음 (권한 검증 필요)
     * - WAITING 상태의 계약만 거절 가능
     * - 거절 사유는 필수 (사용자에게 거절 이유를 입력받아야 함)
     * 
     * [주의사항]
     * - freelancerId 파라미터는 현재 미사용
     * - 향후 권한 검증 로직 추가 예정
     * - reason이 null이어도 저장 가능 (하지만 비즈니스 로직상 필수 권장)
     * - TERMINATED 상태로 변경되면 더 이상 수정 불가
     * 
     * [호출 위치]
     * - FreelancerContractController: 프리랜서가 계약 거절 버튼 클릭 시
     * - ContractApiController: API를 통한 계약 거절
     * 
     * @param contractId 거절할 계약의 ID
     * @param freelancerId 프리랜서 ID (현재는 미사용, 향후 권한 검증에 사용 예정)
     * @param reason 거절 사유 (사용자가 입력한 거절 이유)
     */
    public void rejectContract(Integer contractId, Integer freelancerId, String reason) {
        // 계약 상태를 TERMINATED로 변경하고 거절 사유 저장
        contractMapper.updateContractStatus(contractId, ContractStatus.TERMINATED.name(), reason);
    }
    
    /**
     * 계약의 마일스톤 목록 조회
     * 
     * [기능]
     * - 특정 계약의 모든 마일스톤을 조회
     * - 단계 순서대로 정렬된 마일스톤 목록 반환
     * 
     * [사용 시나리오]
     * - 계약 상세 페이지에서 마일스톤 목록 표시
     * - 결제 진행 상황 확인
     * - 계약 수정 시 기존 마일스톤 정보 조회
     * 
     * [반환 데이터]
     * - 마일스톤 목록 (step, title, description, amount)
     * - step_order 오름차순 정렬 (1단계, 2단계, 3단계...)
     * 
     * [주의사항]
     * - contractId가 존재하지 않거나 마일스톤이 없으면 빈 리스트 반환
     * - 결제 방식이 FIXED인 계약은 마일스톤이 없을 수 있음
     * - 결제 방식이 MILESTONE인 계약은 반드시 마일스톤 존재
     * 
     * [호출 위치]
     * - ContractService.getContractById(): 계약 조회 시 마일스톤 포함
     * - ContractFormController: 계약 상세 페이지
     * - ContractApiController: API로 마일스톤 목록 요청
     * 
     * @param contractId 조회할 계약의 ID
     * @return 마일스톤 목록 (List<ContractMilestoneResponseDTO>)
     *         - 마일스톤이 없으면 빈 리스트 반환
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
     * 같은 프로젝트/프리랜서 조합의 기존 계약 조회
     * 
     * [기능]
     * - UPDATE vs INSERT 판단을 위한 기존 계약 조회
     * - 경로 패턴: contracts/{clientId}/{projectId}/{freelancerId}/%
     * 
     * [조회 조건]
     * - 같은 clientId + projectId + freelancerId 조합
     * - contract_status != 'TERMINATED' (TERMINATED는 새 계약 생성 가능)
     * 
     * [사용 시나리오]
     * - ContractController.confirmContract()에서 호출
     * - 기존 계약이 있으면 UPDATE, 없으면 INSERT
     * 
     * @param clientId 클라이언트 ID
     * @param projectId 프로젝트 ID
     * @param freelancerId 프리랜서 ID
     * @return 기존 계약 정보 (없으면 null)
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
     * 계약 최종 완료 (결제 완료)
     * 
     * [기능]
     * - 클라이언트가 계약을 최종 수락하여 상태를 COMPLETED로 변경
     * - 결제 완료 후 호출되는 메서드
     * - 계약이 성공적으로 완료되었음을 의미
     * 
     * [상태 변경]
     * - SIGNED → COMPLETED
     * - SIGNED: 계약 서명 완료 (작업 진행 중)
     * - COMPLETED: 계약 완료 (결제 완료, 모든 작업 완료)
     * 
     * [비즈니스 규칙]
     * - 클라이언트만 계약을 완료 처리할 수 있음 (권한 검증 필요)
     * - SIGNED 상태의 계약만 완료 처리 가능
     * - 결제가 완료된 후에만 호출되어야 함
     * - COMPLETED 상태로 변경되면 더 이상 수정 불가
     * 
     * [후속 작업]
     * - 계약 완료 후 평가 입력 가능 (clientRating, freelancerRating 등)
     * - 재계약 의향 조사 가능 (clientIsRenewalIntended)
     * 
     * [주의사항]
     * - contractId가 존재하지 않으면 업데이트되지 않음 (에러 없음)
     * - 결제 완료 전에 호출되면 안 됨 (비즈니스 로직 검증 필요)
     * 
     * [호출 위치]
     * - ClientContractManagementController: 클라이언트가 결제 완료 후 완료 처리
     * - ContractApiController: API를 통한 계약 완료 처리
     * 
     * @param contractId 완료 처리할 계약의 ID
     */
    public void finalizeContract(Integer contractId) {
        // 계약 상태를 COMPLETED로 변경
        // 완료 처리이므로 취소 사유 없음 (null)
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
     * 
     * [비즈니스 규칙]
     * - 클라이언트만 계약을 취소할 수 있음 (권한 검증 필요)
     * - WAITING 또는 SIGNED 상태의 계약만 취소 가능
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
        contractMapper.updateContractStatus(contractId, ContractStatus.TERMINATED.name(), reason);
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
        // 모든 계약 조회
        List<ContractVO> contracts = contractMapper.selectAllContracts();
        
        // VO 리스트를 DTO 리스트로 변환
        return contracts.stream()
            .map(this::toResponseDTO)  // 각 VO를 DTO로 변환
            .collect(Collectors.toList());  // 리스트로 수집
    }
    
    // =========================================================
    // VO ↔ DTO 변환 메서드
    // =========================================================
    
    /**
     * ContractVO → ContractResponseDTO 변환
     * 
     * [기능]
     * - DB 엔티티(VO)를 응답 DTO로 변환
     * - originContractUrl에서 projectId와 freelancerId 추출
     * 
     * [경로 파싱]
     * - 형식: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
     * - pathParts[2] = projectId
     * - pathParts[3] = freelancerId
     * 
     * @param vo 계약 VO (DB 엔티티)
     * @return 계약 응답 DTO
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
     * ContractMilestoneVO → ContractMilestoneResponseDTO 변환
     * 
     * [기능]
     * - DB 엔티티(VO)를 응답 DTO로 변환
     * - 마일스톤 정보를 클라이언트에 전달하기 위한 변환
     * 
     * [변환 필드]
     * - step: 단계 순서 (1, 2, 3, ...)
     * - title: 마일스톤 제목
     * - description: 작업 범위/설명
     * - amount: 해당 마일스톤의 결제 금액
     * 
     * [사용 위치]
     * - getContractById(): 계약 조회 시 마일스톤 포함
     * - getMilestonesByContractId(): 마일스톤 목록 조회
     * 
     * @param vo 마일스톤 VO (DB 엔티티)
     * @return 마일스톤 응답 DTO
     */
    private ContractMilestoneResponseDTO toMilestoneResponseDTO(ContractMilestoneVO vo) {
        ContractMilestoneResponseDTO dto = new ContractMilestoneResponseDTO();
        dto.setStep(vo.getStep());                    // 단계 순서
        dto.setTitle(vo.getTitle());                  // 마일스톤 제목
        dto.setDescription(vo.getDescription());       // 작업 범위/설명
        dto.setAmount(vo.getAmount());                // 결제 금액
        return dto;
    }
}
