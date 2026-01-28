package com.sanaiclub.contract.service;

import com.sanaiclub.contract.model.dto.*;

import java.io.File;
import java.util.List;

/** 계약서 작성 폼 관련 서비스. 계약서 작성 화면 데이터 준비 및 가공. */
public interface ContractFormService {
    
    /** 계약서 확인 페이지 데이터 준비. */
    ContractCheckPageDTO prepareContractCheckPageData(
            String contractInputType,
            String uploadedPdfFileName,
            File pdfFile,
            Integer projectId,
            Integer freelancerId,
            String contractPurpose,
            String workScope,
            String deliverables,
            String paymentCondition,
            String scheduleCondition,
            String specialTerms,
            String contractStartDate,
            String contractEndDate,
            Long totalBudget,
            String paymentMethod,
            String[] milestoneName,
            String[] milestoneAmount,
            String[] milestoneDesc,
            Integer userId
    );
    
    /** 마일스톤 목록 생성. */
    List<ContractMilestoneRequestDTO> createMilestoneList(
            String[] milestoneName,
            String[] milestoneAmount,
            String[] milestoneDesc
    );
    
    /** 계약 생성 DTO 생성. */
    ContractCreateRequestDTO createContractDto(
            Integer projectId,
            Integer freelancerId,
            String contractStartDate,
            String contractEndDate,
            Long totalBudget,
            String paymentMethod,
            String[] milestoneName,
            String[] milestoneAmount,
            String[] milestoneDesc,
            Integer userId,
            String originContractUrl
    );
    
    /** 계약 수정 DTO 생성. */
    ContractUpdateRequestDTO createUpdateDto(
            Integer contractId,
            Integer projectId,
            Integer freelancerId,
            String contractStartDate,
            String contractEndDate,
            Long totalBudget,
            String paymentMethod,
            String[] milestoneName,
            String[] milestoneAmount,
            String[] milestoneDesc,
            Integer userId,
            String originContractUrl
    );
}
