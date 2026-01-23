package com.sanaiclub.contract.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 계약서 파일 관리 서비스
 * 
 * [역할]
 * - PDF 파일 업로드/다운로드/삭제/이동 처리
 * - 파일 경로 정규화 및 관리
 * - 미확정 PDF 정리
 * 
 * [경로 규칙]
 * - 기본 경로: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
 * - freelancerId는 선택적 (업로드 시점에는 null일 수 있음)
 * 
 * [주요 기능]
 * - uploadPdf: PDF 파일 업로드
 * - normalizeAndMovePdfPath: 경로 정규화 및 파일 이동 (freelancerId 추가)
 * - cleanupUnconfirmedPdfs: 미확정 PDF 삭제
 * - deletePdfIfNotUsed: 사용하지 않는 PDF 삭제
 * 
 * [사용 시나리오]
 * - ContractController.uploadPdf(): PDF 업로드
 * - ContractController.confirmContract(): PDF 경로 정규화 및 이동
 */
@Service
public class ContractFileService {

    private static final Logger logger = LoggerFactory.getLogger(ContractFileService.class);

    /**
     * PDF 파일 업로드
     * 
     * [기능]
     * - MultipartFile을 서버에 저장
     * - 파일명에 타임스탬프 추가 (중복 방지)
     * 
     * [저장 경로]
     * - contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
     * - freelancerId가 null이면 contracts/{clientId}/{projectId}/{fileName}
     * 
     * [파일명 형식]
     * - {timestamp}_{originalFilename}
     * 
     * @param contractPdf 업로드할 PDF 파일
     * @param clientId 클라이언트 ID
     * @param projectId 프로젝트 ID
     * @param freelancerId 프리랜서 ID (선택, null 가능)
     * @return 업로드된 파일의 상대 경로 (contracts/{clientId}/{projectId}/{freelancerId}/{fileName})
     * @throws IllegalArgumentException PDF 파일이 없을 때
     * @throws IOException 파일 저장 실패 시
     */
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

    /**
     * PDF 파일 경로 정규화 및 이동
     * 
     * [기능]
     * - PDF 경로를 통합 경로 형식으로 정규화
     * - freelancerId가 경로에 없으면 추가하고 파일 이동/복사
     * 
     * [처리 시나리오]
     * 1. 경로에 freelancerId가 있으면 그대로 사용
     * 2. 경로에 freelancerId가 없으면:
     *    - 새 경로 생성: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
     *    - 기존 파일을 새 경로로 이동/복사
     * 
     * [파일 이동]
     * - renameTo() 시도 (이동)
     * - 실패 시 copy() 사용 (복사)
     * 
     * [사용 시나리오]
     * - ContractController.confirmContract()에서 PDF 타입일 때 호출
     * - 업로드 시점에는 freelancerId가 없었지만, 확정 시점에 추가
     * 
     * @param originContractUrl 원본 경로 (다양한 형식 가능)
     * @param clientId 클라이언트 ID
     * @param projectId 프로젝트 ID
     * @param freelancerId 프리랜서 ID
     * @return 정규화된 경로 (contracts/{clientId}/{projectId}/{freelancerId}/{fileName})
     */
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

    /**
     * 미확정 PDF 파일 삭제
     * 
     * [기능]
     * - 확정 시점에 이전 미확정 PDF 파일들을 정리
     * - DB에 저장된 확정된 PDF는 보존
     * 
     * [처리 로직]
     * 1. contracts/{clientId}/{projectId}/{freelancerId}/ 디렉토리 스캔
     * 2. 확정된 PDF 경로 목록과 비교
     * 3. 확정되지 않은 PDF 파일 삭제
     * 4. 현재 확정하는 파일은 제외
     * 
     * [사용 시나리오]
     * - ContractController.confirmContract()에서 확정 시점에 호출
     * - 여러 번 업로드한 PDF 중 확정되지 않은 것들 정리
     * 
     * @param clientId 클라이언트 ID
     * @param projectId 프로젝트 ID
     * @param freelancerId 프리랜서 ID
     * @param currentFileName 현재 확정하는 파일명 (삭제 제외)
     * @param confirmedPdfPaths DB에 저장된 확정된 PDF 경로 목록
     */
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

    /**
     * PDF 파일 삭제 (다른 계약에서 사용 중이 아닌 경우)
     * 
     * [기능]
     * - 계약 업데이트 시 이전 PDF가 다른 계약에서 사용 중인지 확인 후 삭제
     * 
     * [처리 로직]
     * 1. 다른 계약에서 사용 중인지 확인
     * 2. 사용 중이 아니면 삭제
     * 3. 사용 중이면 보존
     * 
     * [사용 시나리오]
     * - ContractController.confirmContract()에서 UPDATE 시 호출
     * - 이전 PDF가 현재 PDF와 다를 때
     * 
     * @param pdfPath 삭제할 PDF 경로
     * @param confirmedPdfPaths 다른 계약에서 사용 중인 PDF 경로 목록
     * @return 삭제 성공 여부
     */
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

    /**
     * PDF 파일 경로에서 File 객체 반환
     * 
     * @param relativePath 상대 경로 (contracts/...)
     * @return File 객체
     */
    public File getPdfFile(String relativePath) {
        String baseDir = System.getProperty("user.dir");
        return new File(baseDir, relativePath.replace("/", File.separator));
    }

    /**
     * PDF 파일 존재 여부 확인
     * 
     * @param relativePath 상대 경로
     * @return 존재 여부
     */
    public boolean existsPdfFile(String relativePath) {
        File file = getPdfFile(relativePath);
        return file.exists() && file.isFile();
    }
}
