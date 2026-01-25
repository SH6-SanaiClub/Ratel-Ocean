package com.sanaiclub.contract.controller;

import com.sanaiclub.contract.model.dto.ContractResponseDTO;
import com.sanaiclub.contract.model.dto.ContractDetailDTO;
import com.sanaiclub.contract.model.dto.ContractAnalysisDTO;
import com.sanaiclub.contract.service.ContractService;
import com.sanaiclub.contract.service.ContractFileService;
import com.sanaiclub.contract.service.ContractAnalysisService;
import com.sanaiclub.contract.service.PDFProcessingService;
import com.sanaiclub.contract.dao.ContractMapper;
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
import java.util.stream.Collectors;

/**
 * ============================================================================
 * FreelancerContractController - 프리랜서 계약 관리 컨트롤러
 * ============================================================================
 * 
 * [역할]
 * 프리랜서가 자신과 관련된 계약을 조회하고 관리하는 컨트롤러입니다.
 * 프리랜서 전용 계약 관리 기능을 제공하며, 계약 수락/거절, 지급 요청 등을 처리합니다.
 * 
 * [연관 파일]
 * 
 * Service 계층:
 * - ContractService: 계약 비즈니스 로직 (수락, 거절, 지급 요청 등)
 * - ContractFileService: PDF 파일 제공
 * 
 * DAO 계층:
 * - ContractMapper: 계약 데이터 접근
 * 
 * View 계층:
 * - freelancerContractList.jsp: 프리랜서 계약 목록 및 상세 정보 페이지
 * - includes/statusTitlePaidFreelancer.jsp: PAID 상태 집계 (프리랜서용)
 * - includes/statusTitleSettlementPending.jsp: SETTLEMENT_PENDING 상태 집계
 * 
 * [주요 기능]
 * 
 * 1. 계약 목록 조회
 *    - GET /freelancer/contract/list: 프리랜서의 계약 목록 조회
 *    - 상태별로 그룹화하여 표시 (WAITING, SIGNED, PAID, SETTLEMENT_PENDING, COMPLETED_HISTORY, TERMINATED)
 *    - 계약 상세 정보 조회 (contractId 파라미터)
 *    - origin_contract_url에서 freelancerId 추출하여 필터링
 * 
 * 2. 계약 상태 변경
 *    - POST /freelancer/contract/accept: 계약 수락 (WAITING → SIGNED)
 *    - POST /freelancer/contract/reject: 계약 거절 (WAITING → TERMINATED)
 * 
 * 3. 지급 요청
 *    - POST /freelancer/contract/request-payment: 프리랜서 지급 요청
 *      * 마일스톤: 마일스톤 상태 WAITING → REQUESTED
 *      * 일시지급: cancel_reason에 "[지급요청]" 저장
 * 
 * 4. PDF 파일 제공
 *    - GET /freelancer/contract/file/**: PDF 파일 다운로드/미리보기
 * 
 * [필터링 로직]
 * origin_contract_url 형식: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
 * - 경로에서 freelancerId 추출 (pathParts[3])
 * - 현재 로그인한 프리랜서 ID와 일치하는 계약만 포함
 * - 프리랜서 시점: 상대방은 클라이언트 (counterpartName = clientName)
 * 
 * [복잡한 분류 로직]
 * ClientContractManagementController와 유사한 분류 로직을 사용하지만,
 * 프리랜서 시점에 맞게 UI 텍스트가 다릅니다:
 * 
 * - PAID 상태: "결제 완료" (클라이언트는 "최종 승인 대기")
 * - SETTLEMENT_PENDING: "정산 대기" (일시지급 요청 전/후 모두 포함)
 * - COMPLETED_HISTORY: "완료 내역" (모든 지급이 완료된 계약)
 * 
 * [경로]
 * - Base URL: /freelancer/contract
 * - 프리랜서 전용 컨트롤러
 * 
 * [인증]
 * - AuthContext.getCurrentUserId()로 현재 로그인한 프리랜서 ID 확인
 * - origin_contract_url에서 freelancerId 추출하여 권한 검증
 * 
 * [책임 분리]
 * - Controller: HTTP 요청 처리, 뷰 선택, 필터링 및 분류
 * - Service: 비즈니스 로직 처리 (계약 상태 변경, 지급 요청 등)
 * - Mapper: 데이터 접근 (계약 상세 정보 조회)
 * 
 * ============================================================================
 */
@Slf4j
@Controller
@RequestMapping("/freelancer/contract")
@RequiredArgsConstructor
public class FreelancerContractController {

    private final ContractService contractService;
    private final ContractMapper contractMapper;
    private final ContractFileService contractFileService;
    private final ContractAnalysisService contractAnalysisService;
    private final PDFProcessingService pdfProcessingService;

    /**
     * 프리랜서용 PDF 파일 제공
     * 
     * [기능]
     * - 저장된 PDF 파일을 브라우저에서 조회
     * - iframe이나 embed 태그에서 사용
     * - ContractFileService의 공통 메서드 사용
     * 
     * [경로 형식]
     * - GET /freelancer/contract/file/{encodedPath}
     * - 경로: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
     * 
     * [보안]
     * - ContractFileService.servePdfResource()에서 Path Traversal 방지
     * - contracts/로 시작하는 경로만 허용
     * 
     * @param request HTTP 요청 (URI에서 경로 추출)
     * @return PDF 파일 리소스 (application/pdf)
     */
    @GetMapping("/file/**")
    public ResponseEntity<org.springframework.core.io.Resource> servePdf(
            javax.servlet.http.HttpServletRequest request) {
        String requestURI = request.getRequestURI();
        return contractFileService.servePdfResource(requestURI);
    }

    /**
     * ============================================================================
     * 프리랜서 계약 목록 조회
     * ============================================================================
     * 
     * [기능]
     * 프리랜서가 자신과 관련된 모든 계약을 조회하고, 상태별로 분류하여 표시하는 메서드입니다.
     * 클라이언트 계약 관리 페이지와 유사한 분류 로직을 사용하지만, 프리랜서 시점에 맞게
     * UI 텍스트와 분류 기준이 다릅니다.
     * 
     * [연관 파일]
     * - ContractService.getAllContracts(): 모든 계약 목록 조회 (마일스톤 집계 포함)
     * - ContractMapper.selectContractDetailWithJoin(): 계약 상세 정보 조회 (JOIN)
     * - freelancerContractList.jsp: 프리랜서 계약 목록 및 상세 정보를 표시하는 뷰
     * - includes/statusTitlePaidFreelancer.jsp: PAID 상태 집계 및 제목 표시 (인클루드)
     * - includes/statusTitleSettlementPending.jsp: SETTLEMENT_PENDING 상태 집계 (인클루드)
     * 
     * [처리 흐름]
     * 1. 현재 로그인한 프리랜서 ID 확인 (AuthContext)
     * 2. 모든 계약 목록 조회 (ContractService.getAllContracts())
     * 3. 프리랜서의 계약만 필터링 (origin_contract_url에서 freelancerId 추출)
     * 4. 상태별로 그룹화 (기본 상태: WAITING, SIGNED, PAID, COMPLETED, TERMINATED)
     * 5. 복잡한 분류 로직 적용:
     *    a) PAID 상태를 "결제 완료"와 "정산 대기"로 분리
     *    b) COMPLETED 상태를 "정산 대기"와 "완료 내역"으로 분리
     * 6. 선택한 계약이 있으면 상세 정보 조회 (JOIN)
     * 7. Model에 데이터 전달
     * 
     * [필터링 로직]
     * origin_contract_url 형식: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
     * - 경로에서 freelancerId 추출 (pathParts[3])
     * - 현재 로그인한 프리랜서 ID와 일치하는 계약만 포함
     * - 프리랜서 시점: 상대방은 클라이언트 (counterpartName = clientName)
     * 
     * [복잡한 분류 로직 상세 설명]
     * 
     * 1. PAID 상태 분리
     *    PAID 상태의 계약을 두 가지로 분류합니다:
     *    
     *    a) "결제 완료" (PAID 키 유지)
     *       - 마일스톤 방식 계약만 해당
     *       - 마일스톤이 있고, 일시지급이 아닌 경우
     *       - 사이드바에 "💰 결제 완료"로 표시
     *       - 예: "💰 결제 완료 (지급 요청 중: 2건)"
     *    
     *    b) "정산 대기" (SETTLEMENT_PENDING으로 이동)
     *       - 일시지급 계약만 해당
     *       - 마일스톤이 없고, FIXED/FULL/null인 경우
     *       - 요청 전(cancel_reason = null)과 요청 후(cancel_reason = "[지급요청]") 모두 포함
     *       - 사이드바에 "🎉 정산 대기"로 표시
     *       - 예: "🎉 정산 대기 (일시지급 요청 대기: 1건)"
     * 
     * 2. COMPLETED 상태 분리
     *    COMPLETED 상태의 계약을 두 가지로 분류합니다:
     *    
     *    a) "정산 대기" (SETTLEMENT_PENDING)
     *       - 아직 완전히 끝나지 않은 계약
     *       - 마일스톤 계약: 일부 마일스톤만 PAID (paidMilestones < totalMilestones)
     *       - 사이드바에 "🎉 정산 대기"로 표시
     *    
     *    b) "완료 내역" (COMPLETED_HISTORY)
     *       - 완전히 끝난 계약
     *       - 마일스톤 계약: 모든 마일스톤이 PAID (paidMilestones == totalMilestones)
     *       - 일시지급 계약: COMPLETED 상태이면 완료 내역 (일시지급 수락 시 COMPLETED로 변경)
     *       - 사이드바에 "✅ 완료 내역"으로 표시
     * 
     * [일시지급 계약 처리 방식]
     * DB 스키마 변경 없이 일시지급 지급 요청 상태를 관리하기 위해 cancel_reason 컬럼을 재활용합니다.
     * 
     * - cancel_reason = null: 아직 지급 요청하지 않은 상태
     *   → 사이드바: "🎉 정산 대기 (일시지급: 1건)"
     *   → 상세 페이지: "💰 일시지급 요청" 버튼 표시
     * 
     * - cancel_reason = "[지급요청]": 프리랜서가 지급 요청한 상태
     *   → 사이드바: "🎉 정산 대기 (일시지급 요청 대기: 1건)"
     *   → 상세 페이지: "📤 클라이언트의 지급 수락을 기다리는 중입니다." 메시지 표시
     * 
     * - 일시지급 수락 후: COMPLETED 상태로 변경, cancel_reason = null
     *   → 사이드바: "✅ 완료 내역"
     *   → 상세 페이지: "✅ 일시지급이 완료되었습니다." 메시지 표시
     * 
     * [상세 정보 조회]
     * - contractId가 있으면 selectContractDetailWithJoin()으로 상세 정보 조회
     * - 프로젝트, 클라이언트, 회사 정보 포함 (LEFT JOIN)
     * - JOIN 실패 시에도 계약 기본 정보는 표시 가능 (에러 처리)
     * 
     * [Model Attributes]
     * - contractsByStatus: 상태별 계약 목록 (Map<String, List<ContractResponseDTO>>)
     *   * 키: "WAITING", "SIGNED", "PAID", "SETTLEMENT_PENDING", "COMPLETED_HISTORY", "TERMINATED"
     * - allContracts: 프리랜서의 모든 계약 목록
     * - contractDetail: 선택한 계약의 상세 정보 (JOIN 결과)
     * - project, clientUser, clientProfile, company: 상세 정보의 관련 데이터
     * - selectedContract: 선택한 계약 정보 (ContractResponseDTO)
     * - milestones: 선택한 계약의 마일스톤 목록
     * 
     * [에러 처리]
     * - 로그인하지 않았으면 에러 메시지 표시
     * - 계약 상세 정보 조회 실패 시에도 기본 정보는 표시 가능
     * - origin_contract_url 파싱 실패 시 경고 로그 출력
     * 
     * @param contractId 선택한 계약 ID (선택, 쿼리 파라미터)
     *                   - URL: /freelancer/contract/list?contractId=123
     * @param model Spring MVC Model (뷰에 전달할 데이터)
     * @return 뷰 이름 ("contract/freelancerContractList")
     * 
     * ============================================================================
     */
    @GetMapping("/list")
    public String freelancerContractList(
            @RequestParam(value = "contractId", required = false) Integer contractId,
            Model model) {
        // 로그인 프리랜서 ID 조회
        Integer freelancerId = com.sanaiclub.common.util.AuthContext.getCurrentUserId();
        if (freelancerId == null) {
            model.addAttribute("errorMessage", "로그인이 필요합니다.");
            return "contract/freelancerContractList";
        }
        
        // 모든 계약 목록 조회
        List<ContractResponseDTO> allContractsList = contractService.getAllContracts();
        
        // 프리랜서가 받은 계약만 필터링
        // origin_contract_url 형식: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
        List<ContractResponseDTO> allContracts = allContractsList.stream()
            .filter(contract -> {
                String originUrl = contract.getOriginContractUrl();
                // origin_contract_url이 null이거나 비어있으면 제외
                if (originUrl == null || originUrl.isEmpty()) {
                    return false;
                }
                // origin_contract_url 형식 확인: contracts/{clientId}/{projectId}/{freelancerId}/...
                if (!originUrl.startsWith("contracts/")) {
                    return false;
                }
                // 경로에서 freelancerId 추출
                // contracts/{clientId}/{projectId}/{freelancerId}/...
                String[] pathParts = originUrl.split("/");
                if (pathParts.length < 4) {
                    return false;
                }
                try {
                    // pathParts[3]이 freelancerId
                    Integer contractFreelancerId = Integer.parseInt(pathParts[3]);
                    // 현재 로그인한 프리랜서의 계약만 포함
                    return contractFreelancerId.equals(freelancerId);
                } catch (NumberFormatException e) {
                    log.warn("origin_contract_url에서 freelancerId 추출 실패: {}", originUrl);
                    return false;
                }
            })
            .map(contract -> {
                // 프리랜서 시점: 상대방은 클라이언트
                contract.setCounterpartName(contract.getClientName());
                return contract;
            })
            .collect(Collectors.toList());
        
        // 상태별로 그룹화
        Map<String, List<ContractResponseDTO>> contractsByStatus = allContracts.stream()
                .collect(Collectors.groupingBy(
                    contract -> contract.getContractStatus() != null ? contract.getContractStatus() : "UNKNOWN"
                ));
        
        // PAID 상태를 "결제 완료"와 "정산 대기"로 분리
        // 일시지급 계약은 항상 "정산 대기"로 분류 (요청 전/후 모두)
        List<ContractResponseDTO> paidContracts = contractsByStatus.remove("PAID");
        List<ContractResponseDTO> settlementPendingFromPaid = new java.util.ArrayList<>(); // 임시 저장
        if (paidContracts != null && !paidContracts.isEmpty()) {
            List<ContractResponseDTO> paymentCompleted = new java.util.ArrayList<>();
            
            for (ContractResponseDTO contract : paidContracts) {
                // 일시지급 계약인지 확인 (마일스톤이 없고, FIXED/FULL)
                boolean isLumpSum = (contract.getTotalMilestones() == null || contract.getTotalMilestones() == 0)
                        && ("FIXED".equals(contract.getPaymentMethod()) 
                            || "FULL".equals(contract.getPaymentMethod()) 
                            || contract.getPaymentMethod() == null);
                
                // 일시지급 계약이면 항상 "정산 대기"로 분류
                // (요청 전: cancel_reason = null, 요청 후: cancel_reason = "[지급요청]")
                if (isLumpSum) {
                    settlementPendingFromPaid.add(contract);
                } else {
                    // 마일스톤 계약은 "결제 완료"로 분류
                    paymentCompleted.add(contract);
                }
            }
            
            // 결제 완료만 먼저 추가
            if (!paymentCompleted.isEmpty()) {
                contractsByStatus.put("PAID", paymentCompleted);
            }
            // settlementPendingFromPaid는 나중에 COMPLETED 분리 후에 합치기
        }
        
        // COMPLETED 상태를 "정산 대기"와 "완료 내역"으로 분리
        List<ContractResponseDTO> completedContracts = contractsByStatus.remove("COMPLETED");
        if (completedContracts != null && !completedContracts.isEmpty()) {
            List<ContractResponseDTO> settlementPending = new java.util.ArrayList<>();
            List<ContractResponseDTO> completedHistory = new java.util.ArrayList<>();
            
            for (ContractResponseDTO contract : completedContracts) {
                // 완전히 끝난 경우: 모든 마일스톤(또는 가상 마일스톤)이 PAID
                boolean isFullyCompleted = false;
                
                // 일시지급 계약인지 확인
                boolean isLumpSum = (contract.getTotalMilestones() == null || contract.getTotalMilestones() == 0)
                        && ("FIXED".equals(contract.getPaymentMethod()) 
                            || "FULL".equals(contract.getPaymentMethod()) 
                            || contract.getPaymentMethod() == null);
                
                // 일시지급이든 마일스톤이든 모두 paidMilestones를 확인
                if (contract.getTotalMilestones() != null && contract.getTotalMilestones() > 0) {
                    // 마일스톤 계약: 모든 마일스톤이 PAID인지 확인
                    if (contract.getPaidMilestones() != null 
                            && contract.getPaidMilestones().equals(contract.getTotalMilestones())) {
                        isFullyCompleted = true;
                    }
                } else if (isLumpSum) {
                    // 일시지급 계약: COMPLETED 상태이면 완료 내역
                    // (일시지급 수락 시 COMPLETED로 변경되므로)
                    isFullyCompleted = true;
                } else {
                    // 마일스톤이 없고 일시지급도 아닌 경우 (이상한 상태)
                    isFullyCompleted = false;
                }
                
                if (isFullyCompleted) {
                    completedHistory.add(contract);
                } else {
                    settlementPending.add(contract);
                }
            }
            
            // 정산 대기와 완료 내역을 별도 키로 추가
            if (!settlementPending.isEmpty()) {
                contractsByStatus.put("SETTLEMENT_PENDING", settlementPending);
            }
            if (!completedHistory.isEmpty()) {
                contractsByStatus.put("COMPLETED_HISTORY", completedHistory);
            }
        }
        
        // PAID에서 온 정산 대기 계약들을 SETTLEMENT_PENDING에 합치기
        if (!settlementPendingFromPaid.isEmpty()) {
            List<ContractResponseDTO> existingSettlement = contractsByStatus.getOrDefault("SETTLEMENT_PENDING", new java.util.ArrayList<>());
            existingSettlement.addAll(settlementPendingFromPaid);
            contractsByStatus.put("SETTLEMENT_PENDING", existingSettlement);
        }
        
        model.addAttribute("contractsByStatus", contractsByStatus);
        model.addAttribute("allContracts", allContracts);
        
        // 선택한 계약 상세 정보 (contract_id를 통해 JOIN하여 조회)
        if (contractId != null) {
            ContractResponseDTO selectedContract = contractService.getContractById(contractId);
            if (selectedContract != null) {
                // 선택한 계약이 현재 프리랜서의 계약인지 확인
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
                    // contract_id를 통해 JOIN하여 상세 정보 조회
                    ContractDetailDTO contractDetail = null;
                    try {
                        contractDetail = contractMapper.selectContractDetailWithJoin(contractId);
                    } catch (Exception e) {
                        log.warn("계약 상세 정보 조회 실패 (contractId: {}): {}", contractId, e.getMessage());
                    }
                    
                    model.addAttribute("contractDetail", contractDetail);
                    model.addAttribute("project", contractDetail != null ? contractDetail.getProject() : null);
                    model.addAttribute("clientUser", contractDetail != null ? contractDetail.getClientUser() : null);
                    model.addAttribute("clientProfile", contractDetail != null ? contractDetail.getClientProfile() : null);
                    model.addAttribute("company", contractDetail != null ? contractDetail.getCompany() : null);
                    model.addAttribute("selectedContract", selectedContract);
                    model.addAttribute("milestones", selectedContract.getMilestones());
                } else {
                    model.addAttribute("errorMessage", "해당 계약에 접근할 권한이 없습니다.");
                }
            } else {
                model.addAttribute("errorMessage", "계약을 찾을 수 없습니다. (contractId: " + contractId + ")");
            }
        }
        
        return "contract/freelancerContractList";
    }
    
    /**
     * 계약 확인 페이지 리다이렉트
     * 
     * [기능]
     * - 계약 확인 페이지 요청을 목록 페이지로 리다이렉트
     * - 목록 페이지에서 계약 상세 정보를 함께 표시
     * 
     * [사용 시나리오]
     * - 다른 페이지에서 계약 확인 페이지로 이동할 때
     * - 목록 페이지로 리다이렉트하여 상세 정보 표시
     * 
     * @param contractId 계약 ID (필수)
     * @param projectId 프로젝트 ID (선택, 현재 미사용)
     * @return 리다이렉트 URL ("redirect:/freelancer/contract/list?contractId={contractId}")
     */
    @GetMapping("/check")
    public String freelancerContractCheck(
            @RequestParam("contractId") Integer contractId,
            @RequestParam(value = "projectId", required = false) Integer projectId) {
        // 확인 페이지를 목록 페이지로 리다이렉트
        return "redirect:/freelancer/contract/list?contractId=" + contractId;
    }

    /**
     * 계약 수락
     * 
     * [기능]
     * - 프리랜서가 계약을 수락하여 상태를 SIGNED로 변경
     * - ContractService.acceptContract() 호출
     * 
     * [상태 변경]
     * - WAITING → SIGNED
     * 
     * [처리 흐름]
     * 1. 현재 로그인한 프리랜서 ID 확인
     * 2. ContractService.acceptContract() 호출
     * 3. 목록 페이지로 리다이렉트
     * 
     * [에러 처리]
     * - 예외 발생 시에도 목록 페이지로 리다이렉트 (에러 로그만 기록)
     * 
     * [주의사항]
     * - projectId 파라미터는 현재 미사용
     * - 향후 권한 검증 로직 추가 예정 (해당 프리랜서가 계약을 수락할 권한이 있는지 확인)
     * 
     * @param contractId 수락할 계약의 ID (필수)
     * @param projectId 프로젝트 ID (선택, 현재 미사용)
     * @return 리다이렉트 URL ("redirect:/freelancer/contract/list?contractId={contractId}")
     */
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
    
    /**
     * 계약 거절
     * 
     * [기능]
     * - 프리랜서가 계약을 거절하여 상태를 TERMINATED로 변경
     * - 거절 사유를 cancel_reason에 저장
     * - ContractService.rejectContract() 호출
     * 
     * [상태 변경]
     * - WAITING → TERMINATED
     * 
     * [처리 흐름]
     * 1. 현재 로그인한 프리랜서 ID 확인
     * 2. ContractService.rejectContract() 호출 (거절 사유 포함)
     * 3. 목록 페이지로 리다이렉트
     * 
     * [에러 처리]
     * - 예외 발생 시에도 목록 페이지로 리다이렉트 (에러 로그만 기록)
     * 
     * [주의사항]
     * - reason은 필수 (사용자가 거절 이유를 입력해야 함)
     * - projectId 파라미터는 현재 미사용
     * - 향후 권한 검증 로직 추가 예정
     * 
     * @param contractId 거절할 계약의 ID (필수)
     * @param reason 거절 사유 (필수, 사용자가 입력한 거절 이유)
     * @param projectId 프로젝트 ID (선택, 현재 미사용)
     * @return 리다이렉트 URL ("redirect:/freelancer/contract/list?contractId={contractId}")
     */
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
    
    /**
     * ============================================================================
     * 프리랜서 지급 요청
     * ============================================================================
     * 
     * [기능]
     * 프리랜서가 작업 완료 후 클라이언트에게 지급을 요청하는 메서드입니다.
     * 마일스톤 방식과 일시지급 방식을 모두 지원하며, 일시지급의 경우 DB 스키마 변경 없이
     * cancel_reason 컬럼을 재활용하여 지급 요청 상태를 관리합니다.
     * 
     * [연관 파일]
     * - ContractService.requestPayment(): 실제 지급 요청 로직 처리
     * - ContractMapper.updateContractStatus(): 일시지급 요청 시 cancel_reason 업데이트
     * - ContractMilestoneMapper.updateMilestoneStatus(): 마일스톤 요청 시 상태 업데이트
     * - freelancerContractList.jsp: 프리랜서가 지급 요청 버튼을 클릭하는 UI
     * - contractManagement.jsp: 클라이언트가 지급 요청을 확인하고 수락/거부할 수 있는 UI
     * 
     * [처리 흐름]
     * 1. ContractService.requestPayment() 호출
     * 2. 마일스톤 방식: 마일스톤 상태 WAITING → REQUESTED
     * 3. 일시지급 방식: cancel_reason에 "[지급요청]" 저장
     * 4. 계약 목록 페이지로 리다이렉트
     * 
     * [일시지급 지급 요청 구현 방식]
     * DB 스키마 변경 없이 일시지급 지급 요청 상태를 관리하기 위해 cancel_reason 컬럼을 재활용합니다.
     * 
     * - cancel_reason = null → "[지급요청]": 프리랜서가 지급 요청한 상태
     * - 클라이언트가 수락하면: approvePayment()에서 COMPLETED로 변경, cancel_reason = null
     * - 클라이언트가 거부하면: rejectPayment()에서 cancel_reason = null (재요청 가능)
     * 
     * [상태 전이]
     * 마일스톤 방식:
     *   - 마일스톤 상태: WAITING → REQUESTED
     *   - 계약 상태: PAID (변경 없음)
     * 
     * 일시지급 방식:
     *   - cancel_reason: null → "[지급요청]"
     *   - 계약 상태: PAID (변경 없음)
     * 
     * [비즈니스 규칙]
     * - 계약 상태가 PAID 또는 COMPLETED여야 함
     * - 마일스톤 방식: step이 지정되면 해당 마일스톤만, null이면 모든 WAITING 마일스톤
     * - 일시지급 방식: step은 항상 null, cancel_reason이 null이어야 함
     * 
     * [에러 처리]
     * - 예외 발생 시에도 계약 목록 페이지로 리다이렉트 (에러 로그만 출력)
     * - 사용자에게는 에러 메시지 표시 안 함 (향후 개선 가능)
     * 
     * @param contractId 계약 ID
     * @param step 마일스톤 단계 (null이면 모든 WAITING 마일스톤, 일시지급은 항상 null)
     * @return 리다이렉트 URL ("redirect:/freelancer/contract/list?contractId={contractId}")
     * 
     * ============================================================================
     */
    /**
     * ============================================================================
     * 프리랜서 지급 요청
     * ============================================================================
     * 
     * [기능]
     * 프리랜서가 작업 완료 후 클라이언트에게 지급을 요청하는 메서드입니다.
     * 마일스톤 방식과 일시지급 방식을 모두 지원하며, 일시지급의 경우 DB 스키마 변경 없이
     * cancel_reason 컬럼을 재활용하여 지급 요청 상태를 관리합니다.
     * 
     * [연관 파일]
     * - ContractService.requestPayment(): 실제 지급 요청 로직 처리
     * - ContractMapper.updateContractStatus(): 일시지급 요청 시 cancel_reason 업데이트
     * - ContractMilestoneMapper.updateMilestoneStatus(): 마일스톤 요청 시 상태 업데이트
     * - freelancerContractList.jsp: 프리랜서가 지급 요청 버튼을 클릭하는 UI
     * - contractManagement.jsp: 클라이언트가 지급 요청을 확인하고 수락/거부할 수 있는 UI
     * 
     * [처리 흐름]
     * 1. ContractService.requestPayment() 호출
     * 2. 마일스톤 방식: 마일스톤 상태 WAITING → REQUESTED
     * 3. 일시지급 방식: cancel_reason에 "[지급요청]" 저장
     * 4. 계약 목록 페이지로 리다이렉트
     * 
     * [일시지급 지급 요청 구현 방식]
     * DB 스키마 변경 없이 일시지급 지급 요청 상태를 관리하기 위해 cancel_reason 컬럼을 재활용합니다.
     * 
     * - cancel_reason = null → "[지급요청]": 프리랜서가 지급 요청한 상태
     * - 클라이언트가 수락하면: approvePayment()에서 COMPLETED로 변경, cancel_reason = null
     * - 클라이언트가 거부하면: rejectPayment()에서 cancel_reason = null (재요청 가능)
     * 
     * [상태 전이]
     * 마일스톤 방식:
     *   - 마일스톤 상태: WAITING → REQUESTED
     *   - 계약 상태: PAID (변경 없음)
     * 
     * 일시지급 방식:
     *   - cancel_reason: null → "[지급요청]"
     *   - 계약 상태: PAID (변경 없음)
     * 
     * [비즈니스 규칙]
     * - 계약 상태가 PAID 또는 COMPLETED여야 함
     * - 마일스톤 방식: step이 지정되면 해당 마일스톤만, null이면 모든 WAITING 마일스톤
     * - 일시지급 방식: step은 항상 null, cancel_reason이 null이어야 함
     * 
     * [에러 처리]
     * - 예외 발생 시에도 계약 목록 페이지로 리다이렉트 (에러 로그만 출력)
     * - 사용자에게는 에러 메시지 표시 안 함 (향후 개선 가능)
     * 
     * @param contractId 계약 ID
     * @param step 마일스톤 단계 (null이면 모든 WAITING 마일스톤, 일시지급은 항상 null)
     * @return 리다이렉트 URL ("redirect:/freelancer/contract/list?contractId={contractId}")
     * 
     * ============================================================================
     */
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

    /**
     * ============================================================================
     * AI 계약 분석 리포트 조회
     * ============================================================================
     * 
     * [기능]
     * 프리랜서가 계약을 수락하기 전에 AI로 계약서의 위험 요소를 분석하여
     * 위험도 및 권장사항을 확인하는 리포트를 제공하는 메서드입니다.
     * 새 창에서 리포트만 표시되며, 계약 수락/거절은 계약 관리 페이지에서 진행합니다.
     * 
     * [연관 파일]
     * 
     * Service 계층:
     * - ContractAnalysisService.analyzeContract(): AI 계약 분석 서비스
     *   * 계약 정보, 프로젝트 정보, 마일스톤 정보, PDF 텍스트를 종합하여 분석
     *   * 위험도 점수, 위험 조항 목록, 권장사항 생성
     * - ContractService.getContractById(): 계약 정보 조회 (마일스톤 포함)
     * - ContractMapper.selectContractDetailWithJoin(): 계약 상세 정보 조회 (JOIN)
     * - ContractFileService.getPdfFile(): PDF 파일 조회
     * - PDFProcessingService.extractText(): PDF 텍스트 추출
     * 
     * View 계층:
     * - contractAnalysis.jsp: AI 분석 리포트 페이지
     *   * 위험도 점수, 위험 조항 목록, 권장사항 표시
     *   * 계약 수락/거절 버튼 없음 (참고용 리포트만 제공)
     * 
     * [처리 흐름]
     * 
     * 1. 로그인 확인
     *    - AuthContext.getCurrentUserId()로 현재 로그인한 프리랜서 ID 확인
     *    - 로그인하지 않았으면 에러 메시지 표시
     * 
     * 2. 계약 정보 조회
     *    - ContractService.getContractById()로 계약 정보 조회
     *    - 계약이 없으면 에러 메시지 표시
     * 
     * 3. 권한 검증
     *    - origin_contract_url에서 freelancerId 추출
     *    - 현재 로그인한 프리랜서의 계약인지 확인
     *    - 권한이 없으면 에러 메시지 표시
     * 
     * 4. 계약 상세 정보 조회 (JOIN)
     *    - ContractMapper.selectContractDetailWithJoin()으로 상세 정보 조회
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
                contractDetail = contractMapper.selectContractDetailWithJoin(contractId);
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
            model.addAttribute("contractDetail", contractDetail);
            model.addAttribute("project", contractDetail != null ? contractDetail.getProject() : null);
            model.addAttribute("clientUser", contractDetail != null ? contractDetail.getClientUser() : null);
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
