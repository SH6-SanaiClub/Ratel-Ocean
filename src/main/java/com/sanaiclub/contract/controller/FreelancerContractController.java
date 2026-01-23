package com.sanaiclub.contract.controller;

import com.sanaiclub.contract.model.dto.ContractResponseDTO;
import com.sanaiclub.contract.model.vo.ContractProjectVO;
import com.sanaiclub.contract.model.vo.ContractClientVO;
import com.sanaiclub.contract.service.ContractService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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

@Controller
@RequestMapping("/freelancer/contract")
public class FreelancerContractController {

    private static final Logger logger = LoggerFactory.getLogger(FreelancerContractController.class);

    private final ContractService contractService;

    /**
     * 생성자 주입
     */
    public FreelancerContractController(ContractService contractService) {
        this.contractService = contractService;
    }

    /**
     * 프리랜서용 PDF 파일 제공
     * /freelancer/contract/file/** 경로로 접근
     * ContractController의 servePdf와 동일한 로직 사용
     */
    @GetMapping("/file/**")
    public ResponseEntity<org.springframework.core.io.Resource> servePdf(
            javax.servlet.http.HttpServletRequest request) {
        try {
            String baseDir = System.getProperty("user.dir");
            String requestURI = request.getRequestURI();
            
            // /freelancer/contract/file/ 이후의 경로 추출
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
            
            // 경로 정규화: 백슬래시를 슬래시로 변환
            String normalizedPath = decodedPath.toString().replace("\\", "/");
            
            // 보안 검증: contracts/로 시작하는지 확인
            if (!normalizedPath.startsWith("contracts/")) {
                return ResponseEntity.status(org.springframework.http.HttpStatus.BAD_REQUEST).build();
            }
            
            // 파일 경로 구성
            java.io.File pdfFile = new java.io.File(baseDir, normalizedPath.replace("/", java.io.File.separator));
            
            // 보안 검증: baseDir 밖으로 나가는 경로 차단
            String canonicalBase = new java.io.File(baseDir).getCanonicalPath();
            String canonicalFile = pdfFile.getCanonicalPath();
            if (!canonicalFile.startsWith(canonicalBase)) {
                return ResponseEntity.status(org.springframework.http.HttpStatus.FORBIDDEN).build();
            }
            
            if (!pdfFile.exists() || !pdfFile.isFile()) {
                return ResponseEntity.status(org.springframework.http.HttpStatus.NOT_FOUND).build();
            }
            
            org.springframework.core.io.Resource resource = 
                new org.springframework.core.io.FileSystemResource(pdfFile);
            
            return ResponseEntity.ok()
                .contentType(org.springframework.http.MediaType.APPLICATION_PDF)
                .header(org.springframework.http.HttpHeaders.CONTENT_DISPOSITION, 
                    "inline; filename=\"" + pdfFile.getName() + "\"")
                .body(resource);
                
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

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
                ContractClientVO client = null;
                
                if (projectId != null) {
                    project = contractService.getProjectById(projectId);
                    if (project != null) {
                        client = contractService.getClientById(project.getClientId());
                    }
                }
        
                model.addAttribute("project", project);
                model.addAttribute("client", client);
                model.addAttribute("selectedContract", selectedContract);
                model.addAttribute("milestones", selectedContract.getMilestones());
            }
        }
        
        return "contract/freelancerContractList";
    }
    
    @GetMapping("/check")
    public String freelancerContractCheck(
            @RequestParam("contractId") Integer contractId,
            @RequestParam(value = "projectId", required = false) Integer projectId) {
        // 확인 페이지를 목록 페이지로 리다이렉트
        return "redirect:/freelancer/contract/list?contractId=" + contractId;
    }

    @PostMapping("/accept")
    public String acceptContract(
            @RequestParam("contractId") Integer contractId,
            @RequestParam(value = "projectId", required = false) Integer projectId) {
        Integer loginUserId = com.sanaiclub.common.util.AuthContext.getCurrentUserId();
        logger.info("계약 수락 요청: contractId={}, freelancerId={}", contractId, loginUserId);
        try {
            contractService.acceptContract(contractId, loginUserId);
            // 목록 페이지로 리다이렉트
            return "redirect:/freelancer/contract/list?contractId=" + contractId;
        } catch (Exception e) {
            logger.error("계약 수락 실패: contractId={}, error={}", contractId, e.getMessage(), e);
            // 오류 발생 시에도 목록 페이지로 리다이렉트
            return "redirect:/freelancer/contract/list?contractId=" + contractId;
        }
    }
    
    @PostMapping("/reject")
    public String rejectContract(
            @RequestParam("contractId") Integer contractId,
            @RequestParam("reason") String reason,
            @RequestParam(value = "projectId", required = false) Integer projectId) {
        Integer loginUserId = com.sanaiclub.common.util.AuthContext.getCurrentUserId();
        logger.info("계약 거절 요청: contractId={}, freelancerId={}, reason={}", contractId, loginUserId, reason);
        try {
            contractService.rejectContract(contractId, loginUserId, reason);
            // 목록 페이지로 리다이렉트
            return "redirect:/freelancer/contract/list?contractId=" + contractId;
        } catch (Exception e) {
            logger.error("계약 거절 실패: contractId={}, error={}", contractId, e.getMessage(), e);
            // 오류 발생 시에도 목록 페이지로 리다이렉트
            return "redirect:/freelancer/contract/list?contractId=" + contractId;
        }
    }
}
