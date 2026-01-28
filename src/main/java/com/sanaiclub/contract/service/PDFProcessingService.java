package com.sanaiclub.contract.service;

import java.io.File;
import java.io.IOException;

/** PDF 처리 전용 서비스 인터페이스. PDFBox 기반 순수 PDF 처리 로직만 담당. */
public interface PDFProcessingService {

    /** PDF 파일에서 전체 텍스트 추출. 실패 시 빈 문자열 반환. */
    String extractText(File pdfFile) throws IOException;

    /** 업로드된 PDF 파일을 임시 디렉토리에 저장. */
    String saveTemporaryPDF(File uploadedFile, String originalFilename)
            throws IOException;

    /** PDF 파일의 전체 페이지 수 반환. */
    int getPageCount(File pdfFile) throws IOException;
}
