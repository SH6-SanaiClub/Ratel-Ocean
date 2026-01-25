package com.sanaiclub.contract.service;

import com.sanaiclub.contract.model.vo.*;
import com.sanaiclub.contract.model.dto.*;
import com.sanaiclub.contract.model.vo.ContractStatus;
import com.sanaiclub.contract.dao.ContractMapper;
import com.sanaiclub.contract.dao.ContractMilestoneMapper;

import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;


@Service
@RequiredArgsConstructor
public class ContractService {

    private static final Logger logger = LoggerFactory.getLogger(ContractService.class);

    private final ContractMapper contractMapper;
    private final ContractMilestoneMapper contractMilestoneMapper;

    /**
     * 계약 생성 (INSERT)
     */
    @Transactional
    public Integer createContract(ContractCreateRequestDTO dto) {
        // ====================================================================
        // 1단계: DTO → VO 변환
        // ====================================================================
        
        // 계약 상태 설정: DTO에 상태가 없으면 기본값 WAITING 사용
        // WAITING은 계약 생성 직후의 기본 상태 (프리랜서 수락 대기)
        ContractStatus contractStatus = dto.getContractStatus() != null
            ? dto.getContractStatus() 
            : ContractStatus.WAITING;
        
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
     */
    public void acceptContract(Integer contractId, Integer freelancerId) {
        // 계약 상태를 SIGNED로 변경
        // rejectReason은 null (수락이므로 취소 사유 없음)
        contractMapper.updateContractStatus(contractId, ContractStatus.SIGNED.name(), null);
    }

    /**
     * 계약 거절
     */
    public void rejectContract(Integer contractId, Integer freelancerId, String reason) {
        // 계약 상태를 TERMINATED로 변경하고 거절 사유 저장
        contractMapper.updateContractStatus(contractId, ContractStatus.TERMINATED.name(), reason);
    }
    
    /**
     * 계약의 마일스톤 목록 조회
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
     */
    @Transactional
    public void updateOriginContractUrl(Integer contractId, String originContractUrl) {
        contractMapper.updateOriginContractUrl(contractId, originContractUrl);
    }
    
    /**
     * 경로 패턴으로 계약서 파일 경로 목록 조회
     */
    public List<String> getOriginContractUrlsByPathPattern(String pathPattern) {
        return contractMapper.selectOriginContractUrlsByPathPattern(pathPattern);
    }
    
    /**
     * 같은 프로젝트/프리랜서 조합의 기존 계약 조회
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
     */
    @Transactional
    public void updateContract(ContractUpdateRequestDTO dto) {
        // ====================================================================
        // 1단계: 계약 상태 설정
        // ====================================================================
        
        // 계약 상태가 설정되지 않았으면 기본값 WAITING으로 설정
        // WAITING은 계약 수정 후에도 기본 상태로 유지
        ContractStatus contractStatus = dto.getContractStatus() != null ? dto.getContractStatus() : ContractStatus.WAITING;
        
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
     */
    public void finalizeContract(Integer contractId) {
        // 계약 상태를 COMPLETED로 변경
        // 완료 처리이므로 취소 사유 없음 (null)
        contractMapper.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);
    }

    /**
     * 계약 취소
     */
    public void cancelContract(Integer contractId, String reason) {
        // 계약 상태를 TERMINATED로 변경하고 취소 사유 저장
        contractMapper.updateContractStatus(contractId, ContractStatus.TERMINATED.name(), reason);
    }
    
    /**
     * 모든 계약 목록 조회 (프리랜서용)
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
     */
    private ContractMilestoneResponseDTO toMilestoneResponseDTO(ContractMilestoneVO vo) {
        ContractMilestoneResponseDTO dto = new ContractMilestoneResponseDTO();
        dto.setMilestoneId(vo.getMilestoneId());
        dto.setStep(vo.getStep());                    // 단계 순서
        dto.setTitle(vo.getTitle());                  // 마일스톤 제목
        dto.setDescription(vo.getDescription());       // 작업 범위/설명
        dto.setAmount(vo.getAmount());                // 결제 금액
        dto.setDueDate(vo.getDueDate());
        dto.setStatus(vo.getStatus());
        return dto;
    }

    /**
     * 계약 결제 상태 변경
     */
    public void updatePaymentStatus(Integer contractId, PaymentStatus paymentStatus) {
        contractMapper.updatePaymentStatus(contractId, paymentStatus.name());
    }
}
