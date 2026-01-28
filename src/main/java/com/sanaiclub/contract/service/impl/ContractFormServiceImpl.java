package com.sanaiclub.contract.service.impl;

import com.sanaiclub.contract.model.dto.*;
import com.sanaiclub.contract.service.ContractAutoFillService;
import com.sanaiclub.contract.service.ContractFormService;
import com.sanaiclub.contract.service.ContractService;
import com.sanaiclub.contract.service.ContractFileService;
import com.sanaiclub.project.model.vo.ProjectsVO;
import com.sanaiclub.user.dao.UserMapper;
import com.sanaiclub.user.dao.ClientProfileMapper;
import com.sanaiclub.user.dao.CompanyMapper;
import com.sanaiclub.user.dao.FreelancerProfileMapper;
import com.sanaiclub.user.model.vo.UserVO;
import com.sanaiclub.user.model.vo.FreelancerProfileVO;
import com.sanaiclub.user.model.vo.ClientProfileVO;
import com.sanaiclub.user.model.vo.CompanyVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.File;
import java.util.*;

/** 계약서 작성 폼 서비스 구현체. */
@Slf4j
@Service
@RequiredArgsConstructor
public class ContractFormServiceImpl implements ContractFormService {

    private final ContractService contractService;
    private final ContractAutoFillService contractAutoFillService;
    private final ContractFileService contractFileService;
    private final UserMapper userMapper;
    private final ClientProfileMapper clientProfileMapper;
    private final CompanyMapper companyMapper;
    private final FreelancerProfileMapper freelancerProfileMapper;

    @Override
    public ContractCheckPageDTO prepareContractCheckPageData(
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
            Integer userId) {
        
        ContractCheckPageDTO.ContractCheckPageDTOBuilder builder = ContractCheckPageDTO.builder();
        
        // 1. 기본 정보 설정
        builder.contractInputType(contractInputType);
        
        String originContractUrl = null;
        if ("PDF".equals(contractInputType) && uploadedPdfFileName != null && !uploadedPdfFileName.trim().isEmpty()) {
            originContractUrl = uploadedPdfFileName.trim();
        }
        builder.originContractUrl(originContractUrl);
        
        // 2. 프로젝트 정보 조회 (한 번만 조회하여 재사용)
        ProjectsVO project = null;
        if (projectId != null) {
            try {
                project = contractService.getProjectById(projectId);
            } catch (Exception e) {
                log.warn("프로젝트 정보 조회 실패: projectId={}, error={}", projectId, e.getMessage());
            }
        }
        builder.project(project);
        
        // 3. AI 계약서 초안 생성 (이미 조회한 project 재사용)
        ContractAutoFillDTO autoFillDTO = null;
        if (projectId != null && freelancerId != null) {
            try {
                autoFillDTO = generateAutoFillDTO(
                    pdfFile, originContractUrl, contractPurpose, workScope, deliverables,
                    paymentCondition, scheduleCondition, specialTerms,
                    projectId, freelancerId, project
                );
            } catch (Exception e) {
                log.error("AI 계약서 초안 생성 실패", e);
                builder.errorMessage("계약서 초안 생성 중 오류가 발생했습니다: " + e.getMessage());
            }
        }
        builder.autoFillDTO(autoFillDTO);
        
        // 4. formDto 생성
        Map<String, Object> formDto = createFormDto(
            projectId, freelancerId, contractPurpose, workScope, deliverables,
            paymentCondition, scheduleCondition, specialTerms
        );
        builder.formDto(formDto);
        
        // 5. 클라이언트 정보 조회
        Map<String, Object> client = getClientInfo(userId);
        builder.client(client);
        
        // 6. 프리랜서 정보 조회
        Map<String, Object> freelancer = getFreelancerInfo(freelancerId);
        builder.freelancer(freelancer);
        
        // 7. contract 객체 생성 (AI 값 우선 사용)
        Map<String, Object> contract = createContractMap(
            autoFillDTO, contractStartDate, contractEndDate, totalBudget, paymentMethod
        );
        builder.contract(contract);
        
        // 8. 마일스톤 처리
        List<ContractMilestoneRequestDTO> milestoneList = createMilestoneListFromAutoFillOrParams(
            autoFillDTO, milestoneName, milestoneAmount, milestoneDesc
        );
        builder.milestones(milestoneList);
        
        // contract 객체에 milestones 추가
        contract.put("milestones", milestoneList);
        
        return builder.build();
    }

    /**
     * AI 계약서 초안 생성
     */
    private ContractAutoFillDTO generateAutoFillDTO(
            File pdfFile, String originContractUrl,
            String contractPurpose, String workScope, String deliverables,
            String paymentCondition, String scheduleCondition, String specialTerms,
            Integer projectId, Integer freelancerId, ProjectsVO project) throws Exception {
        
        // project는 이미 조회된 것을 재사용 (중복 조회 방지)
        UserVO freelancerUser = userMapper.findByUserId(freelancerId);
        FreelancerProfileVO freelancerProfile = freelancerProfileMapper.findByUserId(freelancerId);
        
        File pdfFileObj = pdfFile;
        if (pdfFileObj == null && originContractUrl != null) {
            pdfFileObj = contractFileService.getPdfFile(originContractUrl);
        }
        
        String manualText = buildManualText(
            contractPurpose, workScope, deliverables,
            paymentCondition, scheduleCondition, specialTerms
        );
        
        return contractAutoFillService.generateDraft(
            pdfFileObj, manualText, project, freelancerUser, freelancerProfile
        );
    }

    /**
     * 수동 입력 텍스트 조립
     */
    private String buildManualText(
            String contractPurpose, String workScope, String deliverables,
            String paymentCondition, String scheduleCondition, String specialTerms) {
        
        StringBuilder builder = new StringBuilder();
        if (contractPurpose != null && !contractPurpose.trim().isEmpty()) {
            builder.append("계약 목적: ").append(contractPurpose.trim()).append("\n");
        }
        if (workScope != null && !workScope.trim().isEmpty()) {
            builder.append("업무 범위: ").append(workScope.trim()).append("\n");
        }
        if (deliverables != null && !deliverables.trim().isEmpty()) {
            builder.append("결과물: ").append(deliverables.trim()).append("\n");
        }
        if (paymentCondition != null && !paymentCondition.trim().isEmpty()) {
            builder.append("지급 조건: ").append(paymentCondition.trim()).append("\n");
        }
        if (scheduleCondition != null && !scheduleCondition.trim().isEmpty()) {
            builder.append("일정 조건: ").append(scheduleCondition.trim()).append("\n");
        }
        if (specialTerms != null && !specialTerms.trim().isEmpty()) {
            builder.append("기타 특약: ").append(specialTerms.trim()).append("\n");
        }
        
        return builder.length() > 0 ? builder.toString() : null;
    }

    /**
     * formDto 생성
     */
    private Map<String, Object> createFormDto(
            Integer projectId, Integer freelancerId,
            String contractPurpose, String workScope, String deliverables,
            String paymentCondition, String scheduleCondition, String specialTerms) {
        
        Map<String, Object> formDto = new HashMap<>();
        formDto.put("projectId", projectId);
        formDto.put("freelancerId", freelancerId);
        formDto.put("contractPurpose", contractPurpose);
        formDto.put("workScope", workScope);
        formDto.put("deliverables", deliverables);
        formDto.put("paymentCondition", paymentCondition);
        formDto.put("scheduleCondition", scheduleCondition);
        formDto.put("specialTerms", specialTerms);
        return formDto;
    }

    /**
     * 클라이언트 정보 조회
     */
    private Map<String, Object> getClientInfo(Integer userId) {
        Map<String, Object> client = new HashMap<>();
        try {
            UserVO clientUser = userMapper.findByUserId(userId);
            ClientProfileVO clientProfile = clientProfileMapper.findByUserId(userId);
            CompanyVO company = clientProfile != null && clientProfile.getCompanyId() != null
                ? companyMapper.findByCompanyId(clientProfile.getCompanyId())
                : null;
            
            if (clientUser != null) {
                client.put("clientName", clientUser.getName());
                client.put("email", clientUser.getEmail());
                client.put("phone", clientUser.getPhone());
            }
            if (company != null) {
                client.put("companyName", company.getCompanyName());
            }
        } catch (Exception e) {
            log.warn("클라이언트 정보 조회 실패: userId={}, error={}", userId, e.getMessage());
        }
        return client;
    }

    /**
     * 프리랜서 정보 조회
     */
    private Map<String, Object> getFreelancerInfo(Integer freelancerId) {
        Map<String, Object> freelancer = new HashMap<>();
        if (freelancerId != null) {
            try {
                UserVO freelancerUser = userMapper.findByUserId(freelancerId);
                FreelancerProfileVO freelancerProfile = freelancerProfileMapper.findByUserId(freelancerId);
                
                if (freelancerUser != null) {
                    freelancer.put("name", freelancerUser.getName());
                    freelancer.put("email", freelancerUser.getEmail());
                    freelancer.put("phone", freelancerUser.getPhone());
                }
                if (freelancerProfile != null) {
                    freelancer.put("nickname", freelancerProfile.getNickname());
                }
            } catch (Exception e) {
                log.warn("프리랜서 정보 조회 실패: freelancerId={}, error={}", freelancerId, e.getMessage());
            }
        }
        return freelancer;
    }

    /**
     * contract Map 생성 (AI 값 우선 사용)
     */
    private Map<String, Object> createContractMap(
            ContractAutoFillDTO autoFillDTO,
            String contractStartDate, String contractEndDate,
            Long totalBudget, String paymentMethod) {
        
        Map<String, Object> contract = new HashMap<>();
        
        String finalContractStartDate = null;
        String finalContractEndDate = null;
        Long finalTotalBudget = null;
        String finalPaymentMethod = null;
        
        if (autoFillDTO != null) {
            // AI가 생성한 값 우선 사용
            if (autoFillDTO.getContractStartDate() != null) {
                finalContractStartDate = autoFillDTO.getContractStartDate().toString();
            } else if (contractStartDate != null) {
                finalContractStartDate = contractStartDate;
            }
            
            if (autoFillDTO.getContractEndDate() != null) {
                finalContractEndDate = autoFillDTO.getContractEndDate().toString();
            } else if (contractEndDate != null) {
                finalContractEndDate = contractEndDate;
            }
            
            if (autoFillDTO.getTotalBudget() != null) {
                finalTotalBudget = autoFillDTO.getTotalBudget();
            } else if (totalBudget != null) {
                finalTotalBudget = totalBudget;
            }
            
            if (autoFillDTO.getPaymentMethod() != null && !autoFillDTO.getPaymentMethod().trim().isEmpty()) {
                finalPaymentMethod = autoFillDTO.getPaymentMethod();
            } else if (paymentMethod != null) {
                finalPaymentMethod = paymentMethod;
            } else {
                finalPaymentMethod = "FULL";
            }
        } else {
            // AI 생성 실패 시 요청 파라미터 사용
            finalContractStartDate = contractStartDate;
            finalContractEndDate = contractEndDate;
            finalTotalBudget = totalBudget;
            finalPaymentMethod = paymentMethod != null ? paymentMethod : "FULL";
        }
        
        contract.put("contractStartDate", finalContractStartDate);
        contract.put("contractEndDate", finalContractEndDate);
        contract.put("totalBudget", finalTotalBudget);
        contract.put("paymentMethod", finalPaymentMethod);
        
        return contract;
    }

    /**
     * 마일스톤 목록 생성 (AI 값 우선 사용)
     */
    private List<ContractMilestoneRequestDTO> createMilestoneListFromAutoFillOrParams(
            ContractAutoFillDTO autoFillDTO,
            String[] milestoneName, String[] milestoneAmount, String[] milestoneDesc) {
        
        List<ContractMilestoneRequestDTO> milestoneList = new ArrayList<>();
        
        if (autoFillDTO != null && autoFillDTO.getMilestones() != null && !autoFillDTO.getMilestones().isEmpty()) {
            // AI가 생성한 마일스톤 사용
            for (ContractMilestoneResponseDTO m : autoFillDTO.getMilestones()) {
                ContractMilestoneRequestDTO reqMilestone = new ContractMilestoneRequestDTO();
                reqMilestone.setStep(m.getStep());
                reqMilestone.setTitle(m.getTitle());
                reqMilestone.setDescription(m.getDescription());
                reqMilestone.setAmount(m.getAmount());
                milestoneList.add(reqMilestone);
            }
        } else {
            // 요청 파라미터에서 마일스톤 생성
            milestoneList = createMilestoneList(milestoneName, milestoneAmount, milestoneDesc);
        }
        
        return milestoneList;
    }

    @Override
    public List<ContractMilestoneRequestDTO> createMilestoneList(
            String[] milestoneName, String[] milestoneAmount, String[] milestoneDesc) {
        
        List<ContractMilestoneRequestDTO> milestoneList = new ArrayList<>();
        
        if (milestoneName != null && milestoneAmount != null) {
            for (int i = 0; i < milestoneName.length; i++) {
                if (milestoneName[i] != null && !milestoneName[i].trim().isEmpty()
                    && milestoneAmount[i] != null && !milestoneAmount[i].trim().isEmpty()) {
                    try {
                        ContractMilestoneRequestDTO milestone = new ContractMilestoneRequestDTO();
                        milestone.setStep(i + 1);
                        milestone.setTitle(milestoneName[i].trim());
                        milestone.setDescription(milestoneDesc != null && i < milestoneDesc.length ? milestoneDesc[i] : null);
                        milestone.setAmount(Long.parseLong(milestoneAmount[i].trim().replaceAll(",", "")));
                        milestoneList.add(milestone);
                    } catch (NumberFormatException e) {
                        log.warn("마일스톤 금액 파싱 실패: {}", milestoneAmount[i], e);
                    }
                }
            }
        }
        
        return milestoneList;
    }

    @Override
    public ContractCreateRequestDTO createContractDto(
            Integer projectId, Integer freelancerId, String contractStartDate, String contractEndDate,
            Long totalBudget, String paymentMethod, String[] milestoneName, String[] milestoneAmount,
            String[] milestoneDesc, Integer userId, String originContractUrl) {
        
        ContractCreateRequestDTO dto = new ContractCreateRequestDTO();
        dto.setProjectId(projectId);
        dto.setFreelancerId(freelancerId);
        dto.setContractStartDate(contractStartDate);
        dto.setContractEndDate(contractEndDate);
        dto.setTotalBudget(totalBudget);
        dto.setPaymentMethod(paymentMethod);
        
        if (originContractUrl != null && !originContractUrl.trim().isEmpty()) {
            String trimmedUrl = originContractUrl.trim();
            // 경로 형식 변환:
            // 1. contracts/{clientId}/filename (2 segments) -> contracts/{clientId}/{projectId}/{freelancerId}/filename
            // 2. contracts/{clientId}/{projectId}/filename (3 segments) -> contracts/{clientId}/{projectId}/{freelancerId}/filename
            // 3. contracts/{clientId}/{projectId}/{freelancerId}/filename (4 segments) - 이미 올바른 형식, 그대로 사용
            
            String[] parts = trimmedUrl.split("/");
            if (parts.length >= 2 && parts[0].equals("contracts")) {
                String clientId = parts[1];
                
                // 형식 1: contracts/{clientId}/filename
                if (parts.length == 3 && projectId != null && freelancerId != null) {
                    String filename = parts[2];
                    trimmedUrl = String.format("contracts/%s/%d/%d/%s", clientId, projectId, freelancerId, filename);
                    log.debug("계약 생성 DTO - originContractUrl 형식 변환 (2 segments): {} -> {}", originContractUrl, trimmedUrl);
                }
                // 형식 2: contracts/{clientId}/{projectId}/filename
                else if (parts.length == 4 && projectId != null && freelancerId != null) {
                    String filename = parts[3];
                    trimmedUrl = String.format("contracts/%s/%d/%d/%s", clientId, projectId, freelancerId, filename);
                    log.debug("계약 생성 DTO - originContractUrl 형식 변환 (3 segments): {} -> {}", originContractUrl, trimmedUrl);
                }
                // 형식 3: contracts/{clientId}/{projectId}/{freelancerId}/filename - 이미 올바른 형식
                else if (parts.length == 5) {
                    log.debug("계약 생성 DTO - originContractUrl 이미 올바른 형식 (4 segments): {}", trimmedUrl);
                }
            }
            dto.setOriginContractUrl(trimmedUrl);
            log.debug("계약 생성 DTO - originContractUrl 최종: {}", trimmedUrl);
        } else {
            String defaultOriginContractUrl = "contracts/" + userId + "/" + projectId + "/" + freelancerId + "/contract.pdf";
            dto.setOriginContractUrl(defaultOriginContractUrl);
            log.debug("계약 생성 DTO - originContractUrl 기본값 생성: {}", defaultOriginContractUrl);
        }
        
        List<ContractMilestoneRequestDTO> milestoneList = createMilestoneList(milestoneName, milestoneAmount, milestoneDesc);
        if (!milestoneList.isEmpty()) {
            dto.setMilestones(milestoneList);
        }
        
        return dto;
    }

    @Override
    public ContractUpdateRequestDTO createUpdateDto(
            Integer contractId, Integer projectId, Integer freelancerId, String contractStartDate,
            String contractEndDate, Long totalBudget, String paymentMethod, String[] milestoneName,
            String[] milestoneAmount, String[] milestoneDesc, Integer userId, String originContractUrl) {
        
        ContractUpdateRequestDTO dto = new ContractUpdateRequestDTO();
        dto.setContractId(contractId);
        dto.setContractStartDate(contractStartDate);
        dto.setContractEndDate(contractEndDate);
        dto.setTotalBudget(totalBudget);
        dto.setPaymentMethod(paymentMethod);
        
        if (originContractUrl != null && !originContractUrl.trim().isEmpty()) {
            String trimmedUrl = originContractUrl.trim();
            // 기존 URL이 contracts/{clientId}/filename 형식인 경우, 
            // contracts/{clientId}/{projectId}/{freelancerId}/filename 형식으로 변환
            if (trimmedUrl.matches("^contracts/\\d+/[^/]+$")) {
                // contracts/{clientId}/filename -> contracts/{clientId}/{projectId}/{freelancerId}/filename
                String[] parts = trimmedUrl.split("/", 3);
                if (parts.length == 3 && projectId != null && freelancerId != null) {
                    String filename = parts[2];
                    trimmedUrl = String.format("contracts/%s/%d/%d/%s", parts[1], projectId, freelancerId, filename);
                    log.debug("계약 수정 DTO - originContractUrl 형식 변환: {} -> {}", originContractUrl, trimmedUrl);
                }
            }
            dto.setOriginContractUrl(trimmedUrl);
            log.debug("계약 수정 DTO - originContractUrl 사용: {}", trimmedUrl);
        } else {
            String defaultOriginContractUrl = "contracts/" + userId + "/" + projectId + "/" + freelancerId + "/contract.pdf";
            dto.setOriginContractUrl(defaultOriginContractUrl);
            log.debug("계약 수정 DTO - originContractUrl 기본값 생성: {}", defaultOriginContractUrl);
        }
        
        List<ContractMilestoneRequestDTO> milestoneList = createMilestoneList(milestoneName, milestoneAmount, milestoneDesc);
        if (!milestoneList.isEmpty()) {
            dto.setMilestones(milestoneList);
        }
        
        return dto;
    }
}
