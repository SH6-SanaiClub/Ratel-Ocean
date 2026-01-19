package com.sanaiclub.domain.test.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * TestFileController
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [설명]
 * 파일 업로드 및 다운로드 테스트를 위한 컨트롤러입니다.
 * - 다른 사람 PC에서 파일 업로드 테스트
 * - 업로드된 파일 목록 조회
 * - 파일 다운로드
 * 
 * [엔드포인트]
 * - GET  /test/upload : 파일 업로드 페이지
 * - POST /test/upload : 파일 업로드 처리
 * - GET  /test/files  : 업로드된 파일 목록 페이지
 * - GET  /test/download : 파일 다운로드
 * - POST /test/delete : 파일 삭제
 */
@Controller
@RequestMapping("/test")
public class TestFileController {

    // 파일 저장 경로 (톰캣 배포 디렉토리 기준)
    private static final String UPLOAD_DIR = System.getProperty("user.home") + File.separator + "Desktop" + File.separator + "test_uploads";

    /**
     * ─────────────────────────────────────────────────────────────────
     * [파일 업로드 페이지]
     * ─────────────────────────────────────────────────────────────────
     * 엔드포인트: GET /test/upload
     * 설명: 파일을 업로드할 수 있는 테스트 페이지입니다.
     */
    @GetMapping("/upload")
    public String uploadPage() {
        // 업로드 디렉토리가 없으면 생성
        File uploadDir = new File(UPLOAD_DIR);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        return "test/test_upload";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [파일 업로드 처리]
     * ─────────────────────────────────────────────────────────────────
     * 엔드포인트: POST /test/upload
     * 설명: 업로드된 파일을 서버 디스크에 저장합니다.
     */
    @PostMapping("/upload")
    public String uploadFile(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "description", required = false) String description,
            Model model) {
        
        try {
            if (file.isEmpty()) {
                model.addAttribute("error", "파일을 선택해주세요.");
                return "test/test_upload";
            }

            // 파일명 생성 (timestamp + 원본파일명)
            String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
            String originalFilename = file.getOriginalFilename();
            String safeFilename = timestamp + "_" + originalFilename;
            
            // 파일 저장
            File uploadDir = new File(UPLOAD_DIR);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            File destFile = new File(uploadDir, safeFilename);
            file.transferTo(destFile);
            
            // 성공 메시지
            model.addAttribute("success", "파일 업로드 성공!");
            model.addAttribute("filename", safeFilename);
            model.addAttribute("filesize", formatFileSize(file.getSize()));
            model.addAttribute("filepath", destFile.getAbsolutePath());
            model.addAttribute("description", description);
            
        } catch (Exception e) {
            model.addAttribute("error", "파일 업로드 실패: " + e.getMessage());
            e.printStackTrace();
        }
        
        return "test/test_upload";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [업로드된 파일 목록 페이지]
     * ─────────────────────────────────────────────────────────────────
     * 엔드포인트: GET /test/files
     * 설명: 업로드된 모든 파일의 목록을 조회합니다.
     */
    @GetMapping("/files")
    public String fileListPage(Model model) {
        try {
            File uploadDir = new File(UPLOAD_DIR);
            
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            // 파일 목록 가져오기
            File[] files = uploadDir.listFiles();
            List<Map<String, Object>> fileList = new ArrayList<>();
            
            if (files != null && files.length > 0) {
                // 최신 파일이 위로 오도록 정렬
                Arrays.sort(files, (f1, f2) -> Long.compare(f2.lastModified(), f1.lastModified()));
                
                for (File file : files) {
                    if (file.isFile()) {
                        Map<String, Object> fileInfo = new HashMap<>();
                        fileInfo.put("name", file.getName());
                        fileInfo.put("size", formatFileSize(file.length()));
                        fileInfo.put("sizeBytes", file.length());
                        fileInfo.put("uploadDate", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date(file.lastModified())));
                        fileInfo.put("path", file.getAbsolutePath());
                        
                        // 파일 확장자
                        String ext = "";
                        String name = file.getName();
                        int lastDot = name.lastIndexOf('.');
                        if (lastDot > 0) {
                            ext = name.substring(lastDot + 1).toUpperCase();
                        }
                        fileInfo.put("extension", ext);
                        
                        fileList.add(fileInfo);
                    }
                }
            }
            
            model.addAttribute("files", fileList);
            model.addAttribute("totalFiles", fileList.size());
            model.addAttribute("uploadDir", UPLOAD_DIR);
            
        } catch (Exception e) {
            model.addAttribute("error", "파일 목록 조회 실패: " + e.getMessage());
            e.printStackTrace();
        }
        
        return "test/test_files";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [파일 다운로드]
     * ─────────────────────────────────────────────────────────────────
     * 엔드포인트: GET /test/download
     * 설명: 업로드된 파일을 다운로드합니다.
     */
    @GetMapping("/download")
    public void downloadFile(
            @RequestParam("filename") String filename,
            HttpServletResponse response) {
        
        try {
            File file = new File(UPLOAD_DIR, filename);
            
            if (!file.exists() || !file.isFile()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "파일을 찾을 수 없습니다.");
                return;
            }
            
            // Content-Type 설정
            String mimeType = Files.probeContentType(file.toPath());
            if (mimeType == null) {
                mimeType = "application/octet-stream";
            }
            response.setContentType(mimeType);
            
            // 파일 다운로드 헤더 설정
            response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");
            response.setContentLengthLong(file.length());
            
            // 파일 전송
            try (FileInputStream fis = new FileInputStream(file);
                 OutputStream os = response.getOutputStream()) {
                
                byte[] buffer = new byte[8192];
                int bytesRead;
                while ((bytesRead = fis.read(buffer)) != -1) {
                    os.write(buffer, 0, bytesRead);
                }
                os.flush();
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 파일 크기를 사람이 읽기 쉬운 형식으로 변환
     */
    private String formatFileSize(long bytes) {
        if (bytes < 1024) {
            return bytes + " B";
        } else if (bytes < 1024 * 1024) {
            return String.format("%.2f KB", bytes / 1024.0);
        } else if (bytes < 1024 * 1024 * 1024) {
            return String.format("%.2f MB", bytes / (1024.0 * 1024.0));
        } else {
            return String.format("%.2f GB", bytes / (1024.0 * 1024.0 * 1024.0));
        }
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [파일 삭제]
     * ─────────────────────────────────────────────────────────────────
     * 엔드포인트: POST /test/delete
     * 설명: 업로드된 파일을 서버 디스크에서 삭제합니다.
     *      실제 DB 연동 시스템에서는 messages, contracts 등의 테이블에서
     *      file_url을 NULL로 업데이트하거나 레코드를 삭제해야 합니다.
     */
    @PostMapping("/delete")
    @ResponseBody
    public Map<String, Object> deleteFile(@RequestParam("filename") String filename) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            File file = new File(UPLOAD_DIR, filename);
            
            if (!file.exists() || !file.isFile()) {
                response.put("success", false);
                response.put("message", "파일을 찾을 수 없습니다.");
                return response;
            }
            
            // 파일 삭제
            boolean deleted = file.delete();
            
            if (deleted) {
                response.put("success", true);
                response.put("message", "파일이 성공적으로 삭제되었습니다.");
                
                // 실제 시스템에서는 여기서 DB 업데이트 필요:
                // 예시 1: messages 테이블의 file_url을 NULL로 업데이트
                // messageMapper.updateFileUrl(messageId, null);
                
                // 예시 2: contracts 테이블의 파일 URL 삭제
                // contractMapper.deleteContractFile(contractId, fileType);
                
                // 예시 3: freelancer_portfolios 테이블에서 포트폴리오 삭제
                // portfolioMapper.deletePortfolio(portfolioId);
                
            } else {
                response.put("success", false);
                response.put("message", "파일 삭제에 실패했습니다.");
            }
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "파일 삭제 중 오류가 발생했습니다: " + e.getMessage());
            e.printStackTrace();
        }
        
        return response;
    }
}
