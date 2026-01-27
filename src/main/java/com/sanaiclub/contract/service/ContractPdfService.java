package com.sanaiclub.contract.service;

import com.sanaiclub.contract.model.dto.ContractCreateRequestDTO;
import com.sanaiclub.user.model.vo.UserVO;
import com.sanaiclub.user.model.vo.FreelancerProfileVO;
import com.sanaiclub.user.model.vo.ClientProfileVO;
import com.sanaiclub.user.model.vo.CompanyVO;

import java.io.File;
import java.io.IOException;

/** 계약서 PDF 생성 서비스 인터페이스. 다양한 PDF 생성 라이브러리로 구현체 교체 가능. */
public interface ContractPdfService {

    /** 계약서 PDF 생성. HTML 템플릿에 정보 채워서 PDF 생성. */
    File generateContractPdf(
            UserVO clientUser,
            ClientProfileVO clientProfile,
            CompanyVO company,
            UserVO freelancerUser,
            FreelancerProfileVO freelancerProfile,
            ContractCreateRequestDTO form,
            String saveDir,
            String fileName
    ) throws IOException;
}
