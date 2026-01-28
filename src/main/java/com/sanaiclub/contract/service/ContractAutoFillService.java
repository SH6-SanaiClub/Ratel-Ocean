package com.sanaiclub.contract.service;

import java.io.File;
import com.sanaiclub.contract.model.dto.ContractAutoFillDTO;
import com.sanaiclub.project.model.vo.ProjectsVO;
import com.sanaiclub.user.model.vo.UserVO;
import com.sanaiclub.user.model.vo.FreelancerProfileVO;

/** 계약 자동 초안 생성 서비스 인터페이스. PDF/사용자 입력/AI를 활용한 계약 정보 추출. */
public interface ContractAutoFillService {

    /** 계약 주요 정보 초안 생성. PDF/사용자 입력/프로젝트/프리랜서 정보를 AI로 분석하여 추출. */
    ContractAutoFillDTO generateDraft(
            File pdfFile,
            String manualText,
            ProjectsVO project,
            UserVO freelancerUser,
            FreelancerProfileVO freelancerProfile
    );
}
