package com.sanaiclub.portfolio.service;

import com.sanaiclub.portfolio.model.dto.FreelancerProfileBasicSaveRequestDTO;
import com.sanaiclub.portfolio.model.dto.FreelancerProfileBasicViewDTO;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

public interface FreelancerProfileBasicService {

    FreelancerProfileBasicViewDTO getView(Integer userId);

    void saveBasic(FreelancerProfileBasicSaveRequestDTO dto);

    void uploadProfileImage(Integer userId, MultipartFile imageFile) throws IOException;

    void deleteProfileImage(Integer userId);

    void uploadPortfolio(Integer userId, MultipartFile file) throws IOException;

    void deletePortfolio(Integer userId, Integer portfolioId);
}
