package com.sanaiclub.contract.service;

import com.sanaiclub.contract.model.vo.*;
import com.sanaiclub.contract.model.dto.*;
import com.sanaiclub.contract.model.enums.ContractStatus;
import com.sanaiclub.contract.model.enums.MilestoneStatus;
import com.sanaiclub.contract.dao.ContractMapper;
import com.sanaiclub.contract.dao.ContractMilestoneMapper;
import com.sanaiclub.project.dao.ProjectDetailMapper;
import com.sanaiclub.project.model.vo.ProjectsVO;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.stream.Collectors;

/** 계약 비즈니스 로직 서비스. 계약 CRUD, 상태 관리, 지급 요청/수락/거부 처리. */
@Service
public class ContractService {

    private static final Logger logger = LoggerFactory.getLogger(ContractService.class);

    private final ContractMapper contractMapper;
    private final ContractMilestoneMapper contractMilestoneMapper;
    private final ProjectDetailMapper projectDetailMapper;
    // User 도메인 Mapper (View용 데이터 조회를 위해 Service 계층에서 사용)
    private final com.sanaiclub.user.dao.UserMapper userMapper;
    private final com.sanaiclub.user.dao.ClientProfileMapper clientProfileMapper;
    private final com.sanaiclub.user.dao.CompanyMapper companyMapper;

    public ContractService(
            ContractMapper contractMapper,
            ContractMilestoneMapper contractMilestoneMapper,
            ProjectDetailMapper projectDetailMapper,
            com.sanaiclub.user.dao.UserMapper userMapper,
            com.sanaiclub.user.dao.ClientProfileMapper clientProfileMapper,
            com.sanaiclub.user.dao.CompanyMapper companyMapper
    ) {
        this.contractMapper = contractMapper;
        this.contractMilestoneMapper = contractMilestoneMapper;
        this.projectDetailMapper = projectDetailMapper;
        this.userMapper = userMapper;
        this.clientProfileMapper = clientProfileMapper;
        this.companyMapper = companyMapper;
    }

    /** 계약 생성. 마일스톤 정보도 함께 저장. */
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
        
        Integer contractId = contract.getContractId();
        if (contractId == null) {
            logger.error("계약 생성 실패: contractId가 null입니다. contract: {}, resultMap: {}", contract, resultMap);
            throw new IllegalStateException("계약 생성 실패: contractId를 가져올 수 없습니다.");
        }
        
        logger.debug("계약 생성 성공: contractId={}, paymentMethod={}, milestones 수={}", 
                contractId, dto.getPaymentMethod(),
                dto.getMilestones() != null ? dto.getMilestones().size() : 0);
        
        if (dto.getMilestones() != null && !dto.getMilestones().isEmpty() && contractId != null) {
            logger.debug("마일스톤 저장 시작: contractId={}, 마일스톤 수={}", contractId, dto.getMilestones().size());
            int savedCount = 0;
            for (ContractMilestoneRequestDTO milestoneDto : dto.getMilestones()) {
                try {
                    contractMilestoneMapper.insertMilestone(
                        contractId,
                        milestoneDto.getStep(),
                        milestoneDto.getTitle(),
                        milestoneDto.getDescription(),
                        milestoneDto.getAmount()
                    );
                    savedCount++;
                } catch (Exception e) {
                    logger.error("마일스톤 저장 실패: contractId={}, step={}, title={}", 
                            contractId, milestoneDto.getStep(), milestoneDto.getTitle(), e);
                    throw new IllegalStateException("마일스톤 저장 실패: " + e.getMessage(), e);
                }
            }
            logger.info("마일스톤 저장 완료: contractId={}, 저장된 마일스톤 수={}/{}", 
                    contractId, savedCount, dto.getMilestones().size());
        }
        
        return contractId;
    }

    /** 계약 단건 조회. 계약 정보와 마일스톤 정보 포함. */
    public ContractResponseDTO getContractById(Integer contractId) {
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
                // 기본값으로 WAITING 설정하거나 null 유지
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
        
        ContractResponseDTO dto = toResponseDTO(contract);
        dto.setProjectTitle((String) contractWithDetails.get("projectTitle"));
        dto.setFreelancerName((String) contractWithDetails.get("freelancerName"));
        dto.setClientName((String) contractWithDetails.get("clientName"));
        
        try {
            List<ContractMilestoneVO> milestoneVOs = contractMilestoneMapper.selectMilestonesByContractId(contractId);
            if (milestoneVOs != null && !milestoneVOs.isEmpty()) {
                List<ContractMilestoneResponseDTO> milestoneDTOs = milestoneVOs.stream()
                    .map(this::toMilestoneResponseDTO)
                    .collect(Collectors.toList());
                dto.setMilestones(milestoneDTOs);
            } else {
                dto.setMilestones(new java.util.ArrayList<>());
            }
        } catch (Exception e) {
            logger.error("마일스톤 조회 실패 (contractId: {}): {}", contractId, e.getMessage(), e);
            dto.setMilestones(new java.util.ArrayList<>());
        }
        
        return dto;
    }

    /** 계약 수락 처리. WAITING → SIGNED */
    public void acceptContract(Integer contractId, Integer freelancerId) {
        contractMapper.updateContractStatus(contractId, ContractStatus.SIGNED.name(), null);
    }

    /** 계약 거절 처리. WAITING → TERMINATED, 거절 사유 저장. */
    public void rejectContract(Integer contractId, Integer freelancerId, String reason) {
        String prefixedReason = (reason != null && !reason.trim().isEmpty()) 
            ? (reason.startsWith("[거절] ") ? reason : "[거절] " + reason)
            : "[거절] 사유 없음";
        contractMapper.updateContractStatus(contractId, ContractStatus.TERMINATED.name(), prefixedReason);
    }
    
    /** 계약의 마일스톤 목록 조회. step 오름차순 정렬. */
    public List<ContractMilestoneResponseDTO> getMilestonesByContractId(Integer contractId) {
        List<ContractMilestoneVO> milestoneVOs = contractMilestoneMapper.selectMilestonesByContractId(contractId);
        return milestoneVOs.stream()
            .map(this::toMilestoneResponseDTO)
            .collect(Collectors.toList());
    }

    /** 원본 계약서 파일 경로 업데이트 */
    @Transactional
    public void updateOriginContractUrl(Integer contractId, String originContractUrl) {
        contractMapper.updateOriginContractUrl(contractId, originContractUrl);
    }
    
    /** 경로 패턴으로 계약서 파일 경로 목록 조회. TERMINATED 제외. */
    public List<String> getOriginContractUrlsByPathPattern(String pathPattern) {
        return contractMapper.selectOriginContractUrlsByPathPattern(pathPattern);
    }
    
    /** 같은 프로젝트/프리랜서 조합의 기존 계약 조회. UPDATE vs INSERT 판단용.
     * origin_contract_url 패턴(contracts/{clientId}/{projectId}/{freelancerId}/%)으로 조회.
     * TERMINATED 상태 제외, 최근 계약 1개만 반환.
     * @param clientId 클라이언트 ID
     * @param projectId 프로젝트 ID
     * @param freelancerId 프리랜서 ID
     * @return 기존 계약 정보, 없으면 null
     */
    public ContractResponseDTO getContractByPathPattern(Integer clientId, Integer projectId, Integer freelancerId) {
        ContractVO contract = contractMapper.selectContractByPathPattern(clientId, projectId, freelancerId);
        if (contract == null) {
            return null;
        }
        return toResponseDTO(contract);
    }
    
    /** 계약 정보 업데이트. 기존 마일스톤 삭제 후 새 마일스톤으로 교체.
     * @param dto 업데이트할 계약 정보
     * @throws IllegalStateException 계약을 찾을 수 없을 때
     */
    @Transactional
    public void updateContract(ContractUpdateRequestDTO dto) {
        ContractStatus contractStatus = dto.getContractStatus() != null 
            ? dto.getContractStatus() 
            : ContractStatus.WAITING;
        
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
    
    /** 클라이언트의 계약 목록 조회. origin_contract_url 패턴으로 필터링. */
    public List<ContractResponseDTO> getContractsByClientPathPattern(String pathPattern) {
        List<ContractVO> contracts = contractMapper.selectContractsByClientPathPattern(pathPattern);
        return contracts.stream()
            .map(this::toResponseDTO)
            .collect(Collectors.toList());
    }
    
    /** 계약 결제 완료 처리. SIGNED → PAID, 에스크로 확보. */
    @Transactional
    public void finalizeContract(Integer contractId) {
        contractMapper.updateContractStatus(contractId, ContractStatus.PAID.name(), null);
    }
    
    /** 계약 정산 완료 처리. PAID → COMPLETED. */
    public void completeContract(Integer contractId) {
        contractMapper.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);
    }

    /** 계약 취소 처리. → TERMINATED, 취소 사유 저장. */
    public void cancelContract(Integer contractId, String reason) {
        String prefixedReason = (reason != null && !reason.trim().isEmpty()) 
            ? (reason.startsWith("[취소] ") ? reason : "[취소] " + reason)
            : "[취소] 사유 없음";
        contractMapper.updateContractStatus(contractId, ContractStatus.TERMINATED.name(), prefixedReason);
    }
    
    /** 모든 계약 목록 조회. 최신순 정렬. */
    public List<ContractResponseDTO> getAllContracts() {
        List<java.util.Map<String, Object>> contractsWithDetails = contractMapper.selectAllContractsWithDetails();
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
                
                ContractResponseDTO dto = toResponseDTO(vo);
                dto.setProjectTitle((String) map.get("projectTitle"));
                dto.setFreelancerName((String) map.get("freelancerName"));
                dto.setClientName((String) map.get("clientName"));
                dto.setTotalMilestones(getIntegerValue.apply(map.get("totalMilestones")));
                dto.setPaidMilestones(getIntegerValue.apply(map.get("paidMilestones")));
                dto.setRequestedMilestones(getIntegerValue.apply(map.get("requestedMilestones")));
                dto.setDepositedMilestones(getIntegerValue.apply(map.get("depositedMilestones")));
                dto.setWaitingMilestones(getIntegerValue.apply(map.get("waitingMilestones")));
                
                return dto;
            })
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
    
    
    /** ContractVO → ContractResponseDTO 변환. originContractUrl에서 projectId, freelancerId 추출.
     * @param vo 계약 VO
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
        dto.setContractedAt(vo.getContractedAt());
        dto.setCompletedAt(vo.getCompletedAt());
        dto.setCancelReason(vo.getCancelReason());
        
        if (vo.getOriginContractUrl() != null && vo.getOriginContractUrl().startsWith("contracts/")) {
            String[] pathParts = vo.getOriginContractUrl().split("/");
            if (pathParts.length >= 3) {
                try {
                    dto.setProjectId(Integer.valueOf(pathParts[2]));
                } catch (NumberFormatException e) {
                }
            }
            if (pathParts.length >= 4) {
                try {
                    dto.setFreelancerId(Integer.valueOf(pathParts[3]));
                } catch (NumberFormatException e) {
                }
            }
        }
        
        return dto;
    }
    
    /** ContractMilestoneVO → ContractMilestoneResponseDTO 변환
     * @param vo 마일스톤 VO
     * @return 마일스톤 응답 DTO
     */
    private ContractMilestoneResponseDTO toMilestoneResponseDTO(ContractMilestoneVO vo) {
        ContractMilestoneResponseDTO dto = new ContractMilestoneResponseDTO();
        dto.setMilestoneId(vo.getMilestoneId());      // 마일스톤 ID
        dto.setStep(vo.getStep());                    // 단계 순서
        dto.setTitle(vo.getTitle());                  // 마일스톤 제목
        dto.setDescription(vo.getDescription());       // 작업 범위/설명
        dto.setAmount(vo.getAmount());                // 결제 금액
        dto.setDueDate(vo.getDueDate());
        
        MilestoneStatus status = vo.getStatus();
        if (status == null) {
            logger.warn("마일스톤 상태가 null입니다 (milestoneId: {}). WAITING으로 설정합니다.", vo.getMilestoneId());
            status = MilestoneStatus.WAITING;
        }
        dto.setStatus(status);
        
        return dto;
    }
    
    /** 문자열을 MilestoneStatus enum으로 안전하게 변환 */
    @SuppressWarnings("unused")
    private MilestoneStatus tryParseMilestoneStatus(String statusString) {
        if (statusString == null || statusString.trim().isEmpty()) {
            return MilestoneStatus.WAITING; // 기본값
        }
        try {
            return MilestoneStatus.valueOf(statusString.toUpperCase().trim());
        } catch (IllegalArgumentException e) {
            logger.warn("Invalid MilestoneStatus value from DB: {}. WAITING으로 설정합니다.", statusString);
            return MilestoneStatus.WAITING; // 기본값
        }
    }
    
    /** 문자열을 ContractStatus enum으로 안전하게 변환 */
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
            // DB 값이 대소문자가 섞여있거나 공백이 있는 경우 로그 남기기
            if (contractId != null && !upperStatus.equals(statusString)) {
                logger.debug("계약 상태 정규화: '{}' -> '{}' (contractId: {})", statusString, upperStatus, contractId);
            }
            return status;
        } catch (IllegalArgumentException e) {
            // DB에 잘못된 상태 값이 있는 경우 (사용자가 수정했다고 했지만, 혹시 모를 경우를 대비)
            logger.error("잘못된 계약 상태 값: '{}' (contractId: {}). 유효한 값: WAITING, SIGNED, PAID, COMPLETED, TERMINATED. null로 설정하여 필터링됩니다.", 
                statusString, contractId);
            return null; // null 반환하여 필터링 가능하도록 함
        }
    }
    
    /** 프리랜서 지급 요청. 마일스톤: WAITING → REQUESTED, 일시지급: cancel_reason에 "[지급요청]" 저장.
     * @param contractId 계약 ID
     * @param step 마일스톤 단계 (null이면 모든 WAITING 마일스톤)
     * @return 업데이트된 마일스톤 개수
     */
    @Transactional
    public int requestPayment(Integer contractId, Integer step) {
        ContractVO contract = contractMapper.selectContractById(contractId);
        if (contract == null) {
            throw new IllegalArgumentException("계약을 찾을 수 없습니다: " + contractId);
        }
        if (contract.getContractStatus() != ContractStatus.PAID 
                && contract.getContractStatus() != ContractStatus.COMPLETED) {
            throw new IllegalStateException("결제 완료 또는 정산 완료된 계약만 지급 요청할 수 있습니다. 현재 상태: " + contract.getContractStatus());
        }
        
        if ("FIXED".equals(contract.getPaymentMethod()) || "FULL".equals(contract.getPaymentMethod()) || contract.getPaymentMethod() == null) {
            List<ContractMilestoneVO> milestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
            if (milestones == null || milestones.isEmpty()) {
                contractMapper.updateContractStatus(contractId, ContractStatus.PAID.name(), "[지급요청]");
                logger.info("일시지급 요청: contractId={}", contractId);
                return 1;
            }
        }
        
        return contractMilestoneMapper.updateMilestoneStatus(contractId, step, MilestoneStatus.REQUESTED.name());
    }
    
    /** 클라이언트 지급 수락. 마일스톤: REQUESTED → DEPOSITED, 일시지급: PAID → COMPLETED.
     * @param contractId 계약 ID
     * @param step 마일스톤 단계 (null이면 모든 REQUESTED 마일스톤)
     * @return 업데이트된 마일스톤 개수
     */
    @Transactional
    public int approvePayment(Integer contractId, Integer step) {
        ContractVO contract = contractMapper.selectContractById(contractId);
        if (contract == null) {
            throw new IllegalArgumentException("계약을 찾을 수 없습니다: " + contractId);
        }
        if (contract.getContractStatus() != ContractStatus.PAID 
                && contract.getContractStatus() != ContractStatus.COMPLETED) {
            throw new IllegalStateException("결제 완료 또는 정산 완료된 계약만 지급 수락할 수 있습니다. 현재 상태: " + contract.getContractStatus());
        }
        
        if (("FIXED".equals(contract.getPaymentMethod()) || "FULL".equals(contract.getPaymentMethod()) || contract.getPaymentMethod() == null)
                && "[지급요청]".equals(contract.getCancelReason())) {
            contractMapper.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);
            contractMapper.updateCancelReason(contractId, null);
            logger.info("일시지급 수락: contractId={}", contractId);
            return 1;
        }
        
        if (step == null) {
            List<ContractMilestoneVO> milestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
            int count = 0;
            for (ContractMilestoneVO milestone : milestones) {
                if (milestone.getStatus() == MilestoneStatus.REQUESTED) {
                    contractMilestoneMapper.updateMilestoneStatus(contractId, milestone.getStep(), MilestoneStatus.DEPOSITED.name());
                    count++;
                }
            }
            
            boolean allDepositedOrPaid = true;
            for (ContractMilestoneVO milestone : milestones) {
                MilestoneStatus status = milestone.getStatus();
                if (status != MilestoneStatus.DEPOSITED && status != MilestoneStatus.PAID) {
                    allDepositedOrPaid = false;
                    break;
                }
            }
            
            if (allDepositedOrPaid && !milestones.isEmpty()) {
                contractMapper.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);
            }
            
            return count;
        } else {
            int updated = contractMilestoneMapper.updateMilestoneStatus(contractId, step, MilestoneStatus.DEPOSITED.name());
            
            List<ContractMilestoneVO> allMilestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
            boolean allDepositedOrPaid = true;
            for (ContractMilestoneVO milestone : allMilestones) {
                MilestoneStatus status = milestone.getStatus();
                if (status != MilestoneStatus.DEPOSITED && status != MilestoneStatus.PAID) {
                    allDepositedOrPaid = false;
                    break;
                }
            }
            
            if (allDepositedOrPaid && !allMilestones.isEmpty()) {
                contractMapper.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);
            }
            
            return updated;
        }
    }
    
    /** 클라이언트 지급 거부. 마일스톤: REQUESTED → WAITING, 일시지급: cancel_reason null로 초기화.
     * @param contractId 계약 ID
     * @param step 마일스톤 단계 (null이면 모든 REQUESTED 마일스톤)
     * @return 업데이트된 마일스톤 개수
     */
    @Transactional
    public int rejectPayment(Integer contractId, Integer step) {
        ContractVO contract = contractMapper.selectContractById(contractId);
        if (contract == null) {
            throw new IllegalArgumentException("계약을 찾을 수 없습니다: " + contractId);
        }
        if (contract.getContractStatus() != ContractStatus.PAID 
                && contract.getContractStatus() != ContractStatus.COMPLETED) {
            throw new IllegalStateException("결제 완료 또는 정산 완료된 계약만 지급 거부할 수 있습니다. 현재 상태: " + contract.getContractStatus());
        }
        
        if (("FIXED".equals(contract.getPaymentMethod()) || "FULL".equals(contract.getPaymentMethod()) || contract.getPaymentMethod() == null)
                && "[지급요청]".equals(contract.getCancelReason())) {
            contractMapper.updateCancelReason(contractId, null);
            logger.info("일시지급 거부: contractId={}, cancel_reason을 null로 설정", contractId);
            return 1;
        }
        
        if (step == null) {
            List<ContractMilestoneVO> milestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
            int count = 0;
            for (ContractMilestoneVO milestone : milestones) {
                if (milestone.getStatus() == MilestoneStatus.REQUESTED) {
                    contractMilestoneMapper.updateMilestoneStatus(contractId, milestone.getStep(), MilestoneStatus.WAITING.name());
                    count++;
                }
            }
            return count;
        } else {
            return contractMilestoneMapper.updateMilestoneStatus(contractId, step, MilestoneStatus.WAITING.name());
        }
    }
    
    /** 마일스톤 지급 완료 처리. DEPOSITED → PAID, 모든 마일스톤 완료 시 계약 상태 COMPLETED로 변경.
     * @param contractId 계약 ID
     * @param step 마일스톤 단계 (null이면 모든 DEPOSITED 마일스톤 처리)
     * @return 업데이트된 마일스톤 개수
     */
    @Transactional
    public int completeMilestonePayment(Integer contractId, Integer step) {
        int updatedCount;
        if (step == null) {
            List<ContractMilestoneVO> milestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
            updatedCount = 0;
            for (ContractMilestoneVO milestone : milestones) {
                if (milestone.getStatus() == MilestoneStatus.DEPOSITED) {
                    contractMilestoneMapper.updateMilestoneStatus(contractId, milestone.getStep(), MilestoneStatus.PAID.name());
                    updatedCount++;
                }
            }
        } else {
            updatedCount = contractMilestoneMapper.updateMilestoneStatus(contractId, step, MilestoneStatus.PAID.name());
        }
        
        List<ContractMilestoneVO> allMilestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
        boolean allPaid = true;
        for (ContractMilestoneVO milestone : allMilestones) {
            if (milestone.getStatus() != MilestoneStatus.PAID) {
                allPaid = false;
                break;
            }
        }
        
        if (allPaid && !allMilestones.isEmpty()) {
            contractMapper.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);
        }
        
        return updatedCount;
    }
    
    /** 계약 상세 정보 조회. 프로젝트, 프리랜서, 클라이언트, 회사 정보 포함. */
    public ContractDetailDTO getContractDetailForView(Integer contractId) {
        return contractMapper.selectContractDetailWithJoin(contractId);
    }
    
    /** 계약 관리 페이지용 View 데이터 조회. DTO 변환 로직 포함. */
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
            logger.warn("클라이언트 프로필 조회 실패 (clientId: {}): {}", clientId, e.getMessage());
        }
        
        java.util.Map<String, Object> project = convertToProjectMap(contractDetail, selectedContract);
        java.util.Map<String, Object> client = convertToClientMap(contractDetail, clientUser, selectedContract);
        
        return new ContractManagementViewData(
            contractDetail, clientUser, clientProfile, company, project, client
        );
    }
    
    /** 프로젝트 정보 Map 변환. JSP 호환성. */
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
    
    /** 클라이언트 정보 Map 변환. JSP 호환성. */
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
    
    /** 계약 관리 페이지용 View 데이터 컨테이너. */
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
    
    /** 계약서 작성 폼용 View 데이터 조회. */
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
            logger.warn("클라이언트 프로필 조회 실패 (userId: {}): {}", userId, e.getMessage());
        }
        
        return new ContractFormViewData(
            clientUser, clientProfile, company, selectedProject, selectedFreelancerUser
        );
    }
    
    /** 계약서 확인 페이지용 View 데이터 조회. */
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
            logger.warn("클라이언트 프로필 조회 실패 (userId: {}): {}", userId, e.getMessage());
        }
        
        return new ContractCheckViewData(
            clientUser, clientProfile, company, project, freelancerUser
        );
    }
    
    /** 프리랜서 계약 관리 페이지용 View 데이터 조회. DTO 변환 로직 포함. */
    public FreelancerContractViewData getFreelancerContractViewData(
            Integer contractId, ContractResponseDTO selectedContract) {
        
        // 계약 상세 정보 조회
        ContractDetailDTO contractDetail = null;
        try {
            contractDetail = getContractDetailForView(contractId);
        } catch (Exception e) {
            logger.warn("계약 상세 정보 조회 실패 (contractId: {}): {}", contractId, e.getMessage());
        }
        
        // JSP 호환성을 위한 Map 변환 (Service 계층에서 처리)
        java.util.Map<String, Object> project = convertToProjectMap(contractDetail, selectedContract);
        java.util.Map<String, Object> client = convertToClientMapForFreelancer(contractDetail, selectedContract);
        
        return new FreelancerContractViewData(contractDetail, project, client);
    }
    
    /** 클라이언트 정보 Map 변환. 프리랜서용, JSP 호환성. */
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
    
    /** 계약서 작성 폼용 View 데이터 컨테이너. */
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
    
    /** 계약서 확인 페이지용 View 데이터 컨테이너. */
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
    
    /** 프리랜서 계약 관리 페이지용 View 데이터 컨테이너. */
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
    
    /** 계약 분석 페이지용 View 데이터 조회. DTO 변환 로직 포함. */
    public ContractAnalysisViewData getContractAnalysisViewData(ContractDetailDTO contractDetail) {
        // JSP 호환성을 위한 Map 변환 (Service 계층에서 처리)
        java.util.Map<String, Object> project = convertToProjectMap(contractDetail, null);
        
        return new ContractAnalysisViewData(contractDetail, project);
    }
    
    /** 권한이 없을 때 기본 프로젝트 정보 Map 생성. */
    public java.util.Map<String, Object> createBasicProjectMap(ContractResponseDTO selectedContract) {
        return convertToProjectMap(null, selectedContract);
    }
    
    /** 계약서 확인 페이지용 클라이언트/프리랜서 정보 Map 변환. */
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
    
    /** 계약서 확인 페이지용 View Map 데이터 컨테이너. */
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
    
    /** 계약 분석 페이지용 View 데이터 컨테이너. */
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
    
    /** PDF 생성용 사용자 정보 조회. */
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
            logger.warn("클라이언트 프로필 조회 실패 (clientId: {}): {}", clientId, e.getMessage());
        }
        
        return new PdfGenerationUserData(clientUser, freelancerUser, clientProfile, company);
    }
    
    /** PDF 생성용 사용자 정보 컨테이너. */
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
    
    /** 클라이언트의 계약 목록 조회. origin_contract_url 패턴으로 필터링, 최신순 정렬. */
    public List<ContractResponseDTO> getContractsByClientId(Integer clientId) {
        // 클라이언트의 계약만 조회 (쿼리에서 필터링)
        List<java.util.Map<String, Object>> contractsWithDetails = 
            contractMapper.selectContractsByClientIdWithDetails(clientId);
        
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
            })
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
    
    /** 프리랜서의 계약 목록 조회. origin_contract_url에서 freelancerId 추출하여 필터링, 최신순 정렬. */
    public List<ContractResponseDTO> getContractsByFreelancerId(Integer freelancerId) {
        // 프리랜서의 계약만 조회 (쿼리에서 필터링)
        List<java.util.Map<String, Object>> contractsWithDetails = 
            contractMapper.selectContractsByFreelancerIdWithDetails(freelancerId);
        
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
                
                // 프리랜서 시점: 상대방은 클라이언트
                dto.setCounterpartName((String) map.get("clientName"));
                
                // 마일스톤 상태 집계 정보 설정
                dto.setTotalMilestones(getIntegerValue.apply(map.get("totalMilestones")));
                dto.setPaidMilestones(getIntegerValue.apply(map.get("paidMilestones")));
                dto.setRequestedMilestones(getIntegerValue.apply(map.get("requestedMilestones")));
                dto.setDepositedMilestones(getIntegerValue.apply(map.get("depositedMilestones")));
                dto.setWaitingMilestones(getIntegerValue.apply(map.get("waitingMilestones")));
                
                return dto;
            })
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

    /** 계약 목록을 UI 표시용으로 분류 (클라이언트용). PAID/COMPLETED를 정산 대기/완료 내역으로 분리.
     * @param contracts 분류할 계약 목록
     * @return 분류된 계약 맵 (키: WAITING, SIGNED, PAYMENT_PENDING, SETTLEMENT_PENDING, COMPLETED_HISTORY, TERMINATED)
     */
    public Map<String, List<ContractResponseDTO>> classifyContractsForClientView(
            List<ContractResponseDTO> contracts) {
        
        // 1단계: 기본 상태별 그룹화 (null 상태 계약 필터링)
        Map<String, List<ContractResponseDTO>> contractsByStatus = contracts.stream()
                .filter(contract -> {
                    if (contract.getContractStatus() == null) {
                        logger.warn("상태가 null인 계약 발견: contractId={}", contract.getContractId());
                        return false;
                    }
                    // 유효한 ContractStatus enum 값만 허용
                    String statusName = contract.getContractStatus().name();
                    try {
                        ContractStatus.valueOf(statusName);
                        return true;
                    } catch (IllegalArgumentException e) {
                        logger.error("유효하지 않은 계약 상태: {} (contractId: {}). 필터링됩니다.", 
                                statusName, contract.getContractId());
                        return false;
                    }
                })
                .collect(Collectors.groupingBy(
                    contract -> contract.getContractStatus().name()
                ));
        
        // 2단계: PAID 상태를 "정산 대기"와 "완료 내역"으로 분리
        List<ContractResponseDTO> paidContracts = contractsByStatus.remove("PAID");
        List<ContractResponseDTO> completedHistory = new ArrayList<>();
        List<ContractResponseDTO> settlementPending = new ArrayList<>();
        if (paidContracts != null && !paidContracts.isEmpty()) {
            for (ContractResponseDTO contract : paidContracts) {
                // 일시지급 계약인지 확인
                boolean isLumpSum = (contract.getTotalMilestones() == null || contract.getTotalMilestones() == 0)
                        && ("FIXED".equals(contract.getPaymentMethod()) 
                            || "FULL".equals(contract.getPaymentMethod()) 
                            || contract.getPaymentMethod() == null);
                
                if (isLumpSum) {
                    // 일시지급 계약: PAID 상태이면 "정산 대기"로 분류
                    // (프리랜서 지급 요청 전이거나 클라이언트 수락 대기 중)
                    settlementPending.add(contract);
                } else if (isFullyCompleted(contract)) {
                    // 마일스톤 계약: 모든 마일스톤이 DEPOSITED 이상이면 "완료 내역"
                    completedHistory.add(contract);
                } else {
                    // 마일스톤 계약: 일부 마일스톤만 완료되었으면 "정산 대기"로 통합
                    settlementPending.add(contract);
                }
            }
        }
        
        // 3단계: COMPLETED 상태를 "정산 대기"와 "완료 내역"으로 분리
        List<ContractResponseDTO> completedContracts = contractsByStatus.remove("COMPLETED");
        if (completedContracts != null && !completedContracts.isEmpty()) {
            for (ContractResponseDTO contract : completedContracts) {
                if (isFullyCompleted(contract)) {
                    completedHistory.add(contract);
                } else {
                    settlementPending.add(contract);
                }
            }
        }
        
        // 정산 대기 추가 (PAID에서 온 모든 지급 대기 계약과 COMPLETED에서 온 미완료 계약 통합)
        if (!settlementPending.isEmpty()) {
            contractsByStatus.put("SETTLEMENT_PENDING", settlementPending);
        }
        
        // 완료 내역 추가 (PAID와 COMPLETED에서 완료된 계약 통합)
        if (!completedHistory.isEmpty()) {
            contractsByStatus.put("COMPLETED_HISTORY", completedHistory);
        }
        
        return contractsByStatus;
    }
    
    /** 계약 목록을 UI 표시용으로 분류 (프리랜서용). PAID/COMPLETED를 정산 대기/완료 내역으로 분리.
     * @param contracts 분류할 계약 목록
     * @return 분류된 계약 맵 (키: WAITING, SIGNED, SETTLEMENT_PENDING, COMPLETED_HISTORY, TERMINATED)
     */
    public Map<String, List<ContractResponseDTO>> classifyContractsForFreelancerView(
            List<ContractResponseDTO> contracts) {
        
        // 1단계: 기본 상태별 그룹화 (null 상태 계약 필터링)
        Map<String, List<ContractResponseDTO>> contractsByStatus = contracts.stream()
                .filter(contract -> {
                    if (contract.getContractStatus() == null) {
                        logger.warn("상태가 null인 계약 발견: contractId={}", contract.getContractId());
                        return false;
                    }
                    // 유효한 ContractStatus enum 값만 허용
                    String statusName = contract.getContractStatus().name();
                    try {
                        ContractStatus.valueOf(statusName);
                        return true;
                    } catch (IllegalArgumentException e) {
                        logger.error("유효하지 않은 계약 상태: {} (contractId: {}). 필터링됩니다.", 
                                statusName, contract.getContractId());
                        return false;
                    }
                })
                .collect(Collectors.groupingBy(
                    contract -> contract.getContractStatus().name()
                ));
        
        // 2단계: PAID 상태와 COMPLETED 상태를 "정산 대기"와 "완료 내역"으로 분리
        List<ContractResponseDTO> paidContracts = contractsByStatus.remove("PAID");
        List<ContractResponseDTO> settlementPending = new ArrayList<>();
        List<ContractResponseDTO> completedHistory = new ArrayList<>();
        
        if (paidContracts != null && !paidContracts.isEmpty()) {
            for (ContractResponseDTO contract : paidContracts) {
                // 일시지급 계약인지 확인
                boolean isLumpSum = (contract.getTotalMilestones() == null || contract.getTotalMilestones() == 0)
                        && ("FIXED".equals(contract.getPaymentMethod()) 
                            || "FULL".equals(contract.getPaymentMethod()) 
                            || contract.getPaymentMethod() == null);
                
                if (isLumpSum) {
                    // 일시지급 계약: PAID 상태이면 "정산 대기"로 분류
                    // (프리랜서 지급 요청 전이거나 클라이언트 수락 대기 중)
                    settlementPending.add(contract);
                } else if (isFullyCompleted(contract)) {
                    // 마일스톤 계약: 모든 마일스톤이 DEPOSITED 이상이면 "완료 내역"
                    completedHistory.add(contract);
                } else {
                    // 마일스톤 계약: 일부 마일스톤만 완료되었으면 "정산 대기"
                    settlementPending.add(contract);
                }
            }
        }
        
        // 3단계: COMPLETED 상태를 "정산 대기"와 "완료 내역"으로 분리
        List<ContractResponseDTO> completedContracts = contractsByStatus.remove("COMPLETED");
        if (completedContracts != null && !completedContracts.isEmpty()) {
            for (ContractResponseDTO contract : completedContracts) {
                if (isFullyCompleted(contract)) {
                    completedHistory.add(contract);
                } else {
                    settlementPending.add(contract);
                }
            }
        }
        
        // 정산 대기와 완료 내역을 별도 키로 추가
        if (!settlementPending.isEmpty()) {
            contractsByStatus.put("SETTLEMENT_PENDING", settlementPending);
        }
        if (!completedHistory.isEmpty()) {
            contractsByStatus.put("COMPLETED_HISTORY", completedHistory);
        }
        
        return contractsByStatus;
    }
    
    /** 계약 완료 여부 확인. 마일스톤: (paid + deposited) >= total, 일시지급: COMPLETED 상태. */
    private boolean isFullyCompleted(ContractResponseDTO contract) {
        // 일시지급 계약인지 확인
        boolean isLumpSum = (contract.getTotalMilestones() == null || contract.getTotalMilestones() == 0)
                && ("FIXED".equals(contract.getPaymentMethod()) 
                    || "FULL".equals(contract.getPaymentMethod()) 
                    || contract.getPaymentMethod() == null);
        
        if (contract.getTotalMilestones() != null && contract.getTotalMilestones() > 0) {
            // 마일스톤 계약: 모든 마일스톤이 PAID 또는 DEPOSITED인지 확인
            // DEPOSITED(입금 완료)도 완료로 간주 (플랫폼에서 실제 지급만 남은 상태)
            Integer paid = contract.getPaidMilestones() != null ? contract.getPaidMilestones() : 0;
            Integer deposited = contract.getDepositedMilestones() != null ? contract.getDepositedMilestones() : 0;
            return (paid + deposited) >= contract.getTotalMilestones();
        } else if (isLumpSum) {
            // 일시지급 계약: COMPLETED 상태일 때만 완료 내역
            // PAID 상태는 아직 프리랜서 지급 요청 전이거나 클라이언트 수락 대기 중이므로 완료 아님
            return contract.getContractStatus() == ContractStatus.COMPLETED;
        } else {
            // 마일스톤이 없고 일시지급도 아닌 경우 (이상한 상태)
            return false;
        }
    }
}
