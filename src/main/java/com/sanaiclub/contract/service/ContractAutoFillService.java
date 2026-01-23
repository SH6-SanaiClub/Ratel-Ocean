package com.sanaiclub.contract.service;

import java.io.File;
import com.sanaiclub.contract.model.dto.ContractAutoFillDTO;

/**
 * 계약 자동 초안 생성 서비스
 *
 * [역할]
 * - PDF 계약서
 * - 사용자가 직접 입력한 계약 내용
 * - 프로젝트/프리랜서 정보
 * 를 종합하여
 * "계약 주요 정보 초안"을 생성
 *
 * [중요]
 * - 이 인터페이스는 "흐름"만 정의한다.
 * - PDF 처리 / AI 호출 / DB 접근은 구현체에서만 수행한다.
 */
public interface ContractAutoFillService {

    /**
     * 계약 주요 정보 초안 생성
     *
     * @param pdfFile
     *  - 업로드된 PDF 계약서 (없을 수도 있음)
     *
     * @param manualText
     *  - 사용자가 직접 작성한 계약 내용 (없을 수도 있음)
     *
     * @param projectId
     *  - 프로젝트 ID
     *
     * @param freelancerId
     *  - 프리랜서 ID
     *
     * @return
     *  - 계약 주요 정보 초안 DTO
     */
    ContractAutoFillDTO generateDraft(
            File pdfFile,
            String manualText,
            Integer projectId,
            Integer freelancerId
    );
}
