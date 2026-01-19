package com.sanaiclub.domain.contract.service;

import java.io.File;
import java.io.IOException;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * PDFProcessingService (Interface)
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [역할]
 * 계약 PDF 파일을 처리하는 서비스의 표준 인터페이스입니다.
 * 
 * [설계 의도]
 * 1. PDF에서 텍스트만 추출 (문서 구조 보존 X)
 * 2. 추출 텍스트는 AI 입력으로만 사용 (DB 저장 X)
 * 3. 원본 PDF 파일은 임시 디렉토리에 저장
 * 4. 계약 확정 후 origin_contract_url 저장
 * 
 * [플로우]
 * 사용자 PDF 업로드
 *   → PDFProcessingService.extractText()
 *   → AI 입력으로 사용
 *   → 계약 확정 시 파일 경로만 DB 저장
 * 
 * [주의]
 * - 추출된 텍스트 자체를 DB에 저장하지 말 것
 * - 파일은 임시 디렉토리(temp/)에 저장
 * - 원본 파일 경로는 origin_contract_url로만 관리
 */
public interface PDFProcessingService {
    
    /**
     * PDF 파일에서 텍스트를 추출합니다.
     * 
     * [입력]
     * @param pdfFile : 업로드된 PDF 파일
     * 
     * [출력]
     * @return 추출된 텍스트
     *         - PDF가 비어있으면 ""
     *         - 추출 실패하면 null
     * 
     * [특징]
     * - 텍스트만 추출 (이미지, 표는 무시)
     * - 한글 인코딩 지원
     * - 페이지별 줄 바꿈 포함
     * 
     * [사용 예시]
     * String pdfText = pdfService.extractText(uploadedFile);
     * AIContractInsightDTO insight = aiService.analyzeContract(pdfText, ...);
     */
    String extractText(File pdfFile) throws IOException;
    
    /**
     * PDF 파일을 임시 디렉토리에 저장합니다.
     * 
     * [입력]
     * @param uploadedFile : 사용자가 업로드한 파일
     * @param originalFilename : 원본 파일명
     * 
     * [출력]
     * @return 저장된 파일 경로 (예: "contracts/20260116_143025_contract.pdf")
     *         추후 origin_contract_url로 DB 저장
     * 
     * [저장 위치]
     * ${CATALINA_HOME}/webapps/ratelocean/uploads/contracts/
     * 또는 설정된 임시 디렉토리
     * 
     * [파일명 규칙]
     * timestamp_originalFilename 형식으로 중복 방지
     */
    String saveTemporaryPDF(File uploadedFile, String originalFilename) throws IOException;
    
    /**
     * PDF 파일의 페이지 수를 반환합니다.
     * 
     * [목적]
     * - UI에서 "페이지 수 표시"
     * - 텍스트 추출 검증
     * 
     * @param pdfFile : PDF 파일
     * @return 페이지 수 (최소 1)
     */
    int getPageCount(File pdfFile) throws IOException;
}
