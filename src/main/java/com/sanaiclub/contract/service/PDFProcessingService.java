package com.sanaiclub.contract.service;

import java.io.File;
import java.io.IOException;


public interface PDFProcessingService {

    /**
     * PDF 파일에서 전체 텍스트를 추출
     */
    String extractText(File pdfFile) throws IOException;

    /**
     * 업로드된 PDF 파일을 서버의 임시 디렉토리에 저장
     */
    String saveTemporaryPDF(File uploadedFile, String originalFilename)
            throws IOException;

    /**
     * PDF 파일의 전체 페이지 수를 반환
     */
    int getPageCount(File pdfFile) throws IOException;
}
