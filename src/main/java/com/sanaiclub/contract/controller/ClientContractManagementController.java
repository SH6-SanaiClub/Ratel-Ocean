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
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * ============================================================================
 * ClientContractManagementController - 클라이언트 계약 관리 컨트롤러
 * ============================================================================
 * 
 * [역할]
 * 클라이언트가 자신이 발주한 모든 계약을 조회하고 관리하는 컨트롤러입니다.
 * 복잡한 분류 로직을 통해 계약을 상태별로 분류하며, 일시지급과 마일스톤 방식을
 * 구분하여 사용자 친화적인 UI를 제공합니다. 특히 DB 스키마 변경 없이 cancel_reason
 * 컬럼을 재활용하여 일시지급 지급 요청 상태를 관리하는 로직이 포함되어 있습니다.
 * 
 * [연관 파일]
 * 
 * Service 계층:
 * - ContractService: 계약 비즈니스 로직 (결제, 지급 수락/거부 등)
 * - ContractService.getAllContracts(): 모든 계약 목록 조회 (마일스톤 집계 포함)
 * - ContractService.approvePayment(): 지급 수락 처리
 * - ContractService.rejectPayment(): 지급 거부 처리
 * - ContractService.finalizeContract(): 계약 결제 완료 처리
 * - ContractService.completeContract(): 계약 정산 완료 처리
 * - ContractService.cancelContract(): 계약 취소 처리
 * 
 * DAO 계층:
 * - ContractMapper: 계약 데이터 접근 (JOIN 쿼리 포함)
 * - ContractMapper.selectContractDetailWithJoin(): 계약 상세 정보 조회 (프로젝트, 프리랜서, 클라이언트 정보 포함)
 * - UserMapper: 사용자 정보 조회
 * - ClientProfileMapper: 클라이언트 프로필 정보 조회
 * - CompanyMapper: 회사 정보 조회
 * 
 * View 계층:
 * - contractManagement.jsp: 클라이언트 계약 관리 페이지 (메인 뷰)
 * - includes/statusTitlePaid.jsp: PAID 상태 집계 및 제목 표시 (인클루드)
 * - includes/statusTitleSettlementPending.jsp: SETTLEMENT_PENDING 상태 집계 (인클루드)
 * 
 * Model 계층:
 * - ContractResponseDTO: 계약 응답 DTO (마일스톤 집계 포함)
 * - ContractDetailDTO: 계약 상세 정보 DTO (JOIN 결과)
 * - UserVO, ClientProfileVO, CompanyVO: 사용자 및 회사 정보
 * 
 * [주요 기능]
 * 
 * 1. 계약 목록 조회 및 분류
 *    - GET /client/contract/management: 클라이언트의 계약 목록 조회
 *    - 상태별로 그룹화하여 표시 (WAITING, SIGNED, PAID, SETTLEMENT_PENDING, COMPLETED_HISTORY, TERMINATED)
 *    - 복잡한 분류 로직 적용 (PAID와 COMPLETED 상태를 세분화)
 * 
 * 2. 계약 상태 변경
 *    - POST /client/contract/finalize: 계약 결제 완료 (SIGNED → PAID)
 *    - POST /client/contract/complete: 계약 정산 완료 (PAID → COMPLETED)
 *    - POST /client/contract/cancel: 계약 취소 (→ TERMINATED)
 * 
 * 3. 지급 관리 (에스크로 시스템)
 *    - POST /client/contract/approve-payment: 지급 수락
 *      * 마일스톤: REQUESTED → DEPOSITED
 *      * 일시지급: cancel_reason "[지급요청]" → null, 계약 상태 PAID → COMPLETED
 *    - POST /client/contract/reject-payment: 지급 거부
 *      * 마일스톤: REQUESTED → WAITING (재요청 가능)
 *      * 일시지급: cancel_reason "[지급요청]" → null (재요청 가능)
 * 
 * [복잡한 분류 로직 상세 설명]
 * 
 * 계약 목록을 조회할 때 단순히 상태별로 그룹화하는 것이 아니라, 사용자 친화적인
 * 분류를 위해 복잡한 로직을 적용합니다. 특히 PAID와 COMPLETED 상태를 세분화하여
 * 실제 업무 흐름에 맞게 표시합니다.
 * 
 * ┌─────────────────────────────────────────────────────────────────────────┐
 * │ 1단계: 기본 상태별 그룹화                                               │
 * │ - WAITING, SIGNED, PAID, COMPLETED, TERMINATED                         │
 * └─────────────────────────────────────────────────────────────────────────┘
 * 
 * ┌─────────────────────────────────────────────────────────────────────────┐
 * │ 2단계: PAID 상태 분리                                                  │
 * │                                                                         │
 * │ PAID 상태의 계약을 두 가지로 분류:                                     │
 * │                                                                         │
 * │ a) "최종 승인 대기" (PAID 키 유지)                                     │
 * │    - 마일스톤 방식 계약만 해당                                         │
 * │    - 조건: totalMilestones > 0 && paymentMethod != FIXED/FULL          │
 * │    - 사이드바 표시: "✅ 최종 승인 대기 (지급 요청 대기: 2건)"          │
 * │    - 의미: 마일스톤별로 지급 요청을 기다리는 상태                       │
 * │                                                                         │
 * │ b) "정산 대기" (SETTLEMENT_PENDING으로 이동)                          │
 * │    - 일시지급 계약만 해당                                              │
 * │    - 조건: totalMilestones == 0 && (FIXED || FULL || null)            │
 * │    - 요청 전/후 모두 포함:                                             │
 * │      * 요청 전: cancel_reason = null                                   │
 * │      * 요청 후: cancel_reason = "[지급요청]"                           │
 * │    - 사이드바 표시: "🎉 정산 대기 (일시지급 요청 대기: 1건)"           │
 * │    - 의미: 일시지급 지급 요청을 기다리는 상태                           │
 * └─────────────────────────────────────────────────────────────────────────┘
 * 
 * ┌─────────────────────────────────────────────────────────────────────────┐
 * │ 3단계: COMPLETED 상태 분리                                             │
 * │                                                                         │
 * │ COMPLETED 상태의 계약을 두 가지로 분류:                                │
 * │                                                                         │
 * │ a) "정산 대기" (SETTLEMENT_PENDING)                                    │
 * │    - 아직 완전히 끝나지 않은 계약                                      │
 * │    - 마일스톤 계약: 일부 마일스톤만 PAID                               │
 * │      * 조건: paidMilestones < totalMilestones                          │
 * │      * 예: 3개 마일스톤 중 2개만 완료                                  │
 * │    - 사이드바 표시: "🎉 정산 대기 (정산 진행 중: 1건)"                 │
 * │    - 의미: 일부 마일스톤이 완료되었지만 아직 남은 마일스톤이 있음       │
 * │                                                                         │
 * │ b) "완료 내역" (COMPLETED_HISTORY)                                     │
 * │    - 완전히 끝난 계약                                                  │
 * │    - 마일스톤 계약: 모든 마일스톤이 PAID                               │
 * │      * 조건: paidMilestones == totalMilestones                         │
 * │    - 일시지급 계약: COMPLETED 상태이면 완료 내역                       │
 * │      * 일시지급 수락 시 COMPLETED로 변경되므로                         │
 * │    - 사이드바 표시: "✅ 완료 내역 (3건)"                               │
 * │    - 의미: 모든 지급이 완료되어 계약이 성공적으로 종료됨                │
 * └─────────────────────────────────────────────────────────────────────────┘
 * 
 * ┌─────────────────────────────────────────────────────────────────────────┐
 * │ 4단계: SETTLEMENT_PENDING 통합                                         │
 * │                                                                         │
 * │ PAID에서 온 정산 대기 계약들과 COMPLETED에서 온 정산 대기 계약들을      │
 * │ 하나의 SETTLEMENT_PENDING 그룹으로 통합:                              │
 * │                                                                         │
 * │ - 일시지급 계약 (PAID 상태, cancel_reason = null 또는 "[지급요청]")    │
 * │ - 마일스톤 계약 (COMPLETED 상태, 일부 마일스톤만 완료)                 │
 * └─────────────────────────────────────────────────────────────────────────┘
 * 
 * [일시지급 계약 처리 방식 - cancel_reason 활용]
 * 
 * DB 스키마 변경 없이 일시지급 지급 요청 상태를 관리하기 위해 cancel_reason 컬럼을
 * 재활용합니다. 이는 기존 컬럼을 활용하여 새로운 기능을 구현하는 효율적인 방법입니다.
 * 
 * ┌─────────────────────────────────────────────────────────────────────────┐
 * │ cancel_reason 값에 따른 상태 및 UI 표시                                  │
 * └─────────────────────────────────────────────────────────────────────────┘
 * 
 * 1. cancel_reason = null (아직 지급 요청하지 않은 상태)
 *    - 사이드바: "🎉 정산 대기 (일시지급: 1건)"
 *    - 상세 페이지: "💰 일시지급 요청" 버튼 표시
 *    - 의미: 프리랜서가 작업을 완료했지만 아직 지급 요청하지 않음
 *    - 프리랜서 액션: requestPayment() 호출 가능
 * 
 * 2. cancel_reason = "[지급요청]" (프리랜서가 지급 요청한 상태)
 *    - 사이드바: "🎉 정산 대기 (일시지급 요청 대기: 1건)"
 *    - 상세 페이지: "📤 클라이언트의 지급 수락을 기다리는 중입니다." 메시지
 *    - 의미: 프리랜서가 지급 요청했고, 클라이언트의 수락을 기다리는 중
 *    - 클라이언트 액션: approvePayment() 또는 rejectPayment() 호출 가능
 * 
 * 3. 일시지급 수락 후 (COMPLETED 상태, cancel_reason = null)
 *    - 사이드바: "✅ 완료 내역"
 *    - 상세 페이지: "✅ 일시지급이 완료되었습니다." 메시지
 *    - 의미: 클라이언트가 지급을 수락하여 계약이 완료됨
 *    - 상태 변경: approvePayment()에서 PAID → COMPLETED, cancel_reason → null
 * 
 * 4. 일시지급 거부 후 (PAID 상태, cancel_reason = null)
 *    - 사이드바: "🎉 정산 대기 (일시지급: 1건)" (다시 1번 상태로 복귀)
 *    - 상세 페이지: "💰 일시지급 요청" 버튼 표시 (재요청 가능)
 *    - 의미: 클라이언트가 지급을 거부하여 프리랜서가 재요청할 수 있는 상태
 *    - 상태 변경: rejectPayment()에서 cancel_reason "[지급요청]" → null
 * 
 * [필터링 로직]
 * 
 * origin_contract_url 형식: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
 * 
 * - origin_contract_url이 "contracts/{clientId}/"로 시작하는 계약만 표시
 * - origin_contract_url이 null이거나 비어있으면 제외
 * - 클라이언트 시점: 상대방은 프리랜서 (counterpartName = freelancerName)
 * 
 * [상세 정보 조회]
 * 
 * - contractId가 있으면 selectContractDetailWithJoin()으로 상세 정보 조회
 * - 프로젝트, 프리랜서, 클라이언트, 회사 정보 포함 (LEFT JOIN)
 * - JOIN 실패 시에도 계약 기본 정보는 표시 가능 (에러 처리)
 * 
 * [마일스톤 집계 정보 활용]
 * 
 * ContractResponseDTO에 포함된 마일스톤 집계 정보를 활용하여 UI에 표시:
 * 
 * - totalMilestones: 전체 마일스톤 개수
 * - paidMilestones: 지급 완료된 마일스톤 개수 (status = 'PAID')
 * - requestedMilestones: 지급 요청된 마일스톤 개수 (status = 'REQUESTED')
 * - depositedMilestones: 입금 완료된 마일스톤 개수 (status = 'DEPOSITED')
 * - waitingMilestones: 대기 중인 마일스톤 개수 (status = 'WAITING')
 * 
 * 이 정보는 ContractMapper.selectAllContractsWithDetails()에서 LEFT JOIN 서브쿼리로
 * 계산되며, UI에서 "지급 요청 대기: 2건" 같은 메시지를 표시하는 데 사용됩니다.
 * 
 * [에러 처리]
 * 
 * - 로그인하지 않았으면 에러 메시지 표시
 * - 사용자 정보가 없으면 에러 메시지 표시
 * - 계약 상세 정보 조회 실패 시에도 기본 정보는 표시 가능
 * - 지급 수락/거부 실패 시 리다이렉트하여 에러 메시지 표시
 * 
 * [경로]
 * - Base URL: /client/contract/management
 * - 클라이언트 전용 컨트롤러
 * 
 * [인증]
 * - AuthContext.getCurrentUserId()로 현재 로그인한 클라이언트 ID 확인
 * - origin_contract_url에서 clientId 추출하여 권한 검증
 * 
 * [책임 분리]
 * - Controller: HTTP 요청 처리, 뷰 선택, 필터링 및 분류
 * - Service: 비즈니스 로직 처리 (계약 상태 변경, 지급 수락/거부 등)
 * - Mapper: 데이터 접근 (계약 상세 정보 조회, JOIN)
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
     * ============================================================================
     * 계약 관리 페이지 조회
     * ============================================================================
     * 
     * [기능]
     * 클라이언트가 자신의 모든 계약을 조회하고, 상태별로 분류하여 표시하는 메서드입니다.
     * 복잡한 분류 로직을 통해 사용자 친화적인 UI를 제공합니다.
     * 
     * [연관 파일]
     * - ContractService.getAllContracts(): 모든 계약 목록 조회 (마일스톤 집계 포함)
     * - ContractMapper.selectContractDetailWithJoin(): 계약 상세 정보 조회 (JOIN)
     * - contractManagement.jsp: 계약 목록 및 상세 정보를 표시하는 뷰
     * - includes/statusTitlePaid.jsp: PAID 상태 집계 및 제목 표시 (인클루드)
     * - includes/statusTitleSettlementPending.jsp: SETTLEMENT_PENDING 상태 집계 (인클루드)
     * 
     * [처리 흐름]
     * 1. 현재 로그인한 클라이언트 ID 확인 (AuthContext)
     * 2. 모든 계약 목록 조회 (ContractService.getAllContracts())
     * 3. 클라이언트의 계약만 필터링 (origin_contract_url 기준)
     * 4. 상태별로 그룹화 (기본 상태: WAITING, SIGNED, PAID, COMPLETED, TERMINATED)
     * 5. 복잡한 분류 로직 적용:
     *    a) PAID 상태를 "최종 승인 대기"와 "정산 대기"로 분리
     *    b) COMPLETED 상태를 "정산 대기"와 "완료 내역"으로 분리
     * 6. 선택한 계약이 있으면 상세 정보 조회 (JOIN)
     * 7. 클라이언트 프로필 및 회사 정보 조회
     * 8. Model에 데이터 전달
     * 
     * [복잡한 분류 로직 상세 설명]
     * 
     * 1. PAID 상태 분리
     *    PAID 상태의 계약을 두 가지로 분류합니다:
     *    
     *    a) "최종 승인 대기" (PAID 키 유지)
     *       - 마일스톤 방식 계약만 해당
     *       - 마일스톤이 있고, 일시지급이 아닌 경우
     *       - 사이드바에 "✅ 최종 승인 대기"로 표시
     *       - 예: "✅ 최종 승인 대기 (지급 요청 대기: 2건)"
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
     *   → 상세 페이지: "⏳ 프리랜서의 지급 요청을 기다리는 중입니다."
     * 
     * - cancel_reason = "[지급요청]": 프리랜서가 지급 요청한 상태
     *   → 사이드바: "🎉 정산 대기 (일시지급 요청 대기: 1건)"
     *   → 상세 페이지: "지급 수락" / "지급 거부" 버튼 표시
     * 
     * - 일시지급 수락 후: COMPLETED 상태로 변경, cancel_reason = null
     *   → 사이드바: "✅ 완료 내역"
     *   → 상세 페이지: "✅ 일시지급이 완료되었습니다."
     * 
     * [필터링 로직]
     * - origin_contract_url이 "contracts/{clientId}/"로 시작하는 계약만 표시
     * - origin_contract_url이 null이거나 비어있으면 제외
     * - 클라이언트 시점: 상대방은 프리랜서 (counterpartName = freelancerName)
     * 
     * [상세 정보 조회]
     * - contractId가 있으면 selectContractDetailWithJoin()으로 상세 정보 조회
     * - 프로젝트, 프리랜서, 클라이언트, 회사 정보 포함 (LEFT JOIN)
     * - JOIN 실패 시에도 계약 기본 정보는 표시 가능 (에러 처리)
     * 
     * [Model Attributes]
     * - contractsByStatus: 상태별 계약 목록 (Map<String, List<ContractResponseDTO>>)
     *   * 키: "WAITING", "SIGNED", "PAID", "SETTLEMENT_PENDING", "COMPLETED_HISTORY", "TERMINATED"
     * - allContracts: 클라이언트의 모든 계약 목록
     * - contractDetail: 선택한 계약의 상세 정보 (JOIN 결과)
     * - project, clientUser, clientProfile, company: 상세 정보의 관련 데이터
     * - selectedContract: 선택한 계약 정보 (ContractResponseDTO)
     * - milestones: 선택한 계약의 마일스톤 목록
     * 
     * [에러 처리]
     * - 로그인하지 않았으면 에러 메시지 표시
     * - 사용자 정보가 없으면 에러 메시지 표시
     * - 계약 상세 정보 조회 실패 시에도 기본 정보는 표시 가능
     * 
     * @param contractId 선택한 계약 ID (선택, 쿼리 파라미터)
     *                   - URL: /client/contract/management?contractId=123
     * @param timestamp 캐시 방지용 타임스탬프 (선택, 현재 미사용)
     * @param model Spring MVC Model (뷰에 전달할 데이터)
     * @return 뷰 이름 ("contract/contractManagement")
     * 
     * ============================================================================
     */
    @GetMapping
    public String contractManagement(
            @RequestParam(value = "contractId", required = false) Integer contractId,
            @RequestParam(value = "_", required = false) String timestamp,
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
        // 모든 계약 조회
        List<ContractResponseDTO> allContractsList = contractService.getAllContracts();
        
        // 클라이언트의 계약만 필터링 (origin_contract_url이 클라이언트 ID로 시작하는 경우만)
        List<ContractResponseDTO> allContracts = allContractsList.stream()
            .filter(contract -> {
                String originUrl = contract.getOriginContractUrl();
                // origin_contract_url이 null이거나 비어있으면 제외
                if (originUrl == null || originUrl.isEmpty()) {
                    return false;
                }
                // origin_contract_url이 "contracts/{clientId}/"로 시작하는 경우만 포함
                return originUrl.startsWith("contracts/" + userId + "/");
            })
            .map(contract -> {
                // 클라이언트 시점: 상대방은 프리랜서
                contract.setCounterpartName(contract.getFreelancerName());
                return contract;
            })
            .collect(Collectors.toList());

        // 상태별로 그룹화
        Map<String, List<ContractResponseDTO>> contractsByStatus = allContracts.stream()
                .collect(Collectors.groupingBy(
                    contract -> contract.getContractStatus() != null ? contract.getContractStatus() : "UNKNOWN"
                ));
        
        // PAID 상태를 "최종 승인 대기"와 "정산 대기"로 분리
        // 일시지급 계약은 항상 "정산 대기"로 분류 (요청 전/후 모두)
        List<ContractResponseDTO> paidContracts = contractsByStatus.remove("PAID");
        List<ContractResponseDTO> settlementPendingFromPaid = new java.util.ArrayList<>(); // 임시 저장
        if (paidContracts != null && !paidContracts.isEmpty()) {
            List<ContractResponseDTO> finalApprovalPending = new java.util.ArrayList<>();
            
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
                    // 마일스톤 계약은 "최종 승인 대기"로 분류
                    finalApprovalPending.add(contract);
                }
            }
            
            // 최종 승인 대기만 먼저 추가
            if (!finalApprovalPending.isEmpty()) {
                contractsByStatus.put("PAID", finalApprovalPending);
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
            try {
                ContractResponseDTO selectedContract = contractService.getContractById(contractId);
                if (selectedContract != null) {
                    // 선택한 계약이 현재 클라이언트의 계약인지 확인
                    String originUrl = selectedContract.getOriginContractUrl();
                    boolean isClientContract = false;
                    if (originUrl != null && !originUrl.isEmpty()) {
                        isClientContract = originUrl.startsWith("contracts/" + userId + "/");
                    }
                    
                    if (isClientContract) {
                        // contract_id를 통해 JOIN하여 상세 정보 조회
                        ContractDetailDTO contractDetail = null;
                        try {
                            contractDetail = contractMapper.selectContractDetailWithJoin(contractId);
                        } catch (Exception e) {
                            log.warn("계약 상세 정보 조회 실패 (contractId: {}): {}", contractId, e.getMessage());
                            // contractDetail이 null이어도 계약 기본 정보는 표시 가능
                        }
                        
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
                    } else {
                        model.addAttribute("errorMessage", "해당 계약에 접근할 권한이 없습니다.");
                    }
                } else {
                    model.addAttribute("errorMessage", "계약을 찾을 수 없습니다. (contractId: " + contractId + ")");
                }
            } catch (Exception e) {
                log.error("계약 조회 중 오류 발생 (contractId: {}): {}", contractId, e.getMessage(), e);
                model.addAttribute("errorMessage", "계약 정보를 조회하는 중 오류가 발생했습니다: " + e.getMessage());
            }
        }

        return "contract/contractManagement";
    }

    /**
     * 계약 결제 완료 처리 (SIGNED → PAID)
     */
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
    
    /**
     * 계약 정산 완료 처리 (PAID → COMPLETED)
     */
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

    /**
     * 계약 취소 처리 (→ TERMINATED)
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
    
    /**
     * 지급 수락 처리
     */
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
    
    /**
     * 지급 거부 처리
     */
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
