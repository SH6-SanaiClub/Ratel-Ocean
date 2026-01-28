package com.sanaiclub.contract.controller;

import com.sanaiclub.contract.model.dto.ContractResponseDTO;
import com.sanaiclub.contract.model.dto.ContractDetailDTO;
import com.sanaiclub.contract.model.dto.ContractAnalysisDTO;
import com.sanaiclub.contract.model.dto.ContractMilestoneResponseDTO;
import com.sanaiclub.contract.service.ContractService;
import com.sanaiclub.contract.service.ContractFileService;
import com.sanaiclub.contract.service.ContractAnalysisService;
import com.sanaiclub.contract.service.PDFProcessingService;
import java.io.File;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.Map;

/** 프리랜서 계약 관리 컨트롤러. 계약 목록 조회, 수락/거절, 지급 요청 처리. */
@Slf4j
@Controller
@RequestMapping("/freelancer/contract")
@RequiredArgsConstructor
public class FreelancerContractController {

    private final ContractService contractService;
    private final ContractFileService contractFileService;
    private final ContractAnalysisService contractAnalysisService;
    private final PDFProcessingService pdfProcessingService;

    /** 프리랜서용 PDF 파일 제공 */
    @GetMapping("/file/**")
    public ResponseEntity<org.springframework.core.io.Resource> servePdf(
            javax.servlet.http.HttpServletRequest request) {
        String requestURI = request.getRequestURI();
        return contractFileService.servePdfResource(requestURI);
    }

    /**
     * 프리랜서용 PDF 파일 다운로드 (Content-Disposition: attachment)
     * 
     * [기능]
     * - 저장된 PDF 파일을 다운로드
     * - 브라우저에서 바로 열리지 않고 다운로드됨
     * 
     * [경로 형식]
     * - GET /freelancer/contract/download/{encodedPath}
     * - 경로: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
     * 
     * [응답]
     * - Content-Type: application/pdf
     * - Content-Disposition: attachment; filename="{fileName}"
     * - 파일이 없으면 404 Not Found
     * 
     * @param request HTTP 요청 (URI에서 경로 추출)
     * @return PDF 파일 리소스 (다운로드용)
     */
    @GetMapping("/download/**")
    public ResponseEntity<org.springframework.core.io.Resource> downloadPdf(
            javax.servlet.http.HttpServletRequest request) {
        String requestURI = request.getRequestURI();
        log.debug("downloadPdf - requestURI: {}", requestURI);
        
        // /download/를 /file/로 변경하여 servePdfResource 호출
        String fileRequestURI = requestURI.replace("/download/", "/file/");
        ResponseEntity<org.springframework.core.io.Resource> response = contractFileService.servePdfResource(fileRequestURI);
        
        // 다운로드 헤더 추가
        if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
            try {
                // 파일명 추출
                String filePathStr = fileRequestURI.substring(fileRequestURI.indexOf("/file/") + "/file/".length());
                String[] segments = filePathStr.split("/");
                String fileName = segments.length > 0 ? segments[segments.length - 1] : "contract.pdf";
                
                // URL 디코딩
                try {
                    fileName = java.net.URLDecoder.decode(fileName, "UTF-8");
                } catch (java.io.UnsupportedEncodingException e) {
                    // 디코딩 실패 시 원본 사용
                }
                
                return ResponseEntity.ok()
                    .contentType(org.springframework.http.MediaType.APPLICATION_PDF)
                    .header(org.springframework.http.HttpHeaders.CONTENT_DISPOSITION, 
                        "attachment; filename=\"" + fileName + "\"")
                    .body(response.getBody());
            } catch (Exception e) {
                log.error("PDF 다운로드 헤더 설정 중 오류: {}", e.getMessage(), e);
                return response;
            }
        }
        
        return response;
    }

    /** 프리랜서 계약 목록 조회 및 상태별 분류 */
    @GetMapping("/list")
    public String freelancerContractList(
            @RequestParam(value = "contractId", required = false) Integer contractId,
            Model model) {
        // 로그인 프리랜서 ID 조회
        Integer freelancerId = com.sanaiclub.common.util.AuthContext.getCurrentUserId();
        String loginId = com.sanaiclub.common.util.AuthContext.getCurrentLoginId();
        if (freelancerId == null) {
            model.addAttribute("errorMessage", "로그인이 필요합니다.");
            return "contract/freelancerContractList";
        }
        
        // 헤더용 loginId 추가
        model.addAttribute("loginId", loginId);
        model.addAttribute("userId", freelancerId);
        
        // 프리랜서의 계약 목록 조회 (쿼리에서 필터링)
        List<ContractResponseDTO> allContracts = contractService.getContractsByFreelancerId(freelancerId);
        
        // Service를 통해 계약 목록을 UI 표시용으로 분류
        Map<String, List<ContractResponseDTO>> contractsByStatus = 
                contractService.classifyContractsForFreelancerView(allContracts);
        
        model.addAttribute("contractsByStatus", contractsByStatus);
        model.addAttribute("allContracts", allContracts);
        
        // 선택한 계약 상세 정보 (contract_id를 통해 JOIN하여 조회)
        if (contractId != null) {
            ContractResponseDTO selectedContract = null;
            try {
                // allContracts에서 먼저 찾기 (마일스톤 집계 정보 포함)
                ContractResponseDTO contractFromList = allContracts.stream()
                    .filter(c -> c.getContractId() != null && c.getContractId().equals(contractId))
                    .findFirst()
                    .orElse(null);
                
                // allContracts에 있든 없든, 마일스톤 목록을 포함한 전체 정보를 가져오기 위해 getContractById 호출
                // (allContracts는 마일스톤 집계만 포함하고 개별 마일스톤 목록은 포함하지 않음)
                try {
                    selectedContract = contractService.getContractById(contractId);
                } catch (Exception e) {
                    log.warn("계약 상세 조회 실패 (contractId: {}): {}", contractId, e.getMessage());
                    // getContractById 실패 시 allContracts에서 찾은 것 사용
                    if (contractFromList != null) {
                        selectedContract = contractFromList;
                    }
                }
                
                // selectedContract가 있으면, 마일스톤이 없거나 비어있으면 무조건 재조회 시도
                // (PAID 상태 계약에서 마일스톤이 표시되지 않는 문제 해결)
                if (selectedContract != null) {
                    // 마일스톤이 없거나 비어있으면 무조건 재조회
                    if (selectedContract.getMilestones() == null || selectedContract.getMilestones().isEmpty()) {
                        try {
                            List<ContractMilestoneResponseDTO> milestones = contractService.getMilestonesByContractId(contractId);
                            if (milestones != null && !milestones.isEmpty()) {
                                selectedContract.setMilestones(milestones);
                                log.debug("마일스톤 재조회 성공 (contractId: {}, 마일스톤 수: {})", contractId, milestones.size());
                            } else {
                                // 마일스톤이 정말 없는 경우도 빈 리스트로 명시적 설정
                                selectedContract.setMilestones(new java.util.ArrayList<>());
                                log.debug("마일스톤이 없습니다 (contractId: {})", contractId);
                            }
                        } catch (Exception e2) {
                            log.error("마일스톤 재조회 실패 (contractId: {}): {}", contractId, e2.getMessage(), e2);
                            selectedContract.setMilestones(new java.util.ArrayList<>());
                        }
                    }
                } else if (contractFromList != null) {
                    // getContractById가 실패했지만 allContracts에는 있는 경우
                    selectedContract = contractFromList;
                    // 마일스톤을 별도로 조회하여 추가
                    try {
                        List<ContractMilestoneResponseDTO> milestones = contractService.getMilestonesByContractId(contractId);
                        if (milestones != null && !milestones.isEmpty()) {
                            selectedContract.setMilestones(milestones);
                            log.debug("마일스톤 조회 성공 (contractId: {}, 마일스톤 수: {})", contractId, milestones.size());
                        } else {
                            selectedContract.setMilestones(new java.util.ArrayList<>());
                            log.debug("마일스톤이 없습니다 (contractId: {})", contractId);
                        }
                    } catch (Exception e2) {
                        log.error("마일스톤 조회 실패 (contractId: {}): {}", contractId, e2.getMessage(), e2);
                        selectedContract.setMilestones(new java.util.ArrayList<>());
                    }
                }
            } catch (Exception e) {
                log.error("계약 조회 중 예외 발생 (contractId: {}): {}", contractId, e.getMessage(), e);
                // selectedContract는 null로 유지
            }
            
            if (selectedContract != null) {
                try {
                    // selectedContract는 항상 model에 추가
                    // null 체크 후 milestones 추가
                    List<ContractMilestoneResponseDTO> milestones = selectedContract.getMilestones();
                    if (milestones == null) {
                        milestones = new java.util.ArrayList<>();
                    }
                    model.addAttribute("selectedContract", selectedContract);
                    model.addAttribute("milestones", milestones);
                    
                    // origin_contract_url에서 freelancerId 추출하여 권한 확인
                    String originUrl = selectedContract.getOriginContractUrl();
                    boolean isFreelancerContract = false;
                    if (originUrl != null && !originUrl.isEmpty() && originUrl.startsWith("contracts/")) {
                        String[] pathParts = originUrl.split("/");
                        if (pathParts.length >= 4) {
                            try {
                                Integer contractFreelancerId = Integer.parseInt(pathParts[3]);
                                isFreelancerContract = contractFreelancerId.equals(freelancerId);
                            } catch (NumberFormatException e) {
                                log.warn("선택한 계약의 origin_contract_url에서 freelancerId 추출 실패: {}", originUrl);
                            }
                        }
                    }
                    
                    if (isFreelancerContract) {
                        // Service를 통해 View 데이터 조회 (모든 DTO 변환 포함)
                        ContractService.FreelancerContractViewData viewData = null;
                        try {
                            viewData = contractService.getFreelancerContractViewData(contractId, selectedContract);
                        } catch (Exception e) {
                            log.warn("계약 상세 정보 조회 실패 (contractId: {}): {}", contractId, e.getMessage());
                        }
                        
                        if (viewData != null) {
                            model.addAttribute("contractDetail", viewData.getContractDetail());
                            model.addAttribute("project", viewData.getProject());
                            model.addAttribute("client", viewData.getClient());
                        } else {
                            // viewData가 null인 경우 기본값 설정
                            model.addAttribute("contractDetail", null);
                            model.addAttribute("project", new java.util.HashMap<>());
                            model.addAttribute("client", new java.util.HashMap<>());
                        }
                    } else {
                        // 권한이 없어도 기본 계약 정보는 표시 (selectedContract는 이미 추가됨)
                        // Service를 통해 기본 프로젝트 Map 생성
                        java.util.Map<String, Object> project = contractService.createBasicProjectMap(selectedContract);
                        model.addAttribute("project", project);
                        
                        model.addAttribute("errorMessage", "해당 계약에 접근할 권한이 없습니다.");
                    }
                } catch (Exception e) {
                    log.error("계약 상세 정보 처리 중 오류 발생 (contractId: {}): {}", contractId, e.getMessage(), e);
                    // selectedContract는 이미 model에 추가되었으므로 기본 정보는 표시 가능
                    model.addAttribute("errorMessage", "계약 상세 정보를 처리하는 중 오류가 발생했습니다.");
                }
            } else {
                model.addAttribute("errorMessage", "계약을 찾을 수 없습니다. (contractId: " + contractId + ")");
            }
        }
        
        return "contract/freelancerContractList";
    }
    
    /** 계약 확인 페이지 리다이렉트. 목록 페이지로 이동. */
    @GetMapping("/check")
    public String freelancerContractCheck(
            @RequestParam("contractId") Integer contractId,
            @RequestParam(value = "projectId", required = false) Integer projectId) {
        // 확인 페이지를 목록 페이지로 리다이렉트
        return "redirect:/freelancer/contract/list?contractId=" + contractId;
    }

    /** 계약 수락 처리. WAITING → SIGNED */
    @PostMapping("/accept")
    public String acceptContract(
            @RequestParam("contractId") Integer contractId,
            @RequestParam(value = "projectId", required = false) Integer projectId) {
        Integer loginUserId = com.sanaiclub.common.util.AuthContext.getCurrentUserId();
        log.info("계약 수락 요청: contractId={}, freelancerId={}", contractId, loginUserId);
        try {
            contractService.acceptContract(contractId, loginUserId);
            // 목록 페이지로 리다이렉트
            return "redirect:/freelancer/contract/list?contractId=" + contractId;
        } catch (Exception e) {
            log.error("계약 수락 실패: contractId={}, error={}", contractId, e.getMessage(), e);
            // 오류 발생 시에도 목록 페이지로 리다이렉트
            return "redirect:/freelancer/contract/list?contractId=" + contractId;
        }
    }
    
    /** 계약 거절 처리. WAITING → TERMINATED, 거절 사유 저장. */
    @PostMapping("/reject")
    public String rejectContract(
            @RequestParam("contractId") Integer contractId,
            @RequestParam("reason") String reason,
            @RequestParam(value = "projectId", required = false) Integer projectId) {
        Integer loginUserId = com.sanaiclub.common.util.AuthContext.getCurrentUserId();
        log.info("계약 거절 요청: contractId={}, freelancerId={}, reason={}", contractId, loginUserId, reason);
        try {
            contractService.rejectContract(contractId, loginUserId, reason);
            // 목록 페이지로 리다이렉트
            return "redirect:/freelancer/contract/list?contractId=" + contractId;
        } catch (Exception e) {
            log.error("계약 거절 실패: contractId={}, error={}", contractId, e.getMessage(), e);
            // 오류 발생 시에도 목록 페이지로 리다이렉트
            return "redirect:/freelancer/contract/list?contractId=" + contractId;
        }
    }
    
    /** 프리랜서 지급 요청. 마일스톤: WAITING → REQUESTED, 일시지급: cancel_reason에 "[지급요청]" 저장. */
    @PostMapping("/request-payment")
    public String requestPayment(
            @RequestParam("contractId") Integer contractId,
            @RequestParam(value = "step", required = false) Integer step) {
        log.info("지급 요청: contractId={}, step={}", contractId, step);
        try {
            contractService.requestPayment(contractId, step);
            return "redirect:/freelancer/contract/list?contractId=" + contractId;
        } catch (Exception e) {
            log.error("지급 요청 실패: contractId={}, step={}, error={}", contractId, step, e.getMessage(), e);
            return "redirect:/freelancer/contract/list?contractId=" + contractId;
        }
    }

    /** AI 계약 분석 리포트 조회. 계약서 위험 요소 분석 및 권장사항 제공.
     *    - 현재 로그인한 프리랜서의 계약인지 확인
     *    - 권한이 없으면 에러 메시지 표시
     * 
     * 4. 계약 상세 정보 조회 (JOIN)
     *    - ContractService.getContractDetailForView()로 상세 정보 조회
     *    - 프로젝트, 클라이언트, 회사 정보 포함
     *    - 조회 실패해도 계속 진행 (에러 로그만 기록)
     * 
     * 5. PDF 텍스트 추출
     *    - origin_contract_url로 PDF 파일 조회
     *    - PDFProcessingService.extractText()로 텍스트 추출
     *    - 추출 실패해도 계속 진행 (빈 문자열로 처리)
     * 
     * 6. AI 분석 서비스 호출
     *    - ContractAnalysisService.analyzeContract() 호출
     *    - 계약 상세 정보, 계약 정보, PDF 텍스트 전달
     *    - 위험도 점수, 위험 조항 목록, 권장사항 생성
     *    - 분석 실패해도 리포트 페이지는 표시 (에러 메시지 포함)
     * 
     * 7. Model에 데이터 전달
     *    - contract: 계약 정보 (ContractResponseDTO)
     *    - contractDetail: 계약 상세 정보 (ContractDetailDTO)
     *    - project: 프로젝트 정보 (ProjectsVO)
     *    - clientUser: 클라이언트 사용자 정보 (UserVO)
     *    - analysis: AI 분석 결과 (ContractAnalysisDTO)
     *    - pdfUrl: PDF 파일 경로
     *    - contractId: 계약 ID
     * 
     * [AI 분석 입력 데이터]
     * 
     * - contractDetail: 계약 상세 정보 (JOIN 결과)
     *   * 계약 정보, 프로젝트 정보, 클라이언트 정보, 회사 정보 포함
     *   * null이어도 분석 시도 (기본 정보만 사용)
     * 
     * - contract: 계약 정보 (마일스톤 포함)
     *   * 계약 기간, 예산, 결제 방식, 마일스톤 정보 포함
     *   * 필수 (없으면 분석 불가)
     * 
     * - pdfText: PDF 텍스트
     *   * PDF 계약서에서 추출한 텍스트
     *   * 빈 문자열이어도 분석 시도 (프로젝트 정보와 계약 정보만 사용)
     * 
     * [AI 분석 출력 데이터]
     * 
     * ContractAnalysisDTO:
     * - riskScore: 위험도 점수 (0-100)
     * - riskLevel: 위험도 레벨 ("LOW", "MEDIUM", "HIGH")
     * - riskDescription: 위험도 설명
     * - totalAmount: 총 금액 (형식화된 문자열)
     * - contractPeriod: 계약 기간 (형식화된 문자열)
     * - paymentMethod: 지급 방식 (형식화된 문자열)
     * - delayPenalty: 지연 손해 배상 (형식화된 문자열)
     * - riskClauses: 위험 조항 목록
     *   * level: 위험도 레벨 ("HIGH", "MEDIUM")
     *   * clauseNumber: 조항 번호 (예: "제 7조")
     *   * clauseTitle: 조항 제목 (예: "지식재산권 귀속")
     *   * problemDescription: 문제 설명
     *   * aiRecommendation: AI 권장 대응
     * 
     * [에러 처리]
     * 
     * - 로그인하지 않았으면: 에러 메시지 표시, 리포트 페이지 반환
     * - 계약이 없으면: 에러 메시지 표시, 리포트 페이지 반환
     * - 권한이 없으면: 에러 메시지 표시, 리포트 페이지 반환
     * - 상세 정보 조회 실패: 경고 로그 기록, 계속 진행 (기본 정보만 사용)
     * - PDF 텍스트 추출 실패: 경고 로그 기록, 계속 진행 (빈 문자열로 처리)
     * - AI 분석 실패: 에러 로그 기록, 리포트 페이지는 표시 (에러 메시지 포함)
     * 
     * [사용 시나리오]
     * 
     * 1. 프리랜서가 계약 목록 페이지에서 "AI 분석" 버튼 클릭
     * 2. 새 창에서 AI 분석 리포트 페이지 표시
     * 3. 위험도 점수, 위험 조항 목록, 권장사항 확인
     * 4. 리포트를 참고하여 계약 수락/거절 결정
     * 5. 계약 관리 페이지로 돌아가서 수락/거절 버튼 클릭
     * 
     * [주의사항]
     * 
     * - AI 분석 결과는 참고용이며, 100% 정확하지 않을 수 있음
     * - 계약 수락/거절은 리포트 페이지에서 하지 않고 계약 관리 페이지에서 진행
     * - PDF 텍스트 추출 실패해도 분석 계속 진행 (프로젝트 정보와 계약 정보만 사용)
     * - 상세 정보 조회 실패해도 분석 시도 (기본 정보만 사용)
     * 
     * @param contractId 계약 ID (필수, 쿼리 파라미터)
     *                   - URL: /freelancer/contract/analyze?contractId=123
     * @param model Spring MVC Model (뷰에 전달할 데이터)
     * @return 뷰 이름 ("contract/contractAnalysis")
     * 
     * ============================================================================
     */
    @GetMapping("/analyze")
    public String analyzeContract(
            @RequestParam("contractId") Integer contractId,
            Model model) {
        
        Integer freelancerId = com.sanaiclub.common.util.AuthContext.getCurrentUserId();
        if (freelancerId == null) {
            model.addAttribute("errorMessage", "로그인이 필요합니다.");
            return "contract/contractAnalysis";
        }
        
        try {
            // 계약 정보 조회
            ContractResponseDTO contract = contractService.getContractById(contractId);
            if (contract == null) {
                model.addAttribute("errorMessage", "계약을 찾을 수 없습니다.");
                model.addAttribute("contractId", contractId);
                return "contract/contractAnalysis";
            }
            
            // 권한 검증: 프리랜서의 계약인지 확인
            String originUrl = contract.getOriginContractUrl();
            boolean isFreelancerContract = false;
            if (originUrl != null && !originUrl.isEmpty() && originUrl.startsWith("contracts/")) {
                String[] pathParts = originUrl.split("/");
                if (pathParts.length >= 4) {
                    try {
                        Integer contractFreelancerId = Integer.parseInt(pathParts[3]);
                        isFreelancerContract = contractFreelancerId.equals(freelancerId);
                    } catch (NumberFormatException e) {
                        log.warn("origin_contract_url에서 freelancerId 추출 실패: {}", originUrl);
                    }
                }
            }
            
            if (!isFreelancerContract) {
                model.addAttribute("errorMessage", "해당 계약에 접근할 권한이 없습니다.");
                model.addAttribute("contractId", contractId);
                return "contract/contractAnalysis";
            }
            
            // 계약 상세 정보 조회
            ContractDetailDTO contractDetail = null;
            try {
                contractDetail = contractService.getContractDetailForView(contractId);
            } catch (Exception e) {
                log.warn("계약 상세 정보 조회 실패: contractId={}, error={}", contractId, e.getMessage());
                // 상세 정보 조회 실패해도 계속 진행
            }
            
            // PDF 텍스트 추출 (실패해도 계속 진행)
            String pdfText = "";
            if (originUrl != null && !originUrl.isEmpty()) {
                try {
                    File pdfFile = contractFileService.getPdfFile(originUrl);
                    if (pdfFile != null && pdfFile.exists()) {
                        pdfText = pdfProcessingService.extractText(pdfFile);
                    }
                } catch (Exception e) {
                    log.warn("PDF 텍스트 추출 실패: {}", e.getMessage());
                    // PDF 추출 실패해도 분석 계속 진행
                }
            }
            
            // AI 분석 (contractDetail이 null이어도 분석 시도)
            ContractAnalysisDTO analysis = null;
            try {
                analysis = contractAnalysisService.analyzeContract(
                    contractDetail, contract, pdfText
                );
            } catch (Exception e) {
                log.error("AI 분석 실패: contractId={}, error={}", contractId, e.getMessage(), e);
                // 분석 실패해도 리포트 페이지는 표시
            }
            
            // Model에 데이터 전달
            model.addAttribute("contract", contract);
            
            // Service를 통해 View 데이터 조회 (모든 DTO 변환 포함)
            ContractService.ContractAnalysisViewData viewData = 
                contractService.getContractAnalysisViewData(contractDetail);
            
            model.addAttribute("contractDetail", viewData.getContractDetail());
            model.addAttribute("project", viewData.getProject());
            
            // clientUser는 contractDetail에서 직접 접근 불가하므로 null로 설정
            // 필요시 contractDetail.getClientName() 등으로 직접 접근
            model.addAttribute("clientUser", null);
            
            model.addAttribute("analysis", analysis);
            model.addAttribute("pdfUrl", originUrl);
            model.addAttribute("contractId", contractId);
            
            return "contract/contractAnalysis";
            
        } catch (Exception e) {
            log.error("계약 분석 페이지 로드 실패: contractId={}, error={}", contractId, e.getMessage(), e);
            model.addAttribute("errorMessage", "계약 분석을 불러오는 중 오류가 발생했습니다.");
            model.addAttribute("contractId", contractId);
            return "contract/contractAnalysis";
        }
    }
}
