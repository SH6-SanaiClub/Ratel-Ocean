package com.sanaiclub.contract.controller;

import com.sanaiclub.contract.model.dto.ContractAutoFillDTO;
import com.sanaiclub.contract.service.ContractAutoFillService;
import com.sanaiclub.contract.service.PDFProcessingService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;

/**
 * 계약서 자동 채우기 컨트롤러 (레거시). 현재 사용되지 않음.
 * 
 * <h3>보존 의도:</h3>
 * <ul>
 *   <li>향후 다른 경로(/contract/autofill)로 계약서 자동 채우기 기능이 필요할 경우를 대비</li>
 *   <li>기존 구현 로직을 참고용으로 보존 (PDF 처리, 텍스트 추출, AI 초안 생성 플로우)</li>
 *   <li>실제 기능은 {@link ContractFormController#contractCheck}에서 처리됨</li>
 * </ul>
 * 
 * <h3>현재 상태:</h3>
 * <ul>
 *   <li>엔드포인트: POST /contract/autofill (호출되지 않음)</li>
 *   <li>실제 사용 경로: POST /client/contract/contractCheck</li>
 *   <li>메서드 내부 로직은 실행되지 않고 에러 메시지만 반환</li>
 * </ul>
 * 
 * @deprecated 현재 사용되지 않음. 실제 기능은 ContractFormController에서 처리됨.
 */
@Deprecated
@Controller
@RequestMapping("/contract")
public class ContractAutoFillController {

    private final PDFProcessingService pdfProcessingService;
    private final ContractAutoFillService contractAutoFillService;

    public ContractAutoFillController(
            PDFProcessingService pdfProcessingService,
            ContractAutoFillService contractAutoFillService
    ) {
        this.pdfProcessingService = pdfProcessingService;
        this.contractAutoFillService = contractAutoFillService;
    }

    /**
     * 계약서 자동 채우기 (레거시). 현재 사용되지 않음.
     * 
     * <h3>보존 의도:</h3>
     * <ul>
     *   <li>PDF 업로드 → 텍스트 추출 → AI 초안 생성 플로우 참고용</li>
     *   <li>향후 다른 경로로 동일 기능이 필요할 경우 구현 참고</li>
     * </ul>
     * 
     * @deprecated 실제 기능은 ContractFormController의 contractCheck 메서드에서 처리됨.
     */
    @Deprecated
    @PostMapping("/autofill")
    public String autoFillContract(
            @RequestParam("contractPdf") MultipartFile contractPdf,
            @RequestParam(value = "manualText", required = false) String manualText,
            @RequestParam("projectId") Long projectId,
            @RequestParam("freelancerId") Long freelancerId,
            Model model
    ) {
        // 레거시 엔드포인트: 실제 기능은 ContractFormController에서 처리됨
        model.addAttribute("errorMessage", 
            "이 기능은 ContractFormController의 /client/contract/contractCheck에서 처리됩니다.");
        return "contract/contractForm";

        /* ============================================
         * 아래 코드는 참고용으로 주석 처리됨
         * 향후 다른 경로로 동일 기능이 필요할 경우 구현 참고
         * 
         * 구현 플로우:
         * 1. PDF 파일 업로드 검증
         * 2. PDF 임시 저장 (File.createTempFile)
         * 3. PDF 텍스트 추출 (PDFProcessingService.extractText)
         * 4. AI 계약서 초안 생성 (ContractAutoFillService.generateDraft)
         *    - 주의: project/user 도메인 Service를 주입받아 정보 조회 필요
         *    - ContractAutoFillService는 contract 도메인만 담당
         * 5. 생성된 초안을 Model에 담아 뷰로 전달
         * 
         * 실제 구현 예시:
         * 
         * // 0. 업로드 파일 검증
         * if (contractPdf == null || contractPdf.isEmpty()) {
         *     model.addAttribute("errorMessage", "PDF 파일을 업로드해주세요.");
         *     return "contract/contractForm";
         * }
         * 
         * File savedPdf = null;
         * try {
         *     // 1. PDF 임시 저장
         *     savedPdf = File.createTempFile("contract_", ".pdf");
         *     savedPdf.deleteOnExit();
         *     contractPdf.transferTo(savedPdf);
         * 
         *     // 2. PDF 텍스트 추출
         *     String pdfText = pdfProcessingService.extractText(savedPdf);
         *     int pageCount = pdfProcessingService.getPageCount(savedPdf);
         * 
         *     // 3. AI 계약서 초안 생성
         *     // TODO: project/user 도메인 Service를 주입받아 프로젝트/프리랜서 정보 조회
         *     // ProjectsVO project = projectService.getProjectById(projectId);
         *     // UserVO freelancerUser = userService.getUserById(freelancerId);
         *     // FreelancerProfileVO freelancerProfile = freelancerService.getProfile(freelancerId);
         *     
         *     // ContractAutoFillDTO draft = contractAutoFillService.generateDraft(
         *     //     savedPdf, manualText, project, freelancerUser, freelancerProfile);
         *     
         *     // model.addAttribute("draft", draft);
         *     // return "contract/contractCheck";
         * 
         * } catch (Exception e) {
         *     e.printStackTrace();
         *     model.addAttribute("errorMessage", "계약서 생성 중 오류가 발생했습니다.");
         *     return "contract/contractForm";
         * }
         * ============================================ */
    }
}
