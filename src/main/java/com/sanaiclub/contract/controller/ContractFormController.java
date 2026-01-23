package com.sanaiclub.contract.controller;

import com.sanaiclub.contract.model.dto.*;
import com.sanaiclub.contract.service.ContractAutoFillService;
import com.sanaiclub.contract.service.ContractService;
import com.sanaiclub.contract.service.ContractPdfService;
import com.sanaiclub.contract.service.ContractFileService;
import com.sanaiclub.contract.dao.ContractMapper;
import com.sanaiclub.project.model.vo.ProjectsVO;
import com.sanaiclub.user.dao.UserMapper;
import com.sanaiclub.user.dao.ClientProfileMapper;
import com.sanaiclub.user.dao.CompanyMapper;
import com.sanaiclub.user.model.vo.UserVO;
import com.sanaiclub.user.model.vo.FreelancerProfileVO;
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

/**
 * ============================================================================
 * ContractFormController - 계약서 작성 플로우 컨트롤러
 * ============================================================================
 * 
 * [역할]
 * - 계약서 작성 플로우 전체 관리: form → contractCheck → confirm
 * - MVC2 구조: HTTP 요청 처리 및 뷰 선택만 담당, 비즈니스 로직은 Service에 위임
 * - 여러 도메인(contract, project, user) 정보를 조합하여 계약서 작성 지원
 * 
 * [주요 플로우]
 * 1. GET /form: 계약서 작성 화면 표시
 *    - 프로젝트 및 프리랜서 선택 UI 제공
 *    - 클라이언트 정보 조회 및 전달
 * 
 * 2. POST /contractCheck: AI 계약서 초안 생성
 *    - PDF 업로드 또는 직접 작성 내용을 기반으로 AI가 계약서 초안 생성
 *    - ContractAutoFillService를 통해 AI API 호출
 *    - 생성된 초안을 contractCheck 화면에 표시
 * 
 * 3. GET /contractCheck: 계약서 상세 조회
 *    - 기존 계약 정보를 조회하여 상세 화면에 표시
 *    - 계약 수정 시 사용
 * 
 * 4. POST /confirm: 계약서 확정 및 저장
 *    - 계약서 작성/수정 후 최종 확정하여 DB에 저장
 *    - 같은 클라이언트/프로젝트/프리랜서 조합이면 UPDATE, 없으면 INSERT
 *    - PDF 생성 또는 경로 정규화 처리
 * 
 * [계약 입력 타입]
 * - FORM: 사용자가 직접 작성한 계약 내용 (ContractPdfService로 PDF 생성)
 * - PDF: 업로드된 PDF 계약서 (AI로 내용 추출)
 * 
 * [책임 분리 원칙]
 * - Controller: HTTP 요청 처리, 파라미터 검증, 뷰 선택, 여러 도메인 정보 조합
 * - Service: 비즈니스 로직 처리 (계약 생성/수정, PDF 생성, AI 호출 등)
 * - Mapper: 데이터 접근 (다른 도메인 Mapper는 Controller에서만 사용)
 * 
 * [다른 도메인 Mapper 사용]
 * - ProjectDetailMapper: 프로젝트 정보 조회
 * - UserMapper: 사용자 정보 조회
 * - ClientProfileMapper: 클라이언트 프로필 조회
 * - CompanyMapper: 회사 정보 조회
 * 
 * [주의사항]
 * - FreelancerProfile은 다른 도메인 Mapper 이슈로 인해 사용하지 않음
 * - 여러 도메인 정보를 조합하는 역할은 Controller에서만 수행
 * - Service는 contract 도메인만 담당
 * 
 * [경로]
 * - Base URL: /client/contract
 * - 클라이언트 전용 컨트롤러
 * 
 * ============================================================================
 */
@Slf4j
@Controller
@RequestMapping("/client/contract")
@RequiredArgsConstructor
public class ContractFormController {

    private final ContractService contractService;
    private final ContractAutoFillService contractAutoFillService;
    private final ContractPdfService contractPdfService;
    private final ContractFileService contractFileService;
    // contract 도메인 Mapper (contract 도메인 내에서 프로젝트 정보 조회)
    private final ContractMapper contractMapper;
    private final UserMapper userMapper;
    private final ClientProfileMapper clientProfileMapper;
    private final CompanyMapper companyMapper;

    /**
     * 계약서 작성 화면 조회
     * 
     * [기능]
     * - 계약서 작성 폼 화면 표시
     * - 프로젝트 및 프리랜서 선택 UI 제공
     * - 클라이언트 정보 및 선택된 프로젝트/프리랜서 정보 전달
     * 
     * [처리 흐름]
     * 1. 현재 로그인한 사용자 인증 확인
     * 2. 클라이언트 사용자 정보 조회
     * 3. 선택된 프로젝트/프리랜서 정보 조회 (파라미터가 있는 경우)
     * 4. 클라이언트 프로필 및 회사 정보 조회
     * 5. 클라이언트의 프로젝트 목록 조회
     * 6. Model에 모든 정보 전달
     * 
     * [Model Attributes]
     * - clientUser: 클라이언트 사용자 정보
     * - clientProfile: 클라이언트 프로필 정보
     * - company: 회사 정보 (있는 경우)
     * - selectedProject: 선택된 프로젝트 (있는 경우)
     * - selectedFreelancerUser: 선택된 프리랜서 사용자 정보 (있는 경우)
     * - selectedFreelancerProfile: 선택된 프리랜서 프로필 (현재 null)
     * - projectList: 클라이언트의 프로젝트 목록
     * - freelancerList: 빈 리스트 (향후 구현 예정)
     * 
     * [인증]
     * - AuthContext.getCurrentUserId()로 현재 사용자 ID 확인
     * - 사용자 정보가 없으면 "error/unauthorized" 뷰 반환
     * 
     * @param projectIdParam 선택된 프로젝트 ID (선택, 쿼리 파라미터)
     *                       - URL: /client/contract/form?projectId=100
     * @param freelancerIdParam 선택된 프리랜서 ID (선택, 쿼리 파라미터)
     *                          - URL: /client/contract/form?freelancerId=50
     * @param model Spring MVC Model (뷰에 전달할 데이터)
     * @return 뷰 이름 ("contract/contractForm")
     *         - 인증 실패 시 "error/unauthorized"
     */
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

        UserVO clientUser = userMapper.findByUserId(userId);
        if (clientUser == null) {
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

        ProjectsVO selectedProject = null;
        UserVO selectedFreelancerUser = null;
        FreelancerProfileVO selectedFreelancerProfile = null;

        if (projectId != null) {
            selectedProject = contractMapper.selectProjectById(projectId);
        }
        if (freelancerId != null) {
            selectedFreelancerUser = userMapper.findByUserId(freelancerId);
            // FreelancerProfile은 다른 도메인 Mapper 이슈로 인해 사용하지 않음
            selectedFreelancerProfile = null;
        }

        // 클라이언트 프로필 및 회사 정보 조회
        ClientProfileVO clientProfile = clientProfileMapper.findByUserId(userId);
        CompanyVO company = null;
        if (clientProfile != null && clientProfile.getCompanyId() != null) {
            company = companyMapper.findByCompanyId(clientProfile.getCompanyId());
        }

        model.addAttribute("clientUser", clientUser);
        model.addAttribute("clientProfile", clientProfile);
        model.addAttribute("company", company);
        model.addAttribute("selectedProject", selectedProject);
        model.addAttribute("selectedFreelancerUser", selectedFreelancerUser);
        model.addAttribute("selectedFreelancerProfile", selectedFreelancerProfile);

        // 클라이언트의 프로젝트 목록 조회 (contract 도메인 내에서 해결)
        List<ProjectsVO> projectList = contractMapper.selectProjectsByClientId(userId);
        model.addAttribute("projectList", projectList);
        model.addAttribute("freelancerList", Collections.emptyList());

        return "contract/contractForm";
    }

    /**
     * 계약서 초안 생성 (AI 자동 작성)
     * 
     * [기능]
     * - PDF 업로드 또는 직접 작성 내용을 기반으로 AI가 계약서 초안 생성
     * - ContractAutoFillService를 통해 AI API 호출
     * - 생성된 초안을 contractCheck 화면에 표시
     * 
     * [처리 흐름]
     * 1. 파라미터 추출 및 검증
     *    - projectId, freelancerId 추출
     *    - contractInputType 확인 (FORM 또는 PDF)
     *    - originContractUrl 정규화
     *    - manualText 생성 (FORM 타입일 때)
     * 
     * 2. DB 조회 및 검증
     *    - 클라이언트 사용자 정보 조회
     *    - 프로젝트 정보 조회
     *    - 프리랜서 사용자 정보 조회
     *    - 클라이언트 프로필 및 회사 정보 조회
     * 
     * 3. AI 초안 생성
     *    - PDF 파일 조회 (PDF 타입일 때)
     *    - ContractAutoFillService.generateDraft() 호출
     *    - AI가 계약 정보 추출 및 초안 생성
     * 
     * 4. Model에 데이터 전달
     *    - 클라이언트, 프리랜서, 프로젝트 정보
     *    - AI 생성 초안 (ContractAutoFillDTO)
     *    - 계약 입력 타입 및 기타 정보
     * 
     * [계약 입력 타입]
     * - FORM: 사용자가 직접 작성한 계약 내용
     *   * contractPurpose, workScope, deliverables 등
     *   * manualText로 변환하여 AI에 전달
     * - PDF: 업로드된 PDF 계약서
     *   * PDF 파일에서 텍스트 추출 후 AI에 전달
     * 
     * [에러 처리]
     * - IllegalStateException: 비즈니스 로직 오류 (에러 메시지 표시)
     * - Exception: 기타 오류 (로그 기록 및 에러 메시지 표시)
     * 
     * [주의사항]
     * - projectId와 freelancerId는 필수
     * - PDF 파일이 없어도 manualText만으로 초안 생성 가능
     * - AI API 호출 실패 시 에러 메시지 표시
     * 
     * @param params 요청 파라미터 맵
     *                - projectId: 프로젝트 ID (필수)
     *                - freelancerId: 프리랜서 ID (필수)
     *                - contractInputType: 입력 타입 (FORM 또는 PDF)
     *                - originContractUrl: PDF 경로 (PDF 타입일 때)
     *                - contractPurpose, workScope 등: 직접 작성 내용 (FORM 타입일 때)
     * @param model Spring MVC Model (뷰에 전달할 데이터)
     * @return 뷰 이름 ("contract/contractCheck")
     *         - 에러 발생 시에도 "contract/contractCheck" 반환 (에러 메시지 포함)
     */
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
            
            UserVO clientUser = userMapper.findByUserId(userId);
            ProjectsVO project = contractMapper.selectProjectById(projectId);
            UserVO freelancerUser = userMapper.findByUserId(freelancerId);
            
            if (!validateDomainObjects(clientUser, project, freelancerUser, model)) {
                return "contract/contractCheck";
            }
            
            // FreelancerProfile은 다른 도메인 Mapper 이슈로 인해 사용하지 않음
            FreelancerProfileVO freelancerProfile = null;
            
            // 클라이언트 프로필 및 회사 정보 조회 (JSP에서 client.companyName 사용)
            ClientProfileVO clientProfile = clientProfileMapper.findByUserId(userId);
            CompanyVO company = null;
            if (clientProfile != null && clientProfile.getCompanyId() != null) {
                company = companyMapper.findByCompanyId(clientProfile.getCompanyId());
            }

            // 3. AI 초안 생성
            java.io.File pdfFile = getPdfFile(finalOriginContractUrl, contractInputType);
            ContractAutoFillDTO draft = contractAutoFillService.generateDraft(
                    pdfFile, manualText, project, freelancerUser, freelancerProfile
            );

            // 4. Model에 데이터 전달
            prepareModelForContractCheck(model, params, clientUser, clientProfile, company, project, freelancerUser, 
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

    /**
     * 계약서 상세 조회 (GET)
     * 
     * [기능]
     * - 기존 계약 정보를 조회하여 상세 화면에 표시
     * - 계약 수정 시 사용
     * 
     * [처리 흐름]
     * 1. contractId로 계약 정보 조회
     * 2. 계약이 없으면 에러 메시지 표시
     * 3. 계약 정보와 마일스톤 정보를 Model에 전달
     * 
     * [사용 시나리오]
     * - 계약 수정 화면 진입
     * - 계약 상세 정보 확인
     * 
     * [Model Attributes]
     * - contract: 계약 정보 (ContractResponseDTO)
     * - milestones: 마일스톤 목록 (List<ContractMilestoneResponseDTO>)
     * 
     * @param contractId 조회할 계약의 ID (필수, 쿼리 파라미터)
     *                  - URL: /client/contract/contractCheck?contractId=123
     * @param model Spring MVC Model (뷰에 전달할 데이터)
     * @return 뷰 이름 ("contract/contractCheck")
     *         - 계약이 없으면 에러 메시지와 함께 "contract/contractCheck" 반환
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

    /**
     * 계약서 최종 확정 및 저장
     * 
     * [기능]
     * - 계약서 작성/수정 후 최종 확정하여 DB에 저장
     * - 같은 클라이언트/프로젝트/프리랜서 조합이면 UPDATE, 없으면 INSERT
     * - PDF 생성 또는 경로 정규화 처리
     * 
     * [처리 흐름]
     * 1. 파라미터 검증
     *    - projectId, freelancerId 필수 확인
     *    - 현재 사용자 인증 확인
     * 
     * 2. PDF 경로 처리
     *    - FORM 타입: ContractPdfService로 PDF 생성
     *    - PDF 타입: 경로 정규화 및 파일 이동
     * 
     * 3. UPDATE vs INSERT 판단
     *    - getContractByPathPattern()으로 기존 계약 조회
     *    - 기존 계약이 있으면 UPDATE
     *    - 기존 계약이 없으면 INSERT
     * 
     * 4. 계약 저장
     *    - UPDATE: updateExistingContract() 호출
     *    - INSERT: createNewContract() 호출
     * 
     * [UPDATE vs INSERT 로직]
     * - 같은 clientId + projectId + freelancerId 조합의 계약이 있으면 UPDATE
     * - 없으면 INSERT
     * - TERMINATED 상태의 계약은 새 계약으로 취급 (INSERT)
     * 
     * [PDF 처리]
     * - FORM 타입: ContractPdfService.generateContractPdf()로 PDF 생성
     *   * 저장 경로: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
     * - PDF 타입: normalizeAndMovePdf()로 경로 정규화 및 파일 이동
     *   * freelancerId가 경로에 없으면 추가하고 파일 이동
     * 
     * [마일스톤 처리]
     * - paymentMethod가 "MILESTONE"인 경우에만 처리
     * - milestoneNames, milestoneAmounts, milestoneDescs 배열을 파싱하여 마일스톤 리스트 생성
     * - UPDATE 시 기존 마일스톤 삭제 후 새로 추가
     * 
     * [에러 처리]
     * - 파라미터 검증 실패: 에러 메시지 표시
     * - PDF 생성 실패: 에러 메시지 표시 (계약은 저장됨)
     * - 계약 저장 실패: 에러 메시지 표시
     * 
     * [주의사항]
     * - contractPdf 파라미터는 현재 사용하지 않음 (향후 구현 예정)
     * - requirements는 INSERT 시에만 사용
     * - FORM 타입의 계약 내용(contractPurpose 등)은 PDF 생성에만 사용 (DB에 저장되지 않음)
     * 
     * @param projectIdStr 프로젝트 ID (필수)
     * @param freelancerIdStr 프리랜서 ID (필수)
     * @param contractStartDate 계약 시작일 (필수)
     * @param contractEndDate 계약 종료일 (필수)
     * @param totalBudgetStr 총 예산 (필수, 숫자 문자열)
     * @param paymentMethod 지급 방식 (MILESTONE 또는 FIXED)
     * @param originContractUrl 업로드된 PDF 경로 (PDF 타입일 때)
     * @param contractInputType 입력 타입 (FORM 또는 PDF)
     * @param requirements 요구사항 (INSERT 시에만 사용)
     * @param milestoneNames 마일스톤 이름 배열 (MILESTONE 타입일 때)
     * @param milestoneAmounts 마일스톤 금액 배열 (MILESTONE 타입일 때)
     * @param milestoneDescs 마일스톤 설명 배열 (MILESTONE 타입일 때)
     * @param contractPurpose 계약 목적 (FORM 타입일 때, PDF 생성에 사용)
     * @param workScope 업무 범위 (FORM 타입일 때, PDF 생성에 사용)
     * @param deliverables 결과물 정의 (FORM 타입일 때, PDF 생성에 사용)
     * @param paymentCondition 지급 조건 (FORM 타입일 때, PDF 생성에 사용)
     * @param scheduleCondition 일정 조건 (FORM 타입일 때, PDF 생성에 사용)
     * @param specialTerms 기타 특약 (FORM 타입일 때, PDF 생성에 사용)
     * @param contractPdf PDF 파일 (현재 미사용, 향후 구현 예정)
     * @param model Spring MVC Model (뷰에 전달할 데이터)
     * @return 뷰 이름 ("contract/contractConfirmResult")
     *         - 성공/실패 메시지를 Model에 담아 전달
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
            
            Integer userId = AuthContext.getCurrentUserId();
            if (userId == null) {
                model.addAttribute("message", "로그인이 필요합니다.");
                return "contract/contractConfirmResult";
            }
            
            UserVO clientUser = userMapper.findByUserId(userId);
            if (clientUser == null) {
                model.addAttribute("message", "사용자 정보를 찾을 수 없습니다.");
                return "contract/contractConfirmResult";
            }
            
            Integer projectId = Integer.valueOf(projectIdStr);
            Integer clientId = userId;
            Integer freelancerId = Integer.valueOf(freelancerIdStr);
            
            // PDF 경로 처리
            String finalPdfPath = processPdfPath(contractInputType, originContractUrl, clientId, 
                    projectId, freelancerId, contractStartDate, contractEndDate, totalBudgetStr, 
                    paymentMethod, contractPurpose, workScope, deliverables, paymentCondition, 
                    scheduleCondition, specialTerms, milestoneNames, milestoneAmounts, milestoneDescs, 
                    clientUser, model);
            
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

    // ============================================================================
    // Private Helper Methods
    // ============================================================================
    // 
    // [역할]
    // - Controller의 복잡한 로직을 작은 단위로 분리
    // - 코드 재사용성 및 가독성 향상
    // - 각 메서드는 단일 책임 원칙 준수
    // 
    // ============================================================================

    /**
     * 파라미터에서 프로젝트 ID 추출
     * 
     * [기능]
     * - 요청 파라미터 맵에서 projectId를 추출하여 Integer로 변환
     * - 파라미터가 없거나 형식이 잘못되면 null 반환
     * 
     * [에러 처리]
     * - NumberFormatException: 에러 메시지를 Model에 추가
     * 
     * @param params 요청 파라미터 맵
     * @param model Spring MVC Model (에러 메시지 전달용)
     * @return 프로젝트 ID (Integer), 없거나 잘못된 형식이면 null
     */
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

    /**
     * 파라미터에서 프리랜서 ID 추출
     * 
     * [기능]
     * - 요청 파라미터 맵에서 freelancerId를 추출하여 Integer로 변환
     * - 파라미터가 없거나 형식이 잘못되면 null 반환
     * 
     * [에러 처리]
     * - NumberFormatException: 에러 메시지를 Model에 추가
     * 
     * @param params 요청 파라미터 맵
     * @param model Spring MVC Model (에러 메시지 전달용)
     * @return 프리랜서 ID (Integer), 없거나 잘못된 형식이면 null
     */
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

    /**
     * PDF 경로 정규화
     * 
     * [기능]
     * - PDF 경로를 표준 형식으로 정규화
     * - 경로 구분자를 "/"로 통일
     * - contracts/로 시작하지 않으면 기본 경로 추가
     * 
     * [경로 형식]
     * - 입력: 다양한 형식 가능
     * - 출력: "contracts/{clientId}/{projectId}/{fileName}" 또는 기존 경로
     * 
     * [처리]
     * - PDF 타입이 아니거나 경로가 없으면 그대로 반환
     * - 이미 contracts/로 시작하면 그대로 반환
     * - 그 외의 경우 기본 경로 추가
     * 
     * @param originContractUrl 원본 PDF 경로
     * @param contractInputType 계약 입력 타입 (FORM 또는 PDF)
     * @param projectId 프로젝트 ID
     * @param freelancerId 프리랜서 ID
     * @return 정규화된 PDF 경로
     */
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

    /**
     * 직접 작성한 계약 내용을 텍스트로 변환
     * 
     * [기능]
     * - FORM 타입의 계약 내용을 하나의 텍스트로 변환
     * - AI 초안 생성 시 manualText로 사용
     * 
     * [포함 내용]
     * - 계약 목적 (contractPurpose)
     * - 업무 범위 (workScope)
     * - 결과물 정의 (deliverables)
     * - 지급 조건 (paymentCondition)
     * - 일정 관련 조건 (scheduleCondition)
     * - 기타 특약 (specialTerms)
     * 
     * [처리]
     * - FORM 타입이 아니면 null 반환
     * - 각 필드를 "필드명: 값\n" 형식으로 조합
     * 
     * @param params 요청 파라미터 맵
     * @param contractInputType 계약 입력 타입 (FORM 또는 PDF)
     * @return 직접 작성한 계약 내용 텍스트, FORM 타입이 아니면 null
     */
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

    /**
     * 도메인 객체 검증
     * 
     * [기능]
     * - 계약서 작성에 필요한 도메인 객체들이 모두 존재하는지 검증
     * - 하나라도 없으면 false 반환하고 에러 메시지 추가
     * 
     * [검증 항목]
     * - clientUser: 클라이언트 사용자 정보
     * - project: 프로젝트 정보
     * - freelancerUser: 프리랜서 사용자 정보
     * 
     * [에러 처리]
     * - 각 객체가 null이면 해당하는 에러 메시지를 Model에 추가
     * 
     * @param clientUser 클라이언트 사용자 정보
     * @param project 프로젝트 정보
     * @param freelancerUser 프리랜서 사용자 정보
     * @param model Spring MVC Model (에러 메시지 전달용)
     * @return 검증 성공 여부 (true: 모두 존재, false: 하나라도 없음)
     */
    private boolean validateDomainObjects(UserVO clientUser, ProjectsVO project, UserVO freelancerUser, Model model) {
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
        
        // JSP에서 기대하는 변수명으로 설정
        // client: clientName, email, phone, companyName 포함
        java.util.Map<String, Object> clientMap = new java.util.HashMap<>();
        clientMap.put("clientName", clientUser != null ? clientUser.getName() : "");
        clientMap.put("email", clientUser != null ? clientUser.getEmail() : "");
        clientMap.put("phone", clientUser != null ? clientUser.getPhone() : "");
        clientMap.put("companyName", company != null ? company.getCompanyName() : null);
        model.addAttribute("client", clientMap);
        
        // freelancer 정보를 Map으로 구성 (JSP에서 freelancer.name 등을 기대)
        java.util.Map<String, Object> freelancerMap = new java.util.HashMap<>();
        freelancerMap.put("name", freelancerUser != null ? freelancerUser.getName() : "");
        freelancerMap.put("email", freelancerUser != null ? freelancerUser.getEmail() : "");
        freelancerMap.put("phone", freelancerUser != null ? freelancerUser.getPhone() : "");
        freelancerMap.put("nickname", freelancerProfile != null ? freelancerProfile.getNickname() : null);
        model.addAttribute("freelancer", freelancerMap);
        
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
            UserVO clientUser, Model model) {
        
        String finalPdfPath = null;
        
        if ("FORM".equals(contractInputType)) {
            finalPdfPath = generatePdfForForm(clientId, projectId, freelancerId, contractStartDate, 
                    contractEndDate, totalBudgetStr, paymentMethod, contractPurpose, workScope, 
                    deliverables, paymentCondition, scheduleCondition, specialTerms, milestoneNames, 
                    milestoneAmounts, milestoneDescs, clientUser, model);
        } else if ("PDF".equals(contractInputType) && originContractUrl != null && !originContractUrl.isBlank()) {
            finalPdfPath = normalizeAndMovePdf(originContractUrl, clientId, projectId, freelancerId);
        }
        
        return finalPdfPath;
    }

    private String generatePdfForForm(Integer clientId, Integer projectId, Integer freelancerId, 
            String contractStartDate, String contractEndDate, String totalBudgetStr, String paymentMethod, 
            String contractPurpose, String workScope, String deliverables, String paymentCondition, 
            String scheduleCondition, String specialTerms, String[] milestoneNames, String[] milestoneAmounts, 
            String[] milestoneDescs, UserVO clientUser, Model model) {
        
        try {
            UserVO freelancerUser = userMapper.findByUserId(freelancerId);
            if (freelancerUser == null) {
                throw new IllegalStateException("프리랜서 정보를 찾을 수 없습니다.");
            }
            
            // FreelancerProfile은 다른 도메인 Mapper 이슈로 인해 사용하지 않음
            FreelancerProfileVO freelancerProfile = null;
            
            ClientProfileVO clientProfile = clientProfileMapper.findByUserId(clientId);
            CompanyVO company = null;
            if (clientProfile != null && clientProfile.getCompanyId() != null) {
                company = companyMapper.findByCompanyId(clientProfile.getCompanyId());
            }
            
            String baseDir = System.getProperty("user.dir");
            String saveDir = baseDir + java.io.File.separator + "contracts" + java.io.File.separator 
                    + clientId + java.io.File.separator + projectId + java.io.File.separator + freelancerId;
            String fileName = System.currentTimeMillis() + "_contract_" + projectId + "_" + freelancerId + ".pdf";
            
            ContractCreateRequestDTO pdfForm = createPdfFormDto(contractStartDate, contractEndDate, 
                    totalBudgetStr, paymentMethod, contractPurpose, workScope, deliverables, 
                    paymentCondition, scheduleCondition, specialTerms, milestoneNames, milestoneAmounts, milestoneDescs);
            
            contractPdfService.generateContractPdf(clientUser, clientProfile, company, 
                    freelancerUser, freelancerProfile, pdfForm, saveDir, fileName);
            
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
            model.addAttribute("message", "계약이 성공적으로 저장되었습니다. (ID: " + contractId + ")");
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
        dto.setContractStatus(com.sanaiclub.contract.model.enums.ContractStatus.WAITING.name());
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
        
        if ("MILESTONE".equals(paymentMethod) && milestoneNames != null && milestoneNames.length > 0) {
            dto.setMilestones(createMilestoneList(milestoneNames, milestoneAmounts, milestoneDescs));
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
        dto.setContractStatus(com.sanaiclub.contract.model.enums.ContractStatus.WAITING.name());
        dto.setOriginContractUrl(originContractUrl);
        
        if ("FORM".equals(contractInputType)) {
            dto.setContractPurpose(contractPurpose);
            dto.setWorkScope(workScope);
            dto.setDeliverables(deliverables);
            dto.setPaymentCondition(paymentCondition);
            dto.setScheduleCondition(scheduleCondition);
            dto.setSpecialTerms(specialTerms);
        }
        
        if ("MILESTONE".equals(paymentMethod) && milestoneNames != null && milestoneNames.length > 0) {
            dto.setMilestones(createMilestoneList(milestoneNames, milestoneAmounts, milestoneDescs));
        }
        
        return dto;
    }

    private java.util.List<ContractMilestoneRequestDTO> createMilestoneList(
            String[] milestoneNames, String[] milestoneAmounts, String[] milestoneDescs
    ) {
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
        
        return milestones;
    }
}
