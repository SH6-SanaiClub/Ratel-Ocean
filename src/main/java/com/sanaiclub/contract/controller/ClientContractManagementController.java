package com.sanaiclub.contract.controller;

import com.sanaiclub.contract.model.dto.ContractResponseDTO;
import com.sanaiclub.contract.model.vo.ContractClientVO;
import com.sanaiclub.contract.model.vo.ContractProjectVO;
import com.sanaiclub.contract.service.ContractService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/client/contract/management")
public class ClientContractManagementController {

    private static final Logger logger = LoggerFactory.getLogger(ClientContractManagementController.class);

    private final ContractService contractService;

    /**
     * 생성자 주입
     */
    public ClientContractManagementController(ContractService contractService) {
        this.contractService = contractService;
    }

    @GetMapping
    public String contractManagement(
            @RequestParam(value = "contractId", required = false) Integer contractId,
            Model model) {
        // 로그인 클라이언트 조회
        ContractClientVO client = contractService.getClientByLoginUser();
        if (client == null) {
            model.addAttribute("errorMessage", "로그인이 필요합니다.");
            return "contract/contractManagement";
        }

        // 클라이언트의 계약 목록 조회
        // 모든 계약 조회 (null 값이나 PDF 없는 계약도 포함)
        List<ContractResponseDTO> allContractsList = contractService.getAllContracts();
        
        // 클라이언트의 계약만 필터링 (origin_contract_url이 null이거나 클라이언트 ID와 일치하는 경우)
        List<ContractResponseDTO> allContracts = allContractsList.stream()
            .filter(contract -> {
                if (contract.getOriginContractUrl() == null || contract.getOriginContractUrl().isEmpty()) {
                    // origin_contract_url이 null인 경우도 포함 (테스트용)
                    return true;
                }
                // origin_contract_url이 클라이언트 ID로 시작하는 경우
                return contract.getOriginContractUrl().startsWith("contracts/" + client.getClientId() + "/");
            })
            .collect(Collectors.toList());

        // 상태별로 그룹화
        Map<String, List<ContractResponseDTO>> contractsByStatus = allContracts.stream()
                .collect(Collectors.groupingBy(
                    contract -> contract.getContractStatus() != null ? contract.getContractStatus() : "UNKNOWN"
                ));

        model.addAttribute("contractsByStatus", contractsByStatus);
        model.addAttribute("allContracts", allContracts);

        // 선택한 계약 상세 정보
        if (contractId != null) {
            ContractResponseDTO selectedContract = contractService.getContractById(contractId);
            if (selectedContract != null) {
                // 프로젝트 정보 추출
                Integer projectId = selectedContract.getProjectId();
                
                ContractProjectVO project = null;
                ContractClientVO clientInfo = null;
                
                if (projectId != null) {
                    project = contractService.getProjectById(projectId);
                    if (project != null) {
                        clientInfo = contractService.getClientById(project.getClientId());
                    }
                } else {
                    // origin_contract_url이 null인 경우, 클라이언트 정보만 표시
                    clientInfo = client;
                }
                
                model.addAttribute("project", project);
                model.addAttribute("client", clientInfo);
                
                model.addAttribute("selectedContract", selectedContract);
                model.addAttribute("milestones", selectedContract.getMilestones());
            }
        }

        return "contract/contractManagement";
    }

    @PostMapping("/finalize")
    public String finalizeContract(
            @RequestParam("contractId") Integer contractId,
            Model model) {
        try {
            contractService.finalizeContract(contractId);
            return "redirect:/client/contract/management?contractId=" + contractId;
        } catch (Exception e) {
            model.addAttribute("errorMessage", "계약 최종 수락 처리 중 오류 발생: " + e.getMessage());
            return "contract/contractManagement";
        }
    }

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
}
