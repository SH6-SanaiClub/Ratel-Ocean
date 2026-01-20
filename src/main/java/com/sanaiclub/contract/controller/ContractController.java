package com.sanaiclub.contract.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.ui.Model;
import java.io.File;
import java.io.IOException;

@Controller
@RequestMapping("/client/contract")
public class ContractController {
    @GetMapping("/projectList")
    @ResponseBody
    public Object getProjectList(javax.servlet.http.HttpSession session) {
        // AuthContext에서 userId를 안전하게 가져옴
        Long clientId = null;
        Object rawId = com.sanaiclub.common.util.AuthContext.getCurrentUserId();
        if (rawId instanceof Long) {
            clientId = (Long) rawId;
        } else if (rawId instanceof Integer) {
            clientId = ((Integer) rawId).longValue();
        }
        if (clientId == null) return java.util.Collections.emptyList();
        return contractService.getProjectsByClientId(clientId);
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
        com.sanaiclub.contract.model.ContractProjectEntity project = contractService.getProjectById(projectId);
        if (project == null) return new Object();
        return project;
    }

    @GetMapping("/freelancerInfo")
    @ResponseBody
    public Object getFreelancerInfo(@RequestParam Long freelancerId) {
        com.sanaiclub.contract.model.ContractFreelancerEntity freelancer = contractService.getFreelancerById(freelancerId);
        if (freelancer == null) return new Object();
        return freelancer;
    }
    private final com.sanaiclub.contract.service.ContractService contractService;

    public ContractController(com.sanaiclub.contract.service.ContractService contractService) {
        this.contractService = contractService;
    }

    @GetMapping("/form")
    public String contractForm(@RequestParam(required = false) Long projectId,
                               @RequestParam(required = false) Long freelancerId,
                               Model model,
                               javax.servlet.http.HttpSession session) {
        if (!com.sanaiclub.common.util.AuthContext.isClient()) {
            return "redirect:/login?error=unauthorized";
        }
        if (projectId != null) {
            model.addAttribute("project", contractService.getProjectById(projectId));
        } else {
            model.addAttribute("project", null);
        }
        if (freelancerId != null) {
            model.addAttribute("freelancer", contractService.getFreelancerById(freelancerId));
        } else {
            model.addAttribute("freelancer", null);
        }
        return "client/contract/contractForm";
    }

    @PostMapping("/upload")
    public String uploadContract(@RequestParam("contractPdf") MultipartFile file) throws IOException {
        if (file.isEmpty()) {
            return "redirect:/contract/form?error";
        }
        String savePath = "C:/upload/" + file.getOriginalFilename();
        file.transferTo(new File(savePath));
        return "redirect:/client/contract/form?success";
    }

    @GetMapping("/example")
    public String contractExample() {
        return "client/contract/contractExample";
    }
}
