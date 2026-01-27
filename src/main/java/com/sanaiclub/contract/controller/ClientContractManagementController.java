package com.sanaiclub.contract.controller;

import com.sanaiclub.contract.model.dto.ContractResponseDTO;
import com.sanaiclub.contract.model.dto.ContractDetailDTO;
import com.sanaiclub.contract.model.vo.ContractStatus;
import com.sanaiclub.contract.service.ContractService;
import com.sanaiclub.contract.dao.ContractMapper;
import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.user.dao.UserMapper;
import com.sanaiclub.user.dao.ClientProfileMapper;
import com.sanaiclub.user.dao.CompanyMapper;
import com.sanaiclub.user.model.vo.UserVO;
import com.sanaiclub.user.model.vo.ClientProfileVO;
import com.sanaiclub.user.model.vo.CompanyVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;


@Slf4j
@Controller
@RequestMapping("/client/contract/management")
@RequiredArgsConstructor
public class ClientContractManagementController {

    private final ContractService contractService;
    private final ContractMapper contractMapper;
    private final UserMapper userMapper;
    private final ClientProfileMapper clientProfileMapper;
    private final CompanyMapper companyMapper;

    /**
     * 클라이언트 계약 관리 페이지 조회
     */
    @GetMapping
    public String contractManagement(
            @RequestParam(value = "contractId", required = false) Integer contractId,
            Model model) {
        // 로그인 클라이언트 조회
        Integer userId = AuthContext.getCurrentUserId();
        if (userId == null) {
            model.addAttribute("errorMessage", "로그인이 필요합니다.");
            return "contract/contractManagement";
        }

        UserVO clientUser = userMapper.findByUserId(userId);
        if (clientUser == null) {
            model.addAttribute("errorMessage", "사용자 정보를 찾을 수 없습니다.");
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
                return contract.getOriginContractUrl().startsWith("contracts/" + userId + "/");
            })
            .collect(Collectors.toList());

        // 상태별로 그룹화
        Map<ContractStatus, List<ContractResponseDTO>> contractsByStatus = allContracts.stream()
                .collect(Collectors.groupingBy(
                    contract -> contract.getContractStatus() != null ? contract.getContractStatus() : ContractStatus.UNKNOWN
                ));

        model.addAttribute("contractsByStatus", contractsByStatus);
        model.addAttribute("allContracts", allContracts);

        // 선택한 계약 상세 정보 (contract_id를 통해 JOIN하여 조회)
        if (contractId != null) {
            ContractResponseDTO selectedContract = contractService.getContractById(contractId);
            if (selectedContract != null) {
                // contract_id를 통해 JOIN하여 상세 정보 조회
                ContractDetailDTO contractDetail = contractMapper.selectContractDetailWithJoin(contractId);
                
                // 클라이언트 프로필 및 회사 정보 조회
                ClientProfileVO clientProfile = clientProfileMapper.findByUserId(userId);
                CompanyVO company = null;
                if (clientProfile != null && clientProfile.getCompanyId() != null) {
                    company = companyMapper.findByCompanyId(clientProfile.getCompanyId());
                }
                
                model.addAttribute("contractDetail", contractDetail);
                model.addAttribute("project", contractDetail != null ? contractDetail.getProject() : null);
                model.addAttribute("clientUser", clientUser);
                model.addAttribute("clientProfile", clientProfile);
                model.addAttribute("company", company);
                model.addAttribute("selectedContract", selectedContract);
                model.addAttribute("milestones", selectedContract.getMilestones());
            }
        }

        return "contract/contractManagement";
    }

    /**
     * 계약 취소 처리
     */
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
