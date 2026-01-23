package com.sanaiclub.contract.controller;

import com.sanaiclub.contract.model.dto.ContractResponseDTO;
import com.sanaiclub.contract.model.dto.ContractDetailDTO;
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

/**
 * ============================================================================
 * ClientContractManagementController - 클라이언트 계약 관리 컨트롤러
 * ============================================================================
 * 
 * [역할]
 * - 클라이언트가 자신의 계약을 조회하고 관리하는 컨트롤러
 * - 클라이언트 전용 계약 관리 기능 제공
 * - 계약 최종 수락/취소 기능 제공
 * 
 * [주요 기능]
 * 1. 계약 목록 조회
 *    - GET /client/contract/management: 클라이언트의 계약 목록 조회
 *    - 상태별로 그룹화하여 표시
 *    - 계약 상세 정보 조회 (contractId 파라미터)
 * 
 * 2. 계약 상태 변경
 *    - POST /client/contract/management/finalize: 계약 최종 완료 (SIGNED → COMPLETED)
 *    - POST /client/contract/management/cancel: 계약 취소 (WAITING/SIGNED → TERMINATED)
 * 
 * [필터링]
 * - origin_contract_url이 클라이언트 ID로 시작하는 계약만 표시
 * - origin_contract_url이 null인 계약도 포함 (테스트용)
 * 
 * [경로]
 * - Base URL: /client/contract/management
 * - 클라이언트 전용 컨트롤러
 * 
 * [인증]
 * - AuthContext.getCurrentUserId()로 현재 로그인한 클라이언트 ID 확인
 * 
 * [책임 분리]
 * - Controller: HTTP 요청 처리, 뷰 선택, 여러 도메인 정보 조합
 * - Service: 비즈니스 로직 처리 (계약 상태 변경 등)
 * - Mapper: 데이터 접근 (계약 상세 정보 조회, 다른 도메인 정보 조회)
 * 
 * ============================================================================
 */
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
     * 
     * [기능]
     * - 클라이언트가 자신의 모든 계약 목록을 조회
     * - 상태별로 그룹화하여 표시
     * - 선택한 계약의 상세 정보도 함께 조회
     * 
     * [처리 흐름]
     * 1. 현재 로그인한 클라이언트 ID 확인
     * 2. 모든 계약 목록 조회
     * 3. 클라이언트의 계약만 필터링 (origin_contract_url 기준)
     * 4. 상태별로 그룹화
     * 5. 선택한 계약이 있으면 상세 정보 조회 (JOIN)
     * 6. 클라이언트 프로필 및 회사 정보 조회
     * 7. Model에 데이터 전달
     * 
     * [필터링 로직]
     * - origin_contract_url이 "contracts/{clientId}/"로 시작하는 계약만 표시
     * - origin_contract_url이 null인 계약도 포함 (테스트용)
     * 
     * [상세 정보 조회]
     * - contractId가 있으면 selectContractDetailWithJoin()으로 상세 정보 조회
     * - 프로젝트, 프리랜서, 클라이언트, 회사 정보 포함
     * 
     * [Model Attributes]
     * - contractsByStatus: 상태별 계약 목록 (Map<String, List<ContractResponseDTO>>)
     * - allContracts: 클라이언트의 모든 계약 목록
     * - contractDetail: 선택한 계약의 상세 정보 (JOIN 결과)
     * - project, clientUser, clientProfile, company: 상세 정보의 관련 데이터
     * - selectedContract: 선택한 계약 정보
     * - milestones: 선택한 계약의 마일스톤 목록
     * 
     * [인증]
     * - 로그인하지 않았으면 에러 메시지 표시
     * - 사용자 정보가 없으면 에러 메시지 표시
     * 
     * @param contractId 선택한 계약 ID (선택, 쿼리 파라미터)
     *                   - URL: /client/contract/management?contractId=123
     * @param model Spring MVC Model (뷰에 전달할 데이터)
     * @return 뷰 이름 ("contract/contractManagement")
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
     * 계약 최종 완료 처리
     * 
     * [기능]
     * - 클라이언트가 계약을 최종 수락하여 상태를 COMPLETED로 변경
     * - 결제 완료 후 호출되는 메서드
     * - ContractService.finalizeContract() 호출
     * 
     * [상태 변경]
     * - SIGNED → COMPLETED
     * 
     * [처리 흐름]
     * 1. ContractService.finalizeContract() 호출
     * 2. 계약 상태를 COMPLETED로 변경
     * 3. 관리 페이지로 리다이렉트
     * 
     * [에러 처리]
     * - 예외 발생 시 에러 메시지를 Model에 추가하고 관리 페이지 반환
     * 
     * [주의사항]
     * - SIGNED 상태의 계약만 완료 처리 가능
     * - 결제 완료 후에만 호출되어야 함
     * - COMPLETED 상태로 변경되면 더 이상 수정 불가
     * 
     * @param contractId 완료 처리할 계약의 ID (필수)
     * @param model Spring MVC Model (에러 메시지 전달용)
     * @return 리다이렉트 URL 또는 뷰 이름
     *         - 성공: "redirect:/client/contract/management?contractId={contractId}"
     *         - 실패: "contract/contractManagement" (에러 메시지 포함)
     */
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

    /**
     * 계약 취소 처리
     * 
     * [기능]
     * - 클라이언트가 계약을 취소하여 상태를 TERMINATED로 변경
     * - 취소 사유를 cancel_reason에 저장
     * - ContractService.cancelContract() 호출
     * 
     * [상태 변경]
     * - WAITING → TERMINATED (계약 대기 중 취소)
     * - SIGNED → TERMINATED (작업 진행 중 취소)
     * 
     * [처리 흐름]
     * 1. ContractService.cancelContract() 호출 (취소 사유 포함)
     * 2. 계약 상태를 TERMINATED로 변경
     * 3. 관리 페이지로 리다이렉트
     * 
     * [에러 처리]
     * - 예외 발생 시 에러 메시지를 Model에 추가하고 관리 페이지 반환
     * 
     * [주의사항]
     * - reason은 필수 (사용자가 취소 이유를 입력해야 함)
     * - WAITING 또는 SIGNED 상태의 계약만 취소 가능
     * - TERMINATED 상태로 변경되면 복구 불가
     * - 취소 사유는 향후 통계 및 분석에 사용될 수 있음
     * 
     * @param contractId 취소할 계약의 ID (필수)
     * @param reason 취소 사유 (필수, 사용자가 입력한 취소 이유)
     * @param model Spring MVC Model (에러 메시지 전달용)
     * @return 리다이렉트 URL 또는 뷰 이름
     *         - 성공: "redirect:/client/contract/management?contractId={contractId}"
     *         - 실패: "contract/contractManagement" (에러 메시지 포함)
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
