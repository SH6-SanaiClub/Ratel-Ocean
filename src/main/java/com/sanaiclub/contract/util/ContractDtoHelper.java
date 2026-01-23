package com.sanaiclub.contract.util;

import com.sanaiclub.contract.model.dto.ContractCreateRequestDTO;
import com.sanaiclub.contract.model.dto.ContractUpdateRequestDTO;
import com.sanaiclub.contract.model.dto.ContractMilestoneRequestDTO;
import com.sanaiclub.contract.model.enums.ContractStatus;

import java.util.ArrayList;
import java.util.List;

/**
 * Contract DTO 생성 헬퍼 클래스
 * Controller에서 중복되는 DTO 생성 로직을 분리
 */
public class ContractDtoHelper {

    /**
     * ContractCreateRequestDTO 생성
     */
    public static ContractCreateRequestDTO createContractDto(
            Integer projectId,
            Integer freelancerId,
            String contractStartDate,
            String contractEndDate,
            String totalBudgetStr,
            String paymentMethod,
            String contractInputType,
            String contractPurpose,
            String workScope,
            String deliverables,
            String paymentCondition,
            String scheduleCondition,
            String specialTerms,
            String originContractUrl,
            String[] milestoneNames,
            String[] milestoneAmounts,
            String[] milestoneDescs,
            String requirements
    ) {
        ContractCreateRequestDTO dto = new ContractCreateRequestDTO();
        dto.setProjectId(projectId);
        dto.setFreelancerId(freelancerId);
        dto.setContractStartDate(contractStartDate);
        dto.setContractEndDate(contractEndDate);
        
        if (totalBudgetStr != null && !totalBudgetStr.isBlank()) {
            try {
                dto.setTotalBudget(Long.valueOf(totalBudgetStr.trim()));
            } catch (NumberFormatException e) {
                // 무시
            }
        }
        
        dto.setPaymentMethod(paymentMethod);
        dto.setContractStatus(ContractStatus.WAITING.name());
        dto.setOriginContractUrl(originContractUrl);
        
        // 직접 작성 시 입력 필드 설정
        if ("FORM".equals(contractInputType)) {
            dto.setContractPurpose(contractPurpose);
            dto.setWorkScope(workScope);
            dto.setDeliverables(deliverables);
            dto.setPaymentCondition(paymentCondition);
            dto.setScheduleCondition(scheduleCondition);
            dto.setSpecialTerms(specialTerms);
        }
        
        // requirements 처리
        if (requirements != null && !requirements.isBlank()) {
            dto.setRequirements(java.util.Arrays.asList(requirements.split("\n")));
        }
        
        // milestones 처리
        if ("MILESTONE".equals(paymentMethod) && milestoneNames != null && milestoneNames.length > 0) {
            dto.setMilestones(createMilestoneList(milestoneNames, milestoneAmounts, milestoneDescs));
        }
        
        return dto;
    }

    /**
     * ContractUpdateRequestDTO 생성
     */
    public static ContractUpdateRequestDTO createUpdateDto(
            Integer contractId,
            String contractStartDate,
            String contractEndDate,
            String totalBudgetStr,
            String paymentMethod,
            String contractInputType,
            String contractPurpose,
            String workScope,
            String deliverables,
            String paymentCondition,
            String scheduleCondition,
            String specialTerms,
            String originContractUrl,
            String[] milestoneNames,
            String[] milestoneAmounts,
            String[] milestoneDescs
    ) {
        ContractUpdateRequestDTO dto = new ContractUpdateRequestDTO();
        dto.setContractId(contractId);
        dto.setContractStartDate(contractStartDate);
        dto.setContractEndDate(contractEndDate);
        
        if (totalBudgetStr != null && !totalBudgetStr.isBlank()) {
            try {
                dto.setTotalBudget(Long.valueOf(totalBudgetStr.trim()));
            } catch (NumberFormatException e) {
                // 무시
            }
        }
        
        dto.setPaymentMethod(paymentMethod);
        dto.setContractStatus(ContractStatus.WAITING.name());
        dto.setOriginContractUrl(originContractUrl);
        
        // 직접 작성 시 입력 필드 설정
        if ("FORM".equals(contractInputType)) {
            dto.setContractPurpose(contractPurpose);
            dto.setWorkScope(workScope);
            dto.setDeliverables(deliverables);
            dto.setPaymentCondition(paymentCondition);
            dto.setScheduleCondition(scheduleCondition);
            dto.setSpecialTerms(specialTerms);
        }
        
        // milestones 처리
        if ("MILESTONE".equals(paymentMethod) && milestoneNames != null && milestoneNames.length > 0) {
            dto.setMilestones(createMilestoneList(milestoneNames, milestoneAmounts, milestoneDescs));
        }
        
        return dto;
    }

    /**
     * 마일스톤 리스트 생성
     */
    private static List<ContractMilestoneRequestDTO> createMilestoneList(
            String[] milestoneNames,
            String[] milestoneAmounts,
            String[] milestoneDescs
    ) {
        List<ContractMilestoneRequestDTO> milestones = new ArrayList<>();
        
        int maxLength = Math.max(
            Math.max(milestoneNames != null ? milestoneNames.length : 0, 
                     milestoneAmounts != null ? milestoneAmounts.length : 0),
            milestoneDescs != null ? milestoneDescs.length : 0
        );
        
        for (int i = 0; i < maxLength; i++) {
            String name = (milestoneNames != null && i < milestoneNames.length && milestoneNames[i] != null) 
                ? milestoneNames[i].trim() : "";
            String amountStr = (milestoneAmounts != null && i < milestoneAmounts.length && milestoneAmounts[i] != null) 
                ? milestoneAmounts[i].trim() : "";
            String desc = (milestoneDescs != null && i < milestoneDescs.length && milestoneDescs[i] != null) 
                ? milestoneDescs[i].trim() : "";
            
            if (!name.isEmpty() && !amountStr.isEmpty()) {
                try {
                    ContractMilestoneRequestDTO milestone = new ContractMilestoneRequestDTO();
                    milestone.setStep(i + 1);
                    milestone.setTitle(name);
                    milestone.setAmount(Long.valueOf(amountStr));
                    milestone.setDescription(desc);
                    milestones.add(milestone);
                } catch (NumberFormatException e) {
                    // 무시
                }
            }
        }
        
        return milestones;
    }
}
