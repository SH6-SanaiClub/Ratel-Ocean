package com.sanaiclub.contract.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.contract.model.ContractFreelancerVO;
import com.sanaiclub.contract.model.ContractProjectVO;
import com.sanaiclub.project.model.vo.ProjectsVO;
import org.springframework.http.ResponseEntity;
import org.springframework.http.MediaType;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.ui.Model;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.bind.annotation.PathVariable;

import com.sanaiclub.contract.service.ContractService;
import com.sanaiclub.contract.service.ContractCheckService;

@Controller
@RequestMapping({"/contract", "/client/contract"})
public class ContractController {

        @PostMapping(value = "/uploadPdf", produces = MediaType.APPLICATION_JSON_VALUE)
        @ResponseBody
        public ResponseEntity<Map<String, Object>> uploadPdf(@RequestParam("contractPdf") MultipartFile contractPdf) {
            Map<String, Object> result = new HashMap<>();
            if (contractPdf == null || contractPdf.isEmpty()) {
                result.put("success", false);
                result.put("error", "파일이 선택되지 않았습니다.");
                return ResponseEntity.badRequest().body(result);
            }
            try {
                String uploadDir = "uploaded-contracts";
                String originalName = contractPdf.getOriginalFilename();
                String saveName = System.currentTimeMillis() + "_" + (originalName != null ? originalName : "contract.pdf");
                java.nio.file.Path savePath = java.nio.file.Paths.get(uploadDir, saveName);
                java.nio.file.Files.createDirectories(savePath.getParent());
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
    private final ContractService contractService;
    private final ContractCheckService contractCheckService;

    public ContractController(
        com.sanaiclub.contract.service.ContractService contractService,
        ContractCheckService contractCheckService
    ) {
        this.contractService = contractService;
        this.contractCheckService = contractCheckService;
    }

    @PostMapping("/contractCheck")
    public String contractCheck(@RequestParam Long projectId,
                                @RequestParam Long freelancerId,
                                @RequestParam String contractContent,
                                @RequestParam(value = "uploadedPdfFileName", required = false) String uploadedPdfFileName,
                                Model model) {
        // 프로젝트, 프리랜서, 클라이언트 정보 조회
        var project = contractService.getProjectById(projectId);
        var freelancer = contractService.getFreelancerById(freelancerId);
        var client = contractService.getClientByLoginUser();
        model.addAttribute("project", project);
        model.addAttribute("freelancer", freelancer);
        model.addAttribute("client", client);
        model.addAttribute("contractContent", contractContent);
        model.addAttribute("uploadedPdfFileName", uploadedPdfFileName);
        return "contract/contractCheck";
    }

    @GetMapping("/projectList")
    @ResponseBody
    public Object getProjectList(javax.servlet.http.HttpSession session) {
        // AuthContext에서 userId를 안전하게 가져옴 (항상 Integer 반환)
        Integer rawId = com.sanaiclub.common.util.AuthContext.getCurrentUserId();
        if (rawId == null) return java.util.Collections.emptyList();
        Long clientId = rawId.longValue();
        var projects = contractService.getProjectsByClientId(clientId);
        System.out.println("[DEBUG] 반환되는 프로젝트 목록: " + projects);
        return projects;
    }

    @GetMapping("/freelancerList")
    @ResponseBody
    public Object getFreelancerList(@RequestParam Long projectId, javax.servlet.http.HttpSession session) {
        Long clientId = (Long) session.getAttribute("userId");
        if (projectId == null) return java.util.Collections.emptyList();
        return contractService.getFreelancersByProjectId(projectId);
    }

    @GetMapping("/projectInfo")
    @ResponseBody
    public Object getProjectInfo(@RequestParam Long projectId) {
        ContractProjectVO project = contractService.getProjectById(projectId);
        if (project == null) return new Object();
        return project;
    }

    @GetMapping("/freelancerInfo")
    @ResponseBody
    public Object getFreelancerInfo(@RequestParam Long freelancerId) {
        ContractFreelancerVO freelancer = contractService.getFreelancerById(freelancerId);
        if (freelancer == null) return new Object();
        return freelancer;
    }

    @GetMapping("/form")
    public String contractForm(
        @RequestParam(required = false) Long projectId,
        @RequestParam(required = false) Long freelancerId,
        Model model
    ) {
        try {
            Integer rawId = AuthContext.getCurrentUserId();
            if (rawId == null) return "redirect:/login?error=unauthorized";
            Long clientId = rawId.longValue();
            System.out.println("clientId: " + clientId);
            // 프로젝트 목록
            List<ContractProjectVO> projectList = contractService.getProjectsByClientId(clientId);
            System.out.println("!!![DEBUG] 프로젝트 목록: " + projectList);
            model.addAttribute("projectList", projectList != null ? projectList : java.util.Collections.emptyList());




//            // 선택된 프리랜서 정보
//            var selectedFreelancer = (freelancerId != null) ? contractService.getFreelancerById(freelancerId) : null;
//            model.addAttribute("selectedFreelancer", selectedFreelancer);


        } catch (Exception e) {
            model.addAttribute("errorMessage", "일시적인 오류가 발생했습니다. (" + e.getMessage() + ")");
            model.addAttribute("projectList", java.util.Collections.emptyList());
            model.addAttribute("freelancerList", java.util.Collections.emptyList());
            model.addAttribute("selectedProject", null);
            model.addAttribute("selectedFreelancer", null);

        }
        return "contract/contractForm";
    }

    @GetMapping("/client/contract/form")
    public String legacyContractForm(
        @RequestParam(required = false) Long projectId,
        @RequestParam(required = false) Long freelancerId,
        Model model
    ) {
        return contractForm(projectId, freelancerId, model);
    }

    @GetMapping("/project/{projectId}")
    public String f_selectedProject(@PathVariable("projectId") Long projectId, Model model) {
              // 선택된 프로젝트 정보
            //var selectedProject = (projectId != null) ? contractService.getProjectById(projectId) : null;
            //model.addAttribute("selectedProject", selectedProject);


        // 지원자 목록
        List<ContractFreelancerVO>  freelancerList = (projectId != null) ? contractService.getFreelancersByProjectId(projectId) : java.util.Collections.emptyList();
        model.addAttribute("freelancerList", freelancerList);

        return "contract/applier";

    }



    @GetMapping("/example")
    public String contractExample() {
        return "contract/contractExample";
    }

//    @PostMapping("/check")
//    public String showContractCheckPage(
//        @RequestParam("projectId") Long projectId,
//        @RequestParam("freelancerId") Long freelancerId,
//        @RequestParam(value = "uploadedPdfFileName", required = false) String uploadedPdfFileName,
//        javax.servlet.http.HttpSession session,
//        Model model
//    ) {
//        // 1. HttpSession에서 clientId 조회
//        Long clientId = (Long) session.getAttribute("userId");
//        // 2. Service 호출 (DB 조회는 Service에서만)
//        var contractCheckVO = contractCheckService.getContractCheckData(clientId, projectId, freelancerId, uploadedPdfFileName);
//        // 3. 반환된 VO를 Model에 담음 (필요한 모든 속성)
//        model.addAllAttributes(contractCheckVO.toModelMap());
//        return "contract/contractCheck";
//    }
//
//    @GetMapping("/file/{fileName}")
//    public void servePdf(@PathVariable String fileName, javax.servlet.http.HttpServletResponse response) throws java.io.IOException {
//        java.io.File file = new java.io.File("uploaded-contracts", fileName);
//        if (file.exists()) {
//            response.setContentType("application/pdf");
//            java.nio.file.Files.copy(file.toPath(), response.getOutputStream());
//            response.getOutputStream().flush();
//        } else {
//            response.sendError(javax.servlet.http.HttpServletResponse.SC_NOT_FOUND);
//        }
//    }
}
