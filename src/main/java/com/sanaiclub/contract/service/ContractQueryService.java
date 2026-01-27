package com.sanaiclub.contract.service;

import com.sanaiclub.contract.model.vo.ContractVO;
import com.sanaiclub.contract.model.vo.ContractMilestoneVO;
import com.sanaiclub.contract.model.dto.ContractResponseDTO;
import com.sanaiclub.contract.model.dto.ContractDetailDTO;
import com.sanaiclub.contract.model.dto.ContractMilestoneResponseDTO;
import com.sanaiclub.contract.model.enums.ContractStatus;
import com.sanaiclub.contract.dao.ContractMapper;
import com.sanaiclub.contract.dao.ContractMilestoneMapper;
import com.sanaiclub.project.dao.ProjectDetailMapper;
import com.sanaiclub.contract.util.ContractConverter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/** 계약 조회 전용 서비스 */
@Service
public class ContractQueryService {
    
    private static final Logger logger = LoggerFactory.getLogger(ContractQueryService.class);
    
    private final ContractMapper contractMapper;
    private final ContractMilestoneMapper contractMilestoneMapper;
    private final ProjectDetailMapper projectDetailMapper;
    
    public ContractQueryService(
            ContractMapper contractMapper,
            ContractMilestoneMapper contractMilestoneMapper,
            ProjectDetailMapper projectDetailMapper
    ) {
        this.contractMapper = contractMapper;
        this.contractMilestoneMapper = contractMilestoneMapper;
        this.projectDetailMapper = projectDetailMapper;
    }
    
    /** 계약 ID로 단건 조회 */
    public ContractResponseDTO getContractById(Integer contractId) {
        // 계약 정보 조회 (프로젝트 및 상대방 정보 포함)
        java.util.Map<String, Object> contractWithDetails = contractMapper.selectContractWithDetailsById(contractId);
        if (contractWithDetails == null || contractWithDetails.get("contractId") == null) {
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
        
        // ContractStatus 안전하게 변환
        ContractStatus contractStatus = null;
        if (contractWithDetails.get("contractStatus") != null) {
            try {
                String statusStr = (String) contractWithDetails.get("contractStatus");
                if (statusStr != null && !statusStr.isEmpty()) {
                    contractStatus = ContractStatus.valueOf(statusStr.toUpperCase());
                }
            } catch (IllegalArgumentException e) {
                logger.warn("잘못된 계약 상태 값: {}, contractId: {}", contractWithDetails.get("contractStatus"), contractId);
                contractStatus = null;
            }
        }
        
        // ContractVO Builder로 생성
        ContractVO contract = ContractVO.builder()
            .contractId(contractWithDetails.get("contractId") != null ? ((Number) contractWithDetails.get("contractId")).intValue() : null)
            .contractStartDate(dateToString.apply(contractWithDetails.get("contractStartDate")))
            .contractEndDate(dateToString.apply(contractWithDetails.get("contractEndDate")))
            .totalBudget(contractWithDetails.get("totalBudget") != null ? ((Number) contractWithDetails.get("totalBudget")).longValue() : null)
            .paymentMethod((String) contractWithDetails.get("paymentMethod"))
            .contractStatus(contractStatus)
            .originContractUrl((String) contractWithDetails.get("originContractUrl"))
            .contractedAt(dateToString.apply(contractWithDetails.get("contractedAt")))
            .completedAt(dateToString.apply(contractWithDetails.get("completedAt")))
            .cancelReason((String) contractWithDetails.get("cancelReason"))
            .clientRating(contractWithDetails.get("clientRating") != null ? ((Number) contractWithDetails.get("clientRating")).intValue() : null)
            .clientExperience((String) contractWithDetails.get("clientExperience"))
            .clientIsRenewalIntended((Boolean) contractWithDetails.get("clientIsRenewalIntended"))
            .freelancerRating(contractWithDetails.get("freelancerRating") != null ? ((Number) contractWithDetails.get("freelancerRating")).intValue() : null)
            .freelancerExperience((String) contractWithDetails.get("freelancerExperience"))
            .build();
        
        // VO → DTO 변환
        ContractResponseDTO dto = ContractConverter.toResponseDTO(contract);
        
        // 프로젝트 및 상대방 정보 설정
        dto.setProjectTitle((String) contractWithDetails.get("projectTitle"));
        dto.setFreelancerName((String) contractWithDetails.get("freelancerName"));
        dto.setClientName((String) contractWithDetails.get("clientName"));
        
        // 마일스톤 정보 조회 및 변환
        try {
            List<ContractMilestoneVO> milestoneVOs = contractMilestoneMapper.selectMilestonesByContractId(contractId);
            
            if (milestoneVOs != null && !milestoneVOs.isEmpty()) {
                List<ContractMilestoneResponseDTO> milestoneDTOs = milestoneVOs.stream()
                    .map(ContractConverter::toMilestoneResponseDTO)
                    .collect(Collectors.toList());
                dto.setMilestones(milestoneDTOs);
                logger.debug("마일스톤 조회 성공 (contractId: {}, 마일스톤 수: {})", contractId, milestoneDTOs.size());
            } else {
                dto.setMilestones(new java.util.ArrayList<>());
                logger.debug("마일스톤이 없습니다 (contractId: {})", contractId);
            }
        } catch (Exception e) {
            logger.error("마일스톤 조회 실패 (contractId: {}): {}", contractId, e.getMessage(), e);
            dto.setMilestones(new java.util.ArrayList<>());
        }
        
        return dto;
    }
    
    /** 계약의 마일스톤 목록 조회. step 오름차순 정렬. */
    public List<ContractMilestoneResponseDTO> getMilestonesByContractId(Integer contractId) {
        List<ContractMilestoneVO> milestoneVOs = contractMilestoneMapper.selectMilestonesByContractId(contractId);
        
        return milestoneVOs.stream()
            .map(ContractConverter::toMilestoneResponseDTO)
            .collect(Collectors.toList());
    }
    
    /** 계약 상세 정보 조회. 프로젝트, 프리랜서, 클라이언트, 회사 정보 포함. */
    public ContractDetailDTO getContractDetailForView(Integer contractId) {
        return contractMapper.selectContractDetailWithJoin(contractId);
    }
    
    /** 경로 패턴으로 기존 계약 조회. UPDATE vs INSERT 판단용. */
    public ContractResponseDTO getContractByPathPattern(Integer clientId, Integer projectId, Integer freelancerId) {
        ContractVO contract = contractMapper.selectContractByPathPattern(clientId, projectId, freelancerId);
        if (contract == null) {
            return null;
        }
        return ContractConverter.toResponseDTO(contract);
    }
    
    /** 클라이언트의 계약 목록 조회. origin_contract_url 패턴으로 필터링. */
    public List<ContractResponseDTO> getContractsByClientPathPattern(String pathPattern) {
        List<ContractVO> contracts = contractMapper.selectContractsByClientPathPattern(pathPattern);
        
        return contracts.stream()
            .map(ContractConverter::toResponseDTO)
            .collect(Collectors.toList());
    }
    
    /** 모든 계약 목록 조회. 마일스톤 집계 포함, 최신순 정렬. */
    public List<ContractResponseDTO> getAllContracts() {
        List<java.util.Map<String, Object>> contractsWithDetails = contractMapper.selectAllContractsWithDetails();
        
        return contractsWithDetails.stream()
            .map(this::mapToResponseDTO)
            .filter(dto -> {
                // null 상태를 가진 DTO는 필터링 (깨진 글자 방지)
                if (dto.getContractStatus() == null) {
                    logger.warn("contractStatus가 null인 계약 필터링됨: contractId={}", dto.getContractId());
                    return false;
                }
                return true;
            })
            .collect(Collectors.toList());
    }
    
    /** 클라이언트의 계약 목록 조회. origin_contract_url 패턴으로 필터링, 최신순 정렬. */
    public List<ContractResponseDTO> getContractsByClientId(Integer clientId) {
        logger.debug("클라이언트 계약 목록 조회 시작: clientId={}", clientId);
        List<java.util.Map<String, Object>> contractsWithDetails = 
            contractMapper.selectContractsByClientIdWithDetails(clientId);
        
        if (contractsWithDetails == null) {
            logger.warn("클라이언트 계약 목록 조회 결과가 null: clientId={}", clientId);
            return new ArrayList<>();
        }
        
        logger.debug("클라이언트 계약 목록 조회 결과: clientId={}, 조회된 계약 수={}", 
                clientId, contractsWithDetails.size());
        
        if (!contractsWithDetails.isEmpty()) {
            contractsWithDetails.forEach(contract -> {
                Object originUrl = contract.get("originContractUrl");
                Object contractId = contract.get("contractId");
                Object contractStatus = contract.get("contractStatus");
                logger.debug("계약 정보: contractId={}, originContractUrl={}, contractStatus={}", 
                        contractId, originUrl, contractStatus);
            });
        }
        
        return contractsWithDetails.stream()
            .map(this::mapToResponseDTO)
            .filter(dto -> {
                if (dto.getContractStatus() == null) {
                    logger.warn("contractStatus가 null인 계약 필터링됨: contractId={}, originContractUrl={}", 
                            dto.getContractId(), dto.getOriginContractUrl());
                    return false;
                }
                return true;
            })
            .collect(Collectors.toList());
    }
    
    /** 프리랜서의 계약 목록 조회. origin_contract_url에서 freelancerId 추출하여 필터링, 최신순 정렬. */
    public List<ContractResponseDTO> getContractsByFreelancerId(Integer freelancerId) {
        logger.debug("프리랜서 계약 목록 조회 시작: freelancerId={}", freelancerId);
        List<java.util.Map<String, Object>> contractsWithDetails = 
            contractMapper.selectContractsByFreelancerIdWithDetails(freelancerId);
        
        if (contractsWithDetails == null) {
            logger.warn("프리랜서 계약 목록 조회 결과가 null: freelancerId={}", freelancerId);
            return new ArrayList<>();
        }
        
        logger.debug("프리랜서 계약 목록 조회 결과: freelancerId={}, 조회된 계약 수={}", 
                freelancerId, contractsWithDetails.size());
        
        if (!contractsWithDetails.isEmpty()) {
            contractsWithDetails.forEach(contract -> {
                Object originUrl = contract.get("originContractUrl");
                logger.debug("계약 originContractUrl: contractId={}, originContractUrl={}", 
                        contract.get("contractId"), originUrl);
            });
        }
        
        return contractsWithDetails.stream()
            .map(this::mapToResponseDTO)
            .filter(dto -> {
                if (dto.getContractStatus() == null) {
                    logger.warn("contractStatus가 null인 계약 필터링됨: contractId={}, originContractUrl={}", 
                            dto.getContractId(), dto.getOriginContractUrl());
                    return false;
                }
                return true;
            })
            .collect(Collectors.toList());
    }
    
    /** 프로젝트 정보 조회. */
    public com.sanaiclub.project.model.vo.ProjectsVO getProjectById(Integer projectId) {
        return projectDetailMapper.selectProjectById(projectId);
    }
    
    /** 클라이언트의 프로젝트 목록 조회. READY 상태만 반환. */
    public List<com.sanaiclub.project.model.vo.ProjectsVO> getProjectsByClientId(Integer clientId) {
        return projectDetailMapper.selectProjectsByClientId(clientId);
    }
    
    /** 프로젝트별 프리랜서 목록 조회. */
    public List<java.util.Map<String, Object>> getFreelancersByProjectId(Integer projectId) {
        return projectDetailMapper.selectFreelancersByProjectId(projectId);
    }
    
    /** 경로 패턴으로 계약서 파일 경로 목록 조회. TERMINATED 제외. */
    public List<String> getOriginContractUrlsByPathPattern(String pathPattern) {
        return contractMapper.selectOriginContractUrlsByPathPattern(pathPattern);
    }
    
    // =========================================================
    // Private Helper Methods
    // =========================================================
    
    /** Map을 ContractResponseDTO로 변환. */
    private ContractResponseDTO mapToResponseDTO(java.util.Map<String, Object> map) {
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
            .contractStatus(map.get("contractStatus") != null 
                ? ContractConverter.tryParseContractStatus((String) map.get("contractStatus"), 
                    map.get("contractId") != null ? ((Number) map.get("contractId")).intValue() : null)
                : null)
            .originContractUrl((String) map.get("originContractUrl"))
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
        ContractResponseDTO dto = ContractConverter.toResponseDTO(vo);
        
        // 프로젝트 및 상대방 정보 설정
        dto.setProjectTitle((String) map.get("projectTitle"));
        dto.setFreelancerName((String) map.get("freelancerName"));
        dto.setClientName((String) map.get("clientName"));
        
        // 클라이언트 시점: 상대방은 프리랜서
        dto.setCounterpartName((String) map.get("freelancerName"));
        
        // 마일스톤 상태 집계 정보 설정
        dto.setTotalMilestones(getIntegerValue.apply(map.get("totalMilestones")));
        dto.setPaidMilestones(getIntegerValue.apply(map.get("paidMilestones")));
        dto.setRequestedMilestones(getIntegerValue.apply(map.get("requestedMilestones")));
        dto.setDepositedMilestones(getIntegerValue.apply(map.get("depositedMilestones")));
        dto.setWaitingMilestones(getIntegerValue.apply(map.get("waitingMilestones")));
        
        return dto;
    }
}
