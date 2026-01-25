package com.sanaiclub.contract.service.impl;

import com.sanaiclub.contract.service.PDFProcessingService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import java.io.File;
import java.io.IOException;

@Slf4j
@Service("pdfProcessingServiceImpl")
public class PDFProcessingServiceImpl implements PDFProcessingService {

    @Override
    public String extractText(File pdfFile) throws IOException {
        try (org.apache.pdfbox.pdmodel.PDDocument doc = org.apache.pdfbox.pdmodel.PDDocument.load(pdfFile)) {
            org.apache.pdfbox.text.PDFTextStripper stripper = new org.apache.pdfbox.text.PDFTextStripper();
            return stripper.getText(doc);
        } catch (Exception e) {
            log.error("PDF 텍스트 추출 실패: {}", e.getMessage(), e);
            return "";
        }
    }

    @Override
    public String saveTemporaryPDF(File uploadedFile, String originalFilename) throws IOException {
        // 임시 디렉토리에 저장
        String tempDir = System.getProperty("java.io.tmpdir");
        File tempFile = new File(tempDir, "contract_" + System.currentTimeMillis() + "_" + originalFilename);
        java.nio.file.Files.copy(uploadedFile.toPath(), tempFile.toPath(), java.nio.file.StandardCopyOption.REPLACE_EXISTING);
        return tempFile.getAbsolutePath();
    }

    @Override
    public int getPageCount(File pdfFile) throws IOException {
        try (org.apache.pdfbox.pdmodel.PDDocument doc = org.apache.pdfbox.pdmodel.PDDocument.load(pdfFile)) {
            return doc.getNumberOfPages();
        } catch (Exception e) {
            log.error("PDF 페이지 수 조회 실패: {}", e.getMessage(), e);
            return 0;
        }
    }
}
