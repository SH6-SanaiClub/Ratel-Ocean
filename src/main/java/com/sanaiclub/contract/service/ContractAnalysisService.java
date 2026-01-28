package com.sanaiclub.contract.service;

import com.sanaiclub.contract.model.dto.ContractAnalysisDTO;
import com.sanaiclub.contract.model.dto.ContractDetailDTO;
import com.sanaiclub.contract.model.dto.ContractResponseDTO;

/** 계약서 AI 분석 서비스 인터페이스. 계약 위험도 평가 및 위험 조항 식별. */
public interface ContractAnalysisService {

    /** 계약서 AI 분석. 위험도 점수, 위험 조항 목록 반환. */
    ContractAnalysisDTO analyzeContract(
        ContractDetailDTO contractDetail,
        ContractResponseDTO contract,
        String pdfText
    );
}
