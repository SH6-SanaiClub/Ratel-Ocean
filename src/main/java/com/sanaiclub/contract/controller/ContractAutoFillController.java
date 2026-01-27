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

/** 계약서 자동 채우기 컨트롤러 (레거시). 현재 사용되지 않음. */
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

    /** 계약서 자동 채우기 (레거시). 현재 사용되지 않음. */
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
            // 주의: 다른 도메인 정보는 Controller에서 조회하여 전달해야 합니다.
            // ContractAutoFillService는 contract 도메인만 담당하므로 다른 도메인을 침범하지 않습니다.
            // TODO: Controller에서 project/user 도메인 Service를 주입받아 정보를 조회하고 전달하도록 구현 필요
            // 현재는 ContractController에서 처리하도록 변경됨
            model.addAttribute("errorMessage", "이 기능은 ContractController에서 처리됩니다.");
            return "contract/contractForm";

        } catch (Exception e) {
            e.printStackTrace(); // 개발 단계 로그
            model.addAttribute("errorMessage", "계약서 생성 중 오류가 발생했습니다.");
            return "contract/contractForm";
        }
    }
}
