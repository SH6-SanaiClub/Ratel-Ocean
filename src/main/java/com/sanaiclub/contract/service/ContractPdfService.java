package com.sanaiclub.contract.service;

import com.sanaiclub.contract.model.vo.ContractClientVO;
import com.sanaiclub.contract.model.vo.ContractFreelancerVO;
import com.sanaiclub.contract.model.dto.ContractCreateRequestDTO;
import com.sanaiclub.contract.model.dto.ContractMilestoneRequestDTO;
import com.openhtmltopdf.pdfboxout.PdfRendererBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.text.NumberFormat;

/**
 * 계약서 PDF 생성 서비스
 * 
 * [역할]
 * - HTML 템플릿을 생성하고 OpenHTMLToPDF를 사용하여 PDF로 변환
 * - 계약서 양식에 클라이언트/프리랜서 정보 및 계약 내용을 채워서 PDF 생성
 * 
 * [기술 스택]
 * - OpenHTMLToPDF: HTML → PDF 변환 라이브러리
 * - 한글 폰트 지원: 맑은 고딕 (Windows 시스템 폰트)
 * 
 * [처리 흐름]
 * 1. generateContractHtml(): HTML 템플릿 생성
 * 2. OpenHTMLToPDF로 HTML → PDF 변환
 * 3. 파일 저장 및 유효성 검증
 * 
 * [사용 시나리오]
 * - ContractController.confirmContract()에서 직접 작성(FORM) 시 호출
 * - 저장 경로: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}
 */
@Service
public class ContractPdfService {

    private static final Logger logger = LoggerFactory.getLogger(ContractPdfService.class);

    /**
     * 계약서 PDF 생성
     * 
     * [기능]
     * - 클라이언트/프리랜서 정보와 계약 내용을 HTML 템플릿에 채워서 PDF 생성
     * - OpenHTMLToPDF를 사용하여 HTML → PDF 변환
     * 
     * [처리 흐름]
     * 1. HTML 템플릿 생성 (generateContractHtml)
     * 2. 디렉토리 생성 (없으면)
     * 3. 한글 폰트 로드 (맑은 고딕)
     * 4. OpenHTMLToPDF로 PDF 생성
     * 5. PDF 유효성 검증 (헤더 확인)
     * 
     * [한글 폰트]
     * - Windows 시스템 폰트 경로에서 맑은 고딕 로드
     * - 폰트 로드 실패 시 기본 폰트 사용 (한글 깨짐 가능)
     * 
     * @param client 클라이언트 정보
     * @param freelancer 프리랜서 정보
     * @param form 계약 내용 (계약 목적, 업무 범위, 지급 조건 등)
     * @param saveDir PDF 저장 디렉토리 (절대 경로)
     * @param fileName PDF 파일명
     * @return 생성된 PDF 파일
     * @throws IOException PDF 생성 실패 시
     */
    public File generateContractPdf(
            ContractClientVO client,
            ContractFreelancerVO freelancer,
            ContractCreateRequestDTO form,
            String saveDir,
            String fileName
    ) throws IOException {
        logger.info("PDF 생성 시작 (OpenHTMLToPDF) - 저장 경로: {}, 파일명: {}", saveDir, fileName);
        
        // HTML 생성
        String html = generateContractHtml(client, freelancer, form);
        
        // 디렉토리 생성
        File dir = new File(saveDir);
        if (!dir.exists()) {
            boolean created = dir.mkdirs();
            logger.info("디렉토리 생성: {} (성공: {})", saveDir, created);
        }
        
        // PDF 파일 생성
        File pdfFile = new File(dir, fileName);
        
        // HTML 디버깅용 저장 (선택적)
        try {
            File htmlDebugFile = new File(dir, fileName.replace(".pdf", "_debug.html"));
            try (java.io.FileWriter writer = new java.io.FileWriter(htmlDebugFile)) {
                writer.write(html);
            }
            logger.debug("HTML 디버그 파일 저장: {}", htmlDebugFile.getAbsolutePath());
        } catch (Exception e) {
            logger.warn("HTML 디버그 파일 저장 실패 (무시): {}", e.getMessage());
        }
        
        try (OutputStream os = new FileOutputStream(pdfFile)) {
            PdfRendererBuilder builder = new PdfRendererBuilder();
            
            // 한글 폰트 로드 (Windows 시스템 폰트 경로)
            try {
                // 맑은 고딕 폰트 로드 (여러 이름으로 등록)
                String[] fontPaths = {
                    "C:/Windows/Fonts/malgun.ttf",           // 맑은 고딕
                    "C:/Windows/Fonts/malgunbd.ttf"          // 맑은 고딕 Bold
                };
                
                boolean fontLoaded = false;
                for (String fontPath : fontPaths) {
                    File fontFile = new File(fontPath);
                    if (fontFile.exists() && fontFile.isFile()) {
                        try {
                            // OpenHTMLToPDF는 폰트 패밀리 이름으로 등록
                            builder.useFont(fontFile, "Malgun Gothic");
                            builder.useFont(fontFile, "맑은 고딕");
                            logger.debug("폰트 로드 성공: {}", fontPath);
                            fontLoaded = true;
                            break;
                        } catch (Exception e) {
                            logger.warn("폰트 로드 실패: {} - {}", fontPath, e.getMessage());
                        }
                    }
                }
                
                if (!fontLoaded) {
                    logger.warn("한글 폰트를 찾을 수 없습니다. 기본 폰트를 사용합니다.");
                }
            } catch (Exception e) {
                logger.warn("폰트 로드 중 오류 (계속 진행): {}", e.getMessage());
            }
            
            // HTML 콘텐츠 설정 (baseUri를 현재 디렉토리로 설정)
            builder.withHtmlContent(html, dir.getAbsolutePath());
            builder.toStream(os);
            
            // A4 페이지 크기 설정
            builder.useDefaultPageSize(210, 297, PdfRendererBuilder.PageSizeUnits.MM);
            
            // PDF 생성 실행
            try {
                builder.run();
                // OutputStream이 제대로 닫히도록 명시적으로 flush
                os.flush();
            } catch (Exception e) {
                logger.error("PDF 렌더링 중 오류: {}", e.getMessage(), e);
                throw e;
            }
            
            // 파일이 제대로 생성되었는지 확인
            if (!pdfFile.exists()) {
                throw new IOException("PDF 파일이 생성되지 않았습니다.");
            }
            
            if (pdfFile.length() == 0) {
                throw new IOException("PDF 파일이 비어있습니다. (크기: 0 bytes)");
            }
            
            // PDF 파일 유효성 검증 (간단한 헤더 확인)
            try (java.io.FileInputStream fis = new java.io.FileInputStream(pdfFile)) {
                byte[] header = new byte[4];
                fis.read(header);
                String headerStr = new String(header);
                if (!headerStr.startsWith("%PDF")) {
                    throw new IOException("생성된 파일이 유효한 PDF가 아닙니다. (헤더: " + headerStr + ")");
                }
            }
            
            logger.info("PDF 생성 완료: {} (크기: {} bytes)", pdfFile.getAbsolutePath(), pdfFile.length());
            
        } catch (Exception e) {
            logger.error("PDF 생성 중 예외 발생: {}", e.getMessage(), e);
            
            // 생성 실패한 파일 삭제
            if (pdfFile.exists()) {
                if (pdfFile.length() == 0) {
                    boolean deleted = pdfFile.delete();
                    logger.info("빈 파일 삭제: {}", deleted);
                } else {
                    logger.warn("손상된 PDF 파일이 남아있을 수 있습니다: {}", pdfFile.getAbsolutePath());
                }
            }
            
            throw new IOException("PDF 생성 실패: " + e.getMessage(), e);
        }
        
        return pdfFile;
    }
    
    /**
     * 계약서 HTML 템플릿 생성
     * 
     * [기능]
     * - 클라이언트/프리랜서 정보와 계약 내용을 HTML 템플릿에 채워서 반환
     * - 전문적인 계약서 양식 (제1조~제7조)
     * 
     * [HTML 구조]
     * - DOCTYPE 선언 (&nbsp; 엔티티 포함)
     * - CSS 스타일 (A4 페이지, 한글 폰트, 테이블 스타일 등)
     * - 제1조: 당사자 (발주자/수주자)
     * - 제2조: 계약의 목적 및 범위
     * - 제3조: 계약 기간 및 금액
     * - 제4조: 지급 방식
     * - 제5조: 마일스톤 (MILESTONE 타입일 때)
     * - 제6조: 지급 조건 및 일정
     * - 제7조: 기타 특약 사항
     * 
     * [데이터 처리]
     * - null/빈 문자열 체크 및 trim 처리
     * - HTML 이스케이프 (XSS 방지)
     * - 숫자 포맷팅 (금액)
     * 
     * @param client 클라이언트 정보
     * @param freelancer 프리랜서 정보
     * @param form 계약 내용
     * @return HTML 템플릿 문자열
     * @throws IllegalArgumentException 필수 파라미터가 null일 때
     */
    private String generateContractHtml(
            ContractClientVO client,
            ContractFreelancerVO freelancer,
            ContractCreateRequestDTO form
    ) {
        // null 체크
        if (client == null) {
            throw new IllegalArgumentException("client는 null일 수 없습니다.");
        }
        if (freelancer == null) {
            throw new IllegalArgumentException("freelancer는 null일 수 없습니다.");
        }
        if (form == null) {
            throw new IllegalArgumentException("form은 null일 수 없습니다.");
        }
        
        logger.debug("PDF 생성 데이터 - Client: {}, Freelancer: {}, StartDate: {}, EndDate: {}, Budget: {}", 
            client.getClientName(),
            freelancer.getName(),
            form.getContractStartDate(),
            form.getContractEndDate(),
            form.getTotalBudget());
        
        NumberFormat nf = NumberFormat.getInstance();
        
        StringBuilder html = new StringBuilder();
        html.append("<!DOCTYPE html [\n");
        html.append("  <!ENTITY nbsp \"&#160;\">\n");
        html.append("]>\n");
        html.append("<html>\n");
        html.append("<head>\n");
        html.append("<meta charset=\"UTF-8\" />\n");
        html.append("<style>\n");
        html.append("@page {\n");
        html.append("    size: A4;\n");
        html.append("    margin: 2cm 2.5cm;\n");
        html.append("}\n");
        html.append("body, * {\n");
        html.append("    font-family: 'Malgun Gothic', '맑은 고딕', sans-serif !important;\n");
        html.append("}\n");
        html.append("body {\n");
        html.append("    font-size: 11pt;\n");
        html.append("    line-height: 1.6;\n");
        html.append("    color: #333;\n");
        html.append("    margin: 0;\n");
        html.append("    padding: 0;\n");
        html.append("}\n");
        html.append(".header {\n");
        html.append("    text-align: center;\n");
        html.append("    border-bottom: 3px solid #2c3e50;\n");
        html.append("    padding-bottom: 20px;\n");
        html.append("    margin-bottom: 30px;\n");
        html.append("}\n");
        html.append(".header h1 {\n");
        html.append("    font-size: 28pt;\n");
        html.append("    font-weight: bold;\n");
        html.append("    color: #2c3e50;\n");
        html.append("    margin: 0 0 10px 0;\n");
        html.append("    letter-spacing: 2px;\n");
        html.append("}\n");
        html.append(".section {\n");
        html.append("    margin-bottom: 25px;\n");
        html.append("    page-break-inside: avoid;\n");
        html.append("}\n");
        html.append(".section-title {\n");
        html.append("    font-size: 14pt;\n");
        html.append("    font-weight: bold;\n");
        html.append("    color: #2c3e50;\n");
        html.append("    background-color: #ecf0f1;\n");
        html.append("    padding: 10px 15px;\n");
        html.append("    margin-bottom: 15px;\n");
        html.append("    border-left: 5px solid #3498db;\n");
        html.append("}\n");
        html.append(".party-info {\n");
        html.append("    display: flex;\n");
        html.append("    gap: 20px;\n");
        html.append("    margin-bottom: 20px;\n");
        html.append("}\n");
        html.append(".party-box {\n");
        html.append("    flex: 1;\n");
        html.append("    border: 2px solid #bdc3c7;\n");
        html.append("    border-radius: 8px;\n");
        html.append("    padding: 15px;\n");
        html.append("    background-color: #f8f9fa;\n");
        html.append("}\n");
        html.append(".party-box h3 {\n");
        html.append("    font-size: 12pt;\n");
        html.append("    font-weight: bold;\n");
        html.append("    color: #2c3e50;\n");
        html.append("    margin: 0 0 10px 0;\n");
        html.append("    padding-bottom: 8px;\n");
        html.append("    border-bottom: 1px solid #bdc3c7;\n");
        html.append("}\n");
        html.append(".party-box p {\n");
        html.append("    margin: 5px 0;\n");
        html.append("    font-size: 10pt;\n");
        html.append("    color: #555;\n");
        html.append("}\n");
        html.append(".info-table {\n");
        html.append("    width: 100%;\n");
        html.append("    border-collapse: collapse;\n");
        html.append("    margin: 15px 0;\n");
        html.append("}\n");
        html.append(".info-table th,\n");
        html.append(".info-table td {\n");
        html.append("    border: 1px solid #ddd;\n");
        html.append("    padding: 12px;\n");
        html.append("    text-align: left;\n");
        html.append("}\n");
        html.append(".info-table th {\n");
        html.append("    background-color: #34495e;\n");
        html.append("    color: white;\n");
        html.append("    font-weight: bold;\n");
        html.append("    width: 25%;\n");
        html.append("}\n");
        html.append(".info-table td {\n");
        html.append("    background-color: #fff;\n");
        html.append("}\n");
        html.append(".content-box {\n");
        html.append("    background-color: #f8f9fa;\n");
        html.append("    border-left: 4px solid #3498db;\n");
        html.append("    padding: 15px;\n");
        html.append("    margin: 10px 0;\n");
        html.append("    border-radius: 4px;\n");
        html.append("}\n");
        html.append(".content-box h4 {\n");
        html.append("    font-size: 11pt;\n");
        html.append("    font-weight: bold;\n");
        html.append("    color: #2c3e50;\n");
        html.append("    margin: 0 0 10px 0;\n");
        html.append("}\n");
        html.append(".content-box p {\n");
        html.append("    margin: 5px 0;\n");
        html.append("    white-space: pre-wrap;\n");
        html.append("    word-wrap: break-word;\n");
        html.append("    line-height: 1.8;\n");
        html.append("}\n");
        html.append(".milestone-list {\n");
        html.append("    list-style: none;\n");
        html.append("    padding: 0;\n");
        html.append("    margin: 10px 0;\n");
        html.append("}\n");
        html.append(".milestone-item {\n");
        html.append("    background-color: #fff;\n");
        html.append("    border: 1px solid #ddd;\n");
        html.append("    border-radius: 6px;\n");
        html.append("    padding: 12px;\n");
        html.append("    margin-bottom: 10px;\n");
        html.append("}\n");
        html.append(".milestone-item strong {\n");
        html.append("    color: #2c3e50;\n");
        html.append("    font-size: 11pt;\n");
        html.append("}\n");
        html.append(".milestone-amount {\n");
        html.append("    color: #e74c3c;\n");
        html.append("    font-weight: bold;\n");
        html.append("    float: right;\n");
        html.append("}\n");
        html.append(".footer {\n");
        html.append("    margin-top: 40px;\n");
        html.append("    padding-top: 20px;\n");
        html.append("    border-top: 2px solid #bdc3c7;\n");
        html.append("    text-align: center;\n");
        html.append("    font-size: 9pt;\n");
        html.append("    color: #7f8c8d;\n");
        html.append("}\n");
        html.append("</style>\n");
        html.append("</head>\n");
        html.append("<body>\n");
        
        // 헤더
        html.append("<div class=\"header\">\n");
        html.append("    <h1>계약서</h1>\n");
        html.append("    <p style=\"font-size: 10pt; color: #7f8c8d;\">CONTRACT AGREEMENT</p>\n");
        html.append("</div>\n");
        
        // 제1조: 당사자
        html.append("<div class=\"section\">\n");
        html.append("    <div class=\"section-title\">제1조 (당사자)</div>\n");
        html.append("    <div class=\"party-info\">\n");
        
        // 발주자
        html.append("        <div class=\"party-box\">\n");
        html.append("            <h3>발주자 (갑)</h3>\n");
        html.append("            <p style=\"font-size: 12pt; font-weight: bold; color: #2c3e50; margin-bottom: 10px;\">")
            .append(escapeHtml(client.getClientName() != null ? client.getClientName() : "-")).append("</p>\n");
        if (client.getEmail() != null) {
            html.append("            <p><strong>이메일:</strong> ").append(escapeHtml(client.getEmail())).append("</p>\n");
        }
        if (client.getPhone() != null) {
            html.append("            <p><strong>연락처:</strong> ").append(escapeHtml(client.getPhone())).append("</p>\n");
        }
        if (client.getCompanyName() != null && !client.getCompanyName().trim().isEmpty()) {
            html.append("            <p><strong>회사명:</strong> ").append(escapeHtml(client.getCompanyName())).append("</p>\n");
        }
        html.append("        </div>\n");
        
        // 수주자
        html.append("        <div class=\"party-box\">\n");
        html.append("            <h3>수주자 (을)</h3>\n");
        html.append("            <p style=\"font-size: 12pt; font-weight: bold; color: #2c3e50; margin-bottom: 10px;\">")
            .append(escapeHtml(freelancer.getName() != null ? freelancer.getName() : "-")).append("</p>\n");
        if (freelancer.getEmail() != null) {
            html.append("            <p><strong>이메일:</strong> ").append(escapeHtml(freelancer.getEmail())).append("</p>\n");
        }
        if (freelancer.getPhone() != null) {
            html.append("            <p><strong>연락처:</strong> ").append(escapeHtml(freelancer.getPhone())).append("</p>\n");
        }
        html.append("        </div>\n");
        
        html.append("    </div>\n");
        html.append("</div>\n");
        
        // 제2조: 계약의 목적 및 범위
        String contractPurpose = (form.getContractPurpose() != null && !form.getContractPurpose().trim().isEmpty()) 
            ? form.getContractPurpose().trim() : null;
        String workScope = (form.getWorkScope() != null && !form.getWorkScope().trim().isEmpty()) 
            ? form.getWorkScope().trim() : null;
        String deliverables = (form.getDeliverables() != null && !form.getDeliverables().trim().isEmpty()) 
            ? form.getDeliverables().trim() : null;
        
        if (contractPurpose != null || workScope != null || deliverables != null) {
            html.append("<div class=\"section\">\n");
            html.append("    <div class=\"section-title\">제2조 (계약의 목적 및 범위)</div>\n");
            
            if (contractPurpose != null) {
                html.append("    <div class=\"content-box\">\n");
                html.append("        <h4>계약 목적</h4>\n");
                html.append("        <p>").append(escapeHtml(contractPurpose)).append("</p>\n");
                html.append("    </div>\n");
            }
            
            if (workScope != null) {
                html.append("    <div class=\"content-box\">\n");
                html.append("        <h4>업무 범위</h4>\n");
                html.append("        <p>").append(escapeHtml(workScope)).append("</p>\n");
                html.append("    </div>\n");
            }
            
            if (deliverables != null) {
                html.append("    <div class=\"content-box\">\n");
                html.append("        <h4>결과물 정의</h4>\n");
                html.append("        <p>").append(escapeHtml(deliverables)).append("</p>\n");
                html.append("    </div>\n");
            }
            
            html.append("</div>\n");
        }
        
        // 제3조: 계약 기간 및 금액
        html.append("<div class=\"section\">\n");
        html.append("    <div class=\"section-title\">제3조 (계약 기간 및 금액)</div>\n");
        html.append("    <table class=\"info-table\">\n");
        
        if (form.getContractStartDate() != null) {
            html.append("        <tr>\n");
            html.append("            <th>계약 시작일</th>\n");
            html.append("            <td>").append(escapeHtml(form.getContractStartDate())).append("</td>\n");
            html.append("        </tr>\n");
        }
        
        if (form.getContractEndDate() != null) {
            html.append("        <tr>\n");
            html.append("            <th>계약 종료일</th>\n");
            html.append("            <td>").append(escapeHtml(form.getContractEndDate())).append("</td>\n");
            html.append("        </tr>\n");
        }
        
        if (form.getTotalBudget() != null) {
            html.append("        <tr>\n");
            html.append("            <th>총 계약금액</th>\n");
            html.append("            <td style=\"font-weight: bold; color: #e74c3c; font-size: 12pt;\">")
                .append(nf.format(form.getTotalBudget())).append("원</td>\n");
            html.append("        </tr>\n");
        }
        
        html.append("    </table>\n");
        html.append("</div>\n");
        
        // 제4조: 지급 방식
        html.append("<div class=\"section\">\n");
        html.append("    <div class=\"section-title\">제4조 (지급 방식)</div>\n");
        html.append("    <div class=\"content-box\">\n");
        String paymentMethodText = "FULL".equals(form.getPaymentMethod()) 
                ? "일시 지급 (계약 완료 시 일괄 지급)" 
                : "분할 지급 (마일스톤별 단계적 지급)";
        html.append("        <p>").append(escapeHtml(paymentMethodText)).append("</p>\n");
        html.append("    </div>\n");
        html.append("</div>\n");
        
        // 제5조: 마일스톤
        if ("MILESTONE".equals(form.getPaymentMethod()) && form.getMilestones() != null && !form.getMilestones().isEmpty()) {
            html.append("<div class=\"section\">\n");
            html.append("    <div class=\"section-title\">제5조 (마일스톤 및 단계별 지급)</div>\n");
            html.append("    <ul class=\"milestone-list\">\n");
            
            for (ContractMilestoneRequestDTO milestone : form.getMilestones()) {
                html.append("        <li class=\"milestone-item\">\n");
                html.append("            <strong>").append(milestone.getStep()).append("단계: ")
                    .append(escapeHtml(milestone.getTitle())).append("</strong>\n");
                html.append("            <span class=\"milestone-amount\">")
                    .append(nf.format(milestone.getAmount())).append("원</span>\n");
                if (milestone.getDescription() != null && !milestone.getDescription().trim().isEmpty()) {
                    html.append("            <p style=\"margin-top: 8px; color: #555;\">")
                        .append(escapeHtml(milestone.getDescription())).append("</p>\n");
                }
                html.append("        </li>\n");
            }
            
            html.append("    </ul>\n");
            html.append("</div>\n");
        }
        
        // 제6조: 지급 조건 및 일정
        String paymentCondition = (form.getPaymentCondition() != null && !form.getPaymentCondition().trim().isEmpty()) 
            ? form.getPaymentCondition().trim() : null;
        String scheduleCondition = (form.getScheduleCondition() != null && !form.getScheduleCondition().trim().isEmpty()) 
            ? form.getScheduleCondition().trim() : null;
        
        if (paymentCondition != null || scheduleCondition != null) {
            html.append("<div class=\"section\">\n");
            html.append("    <div class=\"section-title\">제6조 (지급 조건 및 일정)</div>\n");
            
            if (paymentCondition != null) {
                html.append("    <div class=\"content-box\">\n");
                html.append("        <h4>지급 조건</h4>\n");
                html.append("        <p>").append(escapeHtml(paymentCondition)).append("</p>\n");
                html.append("    </div>\n");
            }
            
            if (scheduleCondition != null) {
                html.append("    <div class=\"content-box\">\n");
                html.append("        <h4>일정 관련 조건</h4>\n");
                html.append("        <p>").append(escapeHtml(scheduleCondition)).append("</p>\n");
                html.append("    </div>\n");
            }
            
            html.append("</div>\n");
        }
        
        // 제7조: 기타 특약 사항
        String specialTerms = (form.getSpecialTerms() != null && !form.getSpecialTerms().trim().isEmpty()) 
            ? form.getSpecialTerms().trim() : null;
        if (specialTerms != null) {
            html.append("<div class=\"section\">\n");
            html.append("    <div class=\"section-title\">제7조 (기타 특약 사항)</div>\n");
            html.append("    <div class=\"content-box\">\n");
            html.append("        <p>").append(escapeHtml(specialTerms)).append("</p>\n");
            html.append("    </div>\n");
            html.append("</div>\n");
        }
        
        // 푸터
        html.append("<div class=\"footer\">\n");
        html.append("    <p>본 계약서는 양 당사자가 서명함으로써 효력을 발생합니다.</p>\n");
        html.append("    <p style=\"margin-top: 20px;\">\n");
        html.append("        <strong>발주자 (갑)</strong> ").append(escapeHtml(client.getClientName() != null ? client.getClientName() : "")).append(" (서명) &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n");
        html.append("        <strong>수주자 (을)</strong> ").append(escapeHtml(freelancer.getName() != null ? freelancer.getName() : "")).append(" (서명)\n");
        html.append("    </p>\n");
        html.append("</div>\n");
        
        html.append("</body>\n");
        html.append("</html>\n");
        
        return html.toString();
    }
    
    /**
     * HTML 이스케이프
     */
    private String escapeHtml(String text) {
        if (text == null || text.trim().isEmpty()) {
            return "";
        }
        // 개행 문자를 <br>로 변환하고 HTML 특수문자 이스케이프
        return text.replace("&", "&amp;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;")
                   .replace("'", "&#39;")
                   .replace("\n", "<br>")
                   .replace("\r", "");
    }
}
