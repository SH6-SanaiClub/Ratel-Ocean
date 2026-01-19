package com.sanaiclub.domain.contract.controller;

import com.sanaiclub.domain.contract.dto.ContractReviewDTO;
import com.sanaiclub.domain.contract.service.ContractReviewService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 *  ContractReviewController - 계약 리뷰 작성 컨트롤러
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 
 * [역할]
 * 계약 완료 후 클라이언트 ↔ 프리랜서 간 상호 리뷰 작성 기능을 제공합니다.
 * 
 * [엔드포인트]
 * 1. GET  /review/client?contractId=1     → 클라이언트 리뷰 작성 화면
 * 2. POST /review/client                   → 클라이언트 리뷰 저장
 * 3. GET  /review/freelancer?contractId=1  → 프리랜서 리뷰 작성 화면
 * 4. POST /review/freelancer               → 프리랜서 리뷰 저장
 * 
 * [페이지 차이점]
 * - 클라이언트 페이지: 재계약 의사 선택 항목 있음
 * - 프리랜서 페이지: 재계약 의사 항목 없음
 * 
 * [보안]
 * 현재는 userId를 임시로 하드코딩하거나 파라미터로 받습니다.
 * 실제 운영에서는 세션에서 로그인된 userId를 가져와야 합니다.
 * 
 * [에러 처리]
 * - 잘못된 contractId → 에러 메시지 + 리다이렉트
 * - 중복 작성 시도 → 에러 메시지 + 리다이렉트
 * - 권한 없음 → 에러 메시지 + 리다이렉트
 * 
 * [향후 개선]
 * - Spring Security 통합 (세션 userId 자동 주입)
 * - RESTful API 방식으로 전환 (JSON 응답)
 * - 리뷰 수정 기능 추가 (현재는 1회만 작성 가능)
 * 
 * @author Ratel Ocean Team
 * @since 2026-01-15
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 */
@Controller
@RequestMapping("/contract")
public class ContractReviewController {
    
    private static final Logger logger = LoggerFactory.getLogger(ContractReviewController.class);
    
    @Autowired
    private ContractReviewService reviewService;
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 클라이언트 리뷰 작성
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /**
     * GET /review/client?contractId=1
     * 클라이언트 → 프리랜서 리뷰 작성 화면
     * 
     * [화면 구성]
     * 1. 계약 요약 정보 (프로젝트명, 기간, 금액)
     * 2. 별점 입력 (0.0 ~ 10.0, 0.5 단위)
     * 3. 재계약 의사 선택 (YES/NO)
     * 4. 공개 리뷰 작성 (최대 500자)
     * 
     * [중복 방지]
     * 이미 client_rating이 NULL이 아니면
     * "이미 작성 완료" 메시지 표시
     * 
     * [보안]
     * 실제 운영 시 세션 userId와 contract.clientId를 비교하여
     * 본인 소유 계약인지 확인해야 합니다.
     * 
     * @param contractId 계약 ID
     * @param model 뷰에 전달할 데이터
     * @return JSP 뷰 이름
     */
    @GetMapping("/client")
    public String showClientReviewForm(
            @RequestParam(value = "contractId", required = false) Long contractId,
            Model model) {
        
        logger.info("[GET] /contract/client - contractId={}", contractId);
        
        try {
            // contractId가 없는 경우 (테스트용) - 기본 데이터 표시
            if (contractId == null) {
                model.addAttribute("contract", new ContractReviewDTO());
                return "contract/client_review";
            }
            
            // ━━━━ 계약 정보 조회 ━━━━
            ContractReviewDTO contract = reviewService.getContractWithReview(contractId);
            
            if (contract == null) {
                model.addAttribute("errorMessage", "존재하지 않는 계약입니다.");
                return "error/404";
            }
            
            // ━━━━ 중복 작성 확인 ━━━━
            if (contract.isClientReviewSubmitted()) {
                model.addAttribute("errorMessage", "이미 리뷰를 작성하셨습니다.");
                model.addAttribute("contract", contract);
                return "contract/client_review_completed";
            }
            
            // ━━━━ 뷰에 데이터 전달 ━━━━
            model.addAttribute("contract", contract);
            
            logger.info("[리뷰 작성 화면 표시] contractId={}, projectTitle={}",
                contractId, contract.getProjectTitle());
            
            return "contract/client_review";
            
        } catch (Exception e) {
            logger.error("[리뷰 화면 로드 실패] contractId={}, error={}", contractId, e.getMessage(), e);
            model.addAttribute("errorMessage", "리뷰 작성 화면을 불러올 수 없습니다.");
            return "error/500";
        }
    }
    
    /**
     * POST /review/client
     * 클라이언트 리뷰 저장 처리
     * 
     * [전송 데이터]
     * - contractId: 계약 ID
     * - clientId: 클라이언트 ID (실제 운영 시 세션에서 가져옴)
     * - rating: 별점 (0.0 ~ 10.0)
     * - experience: 공개 리뷰 텍스트
     * - isRenewalIntended: 재계약 의사 (true/false)
     * 
     * [성공 시]
     * 리다이렉트 → 완료 페이지 또는 대시보드
     * 
     * [실패 시]
     * 에러 메시지 + 리다이렉트
     * 
     * @param contractId 계약 ID
     * @param clientId 클라이언트 ID (임시, 실제는 세션에서)
     * @param rating 별점 (0.0 ~ 10.0)
     * @param experience 공개 리뷰
     * @param isRenewalIntended 재계약 의사
     * @param redirectAttributes 리다이렉트 시 메시지 전달
     * @return 리다이렉트 URL
     */
    @PostMapping("/client")
    public String saveClientReview(
            @RequestParam("contractId") Long contractId,
            @RequestParam("clientId") Long clientId,  // TODO: 세션에서 가져오기
            @RequestParam("rating") Double rating,
            @RequestParam(value = "experience", required = false) String experience,
            @RequestParam(value = "isRenewalIntended", required = false) Boolean isRenewalIntended,
            RedirectAttributes redirectAttributes) {
        
        logger.info("[POST] /review/client - contractId={}, clientId={}, rating={}",
            contractId, clientId, rating);
        
        try {
            // ━━━━ 리뷰 저장 ━━━━
            reviewService.saveClientReview(
                contractId,
                clientId,
                rating,
                experience,
                isRenewalIntended
            );
            
            logger.info("[클라이언트 리뷰 저장 성공] contractId={}", contractId);
            
            redirectAttributes.addFlashAttribute("successMessage", 
                "리뷰가 성공적으로 작성되었습니다. 감사합니다!");
            
            // 성공 시 대시보드로 이동
            return "redirect:/dashboard";
            
        } catch (IllegalArgumentException e) {
            // 입력값 오류
            logger.warn("[리뷰 저장 실패 - 입력 오류] contractId={}, error={}", contractId, e.getMessage());
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/review/client?contractId=" + contractId;
            
        } catch (IllegalStateException e) {
            // 중복 작성 시도
            logger.warn("[리뷰 저장 실패 - 중복] contractId={}, error={}", contractId, e.getMessage());
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/dashboard";
            
        } catch (Exception e) {
            // DB 오류 등
            logger.error("[리뷰 저장 실패 - 시스템 오류] contractId={}, error={}", 
                contractId, e.getMessage(), e);
            redirectAttributes.addFlashAttribute("errorMessage", 
                "시스템 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
            return "redirect:/review/client?contractId=" + contractId;
        }
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 프리랜서 리뷰 작성
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /**
     * GET /review/freelancer?contractId=1
     * 프리랜서 → 클라이언트 리뷰 작성 화면
     * 
     * [화면 구성]
     * 1. 계약 요약 정보 (프로젝트명, 기간, 금액)
     * 2. 별점 입력 (0.0 ~ 10.0, 0.5 단위)
     * 3. 공개 리뷰 작성 (최대 500자)
     * 
     * [클라이언트와의 차이]
     * - 재계약 의사 항목 없음
     * - 프리랜서는 별점과 리뷰만 작성
     * 
     * [중복 방지]
     * 이미 freelancer_rating이 NULL이 아니면
     * "이미 작성 완료" 메시지 표시
     * 
     * [보안]
     * 실제 운영 시 세션 userId와 contract.freelancerId를 비교하여
     * 본인 소유 계약인지 확인해야 합니다.
     * 
     * @param contractId 계약 ID
     * @param model 뷰에 전달할 데이터
     * @return JSP 뷰 이름
     */
    @GetMapping("/freelancer_review")
    public String showFreelancerReviewForm(
            @RequestParam(value = "contractId", required = false) Long contractId,
            Model model) {
        
        logger.info("[GET] /contract/freelancer_review - contractId={}", contractId);
        
        try {
            // contractId가 없는 경우 (테스트용) - 기본 데이터 표시
            if (contractId == null) {
                model.addAttribute("contract", new ContractReviewDTO());
                return "contract/freelancer_review";
            }
            
            // ━━━━ 계약 정보 조회 ━━━━
            ContractReviewDTO contract = reviewService.getContractWithReview(contractId);
            
            if (contract == null) {
                model.addAttribute("errorMessage", "존재하지 않는 계약입니다.");
                return "error/404";
            }
            
            // ━━━━ 중복 작성 확인 ━━━━
            if (contract.isFreelancerReviewSubmitted()) {
                model.addAttribute("errorMessage", "이미 리뷰를 작성하셨습니다.");
                model.addAttribute("contract", contract);
                return "contract/freelancer_review_completed";
            }
            
            // ━━━━ 뷰에 데이터 전달 ━━━━
            model.addAttribute("contract", contract);
            
            logger.info("[리뷰 작성 화면 표시] contractId={}, projectTitle={}",
                contractId, contract.getProjectTitle());
            
            return "contract/freelancer_review";
            
        } catch (Exception e) {
            logger.error("[리뷰 화면 로드 실패] contractId={}, error={}", contractId, e.getMessage(), e);
            model.addAttribute("errorMessage", "리뷰 작성 화면을 불러올 수 없습니다.");
            return "error/500";
        }
    }
    
    /**
     * POST /review/freelancer
     * 프리랜서 리뷰 저장 처리
     * 
     * [전송 데이터]
     * - contractId: 계약 ID
     * - freelancerId: 프리랜서 ID (실제 운영 시 세션에서 가져옴)
     * - rating: 별점 (0.0 ~ 10.0)
     * - experience: 공개 리뷰 텍스트
     * 
     * [클라이언트와의 차이]
     * - isRenewalIntended 파라미터 없음
     * 
     * [성공 시]
     * 리다이렉트 → 완료 페이지 또는 대시보드
     * 
     * [실패 시]
     * 에러 메시지 + 리다이렉트
     * 
     * @param contractId 계약 ID
     * @param freelancerId 프리랜서 ID (임시, 실제는 세션에서)
     * @param rating 별점 (0.0 ~ 10.0)
     * @param experience 공개 리뷰
     * @param redirectAttributes 리다이렉트 시 메시지 전달
     * @return 리다이렉트 URL
     */
    @PostMapping("/freelancer_review")
    public String saveFreelancerReview(
            @RequestParam("contractId") Long contractId,
            @RequestParam("freelancerId") Long freelancerId,  // TODO: 세션에서 가져오기
            @RequestParam("rating") Double rating,
            @RequestParam(value = "experience", required = false) String experience,
            RedirectAttributes redirectAttributes) {
        
        logger.info("[POST] /review/freelancer - contractId={}, freelancerId={}, rating={}",
            contractId, freelancerId, rating);
        
        try {
            // ━━━━ 리뷰 저장 ━━━━
            reviewService.saveFreelancerReview(
                contractId,
                freelancerId,
                rating,
                experience
            );
            
            logger.info("[프리랜서 리뷰 저장 성공] contractId={}", contractId);
            
            redirectAttributes.addFlashAttribute("successMessage", 
                "리뷰가 성공적으로 작성되었습니다. 감사합니다!");
            
            // 성공 시 대시보드로 이동
            return "redirect:/dashboard";
            
        } catch (IllegalArgumentException e) {
            // 입력값 오류
            logger.warn("[리뷰 저장 실패 - 입력 오류] contractId={}, error={}", contractId, e.getMessage());
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/review/freelancer?contractId=" + contractId;
            
        } catch (IllegalStateException e) {
            // 중복 작성 시도
            logger.warn("[리뷰 저장 실패 - 중복] contractId={}, error={}", contractId, e.getMessage());
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/dashboard";
            
        } catch (Exception e) {
            // DB 오류 등
            logger.error("[리뷰 저장 실패 - 시스템 오류] contractId={}, error={}", 
                contractId, e.getMessage(), e);
            redirectAttributes.addFlashAttribute("errorMessage", 
                "시스템 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
            return "redirect:/review/freelancer?contractId=" + contractId;
        }
    }
}
