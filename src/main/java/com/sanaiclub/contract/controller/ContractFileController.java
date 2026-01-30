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

/** 계약서 파일 관리 컨트롤러. PDF 파일 업로드/다운로드 처리. */
@Slf4j
@Controller
@RequestMapping("/client/contract")
@RequiredArgsConstructor
public class ContractFileController {

    private final ContractFileService contractFileService;

    /** PDF 파일 업로드. AJAX 요청으로 JSON 응답.
     *         - filePath: 업로드된 파일 경로 (성공 시)
     *         - error: 에러 메시지 (실패 시)
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
     * 
     * [기능]
     * - 저장된 PDF 파일을 브라우저에서 조회
     * - iframe이나 embed 태그에서 사용
     * - ContractFileService의 공통 메서드 사용
     * 
     * [경로 형식]
     * - GET /client/contract/file/{encodedPath}
     * - 경로: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
     * - URL 인코딩된 경로 사용 가능
     * 
     * [처리 흐름]
     * 1. HTTP 요청 URI에서 파일 경로 추출
     * 2. ContractFileService.servePdfResource() 호출
     * 3. PDF 파일 리소스 반환
     * 
     * [보안]
     * - ContractFileService.servePdfResource()에서 Path Traversal 방지
     * - contracts/로 시작하는 경로만 허용
     * - baseDir 밖으로 나가는 경로 차단
     * 
     * [응답]
     * - Content-Type: application/pdf
     * - 파일이 없으면 404 Not Found
     * - 보안 위반 시 400 Bad Request 또는 403 Forbidden
     * 
     * [사용 예시]
     * - <iframe src="/client/contract/file/contracts/1/100/50/file.pdf"></iframe>
     * 
     * @param request HTTP 요청 (URI에서 경로 추출)
     *                - request.getRequestURI()로 전체 URI 획득
     * @return PDF 파일 리소스 (ResponseEntity<Resource>)
     *         - 성공: 200 OK with PDF content
     *         - 실패: 404 Not Found, 400 Bad Request, 403 Forbidden 등
     */
    @GetMapping("/file/**")
    public ResponseEntity<org.springframework.core.io.Resource> servePdf(
            javax.servlet.http.HttpServletRequest request) {
        String requestURI = request.getRequestURI();
        log.debug("servePdf - requestURI: {}", requestURI);
        return contractFileService.servePdfResource(requestURI);
    }

    /**
     * PDF 파일 다운로드 (Content-Disposition: attachment)
     * 
     * [기능]
     * - 저장된 PDF 파일을 다운로드
     * - 브라우저에서 바로 열리지 않고 다운로드됨
     * 
     * [경로 형식]
     * - GET /client/contract/download/{encodedPath}
     * - 경로: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
     * 
     * [응답]
     * - Content-Type: application/pdf
     * - Content-Disposition: attachment; filename="{fileName}"
     * - 파일이 없으면 404 Not Found
     * 
     * @param request HTTP 요청 (URI에서 경로 추출)
     * @return PDF 파일 리소스 (다운로드용)
     */
    @GetMapping("/download/**")
    public ResponseEntity<org.springframework.core.io.Resource> downloadPdf(
            javax.servlet.http.HttpServletRequest request) {
        String requestURI = request.getRequestURI();
        log.debug("downloadPdf - requestURI: {}", requestURI);
        
        // /download/를 /file/로 변경하여 servePdfResource 호출
        String fileRequestURI = requestURI.replace("/download/", "/file/");
        ResponseEntity<org.springframework.core.io.Resource> response = contractFileService.servePdfResource(fileRequestURI);
        
        // 다운로드 헤더 추가
        if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
            try {
                // 파일명 추출
                String filePathStr = fileRequestURI.substring(fileRequestURI.indexOf("/file/") + "/file/".length());
                String[] segments = filePathStr.split("/");
                String fileName = segments.length > 0 ? segments[segments.length - 1] : "contract.pdf";
                
                // URL 디코딩
                try {
                    fileName = java.net.URLDecoder.decode(fileName, "UTF-8");
                } catch (java.io.UnsupportedEncodingException e) {
                    // 디코딩 실패 시 원본 사용
                }
                
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_PDF)
                    .header(org.springframework.http.HttpHeaders.CONTENT_DISPOSITION, 
                        "attachment; filename=\"" + fileName + "\"")
                    .body(response.getBody());
            } catch (Exception e) {
                log.error("PDF 다운로드 헤더 설정 중 오류: {}", e.getMessage(), e);
                return response;
            }
        }
        
        return response;
    }
}
