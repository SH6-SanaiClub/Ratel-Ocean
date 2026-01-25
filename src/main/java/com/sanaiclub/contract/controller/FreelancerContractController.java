package com.sanaiclub.contract.controller;

import com.sanaiclub.contract.model.dto.ContractResponseDTO;
import com.sanaiclub.contract.model.dto.ContractDetailDTO;
import com.sanaiclub.contract.model.vo.ContractStatus;
import com.sanaiclub.contract.service.ContractService;
import com.sanaiclub.contract.service.ContractFileService;
import com.sanaiclub.contract.dao.ContractMapper;
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


@Slf4j
@Controller
@RequestMapping("/freelancer/contract")
@RequiredArgsConstructor
public class FreelancerContractController {

    private final ContractService contractService;
    private final ContractMapper contractMapper;
    private final ContractFileService contractFileService;

    /**
     * 프리랜서용 PDF 파일 제공
     */
    @GetMapping("/file/**")
    public ResponseEntity<org.springframework.core.io.Resource> servePdf(
            javax.servlet.http.HttpServletRequest request) {
        String requestURI = request.getRequestURI();
        return contractFileService.servePdfResource(requestURI);
    }

    /**
     * 프리랜서 계약 목록 조회
     */
    @GetMapping("/list")
    public String freelancerContractList(
            @RequestParam(value = "contractId", required = false) Integer contractId,
            Model model) {
        // 로그인 프리랜서 ID 조회 (나중에 프리랜서 필터링 로직 추가 시 사용)
        // Integer freelancerId = com.sanaiclub.common.util.AuthContext.getCurrentUserId();
        
        // 모든 계약 목록 조회
        List<ContractResponseDTO> allContractsList = contractService.getAllContracts();
        
        // 프리랜서가 받은 계약만 필터링
        // origin_contract_url에서 projectId를 추출하고, 해당 프로젝트에 프리랜서가 지원했는지 확인
        // 현재는 모든 계약을 표시하되, 나중에 필터링 로직 추가 가능
        List<ContractResponseDTO> allContracts = allContractsList;
        
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
                
                model.addAttribute("contractDetail", contractDetail);
                model.addAttribute("project", contractDetail != null ? contractDetail.getProject() : null);
                model.addAttribute("clientUser", contractDetail != null ? contractDetail.getClientUser() : null);
                model.addAttribute("clientProfile", contractDetail != null ? contractDetail.getClientProfile() : null);
                model.addAttribute("company", contractDetail != null ? contractDetail.getCompany() : null);
                model.addAttribute("selectedContract", selectedContract);
                model.addAttribute("milestones", selectedContract.getMilestones());
            }
        }
        
        return "contract/freelancerContractList";
    }
    
    /**
     * 계약 확인 페이지 리다이렉트
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
}
