package com.sanaiclub.contract.util;

import com.sanaiclub.contract.model.dto.ContractResponseDTO;
import com.sanaiclub.contract.model.enums.ContractStatus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/** 계약 상태 분류 유틸리티 */
public final class ContractStatusClassifier {
    
    private static final Logger logger = LoggerFactory.getLogger(ContractStatusClassifier.class);
    
    private ContractStatusClassifier() {
        throw new UnsupportedOperationException("Utility class cannot be instantiated");
    }
    
    /** 계약 목록을 상태별로 분류 (클라이언트용) */
    public static Map<String, List<ContractResponseDTO>> classifyForClient(
            List<ContractResponseDTO> contracts) {
        
        List<ContractResponseDTO> validContracts = filterValidContracts(contracts);
        
        Map<String, List<ContractResponseDTO>> contractsByStatus = validContracts.stream()
                .collect(Collectors.groupingBy(
                    contract -> contract.getContractStatus().name()
                ));
        
        List<ContractResponseDTO> paidContracts = contractsByStatus.remove("PAID");
        if (paidContracts != null && !paidContracts.isEmpty()) {
            contractsByStatus.put("PAYMENT_PENDING", paidContracts);
        }
        
        classifyCompletedContracts(contractsByStatus);
        
        return contractsByStatus;
    }
    
    /** 계약 목록을 상태별로 분류 (프리랜서용) */
    public static Map<String, List<ContractResponseDTO>> classifyForFreelancer(
            List<ContractResponseDTO> contracts) {
        
        List<ContractResponseDTO> validContracts = filterValidContracts(contracts);
        
        Map<String, List<ContractResponseDTO>> contractsByStatus = validContracts.stream()
                .collect(Collectors.groupingBy(
                    contract -> contract.getContractStatus().name()
                ));
        
        List<ContractResponseDTO> paidContracts = contractsByStatus.remove("PAID");
        List<ContractResponseDTO> settlementPending = new ArrayList<>();
        
        if (paidContracts != null && !paidContracts.isEmpty()) {
            settlementPending.addAll(paidContracts);
        }
        
        List<ContractResponseDTO> completedContracts = contractsByStatus.remove("COMPLETED");
        List<ContractResponseDTO> completedHistory = new ArrayList<>();
        
        if (completedContracts != null && !completedContracts.isEmpty()) {
            for (ContractResponseDTO contract : completedContracts) {
                if (isFullyCompleted(contract)) {
                    completedHistory.add(contract);
                } else {
                    settlementPending.add(contract);
                }
            }
        }
        
        if (!settlementPending.isEmpty()) {
            contractsByStatus.put("SETTLEMENT_PENDING", settlementPending);
        }
        if (!completedHistory.isEmpty()) {
            contractsByStatus.put("COMPLETED_HISTORY", completedHistory);
        }
        
        return contractsByStatus;
    }
    
    /** 유효한 계약만 필터링 */
    private static List<ContractResponseDTO> filterValidContracts(
            List<ContractResponseDTO> contracts) {
        
        return contracts.stream()
                .filter(contract -> {
                    if (contract.getContractStatus() == null) {
                        logger.warn("상태가 null인 계약 발견: contractId={}", contract.getContractId());
                        return false;
                    }
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
                .collect(Collectors.toList());
    }
    
    /** COMPLETED 상태 계약을 "정산 대기"와 "완료 내역"으로 분리 */
    private static void classifyCompletedContracts(
            Map<String, List<ContractResponseDTO>> contractsByStatus) {
        
        List<ContractResponseDTO> completedContracts = contractsByStatus.remove("COMPLETED");
        if (completedContracts == null || completedContracts.isEmpty()) {
            return;
        }
        
        List<ContractResponseDTO> settlementPending = new ArrayList<>();
        List<ContractResponseDTO> completedHistory = new ArrayList<>();
        
        for (ContractResponseDTO contract : completedContracts) {
            if (isFullyCompleted(contract)) {
                completedHistory.add(contract);
            } else {
                settlementPending.add(contract);
            }
        }
        
        if (!settlementPending.isEmpty()) {
            contractsByStatus.put("SETTLEMENT_PENDING", settlementPending);
        }
        if (!completedHistory.isEmpty()) {
            contractsByStatus.put("COMPLETED_HISTORY", completedHistory);
        }
    }
    
    /** 계약이 완전히 완료되었는지 확인 */
    private static boolean isFullyCompleted(ContractResponseDTO contract) {
        if (isLumpSumContract(contract)) {
            return true;
        }
        
        if (contract.getTotalMilestones() != null && contract.getTotalMilestones() > 0) {
            Integer total = contract.getTotalMilestones();
            Integer deposited = contract.getDepositedMilestones() != null 
                ? contract.getDepositedMilestones() : 0;
            Integer paid = contract.getPaidMilestones() != null 
                ? contract.getPaidMilestones() : 0;
            
            return (deposited + paid) >= total;
        }
        
        return false;
    }
    
    /** 일시지급 계약인지 확인 */
    private static boolean isLumpSumContract(ContractResponseDTO contract) {
        return (contract.getTotalMilestones() == null || contract.getTotalMilestones() == 0)
                && ("FIXED".equals(contract.getPaymentMethod()) 
                    || "FULL".equals(contract.getPaymentMethod()) 
                    || contract.getPaymentMethod() == null);
    }
}
