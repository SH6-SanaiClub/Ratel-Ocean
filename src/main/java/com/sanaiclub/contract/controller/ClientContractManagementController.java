package com.sanaiclub.contract.controller;

import com.sanaiclub.contract.model.dto.ContractResponseDTO;
import com.sanaiclub.contract.model.dto.ContractMilestoneResponseDTO;
import com.sanaiclub.contract.service.ContractService;
import com.sanaiclub.common.util.AuthContext;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import java.util.Map;

/** 클라이언트 계약 관리 컨트롤러. 계약 목록 조회, 상태 변경, 지급 수락/거부 처리. */
@Slf4j
@Controller
@RequestMapping("/client/contract/management")
@RequiredArgsConstructor
public class ClientContractManagementController {

    private final ContractService contractService;

    /** 클라이언트 계약 목록 조회 및 상태별 분류 */
    @GetMapping
    public String contractManagement(
            @RequestParam(value = "contractId", required = false) Integer contractId,
            @RequestParam(value = "_", required = false) String timestamp,
            Model model) {
        // 로그인 클라이언트 조회
        Integer userId = AuthContext.getCurrentUserId();
        String loginId = AuthContext.getCurrentLoginId();
        if (userId == null) {
            model.addAttribute("errorMessage", "로그인이 필요합니다.");
            return "contract/contractManagement";
        }
        
        // 헤더용 loginId 추가
        model.addAttribute("loginId", loginId);

        // 클라이언트의 계약 목록 조회 (쿼리에서 필터링)
        List<ContractResponseDTO> allContracts = contractService.getContractsByClientId(userId);

        // Service를 통해 계약 목록을 UI 표시용으로 분류
        Map<String, List<ContractResponseDTO>> contractsByStatus = 
                contractService.classifyContractsForClientView(allContracts);
        
        model.addAttribute("contractsByStatus", contractsByStatus);
        model.addAttribute("allContracts", allContracts);

        // 선택한 계약 상세 정보 (contract_id를 통해 JOIN하여 조회)
        if (contractId != null) {
            ContractResponseDTO selectedContract = null;
            try {
                selectedContract = contractService.getContractById(contractId);
                // getContractById는 성공했지만 마일스톤이 없는 경우, 별도로 조회 시도
                // (PAID 상태 계약에서 마일스톤이 표시되지 않는 문제 해결)
                if (selectedContract != null) {
                    // 마일스톤이 없거나 비어있으면 무조건 재조회 시도
                    if (selectedContract.getMilestones() == null || selectedContract.getMilestones().isEmpty()) {
                        try {
                            List<ContractMilestoneResponseDTO> milestones = contractService.getMilestonesByContractId(contractId);
                            if (milestones != null && !milestones.isEmpty()) {
                                selectedContract.setMilestones(milestones);
                                log.debug("마일스톤 재조회 성공 (contractId: {}, 마일스톤 수: {})", contractId, milestones.size());
                            } else {
                                // 마일스톤이 정말 없는 경우도 빈 리스트로 설정
                                selectedContract.setMilestones(new java.util.ArrayList<>());
                                log.debug("마일스톤이 없습니다 (contractId: {})", contractId);
                            }
                        } catch (Exception e2) {
                            log.error("마일스톤 재조회 실패 (contractId: {}): {}", contractId, e2.getMessage(), e2);
                            selectedContract.setMilestones(new java.util.ArrayList<>());
                        }
                    }
                }
            } catch (Exception e) {
                log.error("계약 조회 중 예외 발생 (contractId: {}): {}", contractId, e.getMessage(), e);
                // selectedContract는 null로 유지하여 에러 메시지 표시
            }
            
            if (selectedContract != null) {
                try {
                    // selectedContract는 항상 model에 추가 (권한 체크와 무관하게)
                    // null 체크 후 milestones 추가
                    List<ContractMilestoneResponseDTO> milestones = selectedContract.getMilestones();
                    if (milestones == null) {
                        milestones = new java.util.ArrayList<>();
                    }
                    model.addAttribute("selectedContract", selectedContract);
                    model.addAttribute("milestones", milestones);
                    
                    // 선택한 계약이 현재 클라이언트의 계약인지 확인
                    String originUrl = selectedContract.getOriginContractUrl();
                    boolean isClientContract = false;
                    if (originUrl != null && !originUrl.isEmpty()) {
                        isClientContract = originUrl.startsWith("contracts/" + userId + "/");
                    }
                    
                    if (isClientContract) {
                        // Service를 통해 View 데이터 조회 (모든 변환 로직 포함)
                        ContractService.ContractManagementViewData viewData = null;
                        try {
                            viewData = contractService.getContractManagementViewData(contractId, userId, selectedContract);
                        } catch (Exception e) {
                            log.warn("계약 관리 View 데이터 조회 실패 (contractId: {}, userId: {}): {}", 
                                contractId, userId, e.getMessage());
                        }
                        
                        if (viewData != null) {
                            model.addAttribute("contractDetail", viewData.getContractDetail());
                            model.addAttribute("project", viewData.getProject());
                            model.addAttribute("client", viewData.getClient());
                            model.addAttribute("clientUser", viewData.getClientUser());
                            model.addAttribute("clientProfile", viewData.getClientProfile());
                            model.addAttribute("company", viewData.getCompany());
                        }
                    } else {
                        // 권한이 없어도 기본 계약 정보는 표시 (selectedContract는 이미 추가됨)
                        // Service를 통해 기본 View 데이터 조회
                        ContractService.ContractManagementViewData viewData = null;
                        try {
                            viewData = contractService.getContractManagementViewData(contractId, userId, selectedContract);
                        } catch (Exception e) {
                            log.warn("계약 관리 View 데이터 조회 실패 (contractId: {}, userId: {}): {}", 
                                contractId, userId, e.getMessage());
                        }
                        
                        if (viewData != null) {
                            // contractDetail이 없어도 selectedContract의 기본 정보는 표시 가능
                            // Service를 통해 기본 프로젝트 Map 생성
                            java.util.Map<String, Object> project = contractService.createBasicProjectMap(selectedContract);
                            model.addAttribute("project", project);
                            
                            // 클라이언트 정보는 Service에서 조회한 데이터 사용
                            model.addAttribute("client", viewData.getClient());
                            model.addAttribute("clientUser", viewData.getClientUser());
                        } else {
                            // View 데이터 조회 실패 시 기본 정보만 설정
                            // Service를 통해 기본 프로젝트 Map 생성
                            java.util.Map<String, Object> project = contractService.createBasicProjectMap(selectedContract);
                            model.addAttribute("project", project);
                        }
                        
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

        return "contract/contractManagement";
    }

    /** 계약 결제 완료 처리 */
    @PostMapping("/finalize")
    public String finalizeContract(
            @RequestParam("contractId") Integer contractId,
            Model model) {
        try {
            contractService.finalizeContract(contractId);
            return "redirect:/client/contract/management?contractId=" + contractId;
        } catch (Exception e) {
            model.addAttribute("errorMessage", "계약 결제 완료 처리 중 오류 발생: " + e.getMessage());
            return "contract/contractManagement";
        }
    }
    
    /** 계약 정산 완료 처리 */
    @PostMapping("/complete")
    public String completeContract(
            @RequestParam("contractId") Integer contractId,
            Model model) {
        try {
            contractService.completeContract(contractId);
            return "redirect:/client/contract/management?contractId=" + contractId;
        } catch (Exception e) {
            model.addAttribute("errorMessage", "계약 정산 완료 처리 중 오류 발생: " + e.getMessage());
            return "contract/contractManagement";
        }
    }

    /** 계약 취소 처리 */
    @PostMapping("/cancel")
    public String cancelContract(
            @RequestParam("contractId") Integer contractId,
            @RequestParam("reason") String reason,
            Model model) {
        try {
            contractService.cancelContract(contractId, reason);
            return "redirect:/client/contract/management?contractId=" + contractId;
        } catch (Exception e) {
            model.addAttribute("errorMessage", "계약 취소 처리 중 오류 발생: " + e.getMessage());
            return "contract/contractManagement";
        }
    }
    
    /** 지급 수락 처리 */
    @PostMapping("/approve-payment")
    public String approvePayment(
            @RequestParam("contractId") Integer contractId,
            @RequestParam(value = "step", required = false) Integer step,
            RedirectAttributes redirectAttributes) {
        log.info("지급 수락: contractId={}, step={}", contractId, step);
        try {
            contractService.approvePayment(contractId, step);
            redirectAttributes.addFlashAttribute("successMessage", "지급 요청이 수락되었습니다.");
            return "redirect:/client/contract/management?contractId=" + contractId + "&t=" + System.currentTimeMillis();
        } catch (Exception e) {
            log.error("지급 수락 실패: contractId={}, step={}, error={}", contractId, step, e.getMessage(), e);
            redirectAttributes.addFlashAttribute("errorMessage", "지급 수락 처리 중 오류 발생: " + e.getMessage());
            return "redirect:/client/contract/management?contractId=" + contractId + "&t=" + System.currentTimeMillis();
        }
    }
    
    /** 지급 거부 처리 */
    @PostMapping("/reject-payment")
    public String rejectPayment(
            @RequestParam("contractId") Integer contractId,
            @RequestParam(value = "step", required = false) Integer step,
            RedirectAttributes redirectAttributes) {
        log.info("지급 거부: contractId={}, step={}", contractId, step);
        try {
            contractService.rejectPayment(contractId, step);
            redirectAttributes.addFlashAttribute("successMessage", "지급 요청이 거부되었습니다.");
            return "redirect:/client/contract/management?contractId=" + contractId + "&t=" + System.currentTimeMillis();
        } catch (Exception e) {
            log.error("지급 거부 실패: contractId={}, step={}, error={}", contractId, step, e.getMessage(), e);
            redirectAttributes.addFlashAttribute("errorMessage", "지급 거부 처리 중 오류 발생: " + e.getMessage());
            return "redirect:/client/contract/management?contractId=" + contractId + "&t=" + System.currentTimeMillis();
        }
    }
}
