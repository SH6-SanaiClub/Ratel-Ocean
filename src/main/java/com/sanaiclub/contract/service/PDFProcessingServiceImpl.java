package com.sanaiclub.contract.service;

import org.springframework.stereotype.Service;
import java.io.File;
import java.io.IOException;

@Service
public class PDFProcessingServiceImpl implements PDFProcessingService {

    @Override
    public String extractText(File pdfFile) {
        // TODO: 나중에 PDFBox 연동
        // 지금은 구조만 맞추기
        return "";
    }

    @Override
    public String saveTemporaryPDF(File uploadedFile, String originalFilename) throws IOException {
        return "";
    }

    @Override
    public int getPageCount(File pdfFile) throws IOException {
        return 0;
    }
}
