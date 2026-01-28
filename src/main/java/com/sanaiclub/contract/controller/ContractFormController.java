package com.sanaiclub.contract.controller;

import com.sanaiclub.contract.model.dto.*;
import com.sanaiclub.contract.model.vo.ContractStatus;
import com.sanaiclub.contract.service.ContractAutoFillService;
import com.sanaiclub.contract.service.ContractService;
import com.sanaiclub.contract.service.ContractPdfService;
import com.sanaiclub.contract.service.ContractFileService;
import com.sanaiclub.project.model.vo.ProjectsVO;
import com.sanaiclub.user.model.vo.FreelancerProfileVO;
import com.sanaiclub.user.model.vo.UserVO;
import com.sanaiclub.user.model.vo.ClientProfileVO;
import com.sanaiclub.user.model.vo.CompanyVO;
import com.sanaiclub.common.util.AuthContext;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.*;

/** 계약서 작성 플로우 컨트롤러. form → contractCheck → confirm 플로우 관리. */
@Slf4j
@Controller
@RequestMapping("/client/contract")
@RequiredArgsConstructor
public class ContractFormController {

    private final ContractService contractService;
    private final ContractAutoFillService contractAutoFillService;
    private final ContractPdfService contractPdfService;
    private final ContractFileService contractFileService;

    /** 계약서 작성 화면 조회. 프로젝트 및 프리랜서 선택 UI 제공. */
    @GetMapping("/form")
    public String showContractForm(
            @RequestParam(value = "projectId", required = false) String projectIdParam,
            @RequestParam(value = "freelancerId", required = false) String freelancerIdParam,
            Model model
    ) {
        Integer userId = AuthContext.getCurrentUserId();
        if (userId == null) {
            return "error/unauthorized";
        }

        Integer projectId = null;
        Integer freelancerId = null;

        if (projectIdParam != null && !projectIdParam.isBlank()) {
            projectId = Integer.valueOf(projectIdParam);
        }
        if (freelancerIdParam != null && !freelancerIdParam.isBlank()) {
            freelancerId = Integer.valueOf(freelancerIdParam);
        }

        // Service를 통해 View 데이터 조회 (모든 Mapper 호출 포함)
        ContractService.ContractFormViewData viewData = contractService.getContractFormViewData(userId, projectId, freelancerId);
        
        if (viewData.getClientUser() == null) {
            return "error/unauthorized";
        }

        model.addAttribute("clientUser", viewData.getClientUser());
        model.addAttribute("clientProfile", viewData.getClientProfile());
        model.addAttribute("company", viewData.getCompany());
        model.addAttribute("selectedProject", viewData.getSelectedProject());
        model.addAttribute("selectedFreelancerUser", viewData.getSelectedFreelancerUser());
        model.addAttribute("selectedFreelancerProfile", null); // FreelancerProfile은 다른 도메인 Mapper 이슈로 인해 사용하지 않음

        // 클라이언트의 프로젝트 목록 조회 (Service를 통해)
        List<ProjectsVO> projectList = contractService.getProjectsByClientId(userId);
        model.addAttribute("projectList", projectList);
        model.addAttribute("freelancerList", Collections.emptyList());

        return "contract/contractForm";
    }

    /** AI 계약서 초안 생성. PDF 업로드 또는 직접 작성 내용을 기반으로 AI가 계약서 초안 생성. */
    @PostMapping("/contractCheck")
    public String contractCheck(
            @RequestParam Map<String, String> params,
            Model model
    ) {
        try {
            // 1. 파라미터 추출 및 검증
            Integer projectId = extractProjectId(params, model);
            Integer freelancerId = extractFreelancerId(params, model);
            
            if (projectId == null || freelancerId == null) {
                if (projectId == null && freelancerId == null) {
                    model.addAttribute("errorMessage", "프로젝트와 프리랜서를 모두 선택해주세요.");
                }
                return "contract/contractCheck";
            }

            String contractInputType = params.getOrDefault("contractInputType", "FORM");
            String originContractUrl = params.get("originContractUrl");
            
            if ((originContractUrl == null || originContractUrl.isBlank()) && params.get("uploadedPdfFileName") != null && !params.get("uploadedPdfFileName").isBlank()) {
                originContractUrl = params.get("uploadedPdfFileName");
            }
            
            String finalOriginContractUrl = normalizePdfPath(originContractUrl, contractInputType, projectId, freelancerId);
            String manualText = buildManualText(params, contractInputType);

            // 2. DB 조회 및 검증
            Integer userId = AuthContext.getCurrentUserId();
            if (userId == null) {
                model.addAttribute("errorMessage", "로그인이 필요합니다.");
                return "contract/contractCheck";
            }
            
            // Service를 통해 View 데이터 조회 (모든 Mapper 호출 포함)
            ContractService.ContractCheckViewData viewData = contractService.getContractCheckViewData(userId, projectId, freelancerId);
            
            if (!validateDomainObjects(viewData.getClientUser(), viewData.getProject(), viewData.getFreelancerUser(), model)) {
                return "contract/contractCheck";
            }
            
            // FreelancerProfile은 다른 도메인 Mapper 이슈로 인해 사용하지 않음
            FreelancerProfileVO freelancerProfile = null;

            // 3. AI 초안 생성
            java.io.File pdfFile = getPdfFile(finalOriginContractUrl, contractInputType);
            ContractAutoFillDTO draft = contractAutoFillService.generateDraft(
                    pdfFile, manualText, viewData.getProject(), viewData.getFreelancerUser(), freelancerProfile
            );

            // 4. Model에 데이터 전달
            prepareModelForContractCheck(model, params, viewData.getClientUser(), viewData.getClientProfile(), 
                    viewData.getCompany(), viewData.getProject(), viewData.getFreelancerUser(), 
                    freelancerProfile, draft, finalOriginContractUrl, contractInputType, projectId, freelancerId);

            return "contract/contractCheck";
        } catch (IllegalStateException e) {
            model.addAttribute("errorMessage", "계약서 초안 생성 실패: " + e.getMessage());
            return "contract/contractCheck";
        } catch (Exception e) {
            log.error("계약서 초안 생성 중 오류: {}", e.getMessage(), e);
            model.addAttribute("errorMessage", "계약서 초안 생성 중 오류가 발생했습니다: " + e.getMessage());
            return "contract/contractCheck";
        }
    }

    /** 계약서 상세 조회. 기존 계약 정보를 조회하여 상세 화면에 표시. */
    @GetMapping("/contractCheck")
    public String contractCheckGet(@RequestParam("contractId") Integer contractId, Model model) {
        ContractResponseDTO contract = contractService.getContractById(contractId);
        if (contract == null) {
            model.addAttribute("errorMessage", "계약 정보를 찾을 수 없습니다.");
            return "contract/contractCheck";
        }
        
        model.addAttribute("contract", contract);
        model.addAttribute("milestones", contract.getMilestones());
        return "contract/contractCheck";
    }

    /** 계약서 최종 확정 및 저장. 같은 클라이언트/프로젝트/프리랜서 조합이면 UPDATE, 없으면 INSERT. */
    @PostMapping("/confirm")
    public String confirmContract(
            @RequestParam("projectId") String projectIdStr,
            @RequestParam("freelancerId") String freelancerIdStr,
            @RequestParam("contractStartDate") String contractStartDate,
            @RequestParam("contractEndDate") String contractEndDate,
            @RequestParam("totalBudget") String totalBudgetStr,
            @RequestParam("paymentMethod") String paymentMethod,
            @RequestParam(value = "originContractUrl", required = false) String originContractUrl,
            @RequestParam(value = "contractInputType", required = false) String contractInputType,
            @RequestParam(value = "requirements", required = false) String requirements,
            @RequestParam(value = "milestoneName", required = false) String[] milestoneNames,
            @RequestParam(value = "milestoneAmount", required = false) String[] milestoneAmounts,
            @RequestParam(value = "milestoneDesc", required = false) String[] milestoneDescs,
            @RequestParam(value = "contractPurpose", required = false) String contractPurpose,
            @RequestParam(value = "workScope", required = false) String workScope,
            @RequestParam(value = "deliverables", required = false) String deliverables,
            @RequestParam(value = "paymentCondition", required = false) String paymentCondition,
            @RequestParam(value = "scheduleCondition", required = false) String scheduleCondition,
            @RequestParam(value = "specialTerms", required = false) String specialTerms,
            @RequestParam(value = "contractPdf", required = false) MultipartFile contractPdf,
            Model model
    ) {
        try {
            // 파라미터 검증
            if (projectIdStr == null || projectIdStr.isBlank() || 
                freelancerIdStr == null || freelancerIdStr.isBlank()) {
                model.addAttribute("message", "프로젝트와 프리랜서 정보가 필요합니다.");
                return "contract/contractConfirmResult";
            }
            
            Integer userId = AuthContext.getCurrentUserId();
            if (userId == null) {
                model.addAttribute("message", "로그인이 필요합니다.");
                return "contract/contractConfirmResult";
            }
            
            Integer projectId = Integer.valueOf(projectIdStr);
            Integer clientId = userId;
            Integer freelancerId = Integer.valueOf(freelancerIdStr);
            
            // Service를 통해 사용자 정보 조회
            ContractService.PdfGenerationUserData userData = contractService.getPdfGenerationUserData(clientId, freelancerId);
            if (userData.getClientUser() == null) {
                model.addAttribute("message", "사용자 정보를 찾을 수 없습니다.");
                return "contract/contractConfirmResult";
            }
            
            // PDF 경로 처리
            String finalPdfPath = processPdfPath(contractInputType, originContractUrl, clientId, 
                    projectId, freelancerId, contractStartDate, contractEndDate, totalBudgetStr, 
                    paymentMethod, contractPurpose, workScope, deliverables, paymentCondition, 
                    scheduleCondition, specialTerms, milestoneNames, milestoneAmounts, milestoneDescs, 
                    userData, model);
            
            // UPDATE vs INSERT 로직
            ContractResponseDTO existingContract = contractService.getContractByPathPattern(clientId, projectId, freelancerId);
            
            if (existingContract != null && existingContract.getContractId() != null) {
                // UPDATE
                updateExistingContract(existingContract, contractStartDate, contractEndDate, totalBudgetStr, 
                        paymentMethod, contractInputType, contractPurpose, workScope, deliverables, 
                        paymentCondition, scheduleCondition, specialTerms, finalPdfPath, milestoneNames, 
                        milestoneAmounts, milestoneDescs, clientId, projectId, freelancerId, model);
            } else {
                // INSERT
                createNewContract(projectId, freelancerId, contractStartDate, contractEndDate, totalBudgetStr, 
                        paymentMethod, contractInputType, contractPurpose, workScope, deliverables, 
                        paymentCondition, scheduleCondition, specialTerms, finalPdfPath, milestoneNames, 
                        milestoneAmounts, milestoneDescs, requirements, model);
            }
            
            return "contract/contractConfirmResult";
        } catch (Exception e) {
            log.error("계약 저장 중 오류 발생: {}", e.getMessage(), e);
            model.addAttribute("message", "계약 저장 중 오류 발생: " + e.getMessage());
            return "contract/contractConfirmResult";
        }
    }

    /** 파라미터에서 프로젝트 ID 추출 */
    private Integer extractProjectId(Map<String, String> params, Model model) {
        try {
            String projectIdStr = params.get("projectId");
            if (projectIdStr != null && !projectIdStr.isBlank()) {
                return Integer.valueOf(projectIdStr);
            }
        } catch (NumberFormatException e) {
            model.addAttribute("errorMessage", "잘못된 프로젝트 ID입니다.");
        }
        return null;
    }

    /** 파라미터에서 프리랜서 ID 추출 */
    private Integer extractFreelancerId(Map<String, String> params, Model model) {
        try {
            String freelancerIdStr = params.get("freelancerId");
            if (freelancerIdStr != null && !freelancerIdStr.isBlank()) {
                return Integer.valueOf(freelancerIdStr);
            }
        } catch (NumberFormatException e) {
            model.addAttribute("errorMessage", "잘못된 프리랜서 ID입니다.");
        }
        return null;
    }

    /** PDF 경로 정규화. 표준 형식으로 변환. */
    private String normalizePdfPath(String originContractUrl, String contractInputType, Integer projectId, Integer freelancerId) {
        if (!"PDF".equals(contractInputType) || originContractUrl == null || originContractUrl.isBlank()) {
            return originContractUrl;
        }
        
        String normalizedPath = originContractUrl.replace("\\", "/");
        if (normalizedPath.startsWith("contracts/")) {
            return normalizedPath;
        }
        
        Integer userId = AuthContext.getCurrentUserId();
        return "contracts/" + userId + "/" + projectId + "/" + normalizedPath;
    }

    /** 직접 작성한 계약 내용을 텍스트로 변환. AI 초안 생성 시 사용. */
    private String buildManualText(Map<String, String> params, String contractInputType) {
        if (!"FORM".equals(contractInputType)) {
            return null;
        }
        
        StringBuilder sb = new StringBuilder();
        sb.append("계약 목적: ").append(params.getOrDefault("contractPurpose", "")).append("\n");
        sb.append("업무 범위: ").append(params.getOrDefault("workScope", "")).append("\n");
        sb.append("결과물 정의: ").append(params.getOrDefault("deliverables", "")).append("\n");
        sb.append("지급 조건: ").append(params.getOrDefault("paymentCondition", "")).append("\n");
        sb.append("일정 관련 조건: ").append(params.getOrDefault("scheduleCondition", "")).append("\n");
        sb.append("기타 특약: ").append(params.getOrDefault("specialTerms", "")).append("\n");
        return sb.toString();
    }

    /** 도메인 객체 검증. 계약서 작성에 필요한 객체들이 모두 존재하는지 확인. */
    private boolean validateDomainObjects(com.sanaiclub.user.model.vo.UserVO clientUser, ProjectsVO project, 
            com.sanaiclub.user.model.vo.UserVO freelancerUser, Model model) {
        if (clientUser == null) {
            model.addAttribute("errorMessage", "사용자 정보를 찾을 수 없습니다.");
            return false;
        }
        if (project == null) {
            model.addAttribute("errorMessage", "프로젝트를 찾을 수 없습니다.");
            return false;
        }
        if (freelancerUser == null) {
            model.addAttribute("errorMessage", "프리랜서를 찾을 수 없습니다.");
            return false;
        }
        return true;
    }

    private java.io.File getPdfFile(String finalOriginContractUrl, String contractInputType) {
        if (!"PDF".equals(contractInputType) || finalOriginContractUrl == null || finalOriginContractUrl.isBlank()) {
            return null;
        }
        
        if (contractFileService.existsPdfFile(finalOriginContractUrl)) {
            log.info("PDF 파일 찾음: {}", finalOriginContractUrl);
            return contractFileService.getPdfFile(finalOriginContractUrl);
        } else {
            log.warn("PDF 파일을 찾을 수 없습니다: {}", finalOriginContractUrl);
            return null;
        }
    }

    private void prepareModelForContractCheck(Model model, Map<String, String> params, UserVO clientUser, 
            ClientProfileVO clientProfile, CompanyVO company, ProjectsVO project, UserVO freelancerUser, 
            FreelancerProfileVO freelancerProfile, ContractAutoFillDTO draft, String finalOriginContractUrl, 
            String contractInputType, Integer projectId, Integer freelancerId) {
        
        ContractCreateRequestDTO formDto = new ContractCreateRequestDTO();
        formDto.setProjectId(projectId);
        formDto.setFreelancerId(freelancerId);
        
        if ("FORM".equals(contractInputType)) {
            formDto.setContractPurpose(params.get("contractPurpose"));
            formDto.setWorkScope(params.get("workScope"));
            formDto.setDeliverables(params.get("deliverables"));
            formDto.setPaymentCondition(params.get("paymentCondition"));
            formDto.setScheduleCondition(params.get("scheduleCondition"));
            formDto.setSpecialTerms(params.get("specialTerms"));
        }
        
        if (finalOriginContractUrl != null && !finalOriginContractUrl.isBlank()) {
            params.put("originContractUrl", finalOriginContractUrl);
            model.addAttribute("originContractUrl", finalOriginContractUrl);
            formDto.setOriginContractUrl(finalOriginContractUrl);
        }
        
        // Service를 통해 View 데이터 변환 (모든 DTO → Map 변환 포함)
        ContractService.ContractCheckViewMapData viewMaps = 
            contractService.convertToContractCheckViewMaps(clientUser, company, freelancerUser, freelancerProfile);
        
        model.addAttribute("client", viewMaps.getClientMap());
        model.addAttribute("freelancer", viewMaps.getFreelancerMap());
        
        model.addAttribute("project", project);
        model.addAttribute("draft", draft);
        model.addAttribute("contract", draft); // ContractAutoFillDTO가 contractStartDate, contractEndDate, totalBudget, paymentMethod, milestones 포함
        model.addAttribute("formDto", formDto);
        model.addAttribute("contractInputType", contractInputType);
    }

    private String processPdfPath(String contractInputType, String originContractUrl, Integer clientId, 
            Integer projectId, Integer freelancerId, String contractStartDate, String contractEndDate, 
            String totalBudgetStr, String paymentMethod, String contractPurpose, String workScope, 
            String deliverables, String paymentCondition, String scheduleCondition, String specialTerms, 
            String[] milestoneNames, String[] milestoneAmounts, String[] milestoneDescs, 
            ContractService.PdfGenerationUserData userData, Model model) {
        
        String finalPdfPath = null;
        
        if ("FORM".equals(contractInputType)) {
            finalPdfPath = generatePdfForForm(clientId, projectId, freelancerId, contractStartDate, 
                    contractEndDate, totalBudgetStr, paymentMethod, contractPurpose, workScope, 
                    deliverables, paymentCondition, scheduleCondition, specialTerms, milestoneNames, 
                    milestoneAmounts, milestoneDescs, userData, model);
        } else if ("PDF".equals(contractInputType) && originContractUrl != null && !originContractUrl.isBlank()) {
            finalPdfPath = normalizeAndMovePdf(originContractUrl, clientId, projectId, freelancerId);
        }
        
        return finalPdfPath;
    }

    private String generatePdfForForm(Integer clientId, Integer projectId, Integer freelancerId, 
            String contractStartDate, String contractEndDate, String totalBudgetStr, String paymentMethod, 
            String contractPurpose, String workScope, String deliverables, String paymentCondition, 
            String scheduleCondition, String specialTerms, String[] milestoneNames, String[] milestoneAmounts, 
            String[] milestoneDescs, ContractService.PdfGenerationUserData userData, Model model) {
        
        try {
            if (userData.getFreelancerUser() == null) {
                throw new IllegalStateException("프리랜서 정보를 찾을 수 없습니다.");
            }
            
            // FreelancerProfile은 다른 도메인 Mapper 이슈로 인해 사용하지 않음
            FreelancerProfileVO freelancerProfile = null;
            
            String baseDir = System.getProperty("user.dir");
            String saveDir = baseDir + java.io.File.separator + "contracts" + java.io.File.separator 
                    + clientId + java.io.File.separator + projectId + java.io.File.separator + freelancerId;
            String fileName = System.currentTimeMillis() + "_contract_" + projectId + "_" + freelancerId + ".pdf";
            
            ContractCreateRequestDTO pdfForm = createPdfFormDto(contractStartDate, contractEndDate, 
                    totalBudgetStr, paymentMethod, contractPurpose, workScope, deliverables, 
                    paymentCondition, scheduleCondition, specialTerms, milestoneNames, milestoneAmounts, milestoneDescs);
            
            contractPdfService.generateContractPdf(userData.getClientUser(), userData.getClientProfile(), 
                    userData.getCompany(), userData.getFreelancerUser(), freelancerProfile, pdfForm, saveDir, fileName);
            
            String finalPdfPath = "contracts/" + clientId + "/" + projectId + "/" + freelancerId + "/" + fileName;
            log.info("서버에서 계약서 PDF 생성 완료: {}", finalPdfPath);
            return finalPdfPath;
        } catch (Exception e) {
            log.error("계약서 PDF 생성 실패: {}", e.getMessage(), e);
            model.addAttribute("pdfGenerationError", "PDF 생성 중 오류가 발생했습니다: " + e.getMessage());
            return null;
        }
    }

    private ContractCreateRequestDTO createPdfFormDto(String contractStartDate, String contractEndDate, 
            String totalBudgetStr, String paymentMethod, String contractPurpose, String workScope, 
            String deliverables, String paymentCondition, String scheduleCondition, String specialTerms, 
            String[] milestoneNames, String[] milestoneAmounts, String[] milestoneDescs) {
        
        ContractCreateRequestDTO pdfForm = new ContractCreateRequestDTO();
        pdfForm.setContractStartDate(contractStartDate != null ? contractStartDate.trim() : null);
        pdfForm.setContractEndDate(contractEndDate != null ? contractEndDate.trim() : null);
        
        if (totalBudgetStr != null && !totalBudgetStr.isBlank()) {
            try {
                pdfForm.setTotalBudget(Long.valueOf(totalBudgetStr.trim()));
            } catch (NumberFormatException e) {
                // 무시
            }
        }
        
        pdfForm.setPaymentMethod(paymentMethod != null ? paymentMethod.trim() : null);
        pdfForm.setContractPurpose(contractPurpose != null && !contractPurpose.trim().isEmpty() ? contractPurpose.trim() : null);
        pdfForm.setWorkScope(workScope != null && !workScope.trim().isEmpty() ? workScope.trim() : null);
        pdfForm.setDeliverables(deliverables != null && !deliverables.trim().isEmpty() ? deliverables.trim() : null);
        pdfForm.setPaymentCondition(paymentCondition != null && !paymentCondition.trim().isEmpty() ? paymentCondition.trim() : null);
        pdfForm.setScheduleCondition(scheduleCondition != null && !scheduleCondition.trim().isEmpty() ? scheduleCondition.trim() : null);
        pdfForm.setSpecialTerms(specialTerms != null && !specialTerms.trim().isEmpty() ? specialTerms.trim() : null);
        
        if ("MILESTONE".equals(paymentMethod) && milestoneNames != null && milestoneNames.length > 0) {
            pdfForm.setMilestones(createMilestoneList(milestoneNames, milestoneAmounts, milestoneDescs));
        }
        
        return pdfForm;
    }

    private String normalizeAndMovePdf(String originContractUrl, Integer clientId, Integer projectId, Integer freelancerId) {
        String finalPdfPath = contractFileService.normalizeAndMovePdfPath(originContractUrl, clientId, projectId, freelancerId);
        
        if (contractFileService.existsPdfFile(finalPdfPath)) {
            String currentFileName = finalPdfPath.substring(finalPdfPath.lastIndexOf("/") + 1);
            String pathPattern = "contracts/" + clientId + "/" + projectId + "/" + freelancerId + "/%";
            List<String> confirmedPdfPaths = contractService.getOriginContractUrlsByPathPattern(pathPattern);
            
            if (!confirmedPdfPaths.contains(finalPdfPath)) {
                confirmedPdfPaths.add(finalPdfPath);
            }
            
            contractFileService.cleanupUnconfirmedPdfs(clientId, projectId, freelancerId, currentFileName, confirmedPdfPaths);
        }
        
        return finalPdfPath;
    }

    private void updateExistingContract(ContractResponseDTO existingContract, String contractStartDate, 
            String contractEndDate, String totalBudgetStr, String paymentMethod, String contractInputType, 
            String contractPurpose, String workScope, String deliverables, String paymentCondition, 
            String scheduleCondition, String specialTerms, String finalPdfPath, String[] milestoneNames, 
            String[] milestoneAmounts, String[] milestoneDescs, Integer clientId, Integer projectId, 
            Integer freelancerId, Model model) {
        
        try {
            ContractUpdateRequestDTO updateDto = createUpdateDto(
                    existingContract.getContractId(), contractStartDate, contractEndDate, totalBudgetStr, 
                    paymentMethod, contractInputType, contractPurpose, workScope, deliverables, 
                    paymentCondition, scheduleCondition, specialTerms, finalPdfPath, milestoneNames, 
                    milestoneAmounts, milestoneDescs
            );
            
            String previousPdfPath = existingContract.getOriginContractUrl();
            if (previousPdfPath != null && !previousPdfPath.equals(finalPdfPath)) {
                String pathPattern = "contracts/" + clientId + "/" + projectId + "/" + freelancerId + "/%";
                List<String> confirmedPdfPaths = contractService.getOriginContractUrlsByPathPattern(pathPattern);
                contractFileService.deletePdfIfNotUsed(previousPdfPath, confirmedPdfPaths);
            }
            
            contractService.updateContract(updateDto);
            model.addAttribute("message", "계약이 성공적으로 수정되었습니다. (ID: " + existingContract.getContractId() + ")");
        } catch (NumberFormatException e) {
            model.addAttribute("message", "잘못된 예산 형식입니다.");
        }
    }

    private void createNewContract(Integer projectId, Integer freelancerId, String contractStartDate, 
            String contractEndDate, String totalBudgetStr, String paymentMethod, String contractInputType, 
            String contractPurpose, String workScope, String deliverables, String paymentCondition, 
            String scheduleCondition, String specialTerms, String finalPdfPath, String[] milestoneNames, 
            String[] milestoneAmounts, String[] milestoneDescs, String requirements, Model model) {
        
        try {
            ContractCreateRequestDTO createDto = createContractDto(
                    projectId, freelancerId, contractStartDate, contractEndDate, totalBudgetStr, 
                    paymentMethod, contractInputType, contractPurpose, workScope, deliverables, 
                    paymentCondition, scheduleCondition, specialTerms, finalPdfPath, milestoneNames, 
                    milestoneAmounts, milestoneDescs, requirements
            );
            
            Integer contractId = contractService.createContract(createDto);
            if (contractId == null) {
                log.error("계약 생성 실패: contractId가 null입니다. createDto: {}", createDto);
                model.addAttribute("message", "계약 저장 중 오류가 발생했습니다. (contractId 생성 실패)");
            } else {
                model.addAttribute("message", "계약이 성공적으로 저장되었습니다. (ID: " + contractId + ")");
                log.debug("계약 생성 성공: contractId={}, 마일스톤 수={}", 
                        contractId, 
                        createDto.getMilestones() != null ? createDto.getMilestones().size() : 0);
            }
        } catch (NumberFormatException e) {
            model.addAttribute("message", "잘못된 예산 형식입니다.");
        }
    }

    private ContractCreateRequestDTO createContractDto(
            Integer projectId, Integer freelancerId, String contractStartDate, String contractEndDate, 
            String totalBudgetStr, String paymentMethod, String contractInputType, String contractPurpose, 
            String workScope, String deliverables, String paymentCondition, String scheduleCondition, 
            String specialTerms, String originContractUrl, String[] milestoneNames, String[] milestoneAmounts, 
            String[] milestoneDescs, String requirements
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
        dto.setContractStatus(ContractStatus.WAITING);
        dto.setOriginContractUrl(originContractUrl);
        
        if ("FORM".equals(contractInputType)) {
            dto.setContractPurpose(contractPurpose);
            dto.setWorkScope(workScope);
            dto.setDeliverables(deliverables);
            dto.setPaymentCondition(paymentCondition);
            dto.setScheduleCondition(scheduleCondition);
            dto.setSpecialTerms(specialTerms);
        }
        
        if (requirements != null && !requirements.isBlank()) {
            dto.setRequirements(java.util.Arrays.asList(requirements.split("\n")));
        }
        
        // 마일스톤 설정: paymentMethod가 MILESTONE이고 마일스톤 데이터가 있을 때만
        if ("MILESTONE".equals(paymentMethod) && milestoneNames != null && milestoneNames.length > 0) {
            java.util.List<ContractMilestoneRequestDTO> milestones = createMilestoneList(milestoneNames, milestoneAmounts, milestoneDescs);
            // createMilestoneList가 실제로 유효한 마일스톤을 생성했는지 확인
            if (milestones != null && !milestones.isEmpty()) {
                dto.setMilestones(milestones);
                log.debug("마일스톤 {}개가 DTO에 설정됨", milestones.size());
            } else {
                log.warn("paymentMethod가 MILESTONE이지만 유효한 마일스톤이 생성되지 않음. milestoneNames: {}, milestoneAmounts: {}", 
                        java.util.Arrays.toString(milestoneNames), 
                        milestoneAmounts != null ? java.util.Arrays.toString(milestoneAmounts) : "null");
            }
        }
        
        return dto;
    }

    private ContractUpdateRequestDTO createUpdateDto(
            Integer contractId, String contractStartDate, String contractEndDate, String totalBudgetStr, 
            String paymentMethod, String contractInputType, String contractPurpose, String workScope, 
            String deliverables, String paymentCondition, String scheduleCondition, String specialTerms, 
            String originContractUrl, String[] milestoneNames, String[] milestoneAmounts, String[] milestoneDescs
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
        dto.setContractStatus(ContractStatus.WAITING);
        dto.setOriginContractUrl(originContractUrl);
        
        if ("FORM".equals(contractInputType)) {
            dto.setContractPurpose(contractPurpose);
            dto.setWorkScope(workScope);
            dto.setDeliverables(deliverables);
            dto.setPaymentCondition(paymentCondition);
            dto.setScheduleCondition(scheduleCondition);
            dto.setSpecialTerms(specialTerms);
        }
        
        // 마일스톤 설정: paymentMethod가 MILESTONE이고 마일스톤 데이터가 있을 때만
        if ("MILESTONE".equals(paymentMethod) && milestoneNames != null && milestoneNames.length > 0) {
            java.util.List<ContractMilestoneRequestDTO> milestones = createMilestoneList(milestoneNames, milestoneAmounts, milestoneDescs);
            // createMilestoneList가 실제로 유효한 마일스톤을 생성했는지 확인
            if (milestones != null && !milestones.isEmpty()) {
                dto.setMilestones(milestones);
                log.debug("마일스톤 {}개가 UPDATE DTO에 설정됨", milestones.size());
            } else {
                log.warn("paymentMethod가 MILESTONE이지만 유효한 마일스톤이 생성되지 않음 (UPDATE). milestoneNames: {}, milestoneAmounts: {}", 
                        java.util.Arrays.toString(milestoneNames), 
                        milestoneAmounts != null ? java.util.Arrays.toString(milestoneAmounts) : "null");
            }
        }
        
        return dto;
    }

    private java.util.List<ContractMilestoneRequestDTO> createMilestoneList(
            String[] milestoneNames, String[] milestoneAmounts, String[] milestoneDescs
    ) {
        java.util.List<ContractMilestoneRequestDTO> milestones = new java.util.ArrayList<>();
        
        // 입력 파라미터 로깅
        log.debug("createMilestoneList 호출 - milestoneNames: {}, milestoneAmounts: {}, milestoneDescs: {}", 
                milestoneNames != null ? java.util.Arrays.toString(milestoneNames) : "null",
                milestoneAmounts != null ? java.util.Arrays.toString(milestoneAmounts) : "null",
                milestoneDescs != null ? java.util.Arrays.toString(milestoneDescs) : "null");
        
        if (milestoneNames == null || milestoneNames.length == 0) {
            log.warn("createMilestoneList: milestoneNames가 null이거나 비어있음");
            return milestones;
        }
        
        int maxLength = Math.max(
            Math.max(milestoneNames != null ? milestoneNames.length : 0, 
                     milestoneAmounts != null ? milestoneAmounts.length : 0),
            milestoneDescs != null ? milestoneDescs.length : 0
        );
        
        log.debug("createMilestoneList: maxLength={}", maxLength);
        
        for (int i = 0; i < maxLength; i++) {
            String name = (milestoneNames != null && i < milestoneNames.length && milestoneNames[i] != null) 
                ? milestoneNames[i].trim() : "";
            String amountStr = (milestoneAmounts != null && i < milestoneAmounts.length && milestoneAmounts[i] != null) 
                ? milestoneAmounts[i].trim() : "";
            String desc = (milestoneDescs != null && i < milestoneDescs.length && milestoneDescs[i] != null) 
                ? milestoneDescs[i].trim() : "";
            
            log.debug("마일스톤 {}: name='{}', amountStr='{}', desc='{}'", i + 1, name, amountStr, desc);
            
            if (!name.isEmpty() && !amountStr.isEmpty()) {
                try {
                    Long amount = Long.valueOf(amountStr);
                    ContractMilestoneRequestDTO milestone = new ContractMilestoneRequestDTO();
                    milestone.setStep(i + 1);
                    milestone.setTitle(name);
                    milestone.setAmount(amount);
                    milestone.setDescription(desc);
                    milestones.add(milestone);
                    log.debug("마일스톤 {} 추가 성공: title={}, amount={}", i + 1, name, amount);
                } catch (NumberFormatException e) {
                    log.warn("마일스톤 {} 추가 실패: amountStr '{}'를 숫자로 변환할 수 없음", i + 1, amountStr, e);
                }
            } else {
                log.debug("마일스톤 {} 건너뜀: name 또는 amountStr이 비어있음", i + 1);
            }
        }
        
        log.debug("createMilestoneList 완료: {}개의 유효한 마일스톤 생성", milestones.size());
        return milestones;
    }
}
