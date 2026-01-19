package com.sanaiclub.domain.contract.service;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * PDFProcessingServiceImpl
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [역할]
 * Apache PDFBox를 사용한 PDF 처리 구현입니다.
 * 
 * [설계 의도]
 * 1. 가볍고 신뢰할 수 있는 텍스트 추출
 * 2. 에러 처리 (손상된 PDF, 빈 파일 등)
 * 3. 한글 지원
 * 4. DB 저장 금지 (파일 경로만 저장)
 * 
 * [주의]
 * - 이미지 기반 PDF (스캔)는 텍스트 추출 불가
 * - 매우 큰 파일(>50MB)은 메모리 초과 가능
 * - 추출 텍스트는 AI 입력으로만 사용
 * 
 * [테스트]
 * 이 서비스는 test_files 페이지에서 업로드한 PDF로 테스트 가능
 */
@Service
public class PDFProcessingServiceImpl implements PDFProcessingService {
    
    // 임시 파일 저장 경로
    private static final String UPLOAD_DIR = 
        System.getProperty("user.home") + File.separator + "Desktop" + 
        File.separator + "test_uploads" + File.separator + "contracts";
    
    @Override
    public String extractText(File pdfFile) throws IOException {
        System.out.println("[PDF] 텍스트 추출 시작: " + pdfFile.getAbsolutePath());
        
        if (pdfFile == null || !pdfFile.exists()) {
            System.out.println("[PDF] 파일이 없습니다.");
            return null;
        }
        
        PDDocument document = null;
        try {
            // ════════════════════════════════════════════════════════════
            // 1단계: PDF 로드
            // ════════════════════════════════════════════════════════════
            document = PDDocument.load(pdfFile);
            
            if (document.isEncrypted()) {
                System.out.println("[PDF] 암호화된 PDF입니다.");
                // 암호가 없으면 빈 비밀번호로 시도
                document.setAllSecurityToBeRemoved(true);
            }
            
            // ════════════════════════════════════════════════════════════
            // 2단계: 텍스트 추출
            // ════════════════════════════════════════════════════════════
            PDFTextStripper stripper = new PDFTextStripper();
            stripper.setLineSeparator("\n");
            
            String text = stripper.getText(document);
            
            System.out.println("[PDF] 추출 완료: " + text.length() + " 자");
            System.out.println("[PDF] 페이지 수: " + document.getNumberOfPages());
            
            return text.isEmpty() ? null : text;
            
        } catch (Exception e) {
            System.out.println("[PDF] 추출 실패: " + e.getMessage());
            e.printStackTrace();
            return null;
            
        } finally {
            // ════════════════════════════════════════════════════════════
            // 3단계: 리소스 정리 (중요)
            // ════════════════════════════════════════════════════════════
            if (document != null) {
                try {
                    document.close();
                } catch (IOException e) {
                    System.out.println("[PDF] 문서 닫기 실패: " + e.getMessage());
                }
            }
        }
    }
    
    @Override
    public String saveTemporaryPDF(File uploadedFile, String originalFilename) 
            throws IOException {
        System.out.println("[PDF] 임시 저장 시작: " + originalFilename);
        
        if (uploadedFile == null || !uploadedFile.exists()) {
            throw new IOException("업로드된 파일이 없습니다.");
        }
        
        // ════════════════════════════════════════════════════════════
        // 1단계: 저장 경로 생성
        // ════════════════════════════════════════════════════════════
        File uploadDir = new File(UPLOAD_DIR);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
            System.out.println("[PDF] 디렉토리 생성: " + UPLOAD_DIR);
        }
        
        // ════════════════════════════════════════════════════════════
        // 2단계: 안전한 파일명 생성 (중복 방지)
        // ════════════════════════════════════════════════════════════
        String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String safeFilename = timestamp + "_" + originalFilename;
        
        // 경로 탐색 공격 방지
        safeFilename = safeFilename.replaceAll("[^a-zA-Z0-9._-]", "_");
        
        File destFile = new File(uploadDir, safeFilename);
        
        // ════════════════════════════════════════════════════════════
        // 3단계: 파일 복사
        // ════════════════════════════════════════════════════════════
        java.nio.file.Files.copy(
            uploadedFile.toPath(),
            destFile.toPath(),
            java.nio.file.StandardCopyOption.REPLACE_EXISTING
        );
        
        System.out.println("[PDF] 저장 완료: " + destFile.getAbsolutePath());
        
        // 상대 경로 반환 (origin_contract_url로 저장)
        return "uploads/contracts/" + safeFilename;
    }
    
    @Override
    public int getPageCount(File pdfFile) throws IOException {
        if (pdfFile == null || !pdfFile.exists()) {
            return 0;
        }
        
        PDDocument document = null;
        try {
            document = PDDocument.load(pdfFile);
            return document.getNumberOfPages();
        } finally {
            if (document != null) {
                document.close();
            }
        }
    }
}
