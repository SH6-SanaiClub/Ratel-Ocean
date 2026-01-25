package com.sanaiclub.contract.controller;

import com.sanaiclub.contract.service.ContractFileService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.Map;


@Slf4j
@Controller
@RequestMapping("/client/contract")
@RequiredArgsConstructor
public class ContractFileController {

    private final ContractFileService contractFileService;

    /**
     * PDF 파일 업로드 (AJAX)
     */
    @PostMapping(value = "/uploadPdf", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> uploadPdf(
            @RequestParam("contractPdf") MultipartFile contractPdf,
            @RequestParam("projectId") String projectIdStr
    ) {
        Map<String, Object> result = new HashMap<>();
        try {
            if (contractPdf == null || contractPdf.isEmpty()) {
                result.put("success", false);
                result.put("error", "PDF 파일이 없습니다.");
                return result;
            }
            
            if (projectIdStr == null || projectIdStr.isBlank()) {
                result.put("success", false);
                result.put("error", "프로젝트 ID가 필요합니다.");
                return result;
            }
            
            Integer userId = com.sanaiclub.common.util.AuthContext.getCurrentUserId();
            if (userId == null) {
                result.put("success", false);
                result.put("error", "로그인이 필요합니다.");
                return result;
            }
            
            Integer clientId = userId;
            Integer projectId;
            try {
                projectId = Integer.valueOf(projectIdStr);
            } catch (NumberFormatException e) {
                result.put("success", false);
                result.put("error", "유효하지 않은 프로젝트 ID입니다.");
                return result;
            }
            
            // 파일 업로드 (freelancerId는 null로 전달 - 나중에 추가 가능)
            String filePath = contractFileService.uploadPdf(contractPdf, clientId, projectId, null);
            String fileName = filePath.substring(filePath.lastIndexOf("/") + 1);
            
            result.put("success", true);
            result.put("fileName", fileName);
            result.put("filePath", filePath);
        } catch (Exception e) {
            log.error("PDF 업로드 실패: {}", e.getMessage(), e);
            result.put("success", false);
            result.put("error", e.getMessage());
        }
        return result;
    }

    /**
     * PDF 파일 제공 (iframe 미리보기용)
     */
    @GetMapping("/file/**")
    public ResponseEntity<org.springframework.core.io.Resource> servePdf(
            javax.servlet.http.HttpServletRequest request) {
        String requestURI = request.getRequestURI();
        log.debug("servePdf - requestURI: {}", requestURI);
        return contractFileService.servePdfResource(requestURI);
    }
}
