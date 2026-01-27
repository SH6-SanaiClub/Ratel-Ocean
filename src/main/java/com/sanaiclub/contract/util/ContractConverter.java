package com.sanaiclub.contract.util;

import com.sanaiclub.contract.model.vo.ContractVO;
import com.sanaiclub.contract.model.vo.ContractMilestoneVO;
import com.sanaiclub.contract.model.dto.ContractResponseDTO;
import com.sanaiclub.contract.model.dto.ContractMilestoneResponseDTO;
import com.sanaiclub.contract.model.vo.ContractStatus;
import com.sanaiclub.contract.model.vo.MilestoneStatus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/** 계약 VO ↔ DTO 변환 유틸리티 */
public final class ContractConverter {
    
    private static final Logger logger = LoggerFactory.getLogger(ContractConverter.class);
    
    private ContractConverter() {
        throw new UnsupportedOperationException("Utility class cannot be instantiated");
    }
    
    /** ContractVO → ContractResponseDTO 변환 */
    public static ContractResponseDTO toResponseDTO(ContractVO vo) {
        if (vo == null) {
            return null;
        }
        
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
    
    /** ContractMilestoneVO → ContractMilestoneResponseDTO 변환 */
    public static ContractMilestoneResponseDTO toMilestoneResponseDTO(ContractMilestoneVO vo) {
        if (vo == null) {
            return null;
        }
        
        ContractMilestoneResponseDTO dto = new ContractMilestoneResponseDTO();
        dto.setMilestoneId(vo.getMilestoneId());
        dto.setStep(vo.getStep());
        dto.setTitle(vo.getTitle());
        dto.setDescription(vo.getDescription());
        dto.setAmount(vo.getAmount());
        dto.setDueDate(vo.getDueDate());
        
        MilestoneStatus status = vo.getStatus();
        if (status == null) {
            logger.warn("마일스톤 상태가 null입니다 (milestoneId: {}). WAITING으로 설정합니다.", vo.getMilestoneId());
            status = MilestoneStatus.WAITING;
        }
        dto.setStatus(status);
        
        return dto;
    }
    
    /** 문자열을 ContractStatus enum으로 안전하게 변환 */
    public static ContractStatus tryParseContractStatus(String statusString, Integer contractId) {
        if (statusString == null || statusString.trim().isEmpty()) {
            if (contractId != null) {
                logger.warn("계약 상태가 null입니다 (contractId: {}). 필터링됩니다.", contractId);
            }
            return null;
        }
        try {
            String upperStatus = statusString.toUpperCase().trim();
            ContractStatus status = ContractStatus.valueOf(upperStatus);
            if (contractId != null && !upperStatus.equals(statusString)) {
                logger.debug("계약 상태 정규화: '{}' -> '{}' (contractId: {})", statusString, upperStatus, contractId);
            }
            return status;
        } catch (IllegalArgumentException e) {
            logger.error("잘못된 계약 상태 값: '{}' (contractId: {}). null로 설정하여 필터링됩니다.", 
                statusString, contractId);
            return null;
        }
    }
    
    /** 문자열을 MilestoneStatus enum으로 안전하게 변환 */
    public static MilestoneStatus tryParseMilestoneStatus(String statusString) {
        if (statusString == null || statusString.trim().isEmpty()) {
            return MilestoneStatus.WAITING;
        }
        try {
            return MilestoneStatus.valueOf(statusString.toUpperCase().trim());
        } catch (IllegalArgumentException e) {
            logger.warn("Invalid MilestoneStatus value from DB: {}. WAITING으로 설정합니다.", statusString);
            return MilestoneStatus.WAITING;
        }
    }
}
