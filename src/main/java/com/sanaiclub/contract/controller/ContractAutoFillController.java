package com.sanaiclub.contract.controller;

import com.sanaiclub.contract.model.ContractAutoFillDTO;
import com.sanaiclub.contract.service.ContractAutoFillService;
import com.sanaiclub.contract.service.PDFProcessingService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;

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
     * contractForm.jsp → contractCheck.jsp
     */
    @PostMapping("/autofill")
    public String autoFillContract(
            @RequestParam("contractPdf") MultipartFile contractPdf,
            @RequestParam(value = "manualText", required = false) String manualText,
            @RequestParam("projectId") Long projectId,
            @RequestParam("freelancerId") Long freelancerId,
            Model model
    ) {

        /* 0. 업로드 파일 검증 */
        if (contractPdf == null || contractPdf.isEmpty()) {
            model.addAttribute("errorMessage", "PDF 파일을 업로드해주세요.");
            return "contract/contractForm";
        }

        File savedPdf = null;

        try {
            /* 1. PDF 임시 저장 */
            savedPdf = File.createTempFile("contract_", ".pdf");
            savedPdf.deleteOnExit(); // JVM 종료 시 삭제
            contractPdf.transferTo(savedPdf);

            /* 2. PDF 텍스트 추출 */
            String pdfText = pdfProcessingService.extractText(savedPdf);
            int pageCount = pdfProcessingService.getPageCount(savedPdf);

            /* 3. AI 계약서 초안 생성 */
            ContractAutoFillDTO draft = contractAutoFillService.generateDraft(
                    savedPdf,
                    manualText,
                    projectId.intValue(),
                    freelancerId.intValue()
            );

            /* 4. Model에 담기 (contractCheck.jsp에서 사용) */
            model.addAttribute("pdfText", pdfText);
            model.addAttribute("pageCount", pageCount);
            model.addAttribute("draft", draft);
            model.addAttribute("projectId", projectId);
            model.addAttribute("freelancerId", freelancerId);

            return "contract/contractCheck";

        } catch (Exception e) {
            e.printStackTrace(); // 개발 단계 로그
            model.addAttribute("errorMessage", "계약서 생성 중 오류가 발생했습니다.");
            return "contract/contractForm";
        }
    }
}
