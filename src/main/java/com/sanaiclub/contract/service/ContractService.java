package com.sanaiclub.contract.service;

import com.sanaiclub.contract.model.vo.*;
import com.sanaiclub.contract.model.dto.*;
import com.sanaiclub.contract.model.vo.ContractStatus;
import com.sanaiclub.contract.dao.ContractMapper;
import com.sanaiclub.contract.dao.ContractMilestoneMapper;
import com.sanaiclub.project.dao.ProjectDetailMapper;
import com.sanaiclub.project.model.vo.ProjectsVO;
import com.sanaiclub.user.dao.UserMapper;
import com.sanaiclub.user.dao.ClientProfileMapper;
import com.sanaiclub.user.dao.CompanyMapper;
import com.sanaiclub.payment.dao.WalletMapper;
import com.sanaiclub.payment.model.vo.WalletIoType;
import com.sanaiclub.payment.model.vo.FreelancerWalletVO;
import com.sanaiclub.payment.model.vo.WalletHistoryVO;

import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.util.stream.Collectors;


@Service
@RequiredArgsConstructor
public class ContractService {

    private static final Logger logger = LoggerFactory.getLogger(ContractService.class);

    private final ContractMapper contractMapper;
    private final ContractMilestoneMapper contractMilestoneMapper;
    private final ProjectDetailMapper projectDetailMapper;
    private final UserMapper userMapper;
    private final ClientProfileMapper clientProfileMapper;
    private final CompanyMapper companyMapper;
    private final WalletMapper walletMapper;

    /**
     * 계약 생성 (INSERT)
     */
    @Transactional
    public Integer createContract(ContractCreateRequestDTO dto) {

        ContractStatus contractStatus = dto.getContractStatus() != null
            ? dto.getContractStatus() 
            : ContractStatus.WAITING;
        
        String contractedAt = java.time.LocalDateTime.now()
            .toString()
            .substring(0, 19)
            .replace('T', ' ');
        
        ContractVO contract = ContractVO.builder()
            .contractStartDate(dto.getContractStartDate())
            .contractEndDate(dto.getContractEndDate())
            .totalBudget(dto.getTotalBudget())
            .paymentMethod(dto.getPaymentMethod())
            .contractStatus(contractStatus)
            .originContractUrl(dto.getOriginContractUrl())
            .contractedAt(contractedAt)
            .build();

        java.util.Map<String, Object> resultMap = new java.util.HashMap<>();
        contractMapper.insertContract(contract, resultMap);
        
        Integer contractId = (Integer) resultMap.get("contractId");

        if (dto.getMilestones() != null && !dto.getMilestones().isEmpty() && contractId != null) {
            for (ContractMilestoneRequestDTO milestoneDto : dto.getMilestones()) {
                contractMilestoneMapper.insertMilestone(
                    contractId,
                    milestoneDto.getStep(),
                    milestoneDto.getTitle(),
                    milestoneDto.getDescription(),
                    milestoneDto.getAmount()
                );
            }
        } else if ("FULL".equals(dto.getPaymentMethod()) && contractId != null) {
            contractMilestoneMapper.insertMilestone(
                    contractId,
                    1,
                    "프로젝트 완료 시 전액 지급",
                    "프로젝트 완료 후 전체 금액 일괄 지급",
                    dto.getTotalBudget()
            );
        }
        
        return contractId;
    }

    /**
     * 계약 단건 조회
     */
    public ContractResponseDTO getContractById(Integer contractId) {
        ContractVO contract = contractMapper.selectContractById(contractId);
        if (contract == null) {
            return null;
        }
        
        ContractResponseDTO dto = toResponseDTO(contract);
        
        List<ContractMilestoneVO> milestoneVOs = contractMilestoneMapper.selectMilestonesByContractId(contractId);
        if (milestoneVOs != null && !milestoneVOs.isEmpty()) {
            List<ContractMilestoneResponseDTO> milestoneDTOs = milestoneVOs.stream()
                .map(this::toMilestoneResponseDTO)
                .collect(Collectors.toList());
            dto.setMilestones(milestoneDTOs);
        }
        
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
        ContractStatus contractStatus = dto.getContractStatus() != null ? dto.getContractStatus() : ContractStatus.WAITING;
        
        ContractVO existingContract = contractMapper.selectContractById(dto.getContractId());
        if (existingContract == null) {
            throw new IllegalStateException("계약을 찾을 수 없습니다: " + dto.getContractId());
        }
        
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
            .contractedAt(existingContract.getContractedAt())
            .completedAt(existingContract.getCompletedAt())
            .cancelReason(existingContract.getCancelReason())
            .clientRating(existingContract.getClientRating())
            .clientExperience(existingContract.getClientExperience())
            .clientIsRenewalIntended(existingContract.getClientIsRenewalIntended())
            .freelancerRating(existingContract.getFreelancerRating())
            .freelancerExperience(existingContract.getFreelancerExperience())
            .build();
        
        contractMilestoneMapper.deleteMilestonesByContractId(dto.getContractId());
        contractMapper.updateContract(contract);
        
        if (dto.getMilestones() != null && !dto.getMilestones().isEmpty()) {
            for (ContractMilestoneRequestDTO milestoneDto : dto.getMilestones()) {
                contractMilestoneMapper.insertMilestone(
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
     */
    public List<ContractResponseDTO> getContractsByClientPathPattern(String pathPattern) {
        List<ContractVO> contracts = contractMapper.selectContractsByClientPathPattern(pathPattern);
        return contracts.stream()
            .map(this::toResponseDTO)
            .collect(Collectors.toList());
    }
    
    /**
     * 계약 최종 완료 (결제 완료)
     */
    public void finalizeContract(Integer contractId) {
        // 계약 상태를 PAID로 변경
        contractMapper.updateContractStatus(contractId, ContractStatus.PAID.name(), null);
    }
    
    /**
     * 계약 정산 완료 (PAID → COMPLETED)
     */
    @Transactional
    public void completeContract(Integer contractId) {
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
        List<ContractVO> contracts = contractMapper.selectAllContracts();
        return contracts.stream()
            .map(this::toResponseDTO)
            .collect(Collectors.toList());
    }
    
    // VO ↔ DTO 변환 메서드
    
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
     * Note: PaymentStatus는 contract 테이블에 별도 컬럼이 없으므로, 
     * 실제로는 마일스톤 상태나 계약 상태로 관리됩니다.
     * 이 메서드는 향후 확장을 위해 유지하되, 현재는 구현하지 않습니다.
     */
    public void updatePaymentStatus(Integer contractId, PaymentStatus paymentStatus) {
        // TODO: PaymentStatus를 contract 테이블에 추가하거나, 마일스톤 상태로 관리
        logger.debug("updatePaymentStatus 호출됨: contractId={}, paymentStatus={}", contractId, paymentStatus);
    }
    
    // =========================================================
    // View Data 메서드들 (Controller에서 사용)
    // =========================================================
    
    /**
     * 계약서 작성 화면용 View 데이터 조회
     */
    public ContractFormViewData getContractFormViewData(
            Integer userId, Integer projectId, Integer freelancerId) {
        
        // 클라이언트 사용자 정보 조회
        com.sanaiclub.user.model.vo.UserVO clientUser = null;
        try {
            clientUser = userMapper.findByUserId(userId);
        } catch (Exception e) {
            logger.warn("클라이언트 사용자 정보 조회 실패 (userId: {}): {}", userId, e.getMessage());
        }
        
        // 선택된 프로젝트 정보 조회
        ProjectsVO selectedProject = null;
        if (projectId != null) {
            try {
                selectedProject = getProjectById(projectId);
            } catch (Exception e) {
                logger.warn("프로젝트 정보 조회 실패 (projectId: {}): {}", projectId, e.getMessage());
            }
        }
        
        // 선택된 프리랜서 정보 조회
        com.sanaiclub.user.model.vo.UserVO selectedFreelancerUser = null;
        if (freelancerId != null) {
            try {
                selectedFreelancerUser = userMapper.findByUserId(freelancerId);
            } catch (Exception e) {
                logger.warn("프리랜서 사용자 정보 조회 실패 (freelancerId: {}): {}", freelancerId, e.getMessage());
            }
        }
        
        // 클라이언트 프로필 및 회사 정보 조회
        com.sanaiclub.user.model.vo.ClientProfileVO clientProfile = null;
        com.sanaiclub.user.model.vo.CompanyVO company = null;
        try {
            clientProfile = clientProfileMapper.findByUserId(userId);
            if (clientProfile != null && clientProfile.getCompanyId() != null) {
                company = companyMapper.findByCompanyId(clientProfile.getCompanyId());
            }
        } catch (Exception e) {
            logger.warn("클라이언트 프로필 및 회사 정보 조회 실패 (userId: {}): {}", userId, e.getMessage());
        }
        
        return new ContractFormViewData(
            clientUser, clientProfile, company, selectedProject, selectedFreelancerUser
        );
    }
    
    /**
     * 계약서 확인 화면용 View 데이터 조회
     */
    public ContractCheckViewData getContractCheckViewData(
            Integer userId, Integer projectId, Integer freelancerId) {
        
        // 클라이언트 사용자 정보 조회
        com.sanaiclub.user.model.vo.UserVO clientUser = null;
        try {
            clientUser = userMapper.findByUserId(userId);
        } catch (Exception e) {
            logger.warn("클라이언트 사용자 정보 조회 실패 (userId: {}): {}", userId, e.getMessage());
        }
        
        // 프로젝트 정보 조회
        ProjectsVO project = null;
        try {
            project = getProjectById(projectId);
        } catch (Exception e) {
            logger.warn("프로젝트 정보 조회 실패 (projectId: {}): {}", projectId, e.getMessage());
        }
        
        // 프리랜서 사용자 정보 조회
        com.sanaiclub.user.model.vo.UserVO freelancerUser = null;
        try {
            freelancerUser = userMapper.findByUserId(freelancerId);
        } catch (Exception e) {
            logger.warn("프리랜서 사용자 정보 조회 실패 (freelancerId: {}): {}", freelancerId, e.getMessage());
        }
        
        // 클라이언트 프로필 및 회사 정보 조회
        com.sanaiclub.user.model.vo.ClientProfileVO clientProfile = null;
        com.sanaiclub.user.model.vo.CompanyVO company = null;
        try {
            clientProfile = clientProfileMapper.findByUserId(userId);
            if (clientProfile != null && clientProfile.getCompanyId() != null) {
                company = companyMapper.findByCompanyId(clientProfile.getCompanyId());
            }
        } catch (Exception e) {
            logger.warn("클라이언트 프로필 및 회사 정보 조회 실패 (userId: {}): {}", userId, e.getMessage());
        }
        
        return new ContractCheckViewData(
            clientUser, clientProfile, company, project, freelancerUser
        );
    }
    
    /**
     * 프리랜서 계약 관리 화면용 View 데이터 조회
     */
    public FreelancerContractViewData getFreelancerContractViewData(
            Integer contractId, ContractResponseDTO selectedContract) {
        
        // 계약 상세 정보 조회
        ContractDetailDTO contractDetail = null;
        try {
            contractDetail = getContractDetailForView(contractId);
        } catch (Exception e) {
            logger.warn("계약 상세 정보 조회 실패 (contractId: {}): {}", contractId, e.getMessage());
        }
        
        // JSP 전송용 Map 변환 (Service 레이어에서 처리)
        java.util.Map<String, Object> project = convertToProjectMap(contractDetail, selectedContract);
        java.util.Map<String, Object> client = convertToClientMapForFreelancer(contractDetail, selectedContract);
        
        return new FreelancerContractViewData(contractDetail, project, client);
    }
    
    /**
     * 계약 관리 화면용 View 데이터 조회
     */
    public ContractManagementViewData getContractManagementViewData(
            Integer contractId, Integer clientId, ContractResponseDTO selectedContract) {
        
        ContractDetailDTO contractDetail = null;
        try {
            contractDetail = getContractDetailForView(contractId);
        } catch (Exception e) {
            logger.warn("계약 상세 정보 조회 실패 (contractId: {}): {}", contractId, e.getMessage());
        }
        
        com.sanaiclub.user.model.vo.UserVO clientUser = null;
        try {
            clientUser = userMapper.findByUserId(clientId);
        } catch (Exception e) {
            logger.warn("클라이언트 사용자 정보 조회 실패 (clientId: {}): {}", clientId, e.getMessage());
        }
        
        com.sanaiclub.user.model.vo.ClientProfileVO clientProfile = null;
        com.sanaiclub.user.model.vo.CompanyVO company = null;
        try {
            clientProfile = clientProfileMapper.findByUserId(clientId);
            if (clientProfile != null && clientProfile.getCompanyId() != null) {
                company = companyMapper.findByCompanyId(clientProfile.getCompanyId());
            }
        } catch (Exception e) {
            logger.warn("클라이언트 프로필 및 회사 정보 조회 실패 (clientId: {}): {}", clientId, e.getMessage());
        }
        
        java.util.Map<String, Object> project = convertToProjectMap(contractDetail, selectedContract);
        java.util.Map<String, Object> client = convertToClientMap(contractDetail, clientUser, selectedContract);
        
        return new ContractManagementViewData(
            contractDetail, clientUser, clientProfile, company, project, client
        );
    }
    
    /**
     * 계약 분석 화면용 View 데이터 조회
     */
    public ContractAnalysisViewData getContractAnalysisViewData(ContractDetailDTO contractDetail) {
        // JSP 전송용 Map 변환 (Service 레이어에서 처리)
        java.util.Map<String, Object> project = convertToProjectMap(contractDetail, null);
        
        return new ContractAnalysisViewData(contractDetail, project);
    }
    
    /**
     * 기본 프로젝트 정보 Map 생성
     */
    public java.util.Map<String, Object> createBasicProjectMap(ContractResponseDTO selectedContract) {
        return convertToProjectMap(null, selectedContract);
    }
    
    /**
     * 계약서 확인 화면용 클라이언트/프리랜서 정보 Map 변환
     */
    public ContractCheckViewMapData convertToContractCheckViewMaps(
            com.sanaiclub.user.model.vo.UserVO clientUser,
            com.sanaiclub.user.model.vo.CompanyVO company,
            com.sanaiclub.user.model.vo.UserVO freelancerUser,
            com.sanaiclub.user.model.vo.FreelancerProfileVO freelancerProfile) {
        
        // 클라이언트 정보 Map 변환
        java.util.Map<String, Object> clientMap = new java.util.HashMap<>();
        clientMap.put("clientName", clientUser != null ? clientUser.getName() : "");
        clientMap.put("email", clientUser != null ? clientUser.getEmail() : "");
        clientMap.put("phone", clientUser != null ? clientUser.getPhone() : "");
        clientMap.put("companyName", company != null ? company.getCompanyName() : null);
        
        // 프리랜서 정보 Map 변환
        java.util.Map<String, Object> freelancerMap = new java.util.HashMap<>();
        freelancerMap.put("name", freelancerUser != null ? freelancerUser.getName() : "");
        freelancerMap.put("email", freelancerUser != null ? freelancerUser.getEmail() : "");
        freelancerMap.put("phone", freelancerUser != null ? freelancerUser.getPhone() : "");
        freelancerMap.put("nickname", freelancerProfile != null ? freelancerProfile.getNickname() : null);
        
        return new ContractCheckViewMapData(clientMap, freelancerMap);
    }
    
    /**
     * PDF 생성용 사용자 정보 조회
     */
    public PdfGenerationUserData getPdfGenerationUserData(Integer clientId, Integer freelancerId) {
        // 클라이언트 사용자 정보 조회
        com.sanaiclub.user.model.vo.UserVO clientUser = null;
        try {
            clientUser = userMapper.findByUserId(clientId);
        } catch (Exception e) {
            logger.warn("클라이언트 사용자 정보 조회 실패 (clientId: {}): {}", clientId, e.getMessage());
        }
        
        // 프리랜서 사용자 정보 조회
        com.sanaiclub.user.model.vo.UserVO freelancerUser = null;
        try {
            freelancerUser = userMapper.findByUserId(freelancerId);
        } catch (Exception e) {
            logger.warn("프리랜서 사용자 정보 조회 실패 (freelancerId: {}): {}", freelancerId, e.getMessage());
        }
        
        // 클라이언트 프로필 및 회사 정보 조회
        com.sanaiclub.user.model.vo.ClientProfileVO clientProfile = null;
        com.sanaiclub.user.model.vo.CompanyVO company = null;
        try {
            clientProfile = clientProfileMapper.findByUserId(clientId);
            if (clientProfile != null && clientProfile.getCompanyId() != null) {
                company = companyMapper.findByCompanyId(clientProfile.getCompanyId());
            }
        } catch (Exception e) {
            logger.warn("클라이언트 프로필 및 회사 정보 조회 실패 (clientId: {}): {}", clientId, e.getMessage());
        }
        
        return new PdfGenerationUserData(clientUser, freelancerUser, clientProfile, company);
    }
    
    // =========================================================
    // 조회 메서드들 (ContractQueryService에서 가져옴)
    // =========================================================
    
    /**
     * 계약 상세 정보 조회. 프로젝트, 프리랜서, 클라이언트, 회사 정보 포함.
     */
    public ContractDetailDTO getContractDetailForView(Integer contractId) {
        return contractMapper.selectContractDetailWithJoin(contractId);
    }
    
    /**
     * 클라이언트의 계약 목록 조회
     */
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
    
    /**
     * 프리랜서의 계약 목록 조회
     */
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
    
    /**
     * 프로젝트 정보 조회
     */
    public ProjectsVO getProjectById(Integer projectId) {
        return projectDetailMapper.selectProjectById(projectId);
    }
    
    /**
     * 클라이언트의 프로젝트 목록 조회. READY 상태만 반환.
     */
    public List<ProjectsVO> getProjectsByClientId(Integer clientId) {
        return projectDetailMapper.selectProjectsByClientId(clientId);
    }
    
    /**
     * 프로젝트별 프리랜서 목록 조회
     */
    public List<java.util.Map<String, Object>> getFreelancersByProjectId(Integer projectId) {
        return projectDetailMapper.selectFreelancersByProjectId(projectId);
    }
    
    // =========================================================
    // 분류 메서드들
    // =========================================================
    
    /**
     * 계약 목록을 UI 표시용으로 분류 (클라이언트용)
     */
    public Map<String, List<ContractResponseDTO>> classifyContractsForClientView(
            List<ContractResponseDTO> contracts) {
        
        // 1단계: 기본 상태별로 그룹화 (null 상태 계약 필터링)
        Map<String, List<ContractResponseDTO>> contractsByStatus = contracts.stream()
                .filter(contract -> {
                    if (contract.getContractStatus() == null) {
                        logger.warn("상태가 null인 계약 제외: contractId={}", contract.getContractId());
                        return false;
                    }
                    String statusName = contract.getContractStatus().name();
                    try {
                        ContractStatus.valueOf(statusName);
                        return true;
                    } catch (IllegalArgumentException e) {
                        logger.error("유효하지 않은 계약 상태: {} (contractId: {}). 제외합니다.", 
                                statusName, contract.getContractId());
                        return false;
                    }
                })
                .collect(Collectors.groupingBy(
                    contract -> contract.getContractStatus().name()
                ));
        
        // 2단계: PAID 상태를 "작업 진행 중" 또는 "완료 내역"으로 분류
        // - 모든 마일스톤이 PAID가 아니면 "작업 진행 중"
        // - 모든 마일스톤이 PAID이면 "완료 내역" (하지만 상태는 아직 PAID일 수 있음)
        List<ContractResponseDTO> paidContracts = contractsByStatus.remove("PAID");
        List<ContractResponseDTO> activeContracts = new ArrayList<>();  // 작업 진행 중
        List<ContractResponseDTO> completedHistory = new ArrayList<>();  // 완료 내역
        
        if (paidContracts != null && !paidContracts.isEmpty()) {
            for (ContractResponseDTO contract : paidContracts) {
                boolean isLumpSum = (contract.getTotalMilestones() == null || contract.getTotalMilestones() == 0)
                        && ("FIXED".equals(contract.getPaymentMethod()) 
                            || "FULL".equals(contract.getPaymentMethod()) 
                            || contract.getPaymentMethod() == null);
                
                if (isLumpSum) {
                    // 일시지급: 지급 요청 대기 중이면 작업 진행 중, COMPLETED면 완료 내역
                    if (contract.getContractStatus() == ContractStatus.COMPLETED) {
                        completedHistory.add(contract);
                    } else {
                        activeContracts.add(contract);
                    }
                } else {
                    // 마일스톤 계약: 모든 마일스톤이 PAID면 완료 내역, 아니면 작업 진행 중
                    if (isFullyCompleted(contract)) {
                        completedHistory.add(contract);
                    } else {
                        activeContracts.add(contract);
                    }
                }
            }
        }
        
        // 3단계: COMPLETED 상태는 모두 완료 내역
        List<ContractResponseDTO> completedContracts = contractsByStatus.remove("COMPLETED");
        if (completedContracts != null && !completedContracts.isEmpty()) {
            completedHistory.addAll(completedContracts);
        }
        
        // 작업 진행 중 계약을 PAID 키로 다시 추가 (사이드바에서 "작업 진행 중"으로 표시)
        if (!activeContracts.isEmpty()) {
            contractsByStatus.put("PAID", activeContracts);
        }
        
        // 완료 내역 추가
        if (!completedHistory.isEmpty()) {
            contractsByStatus.put("COMPLETED_HISTORY", completedHistory);
        }
        
        return contractsByStatus;
    }
    
    /**
     * 계약 목록을 UI 표시용으로 분류 (프리랜서용)
     */
    public Map<String, List<ContractResponseDTO>> classifyContractsForFreelancerView(
            List<ContractResponseDTO> contracts) {
        
        // 1단계: 기본 상태별로 그룹화 (null 상태 계약 필터링)
        Map<String, List<ContractResponseDTO>> contractsByStatus = contracts.stream()
                .filter(contract -> {
                    if (contract.getContractStatus() == null) {
                        logger.warn("상태가 null인 계약 제외: contractId={}", contract.getContractId());
                        return false;
                    }
                    String statusName = contract.getContractStatus().name();
                    try {
                        ContractStatus.valueOf(statusName);
                        return true;
                    } catch (IllegalArgumentException e) {
                        logger.error("유효하지 않은 계약 상태: {} (contractId: {}). 제외합니다.", 
                                statusName, contract.getContractId());
                        return false;
                    }
                })
                .collect(Collectors.groupingBy(
                    contract -> contract.getContractStatus().name()
                ));
        
        // 2단계: PAID 상태를 "작업 진행 중" 또는 "완료 내역"으로 분류
        // - 모든 마일스톤이 PAID가 아니면 "작업 진행 중"
        // - 모든 마일스톤이 PAID이면 "완료 내역" (하지만 상태는 아직 PAID일 수 있음)
        List<ContractResponseDTO> paidContracts = contractsByStatus.remove("PAID");
        List<ContractResponseDTO> activeContracts = new ArrayList<>();  // 작업 진행 중
        List<ContractResponseDTO> completedHistory = new ArrayList<>();  // 완료 내역
        
        if (paidContracts != null && !paidContracts.isEmpty()) {
            for (ContractResponseDTO contract : paidContracts) {
                boolean isLumpSum = (contract.getTotalMilestones() == null || contract.getTotalMilestones() == 0)
                        && ("FIXED".equals(contract.getPaymentMethod()) 
                            || "FULL".equals(contract.getPaymentMethod()) 
                            || contract.getPaymentMethod() == null);
                
                if (isLumpSum) {
                    // 일시지급: 지급 요청 대기 중이면 작업 진행 중, COMPLETED면 완료 내역
                    if (contract.getContractStatus() == ContractStatus.COMPLETED) {
                        completedHistory.add(contract);
                    } else {
                        activeContracts.add(contract);
                    }
                } else {
                    // 마일스톤 계약: 모든 마일스톤이 PAID면 완료 내역, 아니면 작업 진행 중
                    if (isFullyCompleted(contract)) {
                        completedHistory.add(contract);
                    } else {
                        activeContracts.add(contract);
                    }
                }
            }
        }
        
        // 3단계: COMPLETED 상태는 모두 완료 내역
        List<ContractResponseDTO> completedContracts = contractsByStatus.remove("COMPLETED");
        if (completedContracts != null && !completedContracts.isEmpty()) {
            completedHistory.addAll(completedContracts);
        }
        
        // 작업 진행 중 계약을 PAID 키로 다시 추가 (사이드바에서 "작업 진행 중"으로 표시)
        if (!activeContracts.isEmpty()) {
            contractsByStatus.put("PAID", activeContracts);
        }
        
        // 완료 내역 추가
        if (!completedHistory.isEmpty()) {
            contractsByStatus.put("COMPLETED_HISTORY", completedHistory);
        }
        
        return contractsByStatus;
    }
    
    // =========================================================
    // 지급 관련 메서드들 (ContractCommandService에서 가져옴)
    // =========================================================
    
    /**
     * 프리랜서 지급 요청. 마일스톤: DEPOSITED → REQUESTED, 일시지급: cancel_reason에 "[지급요청]" 저장.
     */
    @Transactional
    public int requestPayment(Integer contractId, Integer step) {
        // 계약 상태 확인
        ContractVO contract = contractMapper.selectContractById(contractId);
        if (contract == null) {
            throw new IllegalArgumentException("계약을 찾을 수 없습니다: " + contractId);
        }
        if (contract.getContractStatus() != ContractStatus.PAID 
                && contract.getContractStatus() != ContractStatus.COMPLETED) {
            throw new IllegalStateException("결제 완료된 계약만 지급 요청할 수 있습니다. 현재 상태: " + contract.getContractStatus());
        }
        
        // 일시지급인 경우 (FIXED, FULL, 또는 paymentMethod가 null)
        if ("FIXED".equals(contract.getPaymentMethod()) 
                || "FULL".equals(contract.getPaymentMethod()) 
                || contract.getPaymentMethod() == null) {
            contractMapper.updateCancelReason(contractId, "[지급요청]");
            logger.info("일시지급 요청: contractId={}", contractId);
            return 1;
        }
        
        // 마일스톤 상태 업데이트: DEPOSITED → REQUESTED
        if (step == null) {
            // 모든 DEPOSITED 마일스톤을 REQUESTED로 변경
            List<ContractMilestoneVO> milestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
            int count = 0;
            
            for (ContractMilestoneVO milestone : milestones) {
                if (milestone.getStatus() == MilestoneStatus.DEPOSITED) {
                    contractMilestoneMapper.updateMilestoneStatus(contractId, milestone.getStep(), MilestoneStatus.REQUESTED.name());
                    count++;
                }
            }
            
            logger.info("모든 마일스톤 지급 요청: contractId={}, count={}", contractId, count);
            return count;
        } else {
            // 특정 마일스톤만 REQUESTED로 변경 (DEPOSITED 상태 확인)
            List<ContractMilestoneVO> milestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
            ContractMilestoneVO targetMilestone = milestones.stream()
                .filter(m -> m.getStep().equals(step) && m.getStatus() == MilestoneStatus.DEPOSITED)
                .findFirst()
                .orElseThrow(() -> new IllegalStateException("지급 요청 가능한 마일스톤이 아닙니다: step=" + step));
            
            int updated = contractMilestoneMapper.updateMilestoneStatus(contractId, step, MilestoneStatus.REQUESTED.name());
            logger.info("마일스톤 지급 요청: contractId={}, step={}", contractId, step);
            return updated;
        }
    }
    
    /**
     * 클라이언트 지급 수락. 마일스톤: REQUESTED → PAID (바로 지급), 일시지급: PAID → COMPLETED.
     */
    @Transactional
    public int approvePayment(Integer contractId, Integer step) {
        // 계약 상태 확인
        ContractVO contract = contractMapper.selectContractById(contractId);
        if (contract == null) {
            throw new IllegalArgumentException("계약을 찾을 수 없습니다: " + contractId);
        }
        if (contract.getContractStatus() != ContractStatus.PAID 
                && contract.getContractStatus() != ContractStatus.COMPLETED) {
            throw new IllegalStateException("결제 완료된 계약만 지급 수락할 수 있습니다. 현재 상태: " + contract.getContractStatus());
        }
        
        // 일시지급이고 cancel_reason이 "[지급요청]"인 경우
        if (("FIXED".equals(contract.getPaymentMethod()) || "FULL".equals(contract.getPaymentMethod()) || contract.getPaymentMethod() == null)
                && "[지급요청]".equals(contract.getCancelReason())) {
            contractMapper.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);
            contractMapper.updateCancelReason(contractId, null);
            logger.info("일시지급 수락: contractId={}", contractId);
            return 1;
        }
        
        // 프리랜서 ID 추출
        Integer freelancerId = extractFreelancerIdFromContract(contract);
        
        // 프리랜서 지갑 조회
        FreelancerWalletVO wallet = walletMapper.selectWalletByUserId(freelancerId);
        if (wallet == null) {
            throw new IllegalArgumentException("프리랜서 지갑을 찾을 수 없습니다: userId=" + freelancerId);
        }
        
        // 마일스톤 상태 업데이트: REQUESTED → PAID (바로 지급)
        if (step == null) {
            // 모든 REQUESTED 마일스톤을 PAID로 변경
            List<ContractMilestoneVO> milestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
            int count = 0;
            
            for (ContractMilestoneVO milestone : milestones) {
                if (milestone.getStatus() == MilestoneStatus.REQUESTED) {
                    // 1. 마일스톤 상태 변경: REQUESTED → PAID
                    contractMilestoneMapper.updateMilestoneStatus(
                        contractId, 
                        milestone.getStep(), 
                        MilestoneStatus.PAID.name()
                    );
                    
                    // 2. 프리랜서 지갑에 입금 처리
                    WalletHistoryVO history = WalletHistoryVO.builder()
                        .walletId(wallet.getWalletId())
                        .ioType(WalletIoType.PAYMENT)
                        .amount(milestone.getAmount())
                        .summary(String.format("마일스톤 %d단계 지급: %s", 
                                milestone.getStep(), milestone.getTitle()))
                        .build();
                    walletMapper.insertWalletHistory(history);
                    
                    count++;
                }
            }
            
            // 3. 모든 마일스톤이 PAID인지 확인하여 계약 완료 처리
            checkAndCompleteContract(contractId);
            
            logger.info("마일스톤 지급 수락 완료: contractId={}, count={}", contractId, count);
            return count;
        } else {
            // 특정 마일스톤만 PAID로 변경
            List<ContractMilestoneVO> milestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
            ContractMilestoneVO targetMilestone = milestones.stream()
                .filter(m -> m.getStep().equals(step) && m.getStatus() == MilestoneStatus.REQUESTED)
                .findFirst()
                .orElseThrow(() -> new IllegalStateException("지급 수락 가능한 마일스톤이 아닙니다: step=" + step));
            
            // 1. 마일스톤 상태 변경: REQUESTED → PAID
            contractMilestoneMapper.updateMilestoneStatus(
                contractId, 
                step, 
                MilestoneStatus.PAID.name()
            );
            
            // 2. 프리랜서 지갑에 입금 처리
            WalletHistoryVO history = WalletHistoryVO.builder()
                .walletId(wallet.getWalletId())
                .ioType(WalletIoType.PAYMENT)
                .amount(targetMilestone.getAmount())
                .summary(String.format("마일스톤 %d단계 지급: %s", 
                        targetMilestone.getStep(), targetMilestone.getTitle()))
                .build();
            walletMapper.insertWalletHistory(history);
            
            // 3. 모든 마일스톤이 PAID인지 확인하여 계약 완료 처리
            checkAndCompleteContract(contractId);
            
            logger.info("마일스톤 지급 수락 완료: contractId={}, step={}", contractId, step);
            return 1;
        }
    }
    
    /**
     * 클라이언트 지급 거부. 마일스톤: REQUESTED → DEPOSITED (다시 에스크로 상태로), 일시지급: cancel_reason null로 초기화.
     */
    @Transactional
    public int rejectPayment(Integer contractId, Integer step) {
        // 계약 상태 확인
        ContractVO contract = contractMapper.selectContractById(contractId);
        if (contract == null) {
            throw new IllegalArgumentException("계약을 찾을 수 없습니다: " + contractId);
        }
        if (contract.getContractStatus() != ContractStatus.PAID 
                && contract.getContractStatus() != ContractStatus.COMPLETED) {
            throw new IllegalStateException("결제 완료된 계약만 지급 거부할 수 있습니다. 현재 상태: " + contract.getContractStatus());
        }
        
        // 일시지급이고 cancel_reason이 "[지급요청]"인 경우
        if (("FIXED".equals(contract.getPaymentMethod()) || "FULL".equals(contract.getPaymentMethod()) || contract.getPaymentMethod() == null)
                && "[지급요청]".equals(contract.getCancelReason())) {
            contractMapper.updateCancelReason(contractId, null);
            logger.info("일시지급 거부: contractId={}, cancel_reason을 null로 설정", contractId);
            return 1;
        }
        
        // 마일스톤 상태 업데이트: REQUESTED → DEPOSITED (다시 에스크로 상태로)
        if (step == null) {
            // 모든 REQUESTED 마일스톤을 DEPOSITED로 변경
            List<ContractMilestoneVO> milestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
            int count = 0;
            
            for (ContractMilestoneVO milestone : milestones) {
                if (milestone.getStatus() == MilestoneStatus.REQUESTED) {
                    contractMilestoneMapper.updateMilestoneStatus(
                        contractId, 
                        milestone.getStep(), 
                        MilestoneStatus.DEPOSITED.name()
                    );
                    count++;
                }
            }
            
            logger.info("마일스톤 지급 거부: contractId={}, count={} (다시 DEPOSITED 상태로)", contractId, count);
            return count;
        } else {
            // 특정 마일스톤만 DEPOSITED로 변경
            int updated = contractMilestoneMapper.updateMilestoneStatus(
                contractId, 
                step, 
                MilestoneStatus.DEPOSITED.name()
            );
            logger.info("마일스톤 지급 거부: contractId={}, step={} (다시 DEPOSITED 상태로)", contractId, step);
            return updated;
        }
    }
    
    // =========================================================
    // Private Helper Methods
    // =========================================================
    
    /**
     * Map을 ContractResponseDTO로 변환
     */
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
                ? tryParseContractStatus((String) map.get("contractStatus"), 
                    map.get("contractId") != null ? ((Number) map.get("contractId")).intValue() : null)
                : null)
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
    
    /**
     * 프로젝트 정보 Map 변환 (JSP 전송용)
     */
    private java.util.Map<String, Object> convertToProjectMap(
            ContractDetailDTO contractDetail, ContractResponseDTO selectedContract) {
        java.util.Map<String, Object> project = new java.util.HashMap<>();
        if (contractDetail != null) {
            project.put("projectId", contractDetail.getProjectId());
            project.put("title", contractDetail.getProjectTitle());
            project.put("description", contractDetail.getProjectDescription());
            project.put("budget", contractDetail.getProjectBudget());
            project.put("startDate", contractDetail.getProjectStartDate());
            project.put("deadlineDate", contractDetail.getProjectDeadlineDate());
            project.put("estDuration", contractDetail.getProjectEstDuration());
        } else if (selectedContract != null) {
            project.put("projectId", selectedContract.getProjectId());
            project.put("title", selectedContract.getProjectTitle());
        }
        return project;
    }
    
    /**
     * 클라이언트 정보 Map 변환 (JSP 전송용)
     */
    private java.util.Map<String, Object> convertToClientMap(
            ContractDetailDTO contractDetail, 
            com.sanaiclub.user.model.vo.UserVO clientUser,
            ContractResponseDTO selectedContract) {
        java.util.Map<String, Object> client = new java.util.HashMap<>();
        if (contractDetail != null) {
            client.put("clientName", contractDetail.getClientName() != null 
                ? contractDetail.getClientName() 
                : (clientUser != null ? clientUser.getName() : null));
            client.put("email", contractDetail.getClientEmail() != null 
                ? contractDetail.getClientEmail() 
                : (clientUser != null ? clientUser.getEmail() : null));
            client.put("phone", contractDetail.getClientPhone() != null 
                ? contractDetail.getClientPhone() 
                : (clientUser != null ? clientUser.getPhone() : null));
        } else if (clientUser != null) {
            client.put("clientName", clientUser.getName());
            client.put("email", clientUser.getEmail());
            client.put("phone", clientUser.getPhone());
        } else if (selectedContract != null) {
            client.put("clientName", selectedContract.getClientName());
        }
        return client;
    }
    
    /**
     * 클라이언트 정보 Map 변환 (프리랜서용, JSP 전송용)
     */
    private java.util.Map<String, Object> convertToClientMapForFreelancer(
            ContractDetailDTO contractDetail, ContractResponseDTO selectedContract) {
        java.util.Map<String, Object> client = new java.util.HashMap<>();
        if (contractDetail != null) {
            client.put("clientName", contractDetail.getClientName());
            client.put("email", contractDetail.getClientEmail());
            client.put("phone", contractDetail.getClientPhone());
        } else if (selectedContract != null) {
            client.put("clientName", selectedContract.getClientName());
        }
        return client;
    }
    
    /**
     * 계약 완료 여부 확인. 마일스톤: (paid + deposited) >= total, 일시지급: COMPLETED 상태.
     */
    /**
     * 계약이 완전히 완료되었는지 확인
     * - 마일스톤 계약: 모든 마일스톤이 PAID 상태일 때만 완료
     * - 일시지급 계약: COMPLETED 상태일 때 완료
     */
    private boolean isFullyCompleted(ContractResponseDTO contract) {
        // 일시지급 계약인지 확인
        boolean isLumpSum = (contract.getTotalMilestones() == null || contract.getTotalMilestones() == 0)
                && ("FIXED".equals(contract.getPaymentMethod()) 
                    || "FULL".equals(contract.getPaymentMethod()) 
                    || contract.getPaymentMethod() == null);
        
        if (contract.getTotalMilestones() != null && contract.getTotalMilestones() > 0) {
            // 마일스톤 계약: 모든 마일스톤이 PAID여야 완료
            Integer paid = contract.getPaidMilestones() != null ? contract.getPaidMilestones() : 0;
            return paid >= contract.getTotalMilestones();
        } else if (isLumpSum) {
            // 일시지급 계약: COMPLETED 상태일 때 완료
            return contract.getContractStatus() == ContractStatus.COMPLETED;
        } else {
            // 마일스톤도 아니고 일시지급도 아닌 경우 (기본 상태)
            return false;
        }
    }
    
    /**
     * 문자열을 ContractStatus enum으로 안전하게 변환
     */
    private ContractStatus tryParseContractStatus(String statusString, Integer contractId) {
        if (statusString == null || statusString.trim().isEmpty()) {
            if (contractId != null) {
                logger.warn("계약 상태가 null입니다 (contractId: {}). 필터링됩니다.", contractId);
            }
            return null;
        }
        try {
            String upperStatus = statusString.toUpperCase().trim();
            ContractStatus status = ContractStatus.valueOf(upperStatus);
            return status;
        } catch (IllegalArgumentException e) {
            logger.error("유효하지 않은 계약 상태 값 '{}' (contractId: {}). 유효한 값: WAITING, SIGNED, PAID, COMPLETED, TERMINATED. null로 설정하여 필터링됩니다.", 
                statusString, contractId);
            return null;
        }
    }
    
    // =========================================================
    // Inner Classes (View Data)
    // =========================================================
    
    /**
     * 계약서 작성 화면용 View 데이터 클래스
     */
    public static class ContractFormViewData {
        private final com.sanaiclub.user.model.vo.UserVO clientUser;
        private final com.sanaiclub.user.model.vo.ClientProfileVO clientProfile;
        private final com.sanaiclub.user.model.vo.CompanyVO company;
        private final ProjectsVO selectedProject;
        private final com.sanaiclub.user.model.vo.UserVO selectedFreelancerUser;
        
        public ContractFormViewData(
                com.sanaiclub.user.model.vo.UserVO clientUser,
                com.sanaiclub.user.model.vo.ClientProfileVO clientProfile,
                com.sanaiclub.user.model.vo.CompanyVO company,
                ProjectsVO selectedProject,
                com.sanaiclub.user.model.vo.UserVO selectedFreelancerUser) {
            this.clientUser = clientUser;
            this.clientProfile = clientProfile;
            this.company = company;
            this.selectedProject = selectedProject;
            this.selectedFreelancerUser = selectedFreelancerUser;
        }
        
        // Getters
        public com.sanaiclub.user.model.vo.UserVO getClientUser() { return clientUser; }
        public com.sanaiclub.user.model.vo.ClientProfileVO getClientProfile() { return clientProfile; }
        public com.sanaiclub.user.model.vo.CompanyVO getCompany() { return company; }
        public ProjectsVO getSelectedProject() { return selectedProject; }
        public com.sanaiclub.user.model.vo.UserVO getSelectedFreelancerUser() { return selectedFreelancerUser; }
    }
    
    /**
     * 계약서 확인 화면용 View 데이터 클래스
     */
    public static class ContractCheckViewData {
        private final com.sanaiclub.user.model.vo.UserVO clientUser;
        private final com.sanaiclub.user.model.vo.ClientProfileVO clientProfile;
        private final com.sanaiclub.user.model.vo.CompanyVO company;
        private final ProjectsVO project;
        private final com.sanaiclub.user.model.vo.UserVO freelancerUser;
        
        public ContractCheckViewData(
                com.sanaiclub.user.model.vo.UserVO clientUser,
                com.sanaiclub.user.model.vo.ClientProfileVO clientProfile,
                com.sanaiclub.user.model.vo.CompanyVO company,
                ProjectsVO project,
                com.sanaiclub.user.model.vo.UserVO freelancerUser) {
            this.clientUser = clientUser;
            this.clientProfile = clientProfile;
            this.company = company;
            this.project = project;
            this.freelancerUser = freelancerUser;
        }
        
        // Getters
        public com.sanaiclub.user.model.vo.UserVO getClientUser() { return clientUser; }
        public com.sanaiclub.user.model.vo.ClientProfileVO getClientProfile() { return clientProfile; }
        public com.sanaiclub.user.model.vo.CompanyVO getCompany() { return company; }
        public ProjectsVO getProject() { return project; }
        public com.sanaiclub.user.model.vo.UserVO getFreelancerUser() { return freelancerUser; }
    }
    
    /**
     * 프리랜서 계약 관리 화면용 View 데이터 클래스
     */
    public static class FreelancerContractViewData {
        private final ContractDetailDTO contractDetail;
        private final java.util.Map<String, Object> project;
        private final java.util.Map<String, Object> client;
        
        public FreelancerContractViewData(
                ContractDetailDTO contractDetail,
                java.util.Map<String, Object> project,
                java.util.Map<String, Object> client) {
            this.contractDetail = contractDetail;
            this.project = project;
            this.client = client;
        }
        
        // Getters
        public ContractDetailDTO getContractDetail() { return contractDetail; }
        public java.util.Map<String, Object> getProject() { return project; }
        public java.util.Map<String, Object> getClient() { return client; }
    }
    
    /**
     * 계약 관리 화면용 View 데이터 클래스
     */
    public static class ContractManagementViewData {
        private final ContractDetailDTO contractDetail;
        private final com.sanaiclub.user.model.vo.UserVO clientUser;
        private final com.sanaiclub.user.model.vo.ClientProfileVO clientProfile;
        private final com.sanaiclub.user.model.vo.CompanyVO company;
        private final java.util.Map<String, Object> project;
        private final java.util.Map<String, Object> client;
        
        public ContractManagementViewData(
                ContractDetailDTO contractDetail,
                com.sanaiclub.user.model.vo.UserVO clientUser,
                com.sanaiclub.user.model.vo.ClientProfileVO clientProfile,
                com.sanaiclub.user.model.vo.CompanyVO company,
                java.util.Map<String, Object> project,
                java.util.Map<String, Object> client) {
            this.contractDetail = contractDetail;
            this.clientUser = clientUser;
            this.clientProfile = clientProfile;
            this.company = company;
            this.project = project;
            this.client = client;
        }
        
        // Getters
        public ContractDetailDTO getContractDetail() { return contractDetail; }
        public com.sanaiclub.user.model.vo.UserVO getClientUser() { return clientUser; }
        public com.sanaiclub.user.model.vo.ClientProfileVO getClientProfile() { return clientProfile; }
        public com.sanaiclub.user.model.vo.CompanyVO getCompany() { return company; }
        public java.util.Map<String, Object> getProject() { return project; }
        public java.util.Map<String, Object> getClient() { return client; }
    }
    
    /**
     * 계약 분석 화면용 View 데이터 클래스
     */
    public static class ContractAnalysisViewData {
        private final ContractDetailDTO contractDetail;
        private final java.util.Map<String, Object> project;
        
        public ContractAnalysisViewData(
                ContractDetailDTO contractDetail,
                java.util.Map<String, Object> project) {
            this.contractDetail = contractDetail;
            this.project = project;
        }
        
        // Getters
        public ContractDetailDTO getContractDetail() { return contractDetail; }
        public java.util.Map<String, Object> getProject() { return project; }
    }
    
    /**
     * 계약서 확인 화면용 View Map 데이터 클래스
     */
    public static class ContractCheckViewMapData {
        private final java.util.Map<String, Object> clientMap;
        private final java.util.Map<String, Object> freelancerMap;
        
        public ContractCheckViewMapData(
                java.util.Map<String, Object> clientMap,
                java.util.Map<String, Object> freelancerMap) {
            this.clientMap = clientMap;
            this.freelancerMap = freelancerMap;
        }
        
        public java.util.Map<String, Object> getClientMap() { return clientMap; }
        public java.util.Map<String, Object> getFreelancerMap() { return freelancerMap; }
    }
    
    /**
     * PDF 생성용 사용자 정보 클래스
     */
    public static class PdfGenerationUserData {
        private final com.sanaiclub.user.model.vo.UserVO clientUser;
        private final com.sanaiclub.user.model.vo.UserVO freelancerUser;
        private final com.sanaiclub.user.model.vo.ClientProfileVO clientProfile;
        private final com.sanaiclub.user.model.vo.CompanyVO company;
        
        public PdfGenerationUserData(
                com.sanaiclub.user.model.vo.UserVO clientUser,
                com.sanaiclub.user.model.vo.UserVO freelancerUser,
                com.sanaiclub.user.model.vo.ClientProfileVO clientProfile,
                com.sanaiclub.user.model.vo.CompanyVO company) {
            this.clientUser = clientUser;
            this.freelancerUser = freelancerUser;
            this.clientProfile = clientProfile;
            this.company = company;
        }
        
        // Getters
        public com.sanaiclub.user.model.vo.UserVO getClientUser() { return clientUser; }
        public com.sanaiclub.user.model.vo.UserVO getFreelancerUser() { return freelancerUser; }
        public com.sanaiclub.user.model.vo.ClientProfileVO getClientProfile() { return clientProfile; }
        public com.sanaiclub.user.model.vo.CompanyVO getCompany() { return company; }
    }
    
    // =========================================================
    // Private Helper Methods
    // =========================================================
    
    /**
     * origin_contract_url에서 프리랜서 ID 추출
     * 형식: contracts/{clientId}/{contractId}/freelancer/{freelancerId}/...
     */
    private Integer extractFreelancerIdFromContract(ContractVO contract) {
        String url = contract.getOriginContractUrl();
        if (url == null || url.isEmpty()) {
            throw new IllegalArgumentException("계약 URL이 없습니다.");
        }
        
        Pattern pattern = Pattern.compile("/freelancer/(\\d+)");
        Matcher matcher = pattern.matcher(url);
        
        if (matcher.find()) {
            return Integer.parseInt(matcher.group(1));
        }
        
        throw new IllegalArgumentException("URL에서 프리랜서 ID를 추출할 수 없습니다: " + url);
    }
    
    /**
     * 계약 완료 여부 확인 (모든 마일스톤이 PAID일 때만 COMPLETED로 변경)
     */
    private void checkAndCompleteContract(Integer contractId) {
        ContractVO contract = contractMapper.selectContractById(contractId);
        if (contract == null || contract.getContractStatus() == ContractStatus.COMPLETED) {
            return;
        }
        
        // 일시지급인 경우는 이미 처리됨
        if ("FIXED".equals(contract.getPaymentMethod()) 
                || "FULL".equals(contract.getPaymentMethod()) 
                || contract.getPaymentMethod() == null) {
            return;
        }
        
        // 마일스톤 계약인 경우: 모든 마일스톤이 PAID인지 확인
        List<ContractMilestoneVO> milestones = 
            contractMilestoneMapper.selectMilestonesByContractId(contractId);
        
        if (milestones == null || milestones.isEmpty()) {
            return;
        }
        
        // 모든 마일스톤이 PAID인지 확인
        boolean allPaid = milestones.stream()
            .allMatch(m -> MilestoneStatus.PAID.equals(m.getStatus()));
        
        if (allPaid) {
            contractMapper.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);
            logger.info("모든 마일스톤 지급 완료, 계약 완료: contractId={}", contractId);
        }
    }
}
