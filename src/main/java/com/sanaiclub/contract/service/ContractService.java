package com.sanaiclub.contract.service;

import com.sanaiclub.contract.model.vo.*;
import com.sanaiclub.contract.model.dto.*;
import com.sanaiclub.contract.model.enums.ContractStatus;
import com.sanaiclub.contract.dao.ContractProjectDao;
import com.sanaiclub.contract.dao.ContractFreelancerDao;
import com.sanaiclub.contract.dao.ContractDao;
import com.sanaiclub.contract.dao.ContractClientDao;
import com.sanaiclub.common.util.AuthContext;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 계약 비즈니스 로직 서비스
 * 
 * [역할]
 * - 계약 CRUD 및 비즈니스 로직 처리
 * - 계약 상태 관리 (WAITING, SIGNED, TERMINATED, COMPLETED)
 * - 프로젝트/프리랜서/클라이언트 정보 조회
 * - VO ↔ DTO 변환
 * 
 * [주요 기능]
 * - createContract: 계약 생성 (INSERT)
 * - updateContract: 계약 수정 (UPDATE)
 * - getContractByPathPattern: 경로 패턴으로 기존 계약 조회 (UPDATE vs INSERT 판단)
 * - acceptContract/rejectContract: 계약 수락/거절
 * - finalizeContract/cancelContract: 계약 최종 수락/취소
 * 
 * [데이터 흐름]
 * - Controller → Service → DAO → DB
 * - DTO (Request/Response) ↔ VO (DB Entity)
 */
@Service
public class ContractService {

    private static final Logger logger = LoggerFactory.getLogger(ContractService.class);

    private final ContractProjectDao contractProjectDao;
    private final ContractFreelancerDao contractFreelancerDao;
    private final ContractClientDao contractClientDao;
    private final ContractDao contractDao;

    /**
     * 생성자 주입
     * 
     * @param contractProjectDao 프로젝트 DAO
     * @param contractFreelancerDao 프리랜서 DAO
     * @param contractClientDao 클라이언트 DAO
     * @param contractDao 계약 DAO
     */
    public ContractService(
            ContractProjectDao contractProjectDao,
            ContractFreelancerDao contractFreelancerDao,
            ContractClientDao contractClientDao,
            ContractDao contractDao
    ) {
        this.contractProjectDao = contractProjectDao;
        this.contractFreelancerDao = contractFreelancerDao;
        this.contractClientDao = contractClientDao;
        this.contractDao = contractDao;
    }

    /**
     * 계약 생성 (INSERT)
     * 
     * [기능]
     * - 새 계약을 DB에 저장
     * - 계약 상태는 기본값 WAITING
     * - contracted_at은 현재 시간으로 설정
     * 
     * [처리 흐름]
     * 1. DTO → VO 변환
     * 2. 계약 정보 저장 (MyBatis useGeneratedKeys로 contractId 자동 생성)
     * 3. 마일스톤 저장 (MILESTONE 타입일 때)
     * 
     * [트랜잭션]
     * - @Transactional: 계약 저장과 마일스톤 저장이 모두 성공해야 커밋
     * 
     * @param dto 계약 생성 요청 DTO
     * @return 생성된 계약 ID
     */
    @Transactional
    public Integer createContract(ContractCreateRequestDTO dto) {
        // DTO → VO 변환
        // 계약 상태가 설정되지 않았으면 기본값 WAITING
        String contractStatus = dto.getContractStatus() != null ? dto.getContractStatus() : ContractStatus.WAITING.name();
        // contracted_at은 현재 시간으로 설정 (INSERT 시)
        String contractedAt = java.time.LocalDateTime.now().toString().substring(0, 19).replace('T', ' ');
        
        ContractVO contract = ContractVO.builder()
            .contractStartDate(dto.getContractStartDate())
            .contractEndDate(dto.getContractEndDate())
            .totalBudget(dto.getTotalBudget())
            .paymentMethod(dto.getPaymentMethod())
            .contractStatus(contractStatus)
            .originContractUrl(dto.getOriginContractUrl())
            .contractedAt(contractedAt)
            .build();
        
        // 계약 저장 (useGeneratedKeys로 contractId 자동 생성)
        // MyBatis가 selectKey로 resultMap의 contractId에 설정
        java.util.Map<String, Object> resultMap = new java.util.HashMap<>();
        contractDao.insertContract(contract, resultMap);
        Integer contractId = (Integer) resultMap.get("contractId");
        
        // 마일스톤 저장 (MILESTONE 타입일 때)
        if (dto.getMilestones() != null && !dto.getMilestones().isEmpty() && contractId != null) {
            for (ContractMilestoneRequestDTO milestoneDto : dto.getMilestones()) {
                contractDao.insertMilestone(
                    contractId,
                    milestoneDto.getStep(),
                    milestoneDto.getTitle(),
                    milestoneDto.getDescription(),
                    milestoneDto.getAmount()
                );
            }
        }
        
        return contractId;
    }

    /**
     * 로그인 클라이언트 조회
     */
    public ContractClientVO getClientByLoginUser() {
        Integer userId = AuthContext.getCurrentUserId();
        if (userId == null) return null;
        return contractClientDao.findByUserId(userId);
    }

    /**
     * 계약 단건 조회
     */
    public ContractResponseDTO getContractById(Integer contractId) {
        ContractVO contract = contractDao.selectContractById(contractId);
        if (contract == null) {
            return null;
        }
        
        // VO → DTO 변환
        ContractResponseDTO dto = toResponseDTO(contract);
        
        // 마일스톤 조회 및 변환
        List<ContractMilestoneVO> milestoneVOs = contractDao.selectMilestonesByContractId(contractId);
        if (milestoneVOs != null && !milestoneVOs.isEmpty()) {
            List<ContractMilestoneResponseDTO> milestoneDTOs = milestoneVOs.stream()
                .map(this::toMilestoneResponseDTO)
                .collect(Collectors.toList());
            dto.setMilestones(milestoneDTOs);
        }
        
        // 요구사항 세팅 (DB에 없으므로 빈 리스트로 초기화)
        dto.setRequirements(new java.util.ArrayList<>());
        
        return dto;
    }

    /**
     * 계약 수락
     * 
     * [기능]
     * - 프리랜서가 계약을 수락하여 상태를 SIGNED로 변경
     * 
     * [상태 변경]
     * - WAITING → SIGNED
     * 
     * @param contractId 계약 ID
     * @param freelancerId 프리랜서 ID (현재는 미사용, 향후 권한 검증에 사용 예정)
     */
    public void acceptContract(Integer contractId, Integer freelancerId) {
        contractDao.updateContractStatus(contractId, ContractStatus.SIGNED.name(), null);
    }

    /**
     * 계약 거절
     * 
     * [기능]
     * - 프리랜서가 계약을 거절하여 상태를 TERMINATED로 변경
     * 
     * [상태 변경]
     * - WAITING → TERMINATED
     * - cancel_reason에 거절 사유 저장
     * 
     * @param contractId 계약 ID
     * @param freelancerId 프리랜서 ID (현재는 미사용, 향후 권한 검증에 사용 예정)
     * @param reason 거절 사유
     */
    public void rejectContract(Integer contractId, Integer freelancerId, String reason) {
        contractDao.updateContractStatus(contractId, ContractStatus.TERMINATED.name(), reason);
    }
    /**
     * 클라이언트의 프로젝트 목록 조회
     */
    public List<ContractProjectVO> getProjectsByClientId(Integer clientId) {
        return contractProjectDao.findByClientId(clientId);
    }

    /**
     * 프로젝트 단건 조회
     */
    public ContractProjectVO getProjectById(Integer id) {
        return contractProjectDao.findById(id);
    }

    /**
     * 프로젝트의 프리랜서 목록 조회
     */
    public List<ContractFreelancerVO> getFreelancersByProjectId(Integer projectId) {
        return contractFreelancerDao.findByProjectId(projectId);
    }

    /**
     * 프리랜서 단건 조회
     */
    public ContractFreelancerVO getFreelancerById(Integer id) {
        return contractFreelancerDao.findById(id);
    }

    /**
     * 클라이언트 단건 조회
     */
    public ContractClientVO getClientById(Integer clientId) {
        return contractClientDao.findById(clientId);
    }

    /**
     * 계약의 마일스톤 목록 조회
     */
    public List<ContractMilestoneResponseDTO> getMilestonesByContractId(Integer contractId) {
        List<ContractMilestoneVO> milestoneVOs = contractDao.selectMilestonesByContractId(contractId);
        return milestoneVOs.stream()
            .map(this::toMilestoneResponseDTO)
            .collect(Collectors.toList());
    }

    /**
     * 모든 프리랜서 목록 조회
     */
    public List<ContractFreelancerVO> findAllFreelancers() {
        return contractFreelancerDao.findAll();
    }

    /**
     * PDF 파일 경로를 contracts.origin_contract_url에 업데이트
     */
    @Transactional
    public void updateOriginContractUrl(Integer contractId, String originContractUrl) {
        contractDao.updateOriginContractUrl(contractId, originContractUrl);
    }
    
    /**
     * 특정 프로젝트 폴더 패턴과 일치하는 확정된 계약의 origin_contract_url 목록 조회
     * 경로 패턴: contracts/{clientId}/{projectId}/%
     */
    public List<String> getOriginContractUrlsByPathPattern(String pathPattern) {
        return contractDao.selectOriginContractUrlsByPathPattern(pathPattern);
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
        ContractVO contract = contractDao.selectContractByPathPattern(clientId, projectId, freelancerId);
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
     * 
     * [처리 흐름]
     * 1. 기존 계약 조회 (contracted_at 등 기존 값 유지)
     * 2. DTO → VO 변환 (기존 값 유지)
     * 3. 기존 마일스톤 삭제
     * 4. 계약 정보 업데이트
     * 5. 새로운 마일스톤 추가
     * 
     * [기존 값 유지]
     * - contracted_at: 기존 값 유지 (수정 시점이 아님)
     * - platformContractUrl, aiReportUrl: 기존 값 유지
     * - completedAt, cancelReason: 기존 값 유지
     * - 평가 관련 필드: 기존 값 유지
     * 
     * [트랜잭션]
     * - @Transactional: 마일스톤 삭제, 계약 업데이트, 마일스톤 추가가 모두 성공해야 커밋
     * 
     * @param dto 계약 수정 요청 DTO
     * @throws IllegalStateException 계약을 찾을 수 없을 때
     */
    @Transactional
    public void updateContract(ContractUpdateRequestDTO dto) {
        // 계약 상태가 설정되지 않았으면 WAITING으로 설정
        String contractStatus = dto.getContractStatus() != null && !dto.getContractStatus().isEmpty() 
            ? dto.getContractStatus() : ContractStatus.WAITING.name();
        
        // 기존 계약 조회 (기존 값 유지를 위해)
        ContractVO existingContract = contractDao.selectContractById(dto.getContractId());
        if (existingContract == null) {
            throw new IllegalStateException("계약을 찾을 수 없습니다: " + dto.getContractId());
        }
        
        // DTO → VO 변환 (기존 값 유지)
        // contracted_at은 기존 값 유지 (수정 시점이 아님)
        ContractVO contract = ContractVO.builder()
            .contractId(dto.getContractId())
            .contractStartDate(dto.getContractStartDate())
            .contractEndDate(dto.getContractEndDate())
            .totalBudget(dto.getTotalBudget())
            .paymentMethod(dto.getPaymentMethod())
            .contractStatus(contractStatus)
            .originContractUrl(dto.getOriginContractUrl())
            .platformContractUrl(existingContract.getPlatformContractUrl())
            .aiReportUrl(existingContract.getAiReportUrl())
            .contractedAt(existingContract.getContractedAt()) // 기존 값 유지
            .completedAt(existingContract.getCompletedAt())
            .cancelReason(existingContract.getCancelReason())
            .clientRating(existingContract.getClientRating())
            .clientExperience(existingContract.getClientExperience())
            .clientIsRenewalIntended(existingContract.getClientIsRenewalIntended())
            .freelancerRating(existingContract.getFreelancerRating())
            .freelancerExperience(existingContract.getFreelancerExperience())
            .build();
        
        // 기존 마일스톤 삭제 (새로운 마일스톤으로 교체)
        contractDao.deleteMilestonesByContractId(dto.getContractId());
        
        // 계약 정보 업데이트
        contractDao.updateContract(contract);
        
        // 새로운 마일스톤 추가
        if (dto.getMilestones() != null && !dto.getMilestones().isEmpty()) {
            for (ContractMilestoneRequestDTO milestoneDto : dto.getMilestones()) {
                contractDao.insertMilestone(
                    dto.getContractId(),
                    milestoneDto.getStep(),
                    milestoneDto.getTitle(),
                    milestoneDto.getDescription(),
                    milestoneDto.getAmount()
                );
            }
        }
    }
    
    /**
     * 클라이언트의 계약 목록 조회
     * 경로 패턴: contracts/{clientId}/%
     */
    public List<ContractResponseDTO> getContractsByClientPathPattern(String pathPattern) {
        List<ContractVO> contracts = contractDao.selectContractsByClientPathPattern(pathPattern);
        return contracts.stream()
            .map(this::toResponseDTO)
            .collect(Collectors.toList());
    }
    
    /**
     * 계약 최종 수락 (결제 완료)
     * 
     * [기능]
     * - 클라이언트가 계약을 최종 수락하여 상태를 COMPLETED로 변경
     * - 결제 완료 후 호출
     * 
     * [상태 변경]
     * - SIGNED → COMPLETED
     * 
     * @param contractId 계약 ID
     */
    public void finalizeContract(Integer contractId) {
        contractDao.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);
    }

    /**
     * 계약 취소
     * 
     * [기능]
     * - 클라이언트가 계약을 취소하여 상태를 TERMINATED로 변경
     * 
     * [상태 변경]
     * - WAITING/SIGNED → TERMINATED
     * - cancel_reason에 취소 사유 저장
     * 
     * @param contractId 계약 ID
     * @param reason 취소 사유
     */
    public void cancelContract(Integer contractId, String reason) {
        contractDao.updateContractStatus(contractId, ContractStatus.TERMINATED.name(), reason);
    }
    
    /**
     * 모든 계약 목록 조회 (프리랜서용)
     */
    public List<ContractResponseDTO> getAllContracts() {
        List<ContractVO> contracts = contractDao.selectAllContracts();
        return contracts.stream()
            .map(this::toResponseDTO)
            .collect(Collectors.toList());
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
    
    private ContractMilestoneResponseDTO toMilestoneResponseDTO(ContractMilestoneVO vo) {
        ContractMilestoneResponseDTO dto = new ContractMilestoneResponseDTO();
        dto.setStep(vo.getStep());
        dto.setTitle(vo.getTitle());
        dto.setDescription(vo.getDescription());
        dto.setAmount(vo.getAmount());
        return dto;
    }
}
