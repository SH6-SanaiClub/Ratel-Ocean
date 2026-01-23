package com.sanaiclub.contract.controller;

import com.sanaiclub.contract.model.dto.ContractResponseDTO;
import com.sanaiclub.contract.model.dto.ContractDetailDTO;
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

/**
 * ============================================================================
 * FreelancerContractController - 프리랜서 계약 관리 컨트롤러
 * ============================================================================
 * 
 * [역할]
 * - 프리랜서가 자신과 관련된 계약을 조회하고 관리하는 컨트롤러
 * - 프리랜서 전용 계약 관리 기능 제공
 * - 계약 수락/거절 기능 제공
 * 
 * [주요 기능]
 * 1. 계약 목록 조회
 *    - GET /freelancer/contract/list: 프리랜서의 계약 목록 조회
 *    - 상태별로 그룹화하여 표시
 *    - 계약 상세 정보 조회 (contractId 파라미터)
 * 
 * 2. 계약 상태 변경
 *    - POST /freelancer/contract/accept: 계약 수락 (WAITING → SIGNED)
 *    - POST /freelancer/contract/reject: 계약 거절 (WAITING → TERMINATED)
 * 
 * 3. PDF 파일 제공
 *    - GET /freelancer/contract/file/**: PDF 파일 다운로드/미리보기
 * 
 * [경로]
 * - Base URL: /freelancer/contract
 * - 프리랜서 전용 컨트롤러
 * 
 * [인증]
 * - AuthContext.getCurrentUserId()로 현재 로그인한 프리랜서 ID 확인
 * - 향후 프리랜서 필터링 로직 추가 예정
 * 
 * [책임 분리]
 * - Controller: HTTP 요청 처리, 뷰 선택
 * - Service: 비즈니스 로직 처리 (계약 상태 변경 등)
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
     * 프리랜서 계약 목록 조회
     * 
     * [기능]
     * - 프리랜서가 자신과 관련된 모든 계약 목록을 조회
     * - 상태별로 그룹화하여 표시
     * - 선택한 계약의 상세 정보도 함께 조회
     * 
     * [처리 흐름]
     * 1. 모든 계약 목록 조회 (현재는 모든 계약 표시)
     * 2. 상태별로 그룹화 (WAITING, SIGNED, TERMINATED, COMPLETED)
     * 3. 선택한 계약이 있으면 상세 정보 조회 (JOIN)
     * 4. Model에 데이터 전달
     * 
     * [필터링]
     * - 현재는 모든 계약을 표시
     * - 향후 프리랜서 필터링 로직 추가 예정
     *   * origin_contract_url에서 freelancerId 추출
     *   * 해당 프로젝트에 프리랜서가 지원했는지 확인
     * 
     * [상세 정보 조회]
     * - contractId가 있으면 selectContractDetailWithJoin()으로 상세 정보 조회
     * - 프로젝트, 클라이언트, 회사 정보 포함
     * 
     * [Model Attributes]
     * - contractsByStatus: 상태별 계약 목록 (Map<String, List<ContractResponseDTO>>)
     * - allContracts: 모든 계약 목록
     * - contractDetail: 선택한 계약의 상세 정보 (JOIN 결과)
     * - project, clientUser, clientProfile, company: 상세 정보의 관련 데이터
     * - selectedContract: 선택한 계약 정보
     * - milestones: 선택한 계약의 마일스톤 목록
     * 
     * @param contractId 선택한 계약 ID (선택, 쿼리 파라미터)
     *                   - URL: /freelancer/contract/list?contractId=123
     * @param model Spring MVC Model (뷰에 전달할 데이터)
     * @return 뷰 이름 ("contract/freelancerContractList")
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
        Map<String, List<ContractResponseDTO>> contractsByStatus = allContracts.stream()
                .collect(Collectors.groupingBy(
                    contract -> contract.getContractStatus() != null ? contract.getContractStatus() : "UNKNOWN"
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
}
