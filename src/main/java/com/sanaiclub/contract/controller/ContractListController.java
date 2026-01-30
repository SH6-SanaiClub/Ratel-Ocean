package com.sanaiclub.contract.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.contract.model.dto.ContractResponseDTO;
import com.sanaiclub.contract.service.ContractService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.Map;

/**
 * 프리랜서 계약 목록 페이지 컨트롤러
 * /contract/list 엔드포인트 제공
 */
@Slf4j
@Controller
@RequestMapping("/contract")
@RequiredArgsConstructor
public class ContractListController {

    private final ContractService contractService;

    /**
     * 프리랜서 계약 목록 페이지
     * /freelancer/contract/list로 리다이렉트
     */
    @GetMapping("/list")
    public String contractList(
            @RequestParam(value = "contractId", required = false) Integer contractId,
            Model model) {
        // 로그인 프리랜서 ID 조회
        Integer freelancerId = AuthContext.getCurrentUserId();
        String loginId = AuthContext.getCurrentLoginId();
        
        if (freelancerId == null) {
            model.addAttribute("errorMessage", "로그인이 필요합니다.");
            return "contract/freelancerContractList";
        }
        
        // 헤더용 loginId 추가
        model.addAttribute("loginId", loginId);
        model.addAttribute("userId", freelancerId);
        
        // 프리랜서의 계약 목록 조회
        List<ContractResponseDTO> allContracts = contractService.getContractsByFreelancerId(freelancerId);
        
        // Service를 통해 계약 목록을 UI 표시용으로 분류
        Map<String, List<ContractResponseDTO>> contractsByStatus = 
                contractService.classifyContractsForFreelancerView(allContracts);
        
        model.addAttribute("contractsByStatus", contractsByStatus);
        model.addAttribute("allContracts", allContracts);
        
        // 선택한 계약 상세 정보
        if (contractId != null) {
            ContractResponseDTO selectedContract = null;
            try {
                ContractResponseDTO contractFromList = allContracts.stream()
                    .filter(c -> c.getContractId() != null && c.getContractId().equals(contractId))
                    .findFirst()
                    .orElse(null);
                
                try {
                    selectedContract = contractService.getContractById(contractId);
                } catch (Exception e) {
                    log.warn("계약 상세 조회 실패 (contractId: {}): {}", contractId, e.getMessage());
                    if (contractFromList != null) {
                        selectedContract = contractFromList;
                    }
                }
                
                if (selectedContract != null) {
                    model.addAttribute("selectedContract", selectedContract);
                    
                    // 마일스톤 목록 조회
                    try {
                        List<com.sanaiclub.contract.model.dto.ContractMilestoneResponseDTO> milestones = 
                            contractService.getMilestonesByContractId(contractId);
                        model.addAttribute("milestones", milestones);
                    } catch (Exception e) {
                        log.warn("마일스톤 목록 조회 실패: {}", e.getMessage());
                    }
                }
            } catch (Exception e) {
                log.error("계약 상세 정보 조회 중 오류: {}", e.getMessage(), e);
            }
        }
        
        return "contract/contractList";
    }
}
