package com.sanaiclub.contract.service;

import java.io.File;
import com.sanaiclub.contract.model.dto.ContractAutoFillDTO;
import com.sanaiclub.project.model.vo.ProjectsVO;
import com.sanaiclub.user.model.vo.UserVO;
import com.sanaiclub.user.model.vo.FreelancerProfileVO;


public interface ContractAutoFillService {

    /**
     * 계약 주요 정보 초안 생성
     */
    ContractAutoFillDTO generateDraft(
            File pdfFile,
            String manualText,
            ProjectsVO project,
            UserVO freelancerUser,
            FreelancerProfileVO freelancerProfile
    );
}
