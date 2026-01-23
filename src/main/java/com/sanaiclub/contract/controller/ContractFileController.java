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

/**
 * ============================================================================
 * ContractFileController - 계약서 파일 관리 컨트롤러
 * ============================================================================
 * 
 * [역할]
 * - PDF 파일 업로드/다운로드 처리
 * - 파일 경로 관리
 * - AJAX 요청 처리 및 JSON 응답 제공
 * 
 * [주요 기능]
 * 1. PDF 파일 업로드
 *    - POST /client/contract/uploadPdf: PDF 파일 업로드 (JSON 응답)
 *    - AJAX 요청으로 비동기 업로드
 *    - 파일명에 타임스탬프 추가 (중복 방지)
 * 
 * 2. PDF 파일 제공
 *    - GET /client/contract/file/**: PDF 파일 다운로드/미리보기
 *    - iframe이나 embed 태그에서 사용
 * 
 * [저장 경로]
 * - contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
 * - freelancerId가 null이면 contracts/{clientId}/{projectId}/{fileName}
 * 
 * [보안]
 * - ContractFileService.servePdfResource()에서 Path Traversal 방지
 * - contracts/로 시작하는 경로만 허용
 * - 로그인 사용자만 접근 가능
 * 
 * [경로]
 * - Base URL: /client/contract
 * - 클라이언트 전용 컨트롤러
 * 
 * [책임 분리]
 * - Controller: HTTP 요청 처리, JSON 응답
 * - Service: 파일 업로드/다운로드 로직 처리
 * 
 * ============================================================================
 */
@Slf4j
@Controller
@RequestMapping("/client/contract")
@RequiredArgsConstructor
public class ContractFileController {

    private final ContractFileService contractFileService;

    /**
     * PDF 파일 업로드 (AJAX)
     * 
     * [기능]
     * - MultipartFile을 서버에 저장
     * - 파일명에 타임스탬프 추가 (중복 방지)
     * - JSON 응답으로 업로드 결과 반환
     * 
     * [처리 흐름]
     * 1. 파일 및 프로젝트 ID 검증
     * 2. 현재 로그인한 사용자 ID 확인
     * 3. ContractFileService.uploadPdf() 호출
     * 4. 업로드된 파일 경로 및 파일명 반환
     * 
     * [저장 경로]
     * - contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
     * - freelancerId가 null이면 contracts/{clientId}/{projectId}/{fileName}
     * - 파일명 형식: {timestamp}_{originalFilename}
     * 
     * [응답 형식]
     * - 성공: {"success": true, "fileName": "...", "filePath": "..."}
     * - 실패: {"success": false, "error": "에러 메시지"}
     * 
     * [에러 처리]
     * - 파일이 없으면: "PDF 파일이 없습니다."
     * - 프로젝트 ID가 없으면: "프로젝트 ID가 필요합니다."
     * - 로그인하지 않았으면: "로그인이 필요합니다."
     * - 프로젝트 ID 형식 오류: "유효하지 않은 프로젝트 ID입니다."
     * - 업로드 실패: 예외 메시지 반환
     * 
     * [주의사항]
     * - freelancerId는 null로 전달 (나중에 추가 가능)
     * - 파일 업로드 후 경로를 originContractUrl로 사용
     * 
     * @param contractPdf 업로드할 PDF 파일 (필수)
     * @param projectIdStr 프로젝트 ID (필수, 문자열 형식)
     * @return JSON 응답 (Map<String, Object>)
     *         - success: 성공 여부 (boolean)
     *         - fileName: 업로드된 파일명 (성공 시)
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
}
