package com.sanaiclub.contract.service;

import java.io.File;
import java.io.IOException;

/**
 * PDF 처리 전용 서비스 인터페이스
 * 
 * [파일 역할]
 * 이 파일은 인터페이스(Interface)로, PDF 처리 서비스가 제공해야 하는 메서드들의 
 * 계약(Contract)을 정의합니다. 실제 구현 로직은 포함하지 않으며, 메서드 시그니처만 선언합니다.
 * 
 * [인터페이스 vs 구현체]
 * - 이 파일 (PDFProcessingService): "무엇을" 해야 하는지 정의 (What)
 * - PDFProcessingServiceImpl: "어떻게" 구현할지 정의 (How)
 * 
 * [역할]
 * - PDF 파일에서 텍스트 추출
 * - PDF 파일 임시 저장
 * - PDF 메타 정보 조회
 *
 * [설계 원칙]
 * - 이 서비스는 계약 도메인을 모른다
 * - 이 서비스는 AI를 모른다
 * - 이 서비스는 DB를 모른다
 *
 * 즉, PDFBox 기반의 순수 PDF 처리 로직만 담당한다.
 * 
 * [사용 예시]
 * PDFProcessingService service = new PDFProcessingServiceImpl();
 * String text = service.extractText(pdfFile);
 * 
 * @see PDFProcessingServiceImpl 이 인터페이스의 구현체
 */
public interface PDFProcessingService {

    /**
     * PDF 파일에서 전체 텍스트를 추출한다.
     *
     * @param pdfFile
     *  - 처리 대상 PDF 파일
     *
     * @return
     *  - 추출된 텍스트
     *  - 실패 시 빈 문자열 반환 (null 반환 금지)
     *
     * @throws IOException
     *  - PDF 파싱 중 I/O 오류 발생 시
     */
    String extractText(File pdfFile) throws IOException;

    /**
     * 업로드된 PDF 파일을 서버의 임시 디렉토리에 저장한다.
     *
     * @param uploadedFile
     *  - 업로드된 PDF 파일 (File 형태)
     *
     * @param originalFilename
     *  - 원본 파일명
     *
     * @return
     *  - 저장된 PDF 파일의 상대 경로
     *
     * @throws IOException
     *  - 파일 저장 실패 시
     */
    String saveTemporaryPDF(File uploadedFile, String originalFilename)
            throws IOException;

    /**
     * PDF 파일의 전체 페이지 수를 반환한다.
     *
     * @param pdfFile
     *  - PDF 파일
     *
     * @return
     *  - 전체 페이지 수
     *
     * @throws IOException
     *  - PDF 로딩 실패 시
     */
    int getPageCount(File pdfFile) throws IOException;
}
