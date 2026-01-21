package com.sanaiclub.contract.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.contract.model.*;
import com.sanaiclub.contract.service.ContractAutoFillService;
import com.sanaiclub.contract.service.ContractCheckService;
import com.sanaiclub.contract.service.ContractService;

import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.*;

@Controller
@RequestMapping({"/contract", "/client/contract"})
public class ContractController {

    private final ContractService contractService;
    private final ContractCheckService contractCheckService;
    private final ContractAutoFillService contractAutoFillService;

    public ContractController(
            ContractService contractService,
            ContractCheckService contractCheckService,
            ContractAutoFillService contractAutoFillService
    ) {
        this.contractService = contractService;
        this.contractCheckService = contractCheckService;
        this.contractAutoFillService = contractAutoFillService;
    }

    /* =========================================================
       PDF FILE SERVE
       ========================================================= */
    @GetMapping("/file/{fileName:.+}")
    public void servePdf(
            @PathVariable String fileName,
            HttpServletResponse response
    ) throws java.io.IOException {

        String uploadDir = "C:/program/apache-tomcat-9.0.112/bin/uploaded-contracts";
        Path filePath = Paths.get(uploadDir, fileName);

        if (!Files.exists(filePath)) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.setContentType("text/plain;charset=UTF-8");
            response.getWriter().write("파일을 찾을 수 없습니다.");
            return;
        }

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "inline; filename=\"" + fileName + "\"");
        Files.copy(filePath, response.getOutputStream());
        response.getOutputStream().flush();
    }

    /* =========================================================
       PDF UPLOAD
       ========================================================= */
    @PostMapping(value = "/uploadPdf", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public ResponseEntity<Map<String, Object>> uploadPdf(
            @RequestParam("contractPdf") MultipartFile contractPdf
    ) {

        Map<String, Object> result = new HashMap<>();

        if (contractPdf == null || contractPdf.isEmpty()) {
            result.put("success", false);
            result.put("error", "파일이 선택되지 않았습니다.");
            return ResponseEntity.badRequest().body(result);
        }

        try {
            String uploadDir = "uploaded-contracts";
            String originalName = contractPdf.getOriginalFilename();
            String saveName = System.currentTimeMillis() + "_" +
                    (originalName != null ? originalName : "contract.pdf");

            Path savePath = Paths.get(uploadDir, saveName);
            Files.createDirectories(savePath.getParent());
            contractPdf.transferTo(savePath.toFile());

            result.put("success", true);
            result.put("fileName", saveName);
            return ResponseEntity.ok(result);

        } catch (Exception e) {
            result.put("success", false);
            result.put("error", e.getMessage());
            return ResponseEntity.internalServerError().body(result);
        }
    }

    /* =========================================================
       STEP 3 : CONTRACT CHECK (AUTO-FILL 연결 핵심)
       ========================================================= */
    @PostMapping("/contractCheck")
    public String contractCheck(
            @ModelAttribute ContractFormDTO formDto,
            @RequestParam(value = "uploadedPdfFileName", required = false) String uploadedPdfFileName,
            Model model
    ) {

        // 1. 기본 정보 조회 (판단 없음)
        ContractProjectVO project = contractService.getProjectById(formDto.getProjectId());
        ContractFreelancerVO freelancer = contractService.getFreelancerById(formDto.getFreelancerId());
        Object client = contractService.getClientByLoginUser();

        if (client == null) {
            model.addAttribute("errorMessage", "클라이언트 정보가 없습니다.");
        }

        if (uploadedPdfFileName != null && !uploadedPdfFileName.isEmpty()) {
            formDto.setUploadedPdfFileName(uploadedPdfFileName);
        }

        // 2. 🔥 AUTO-FILL SERVICE 연결 (STEP 3의 핵심)
        ContractAutoFillDTO autoFilled =
                contractAutoFillService.generateDraft(
                        null,                       // pdfFile (지금은 null 허용)
                        null,                       // manualText
                        formDto.getProjectId(),     // Integer
                        formDto.getFreelancerId()   // Integer
                );

        // 3. Model 전달 (가공 ❌)
        model.addAttribute("project", project);
        model.addAttribute("freelancer", freelancer);
        model.addAttribute("client", client);
        model.addAttribute("formDto", formDto);
        model.addAttribute("contract", autoFilled);

        LocalDateTime now = LocalDateTime.now();
        Date contractedAt = Date.from(now.atZone(ZoneId.systemDefault()).toInstant());
        model.addAttribute("contractedAt", contractedAt);

        return "contract/contractCheck";
    }

    /* =========================================================
       PROJECT / FREELANCER API
       ========================================================= */
    @GetMapping("/projectList")
    @ResponseBody
    public Object getProjectList() {
        Integer clientId = AuthContext.getCurrentUserId();
        if (clientId == null) return Collections.emptyList();
        return contractService.getProjectsByClientId(clientId);
    }

    @GetMapping("/freelancerList")
    @ResponseBody
    public Object getFreelancerList(@RequestParam Integer projectId) {
        if (projectId == null) return Collections.emptyList();
        return contractService.getFreelancersByProjectId(projectId);
    }

    @GetMapping("/projectInfo")
    @ResponseBody
    public Object getProjectInfo(@RequestParam Integer projectId) {
        return contractService.getProjectById(projectId);
    }

    @GetMapping("/freelancerInfo")
    @ResponseBody
    public Object getFreelancerInfo(@RequestParam Integer freelancerId) {
        return contractService.getFreelancerById(freelancerId);
    }

    /* =========================================================
       CONTRACT FORM
       ========================================================= */
    @GetMapping("/form")
    public String contractForm(
            @RequestParam(required = false) Integer projectId,
            @RequestParam(required = false) Integer freelancerId,
            Model model
    ) {

        Integer clientId = AuthContext.getCurrentUserId();
        if (clientId == null) return "redirect:/login";

        List<ContractProjectVO> projectList =
                contractService.getProjectsByClientId(clientId);

        model.addAttribute("projectList",
                projectList != null ? projectList : Collections.emptyList());

        ContractProjectVO selectedProject =
                projectId != null ? contractService.getProjectById(projectId) : null;

        model.addAttribute("selectedProject", selectedProject);

        List<ContractFreelancerVO> freelancerList =
                projectId != null
                        ? contractService.getFreelancersByProjectId(projectId)
                        : Collections.emptyList();

        model.addAttribute("freelancerList", freelancerList);

        ContractFreelancerVO selectedFreelancer =
                freelancerId != null
                        ? contractService.getFreelancerById(freelancerId)
                        : null;

        model.addAttribute("selectedFreelancer", selectedFreelancer);

        return "contract/contractForm";
    }
}
