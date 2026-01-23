package com.sanaiclub.contract.controller;

import com.sanaiclub.contract.model.vo.*;
import com.sanaiclub.contract.model.dto.*;
import com.sanaiclub.contract.service.ContractAutoFillService;
import com.sanaiclub.contract.service.ContractService;
import com.sanaiclub.contract.service.ContractPdfService;
import com.sanaiclub.contract.service.ContractFileService;
import com.sanaiclub.contract.util.ContractDtoHelper;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import java.util.*;

/**
 * 계약서 관리 컨트롤러
 * 
 * [역할]
 * - 클라이언트의 계약서 작성, 수정, 조회, 확정 등의 API 엔드포인트 제공
 * - 계약서 작성 플로우: form → contractCheck → confirm
 * - PDF 업로드/생성 및 파일 관리
 * 
 * [주요 플로우]
 * 1. 계약서 작성 화면 (GET /form) → 프로젝트/프리랜서 선택
 * 2. 계약서 초안 생성 (POST /contractCheck) → AI가 계약서 초안 생성
 * 3. 계약서 확정 및 저장 (POST /confirm) → UPDATE 또는 INSERT
 * 
 * [데이터 흐름]
 * - 같은 clientId + projectId + freelancerId 조합이면 UPDATE
 * - 없으면 INSERT
 * - PDF 경로: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
 * 
 * [관련 서비스]
 * - ContractService: 계약 CRUD 및 비즈니스 로직
 * - ContractPdfService: PDF 생성 (HTML → PDF)
 * - ContractFileService: PDF 파일 업로드/이동/삭제
 * - ContractAutoFillService: AI 기반 계약서 초안 생성
 */
@Controller
@RequestMapping("/client/contract")
public class ContractController {

    private static final Logger logger = LoggerFactory.getLogger(ContractController.class);

    private final ContractService contractService;
    private final ContractAutoFillService contractAutoFillService;
    private final ContractPdfService contractPdfService;
    private final ContractFileService contractFileService;

    /**
     * 생성자 주입
     * 
     * @param contractService 계약 비즈니스 로직 서비스
     * @param contractAutoFillService AI 계약서 초안 생성 서비스
     * @param contractPdfService PDF 생성 서비스
     * @param contractFileService PDF 파일 관리 서비스
     */
    public ContractController(
            ContractService contractService,
            ContractAutoFillService contractAutoFillService,
            ContractPdfService contractPdfService,
            ContractFileService contractFileService
    ) {
        this.contractService = contractService;
        this.contractAutoFillService = contractAutoFillService;
        this.contractPdfService = contractPdfService;
        this.contractFileService = contractFileService;
    }
    /* =========================================================
       계약서 최종 확정 및 저장
       ========================================================= */
    
    /**
     * 계약서 최종 확정 및 저장
     * 
     * [기능]
     * - 계약서 작성/수정 후 최종 확정하여 DB에 저장
     * - 같은 클라이언트/프로젝트/프리랜서 조합이면 UPDATE, 없으면 INSERT
     * 
     * [처리 시나리오]
     * 1. 직접 작성 (FORM): 서버에서 HTML → PDF 생성
     *    - ContractPdfService.generateContractPdf() 호출
     *    - 저장 경로: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
     * 
     * 2. PDF 업로드 (PDF): 업로드된 PDF 경로 정규화 및 이동
     *    - ContractFileService.normalizeAndMovePdfPath() 호출
     *    - freelancerId가 경로에 없으면 추가하고 파일 이동
     * 
     * [UPDATE vs INSERT 로직]
     * - getContractByPathPattern(clientId, projectId, freelancerId)로 기존 계약 조회
     * - TERMINATED 상태가 아닌 계약만 조회 (새 계약 생성 가능)
     * - 기존 계약 있음 → UPDATE (기존 contractId 유지, contracted_at 유지)
     * - 기존 계약 없음 → INSERT (새 contractId 생성, contracted_at = 현재 시간)
     * 
     * [PDF 파일 관리]
     * - UPDATE 시: 이전 PDF가 현재 PDF와 다르면 삭제 고려
     *   → 다른 계약에서 사용 중이 아니면 삭제
     * - 확정 시점: 미확정 PDF 파일 정리 (cleanupUnconfirmedPdfs)
     * 
     * @param projectId 프로젝트 ID
     * @param freelancerId 프리랜서 ID
     * @param contractStartDate 계약 시작일
     * @param contractEndDate 계약 종료일
     * @param totalBudgetStr 총 예산 (문자열)
     * @param paymentMethod 지급 방식 ("ONE_TIME" 또는 "MILESTONE")
     * @param originContractUrl 업로드된 PDF 경로 (PDF 타입일 때)
     * @param contractInputType 입력 타입 ("FORM" 또는 "PDF")
     * @param contractPurpose 계약 목적 (FORM 타입일 때)
     * @param workScope 업무 범위 (FORM 타입일 때)
     * @param deliverables 결과물 정의 (FORM 타입일 때)
     * @param paymentCondition 지급 조건 (FORM 타입일 때)
     * @param scheduleCondition 일정 조건 (FORM 타입일 때)
     * @param specialTerms 기타 특약 (FORM 타입일 때)
     * @param milestoneNames 마일스톤 이름 배열 (MILESTONE 타입일 때)
     * @param milestoneAmounts 마일스톤 금액 배열 (MILESTONE 타입일 때)
     * @param milestoneDescs 마일스톤 설명 배열 (MILESTONE 타입일 때)
     * @param model Spring MVC Model
     * @return 뷰 이름 ("contract/contractConfirmResult")
     */
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
            
            // 클라이언트 정보 조회 (PDF 저장 경로에 필요)
            ContractClientVO client = contractService.getClientByLoginUser();
            if (client == null) {
                model.addAttribute("message", "로그인이 필요합니다.");
                return "contract/contractConfirmResult";
            }
            
            Integer projectId = Integer.valueOf(projectIdStr);
            Integer clientId = client.getClientId();
            
            // ============================================================
            // PDF 경로 처리 (통합 경로: contracts/{clientId}/{projectId}/{freelancerId}/)
            // ============================================================
            String finalPdfPath = null;
            
            // 시나리오 1: 직접 작성 (FORM) - 서버에서 PDF 생성
            // ContractPdfService가 HTML 템플릿을 생성하고 OpenHTMLToPDF로 PDF 변환
            if ("FORM".equals(contractInputType)) {
                try {
                    // 프리랜서 정보 조회
                    ContractFreelancerVO freelancer = contractService.getFreelancerById(Integer.valueOf(freelancerIdStr));
                    if (freelancer == null) {
                        throw new IllegalStateException("프리랜서 정보를 찾을 수 없습니다.");
                    }
                    
                    // 저장 경로 설정 (freelancerId 포함)
                    Integer freelancerId = Integer.valueOf(freelancerIdStr);
                    String baseDir = System.getProperty("user.dir");
                    String saveDir = baseDir + java.io.File.separator 
                        + "contracts" + java.io.File.separator 
                        + clientId + java.io.File.separator 
                        + projectId + java.io.File.separator
                        + freelancerId;
                    
                    String fileName = System.currentTimeMillis() + "_contract_" + projectId + "_" + freelancerId + ".pdf";
                    
                    // ContractCreateRequestDTO 생성 (PDF 생성에 필요한 데이터만)
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
                    
                    // 마일스톤 처리
                    if ("MILESTONE".equals(paymentMethod) && milestoneNames != null && milestoneNames.length > 0) {
                        java.util.List<ContractMilestoneRequestDTO> milestones = new java.util.ArrayList<>();
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
                        pdfForm.setMilestones(milestones);
                    }
                    
                    // 서버에서 PDF 생성
                    java.io.File pdfFile = contractPdfService.generateContractPdf(
                        client, freelancer, pdfForm, saveDir, fileName
                    );
                    
                    finalPdfPath = "contracts/" + clientId + "/" + projectId + "/" + freelancerId + "/" + fileName;
                    logger.info("서버에서 계약서 PDF 생성 완료: {}", finalPdfPath);
                    
                } catch (Exception e) {
                    logger.error("계약서 PDF 생성 실패: {}", e.getMessage(), e);
                    // PDF 생성 실패해도 계약 생성은 계속 진행
                    // 하지만 사용자에게 알림
                    model.addAttribute("pdfGenerationError", "PDF 생성 중 오류가 발생했습니다: " + e.getMessage());
                }
            } 
            // 시나리오 2: PDF 업로드 (PDF) - 업로드된 PDF 경로 정규화 및 이동
            // freelancerId가 경로에 없으면 추가하고 파일을 새 경로로 이동/복사
            else if ("PDF".equals(contractInputType) && originContractUrl != null && !originContractUrl.isBlank()) {
                Integer freelancerId = Integer.valueOf(freelancerIdStr);
                
                // 파일 경로 정규화 및 이동
                finalPdfPath = contractFileService.normalizeAndMovePdfPath(originContractUrl, clientId, projectId, freelancerId);
                
                if (contractFileService.existsPdfFile(finalPdfPath)) {
                    // 확정 시점에 이전 미확정 PDF 삭제
                    String currentFileName = finalPdfPath.substring(finalPdfPath.lastIndexOf("/") + 1);
                                String pathPattern = "contracts/" + clientId + "/" + projectId + "/" + freelancerId + "/%";
                                List<String> confirmedPdfPaths = contractService.getOriginContractUrlsByPathPattern(pathPattern);
                                
                    if (!confirmedPdfPaths.contains(finalPdfPath)) {
                        confirmedPdfPaths.add(finalPdfPath);
                    }
                    
                    contractFileService.cleanupUnconfirmedPdfs(clientId, projectId, freelancerId, currentFileName, confirmedPdfPaths);
                }
            }
            
            // ============================================================
            // UPDATE vs INSERT 로직: 같은 프로젝트/프리랜서 조합 확인
            // ============================================================
            // 경로 패턴: contracts/{clientId}/{projectId}/{freelancerId}/%
            // TERMINATED 상태가 아닌 계약만 조회 (새 계약 생성 가능)
            Integer freelancerId = Integer.valueOf(freelancerIdStr);
            ContractResponseDTO existingContract = contractService.getContractByPathPattern(clientId, projectId, freelancerId);
            
            Integer contractId;
            String previousPdfPath = null;
            
            if (existingContract != null && existingContract.getContractId() != null) {
                // ============================================================
                // 기존 계약이 있으면 UPDATE
                // ============================================================
                // - 기존 contractId 유지
                // - contracted_at 유지 (null이 아니면 기존 값 사용)
                // - 이전 PDF 삭제 고려 (다른 계약에서 사용 안 하는 경우)
                try {
                    ContractUpdateRequestDTO updateDto = ContractDtoHelper.createUpdateDto(
                        existingContract.getContractId(),
                        contractStartDate,
                        contractEndDate,
                        totalBudgetStr,
                        paymentMethod,
                        contractInputType,
                        contractPurpose,
                        workScope,
                        deliverables,
                        paymentCondition,
                        scheduleCondition,
                        specialTerms,
                        finalPdfPath,
                        milestoneNames,
                        milestoneAmounts,
                        milestoneDescs
                    );
                    
                    previousPdfPath = existingContract.getOriginContractUrl();
                    
                    // 이전 PDF가 현재 PDF와 다르면 이전 PDF 삭제 고려
                    if (previousPdfPath != null && !previousPdfPath.equals(finalPdfPath)) {
                        String pathPattern = "contracts/" + clientId + "/" + projectId + "/" + freelancerId + "/%";
                        List<String> confirmedPdfPaths = contractService.getOriginContractUrlsByPathPattern(pathPattern);
                        contractFileService.deletePdfIfNotUsed(previousPdfPath, confirmedPdfPaths);
                    }
                    
                    contractService.updateContract(updateDto);
                    contractId = existingContract.getContractId();
                    model.addAttribute("message", "계약이 성공적으로 수정되었습니다. (ID: " + contractId + ")");
                } catch (NumberFormatException e) {
                    model.addAttribute("message", "잘못된 예산 형식입니다.");
                    return "contract/contractConfirmResult";
                }
            } else {
                // ============================================================
                // 기존 계약이 없으면 INSERT
                // ============================================================
                // - 새 contractId 생성 (MyBatis useGeneratedKeys)
                // - contracted_at = 현재 시간
                try {
                    ContractCreateRequestDTO createDto = ContractDtoHelper.createContractDto(
                        projectId,
                        freelancerId,
                        contractStartDate,
                        contractEndDate,
                        totalBudgetStr,
                        paymentMethod,
                        contractInputType,
                        contractPurpose,
                        workScope,
                        deliverables,
                        paymentCondition,
                        scheduleCondition,
                        specialTerms,
                        finalPdfPath,
                        milestoneNames,
                        milestoneAmounts,
                        milestoneDescs,
                        requirements
                    );
                    
                    contractId = contractService.createContract(createDto);
                    model.addAttribute("message", "계약이 성공적으로 저장되었습니다. (ID: " + contractId + ")");
                } catch (NumberFormatException e) {
                    model.addAttribute("message", "잘못된 예산 형식입니다.");
                    return "contract/contractConfirmResult";
                }
            }
            
            return "contract/contractConfirmResult";
        } catch (Exception e) {
            logger.error("계약 저장 중 오류 발생: {}", e.getMessage(), e);
            model.addAttribute("message", "계약 저장 중 오류 발생: " + e.getMessage());
            return "contract/contractConfirmResult";
        }
    }
    /* =========================================================
       프리랜서 계약 수락 처리
       ========================================================= */
    
    /**
     * 프리랜서 계약 수락 처리
     * 
     * [기능]
     * - 프리랜서가 계약을 수락하여 상태를 SIGNED로 변경
     * 
     * [상태 변경]
     * - WAITING → SIGNED
     * 
     * [주의사항]
     * - TODO: 로그인 프리랜서 검증 필요 (현재는 미구현)
     * 
     * @param contractId 계약 ID
     * @param model Spring MVC Model
     * @return 뷰 이름 ("contract/contractAcceptResult")
     */
    @PostMapping("/freelancer/contract/accept")
    public String acceptContract(
            @RequestParam("contractId") Integer contractId,
            Model model
    ) {
        // TODO: 로그인 프리랜서 검증 필요
        contractService.acceptContract(contractId, null);
        model.addAttribute("message", "계약이 수락 처리되었습니다.");
        return "contract/contractAcceptResult";
    }

    

    /* =========================================================
       프리랜서 계약 거절 처리
       ========================================================= */
    
    /**
     * 프리랜서 계약 거절 처리
     * 
     * [기능]
     * - 프리랜서가 계약을 거절하여 상태를 TERMINATED로 변경
     * 
     * [상태 변경]
     * - WAITING → TERMINATED
     * - cancel_reason에 거절 사유 저장
     * 
     * [주의사항]
     * - TODO: 로그인 프리랜서 검증 필요 (현재는 미구현)
     * 
     * @param contractId 계약 ID
     * @param reason 거절 사유
     * @param model Spring MVC Model
     * @return 뷰 이름 ("contract/contractRejectResult")
     */
    @PostMapping("/freelancer/contract/reject")
    public String rejectContract(
            @RequestParam("contractId") Integer contractId,
            @RequestParam("reason") String reason,
            Model model
    ) {
        // TODO: 로그인 프리랜서 검증 필요
        contractService.rejectContract(contractId, null, reason);

        model.addAttribute("message", "계약이 거절 처리되었습니다.");
        return "contract/contractRejectResult";
    }

    /* =========================================================
       STEP 1 : CONTRACT FORM (계약서 작성 화면)
       ========================================================= */
    
    /**
     * 계약서 작성 화면 조회
     * 
     * [기능]
     * - 계약서 작성 폼 화면 표시
     * - 프로젝트 및 프리랜서 선택 UI 제공
     * 
     * [데이터 흐름]
     * 1. 로그인 클라이언트 조회
     * 2. 클라이언트의 프로젝트 목록 조회
     * 3. 선택된 프로젝트의 프리랜서 목록 조회 (프로젝트 선택 시)
     * 
     * [다음 단계]
     * - 사용자가 폼 작성 후 → POST /contractCheck (AI 초안 생성)
     * 
     * @param projectIdParam 선택된 프로젝트 ID (선택)
     * @param freelancerIdParam 선택된 프리랜서 ID (선택)
     * @param model Spring MVC Model
     * @return 뷰 이름 ("contract/contractForm")
     */
    @GetMapping("/form")
    public String showContractForm(
            @RequestParam(value = "projectId", required = false) String projectIdParam,
            @RequestParam(value = "freelancerId", required = false) String freelancerIdParam,
            Model model
    ) {
        Object client = contractService.getClientByLoginUser();
        if (client == null) {
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

        ContractProjectVO selectedProject = null;
        ContractFreelancerVO selectedFreelancer = null;

        if (projectId != null) {
            selectedProject = contractService.getProjectById(projectId);
        }
        if (freelancerId != null) {
            selectedFreelancer = contractService.getFreelancerById(freelancerId);
        }

        model.addAttribute("client", client);
        model.addAttribute("selectedProject", selectedProject);
        model.addAttribute("selectedFreelancer", selectedFreelancer);

        model.addAttribute(
                "projectList",
                contractService.getProjectsByClientId(
                        ((ContractClientVO) client).getClientId()
                )
        );

        if (projectId != null) {
            model.addAttribute(
                    "freelancerList",
                    contractService.getFreelancersByProjectId(projectId)
            );
        } else {
            model.addAttribute("freelancerList", Collections.emptyList());
        }

        return "contract/contractForm";
    }

    /**
     * 프로젝트별 프리랜서 목록 조회 (AJAX)
     * 
     * [기능]
     * - 계약서 작성 화면에서 프로젝트 선택 시, 해당 프로젝트의 프리랜서 목록을 JSON으로 반환
     * - AJAX 요청으로 동적 로딩
     * 
     * [사용 시나리오]
     * - contractForm.jsp에서 프로젝트 선택 시 JavaScript로 호출
     * - 프리랜서 드롭다운 목록 업데이트
     * 
     * [주의사항]
     * - 보안/권한: 로그인 클라이언트가 소유한 프로젝트인지 검증 필요 (현재는 미구현)
     * 
     * @param projectId 프로젝트 ID
     * @return 프리랜서 목록 (JSON)
     */
    @GetMapping(value = "/freelancers", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public List<ContractFreelancerVO> freelancersByProject(@RequestParam("projectId") Integer projectId) {
        // 보안/권한: 로그인 클라이언트가 소유한 프로젝트인지 검증이 필요하면 여기서 추가
        return contractService.getFreelancersByProjectId(projectId);
    }

    /* =========================================================
       STEP 2 : CONTRACT CHECK (계약서 초안 생성)
       ========================================================= */
    
    /**
     * 계약서 초안 생성 (AI 자동 작성)
     * 
     * [기능]
     * - PDF 업로드 또는 직접 작성 내용을 기반으로 AI가 계약서 초안 생성
     * - ContractAutoFillService를 통해 AI API 호출
     * 
     * [처리 시나리오]
     * 1. 직접 작성 (FORM): 입력 필드 내용을 텍스트로 합쳐서 AI에 전달
     * 2. PDF 업로드 (PDF): PDF 텍스트 추출 후 AI에 전달
     * 
     * [데이터 흐름]
     * 1. 파라미터 검증 (projectId, freelancerId)
     * 2. DB 조회 (클라이언트, 프로젝트, 프리랜서 정보)
     * 3. PDF 파일 처리 (PDF 타입일 때)
     * 4. AI 초안 생성 (ContractAutoFillService.generateDraft())
     * 5. contractCheck.jsp 화면에 초안 표시
     * 
     * [다음 단계]
     * - 사용자가 초안 확인/수정 후 → POST /confirm (계약 확정)
     * 
     * @param params 요청 파라미터 맵
     * @param model Spring MVC Model
     * @return 뷰 이름 ("contract/contractCheck")
     */
    @PostMapping("/contractCheck")
    public String contractCheck(
            @RequestParam Map<String, String> params,
            Model model
    ) {
        try {
            // 1. 파라미터 추출 및 검증
            Integer projectId = null;
            Integer freelancerId = null;
            
            try {
                String projectIdStr = params.get("projectId");
                if (projectIdStr != null && !projectIdStr.isBlank()) {
                    projectId = Integer.valueOf(projectIdStr);
                }
            } catch (NumberFormatException e) {
                model.addAttribute("errorMessage", "잘못된 프로젝트 ID입니다.");
                return "contract/contractCheck";
            }
            
            try {
                String freelancerIdStr = params.get("freelancerId");
                if (freelancerIdStr != null && !freelancerIdStr.isBlank()) {
                    freelancerId = Integer.valueOf(freelancerIdStr);
                }
            } catch (NumberFormatException e) {
                model.addAttribute("errorMessage", "잘못된 프리랜서 ID입니다.");
                return "contract/contractCheck";
            }
            
            if (projectId == null || freelancerId == null) {
                model.addAttribute("errorMessage", "프로젝트와 프리랜서를 모두 선택해주세요.");
                return "contract/contractCheck";
            }
            
            String contractInputType = params.getOrDefault("contractInputType", "FORM");
            String originContractUrl = params.get("originContractUrl");
            
            // PDF 업로드 후 uploadedPdfFileName만 넘어오는 경우 보완
            if ((originContractUrl == null || originContractUrl.isBlank()) && params.get("uploadedPdfFileName") != null && !params.get("uploadedPdfFileName").isBlank()) {
                originContractUrl = params.get("uploadedPdfFileName");
            }
            
            // originContractUrl이 전체 경로인 경우 그대로 사용 (contracts/{clientId}/{projectId}/fileName 형식)
            // 파일명만 있는 경우는 나중에 통합 경로로 해석
            String finalOriginContractUrl = originContractUrl;
            
            String manualText = null;
            if ("FORM".equals(contractInputType)) {
                // 직접작성 내용 합치기
                StringBuilder sb = new StringBuilder();
                sb.append("계약 목적: ").append(params.getOrDefault("contractPurpose", "")).append("\n");
                sb.append("업무 범위: ").append(params.getOrDefault("workScope", "")).append("\n");
                sb.append("결과물 정의: ").append(params.getOrDefault("deliverables", "")).append("\n");
                sb.append("지급 조건: ").append(params.getOrDefault("paymentCondition", "")).append("\n");
                sb.append("일정 관련 조건: ").append(params.getOrDefault("scheduleCondition", "")).append("\n");
                sb.append("기타 특약: ").append(params.getOrDefault("specialTerms", "")).append("\n");
                manualText = sb.toString();
            }

            // 2. DB 조회 및 검증
            ContractClientVO client = contractService.getClientByLoginUser();
            if (client == null) {
                model.addAttribute("errorMessage", "로그인이 필요합니다.");
                return "contract/contractCheck";
            }
            
            ContractProjectVO project = contractService.getProjectById(projectId);
            if (project == null) {
                model.addAttribute("errorMessage", "프로젝트를 찾을 수 없습니다.");
                return "contract/contractCheck";
            }
            
            ContractFreelancerVO freelancer = contractService.getFreelancerById(freelancerId);
            if (freelancer == null) {
                model.addAttribute("errorMessage", "프리랜서를 찾을 수 없습니다.");
                return "contract/contractCheck";
            }

            // ============================================================
            // 3. AI 초안 생성 (PDF/직접작성 모두 지원)
            // ============================================================
            // ContractAutoFillService가 PDF 텍스트 또는 직접 작성 텍스트를 AI에 전달하여
            // 계약서 초안을 생성 (계약 목적, 업무 범위, 지급 조건 등 자동 추출)
            java.io.File pdfFile = null;
            if ("PDF".equals(contractInputType) && finalOriginContractUrl != null && !finalOriginContractUrl.isBlank()) {
                // 경로 정규화: 백슬래시를 슬래시로 변환
                String normalizedPath = finalOriginContractUrl.replace("\\", "/");
                
                if (normalizedPath.startsWith("contracts/")) {
                    finalOriginContractUrl = normalizedPath;
                } else {
                    // 파일명만 있는 경우: 통합 경로로 해석
                    finalOriginContractUrl = "contracts/" + client.getClientId() + "/" + projectId + "/" + normalizedPath;
                }
                
                if (contractFileService.existsPdfFile(finalOriginContractUrl)) {
                    pdfFile = contractFileService.getPdfFile(finalOriginContractUrl);
                    logger.info("PDF 파일 찾음: {}", finalOriginContractUrl);
                } else {
                    logger.warn("PDF 파일을 찾을 수 없습니다: {}", finalOriginContractUrl);
                    pdfFile = null;
                }
            }
            
            ContractAutoFillDTO draft = contractAutoFillService.generateDraft(
                    pdfFile,
                    manualText,
                    projectId,
                    freelancerId
            );

            // 4. ContractCreateRequestDTO 생성 (직접 작성 시 입력 필드 포함)
            ContractCreateRequestDTO formDto = new ContractCreateRequestDTO();
            formDto.setProjectId(projectId);
            formDto.setFreelancerId(freelancerId);
            if ("FORM".equals(contractInputType)) {
                formDto.setContractPurpose((String) params.get("contractPurpose"));
                formDto.setWorkScope((String) params.get("workScope"));
                formDto.setDeliverables((String) params.get("deliverables"));
                formDto.setPaymentCondition((String) params.get("paymentCondition"));
                formDto.setScheduleCondition((String) params.get("scheduleCondition"));
                formDto.setSpecialTerms((String) params.get("specialTerms"));
            }
            
            // 5. model에 데이터 전달
            if (finalOriginContractUrl != null && !finalOriginContractUrl.isBlank()) {
                params.put("originContractUrl", finalOriginContractUrl);
                model.addAttribute("originContractUrl", finalOriginContractUrl);
                formDto.setOriginContractUrl(finalOriginContractUrl);
            }
            params.put("contractInputType", contractInputType);
            
            model.addAttribute("client", client);
            model.addAttribute("project", project);
            model.addAttribute("freelancer", freelancer);
            model.addAttribute("draft", draft);
            model.addAttribute("contract", draft); // contract 이름으로도 추가
            model.addAttribute("formDto", formDto); // ContractCreateRequestDTO 전달
            model.addAttribute("contractInputType", contractInputType);
            model.addAttribute("originContractUrl", originContractUrl);

            return "contract/contractCheck";
        } catch (IllegalStateException e) {
            model.addAttribute("errorMessage", "계약서 초안 생성 실패: " + e.getMessage());
            return "contract/contractCheck";
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("errorMessage", "계약서 초안 생성 중 오류가 발생했습니다: " + e.getMessage());
            return "contract/contractCheck";
        }
    }

    /**
     * 계약서 상세 조회 (GET)
     * 
     * [기능]
     * - 저장된 계약서 상세 정보 조회
     * - contractCheck.jsp 화면에 계약 정보 표시
     * 
     * [사용 시나리오]
     * - 계약 관리 화면에서 계약 상세 보기
     * - 계약서 재확인
     * 
     * @param contractId 계약 ID
     * @param model Spring MVC Model
     * @return 뷰 이름 ("contract/contractCheck")
     */
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

     /* =========================================================
         이하 기존 코드 전부 동일
         (confirm / uploadPdf / servePdf)
         ========================================================= */

    /**
     * PDF 업로드 처리 (AJAX)
     * 
     * [기능]
     * - 계약서 작성 화면에서 PDF 파일 업로드
     * - AJAX 요청으로 비동기 처리
     * 
     * [저장 경로]
     * - contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
     * - freelancerId는 null일 수 있음 (나중에 확정 시 추가)
     * 
     * [데이터 흐름]
     * 1. 파일 검증
     * 2. 로그인 클라이언트 조회
     * 3. ContractFileService.uploadPdf() 호출
     * 4. JSON 응답 반환 (fileName, filePath)
     * 
     * [사용 시나리오]
     * - contractForm.jsp에서 파일 선택 시 JavaScript로 호출
     * - 업로드 성공 후 파일명을 화면에 표시
     * 
     * @param contractPdf 업로드할 PDF 파일
     * @param projectIdStr 프로젝트 ID (문자열)
     * @return JSON 응답 (success, fileName, filePath 또는 error)
     */
    @PostMapping(value = "/uploadPdf", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> uploadPdf(
            @RequestParam("contractPdf") MultipartFile contractPdf,
            @RequestParam("projectId") String projectIdStr
    ) {
        Map<String, Object> result = new HashMap<>();
        try {
            if (contractPdf == null || contractPdf.isEmpty()) {
                result.put("success", false);
                result.put("error", "PDF 파일이 없습니다.");
                return result;
            }
            
            if (projectIdStr == null || projectIdStr.isBlank()) {
                result.put("success", false);
                result.put("error", "프로젝트 ID가 필요합니다.");
                return result;
            }
            
            ContractClientVO client = contractService.getClientByLoginUser();
            if (client == null) {
                result.put("success", false);
                result.put("error", "로그인이 필요합니다.");
                return result;
            }
            
            Integer clientId = client.getClientId();
            Integer projectId;
            try {
                projectId = Integer.valueOf(projectIdStr);
            } catch (NumberFormatException e) {
                result.put("success", false);
                result.put("error", "유효하지 않은 프로젝트 ID입니다.");
                return result;
            }
            
            // 파일 업로드 (freelancerId는 null로 전달 - 나중에 추가 가능)
            String filePath = contractFileService.uploadPdf(contractPdf, clientId, projectId, null);
            String fileName = filePath.substring(filePath.lastIndexOf("/") + 1);
            
            result.put("success", true);
            result.put("fileName", fileName);
            result.put("filePath", filePath);
        } catch (Exception e) {
            logger.error("PDF 업로드 실패: {}", e.getMessage(), e);
            result.put("success", false);
            result.put("error", e.getMessage());
        }
        return result;
    }

    /**
     * PDF 파일 반환 (iframe 미리보기용)
     * 
     * [기능]
     * - 저장된 PDF 파일을 브라우저에서 조회
     * - iframe이나 embed 태그에서 사용
     * 
     * [경로 형식]
     * - GET /client/contract/file/{encodedPath}
     * - 경로: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
     * - 각 세그먼트는 URL 인코딩됨
     * 
     * [보안]
     * - baseDir 밖으로 나가는 경로 차단 (Path Traversal 방지)
     * - contracts/로 시작하는 경로만 허용
     * 
     * [사용 시나리오]
     * - contractCheck.jsp에서 PDF 미리보기
     * - 계약 관리 화면에서 PDF 조회
     * 
     * @param request HTTP 요청 (URI에서 경로 추출)
     * @return PDF 파일 리소스 (application/pdf)
     */
    @GetMapping("/file/**")
    public ResponseEntity<org.springframework.core.io.Resource> servePdf(
                javax.servlet.http.HttpServletRequest request) {
            try {
                String baseDir = System.getProperty("user.dir");
                String requestURI = request.getRequestURI();
                
                // /client/contract/file/ 이후의 경로 추출
                String filePathStr = requestURI.substring(requestURI.indexOf("/file/") + "/file/".length());
                
                // 경로 세그먼트별로 디코딩 (슬래시는 유지)
                // contracts/8/19/encodeURIComponent(file.pdf) 형식
                String[] segments = filePathStr.split("/");
                StringBuilder decodedPath = new StringBuilder();
                for (int i = 0; i < segments.length; i++) {
                    if (i > 0) decodedPath.append("/");
                    try {
                        // 각 세그먼트를 개별적으로 디코딩
                        decodedPath.append(java.net.URLDecoder.decode(segments[i], "UTF-8"));
                    } catch (java.io.UnsupportedEncodingException e) {
                        decodedPath.append(segments[i]);
                    }
                }
                filePathStr = decodedPath.toString();
                
                // 경로 정규화: 백슬래시를 슬래시로 변환
                filePathStr = filePathStr.replace("\\", "/");
                
                logger.debug("servePdf - requestURI: {}", requestURI);
                logger.debug("servePdf - filePathStr (디코딩 후): {}", filePathStr);
                
                java.nio.file.Path filePath;
                
                // 경로가 contracts/로 시작하는지 확인
                if (filePathStr.startsWith("contracts/")) {
                    // 상대 경로: baseDir 기준으로 해석
                    filePath = java.nio.file.Paths.get(baseDir).resolve(filePathStr.replace("/", java.io.File.separator)).normalize();
                    logger.debug("servePdf - 최종 파일 경로: {}", filePath.toString());
                } else {
                    // 파일명만 있는 경우: contracts/ 경로로 해석하지 않고 에러 반환
                    logger.error("servePdf - contracts/로 시작하지 않는 경로: {}", filePathStr);
                    return ResponseEntity.notFound().build();
                }
                
                // 보안: baseDir 밖으로 나가는 경로 차단
                java.nio.file.Path basePath = java.nio.file.Paths.get(baseDir).normalize();
                if (!filePath.startsWith(basePath)) {
                    logger.error("servePdf - 보안 위반: baseDir 밖 경로");
                    return ResponseEntity.status(org.springframework.http.HttpStatus.FORBIDDEN).build();
                }
                
                org.springframework.core.io.Resource resource = new org.springframework.core.io.UrlResource(filePath.toUri());
                if (!resource.exists()) {
                    logger.error("servePdf - 파일이 존재하지 않음: {}", filePath.toString());
                    return ResponseEntity.notFound().build();
                }
                
                logger.info("servePdf - PDF 파일 반환 성공: {}", filePath.toString());
                return ResponseEntity.ok()
                    .contentType(org.springframework.http.MediaType.APPLICATION_PDF)
                    .body(resource);
            } catch (Exception e) {
                logger.error("servePdf - 예외 발생: {}", e.getMessage(), e);
                return ResponseEntity.status(org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR).build();
            }
        }
}
