package com.sanaiclub.contract.service.impl;

import com.sanaiclub.contract.service.ContractFileService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.ResponseEntity;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/** 계약서 파일 관리 서비스 구현체. 로컬 파일 시스템 사용. Path Traversal 방지. */
@Service
public class LocalFileService implements ContractFileService {

    private static final Logger logger = LoggerFactory.getLogger(LocalFileService.class);

    /** PDF 파일 업로드. 파일명에 타임스탬프 추가. 경로: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}. */
    @Override
    public String uploadPdf(MultipartFile contractPdf, Integer clientId, Integer projectId, Integer freelancerId) throws IOException {
        if (contractPdf == null || contractPdf.isEmpty()) {
            throw new IllegalArgumentException("PDF 파일이 없습니다.");
        }

        String baseDir = System.getProperty("user.dir");
        String uploadDir = baseDir + File.separator 
            + "contracts" + File.separator 
            + clientId + File.separator 
            + projectId;
        
        if (freelancerId != null) {
            uploadDir += File.separator + freelancerId;
        }
        
        File dir = new File(uploadDir);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        
        String fileName = System.currentTimeMillis() + "_" + contractPdf.getOriginalFilename();
        File dest = new File(dir, fileName);
        contractPdf.transferTo(dest);
        
        String relativePath = "contracts/" + clientId + "/" + projectId;
        if (freelancerId != null) {
            relativePath += "/" + freelancerId;
        }
        relativePath += "/" + fileName;
        
        logger.info("PDF 파일 업로드 완료: {}", relativePath);
        return relativePath;
    }

    /** PDF 파일 경로 정규화 및 이동. freelancerId가 없으면 추가하고 파일 이동/복사. */
    @Override
    public String normalizeAndMovePdfPath(String originContractUrl, Integer clientId, Integer projectId, Integer freelancerId) {
        String baseDir = System.getProperty("user.dir");
        String normalizedPath = originContractUrl.replace("\\", "/");
        
        File pdfFile = null;
        
        if (normalizedPath.startsWith("contracts/")) {
            String[] pathParts = normalizedPath.split("/");
            boolean hasFreelancerId = pathParts.length >= 5 && 
                pathParts[0].equals("contracts") && 
                pathParts[1].equals(String.valueOf(clientId)) &&
                pathParts[2].equals(String.valueOf(projectId)) &&
                pathParts[3].equals(String.valueOf(freelancerId));
            
            if (!hasFreelancerId || pathParts.length < 5) {
                String fileName = pathParts[pathParts.length - 1];
                normalizedPath = "contracts/" + clientId + "/" + projectId + "/" + freelancerId + "/" + fileName;
            }
            
            pdfFile = new File(baseDir, normalizedPath.replace("/", File.separator));
            
            if (!pdfFile.exists() && pathParts.length >= 3) {
                String oldPath = "contracts/" + clientId + "/" + projectId + "/" + pathParts[pathParts.length - 1];
                File oldFile = new File(baseDir, oldPath.replace("/", File.separator));
                if (oldFile.exists()) {
                    String newDir = baseDir + File.separator 
                        + "contracts" + File.separator 
                        + clientId + File.separator 
                        + projectId + File.separator
                        + freelancerId;
                    File newDirFile = new File(newDir);
                    if (!newDirFile.exists()) {
                        newDirFile.mkdirs();
                    }
                    
                    File newFile = new File(newDirFile, pathParts[pathParts.length - 1]);
                    if (oldFile.renameTo(newFile)) {
                        pdfFile = newFile;
                        logger.info("PDF 파일을 새 경로로 이동: {}", normalizedPath);
                    } else {
                        try {
                            Files.copy(oldFile.toPath(), newFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                            pdfFile = newFile;
                            logger.info("PDF 파일을 새 경로로 복사: {}", normalizedPath);
                        } catch (Exception e) {
                            logger.warn("PDF 파일 이동/복사 실패: {}", e.getMessage());
                            pdfFile = oldFile;
                            normalizedPath = oldPath;
                        }
                    }
                }
            }
        } else {
            String uploadDir = baseDir + File.separator 
                + "contracts" + File.separator 
                + clientId + File.separator 
                + projectId + File.separator
                + freelancerId;
            pdfFile = new File(uploadDir, normalizedPath);
            if (pdfFile.exists()) {
                normalizedPath = "contracts/" + clientId + "/" + projectId + "/" + freelancerId + "/" + normalizedPath;
            }
        }
        
        return normalizedPath;
    }

    /** 미확정 PDF 파일 삭제. 확정 시점에 이전 미확정 PDF 정리. */
    @Override
    public void cleanupUnconfirmedPdfs(Integer clientId, Integer projectId, Integer freelancerId, 
                                      String currentFileName, List<String> confirmedPdfPaths) {
        try {
            String baseDir = System.getProperty("user.dir");
            String projectDir = baseDir + File.separator 
                + "contracts" + File.separator 
                + clientId + File.separator 
                + projectId + File.separator
                + freelancerId;
            File dir = new File(projectDir);
            
            if (!dir.exists() || !dir.isDirectory()) {
                return;
            }
            
            Set<String> confirmedFileNames = new HashSet<>();
            for (String path : confirmedPdfPaths) {
                if (path != null && path.contains("/")) {
                    String fileName = path.substring(path.lastIndexOf("/") + 1);
                    confirmedFileNames.add(fileName);
                }
            }
            
            File[] files = dir.listFiles();
            if (files != null) {
                for (File file : files) {
                    if (file.isFile() && file.getName().toLowerCase().endsWith(".pdf")) {
                        String fileName = file.getName();
                        if (fileName.equals(currentFileName)) {
                            continue;
                        }
                        
                        boolean isConfirmed = confirmedFileNames.contains(fileName);
                        if (!isConfirmed) {
                            boolean deleted = file.delete();
                            if (deleted) {
                                logger.info("이전 미확정 PDF 삭제: {}", fileName);
                            } else {
                                logger.warn("PDF 삭제 실패: {}", fileName);
                            }
                        } else {
                            logger.info("확정된 계약 PDF 보존: {}", fileName);
                        }
                    }
                }
            }
        } catch (Exception e) {
            logger.warn("이전 PDF 삭제 중 오류 (무시): {}", e.getMessage());
        }
    }

    /** PDF 파일 삭제. 다른 계약에서 사용 중이 아닌 경우만 삭제. */
    @Override
    public boolean deletePdfIfNotUsed(String pdfPath, List<String> confirmedPdfPaths) {
        try {
            String baseDir = System.getProperty("user.dir");
            File pdfFile = new File(baseDir, pdfPath.replace("/", File.separator));
            
            if (!pdfFile.exists()) {
                return false;
            }
            
            boolean isUsedByOtherContract = false;
            for (String path : confirmedPdfPaths) {
                if (path != null && path.equals(pdfPath)) {
                    isUsedByOtherContract = true;
                    break;
                }
            }
            
            if (!isUsedByOtherContract) {
                boolean deleted = pdfFile.delete();
                if (deleted) {
                    logger.info("이전 PDF 삭제: {}", pdfPath);
                }
                return deleted;
            } else {
                logger.info("이전 PDF 보존 (다른 계약에서 사용 중): {}", pdfPath);
                return false;
            }
        } catch (Exception e) {
            logger.warn("PDF 삭제 중 오류: {}", e.getMessage());
            return false;
        }
    }

    /** PDF 파일 경로에서 File 객체 반환. 상대 경로를 절대 경로로 변환. */
    @Override
    public File getPdfFile(String relativePath) {
        String baseDir = System.getProperty("user.dir");
        // 경로 구분자를 OS에 맞게 변환
        return new File(baseDir, relativePath.replace("/", File.separator));
    }

    /** PDF 파일 존재 여부 확인. */
    @Override
    public boolean existsPdfFile(String relativePath) {
        File file = getPdfFile(relativePath);
        // 파일이 존재하고 일반 파일인지 확인 (디렉토리가 아닌지)
        return file.exists() && file.isFile();
    }

    /** PDF 파일 제공. HTTP 응답용. Path Traversal 방지. */
    @Override
    public ResponseEntity<org.springframework.core.io.Resource> servePdfResource(String requestURI) {
        try {
            String baseDir = System.getProperty("user.dir");
            
            // /file/ 이후의 경로 추출
            String filePathStr = requestURI.substring(requestURI.indexOf("/file/") + "/file/".length());
            
            // 경로 세그먼트별로 디코딩 (슬래시는 유지)
            String[] segments = filePathStr.split("/");
            StringBuilder decodedPath = new StringBuilder();
            for (int i = 0; i < segments.length; i++) {
                if (i > 0) decodedPath.append("/");
                try {
                    decodedPath.append(java.net.URLDecoder.decode(segments[i], "UTF-8"));
                } catch (java.io.UnsupportedEncodingException e) {
                    decodedPath.append(segments[i]);
                }
            }
            
            // 경로 정규화
            String normalizedPath = decodedPath.toString().replace("\\", "/");
            
            // 보안 검증: contracts/로 시작하는지 확인
            if (!normalizedPath.startsWith("contracts/")) {
                return ResponseEntity.status(org.springframework.http.HttpStatus.BAD_REQUEST).build();
            }
            
            // 파일 경로 구성
            java.nio.file.Path filePath = java.nio.file.Paths.get(baseDir)
                .resolve(normalizedPath.replace("/", java.io.File.separator))
                .normalize();
            
            // 보안 검증: baseDir 밖으로 나가는 경로 차단
            java.nio.file.Path basePath = java.nio.file.Paths.get(baseDir).normalize();
            if (!filePath.startsWith(basePath)) {
                return ResponseEntity.status(org.springframework.http.HttpStatus.FORBIDDEN).build();
            }
            
            // 파일 존재 여부 확인
            org.springframework.core.io.Resource resource = new org.springframework.core.io.UrlResource(filePath.toUri());
            if (!resource.exists()) {
                return ResponseEntity.notFound().build();
            }
            
            return ResponseEntity.ok()
                .contentType(org.springframework.http.MediaType.APPLICATION_PDF)
                .body(resource);
                
        } catch (Exception e) {
            logger.error("PDF 파일 제공 중 오류: {}", e.getMessage(), e);
            return ResponseEntity.status(org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
