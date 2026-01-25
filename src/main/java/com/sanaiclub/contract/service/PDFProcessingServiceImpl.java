package com.sanaiclub.contract.service;

import com.sanaiclub.contract.service.PDFProcessingService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import java.io.File;
import java.io.IOException;

/**
 * PDF 처리 서비스 구현체
 * 
 * [파일 역할]
 * 이 파일은 PDFProcessingService 인터페이스의 실제 구현체(Implementation)입니다.
 * 인터페이스에서 정의한 메서드들의 구체적인 로직을 구현하며, PDFBox 라이브러리를 사용하여
 * 실제 PDF 파일 처리를 수행합니다.
 * 
 * [인터페이스 vs 구현체]
 * - PDFProcessingService (인터페이스): "무엇을" 해야 하는지 정의 (What)
 * - 이 파일 (PDFProcessingServiceImpl): "어떻게" 구현할지 정의 (How)
 * 
 * [주요 특징]
 * - @Service 어노테이션으로 Spring 빈으로 등록되어 의존성 주입 가능
 * - @Override로 인터페이스의 메서드를 구현
 * - PDFBox 라이브러리를 사용한 실제 PDF 처리 로직 포함
 * - 예외 처리 및 로깅 기능 포함
 * 
 * [설계 패턴]
 * 인터페이스와 구현체를 분리함으로써:
 * - 구현체를 다른 구현체로 교체 가능 (예: 테스트용 Mock 구현체)
 * - 단위 테스트 시 Mock 객체 주입 용이
 * - 코드의 유연성과 확장성 향상
 * 
 * @see PDFProcessingService 이 클래스가 구현하는 인터페이스
 */
@Slf4j
@Service("pdfProcessingServiceImpl")
public class PDFProcessingServiceImpl implements PDFProcessingService {

    /**
     * PDF 파일에서 텍스트를 추출합니다.
     * 
     * @param pdfFile 추출할 PDF 파일
     * @return 추출된 텍스트 문자열, 실패 시 빈 문자열 반환
     * @throws IOException 파일 읽기 오류 시 발생
     */
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

    /**
     * 업로드된 PDF 파일을 임시 디렉토리에 저장합니다.
     * 
     * @param uploadedFile 업로드된 파일
     * @param originalFilename 원본 파일명
     * @return 저장된 임시 파일의 절대 경로
     * @throws IOException 파일 복사 오류 시 발생
     */
    @Override
    public String saveTemporaryPDF(File uploadedFile, String originalFilename) throws IOException {
        // 임시 디렉토리에 저장
        String tempDir = System.getProperty("java.io.tmpdir");
        File tempFile = new File(tempDir, "contract_" + System.currentTimeMillis() + "_" + originalFilename);
        java.nio.file.Files.copy(uploadedFile.toPath(), tempFile.toPath(), java.nio.file.StandardCopyOption.REPLACE_EXISTING);
        return tempFile.getAbsolutePath();
    }

    /**
     * PDF 파일의 페이지 수를 조회합니다.
     * 
     * @param pdfFile 조회할 PDF 파일
     * @return PDF 파일의 페이지 수, 실패 시 0 반환
     * @throws IOException 파일 읽기 오류 시 발생
     */
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
