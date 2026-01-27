package com.sanaiclub.portfolio.service.impl;

import com.sanaiclub.portfolio.dao.FreelancerProfileBasicMapper;
import com.sanaiclub.portfolio.model.dto.FreelancerProfileBasicSaveRequestDTO;
import com.sanaiclub.portfolio.model.dto.FreelancerProfileBasicViewDTO;
import com.sanaiclub.portfolio.model.vo.FreelancerPortfolioVO;
import com.sanaiclub.portfolio.service.FreelancerProfileBasicService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.ServletContext;
import java.io.File;
import java.io.IOException;
import java.util.Objects;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class FreelancerProfileBasicServiceImpl implements FreelancerProfileBasicService {

    private final FreelancerProfileBasicMapper freelancerProfileBasicMapper;
    private final ServletContext servletContext;

    private String ensureDir(String realPathDir) {
        File dir = new File(realPathDir);
        if (!dir.exists()) dir.mkdirs();
        return realPathDir;
    }

    private void deletePhysicalFileByUrl(String url) {
        if (url == null || url.isBlank()) return;
        try {
            String realPath = servletContext.getRealPath(url);
            if (realPath == null) return;
            File f = new File(realPath);
            if (f.exists()) f.delete();
        } catch (Exception ignored) {}
    }

    @Override
    public FreelancerProfileBasicViewDTO getView(Integer userId) {
        return freelancerProfileBasicMapper.selectBasicProfile(userId);
    }

    @Override
    @Transactional
    public void saveBasic(FreelancerProfileBasicSaveRequestDTO dto) {
        int updated = freelancerProfileBasicMapper.updateBasicProfile(dto);

        // 해당 user_id의 profile row가 없으면 update가 0건 → insert로 생성
        if (updated == 0) {
            freelancerProfileBasicMapper.insertBasicProfile(dto);
        }
    }

    @Override
    @Transactional
    public void uploadProfileImage(Integer userId, MultipartFile imageFile) throws IOException {
        if (imageFile == null || imageFile.isEmpty()) return;

        // 기존 이미지 삭제
        String oldUrl = freelancerProfileBasicMapper.selectProfileImageUrl(userId);
        if (oldUrl != null && !oldUrl.isBlank()) {
            deletePhysicalFileByUrl(oldUrl);
        }

        String uploadUrlDir = "/resources/upload/profile/";
        String uploadRealDir = ensureDir(Objects.requireNonNull(servletContext.getRealPath(uploadUrlDir)));

        String original = imageFile.getOriginalFilename();
        String saved = UUID.randomUUID() + "_" + (original == null ? "profile" : original);

        File dest = new File(uploadRealDir, saved);
        imageFile.transferTo(dest);

        String newUrl = uploadUrlDir + saved;
        freelancerProfileBasicMapper.updateProfileImageUrl(userId, newUrl);
    }

    @Override
    @Transactional
    public void deleteProfileImage(Integer userId) {
        String oldUrl = freelancerProfileBasicMapper.selectProfileImageUrl(userId);
        if (oldUrl != null && !oldUrl.isBlank()) {
            deletePhysicalFileByUrl(oldUrl);
        }
        freelancerProfileBasicMapper.clearProfileImageUrl(userId);
    }

    @Override
    @Transactional
    public void uploadPortfolio(Integer userId, MultipartFile file) throws IOException {
        if (file == null || file.isEmpty()) return;

        FreelancerPortfolioVO existing = freelancerProfileBasicMapper.selectLatestPortfolio(userId);
        if (existing != null && existing.getPortfolioUrl() != null) {
            // 같은 1개만 유지 : 기존 파일 삭제 후 update로 갈아끼움
            deletePhysicalFileByUrl(existing.getPortfolioUrl());
        }

        String uploadUrlDir = "/resources/upload/portfolio/";
        String uploadRealDir = ensureDir(Objects.requireNonNull(servletContext.getRealPath(uploadUrlDir)));

        String original = file.getOriginalFilename();
        String saved = UUID.randomUUID() + "_" + (original == null ? "portfolio" : original);

        File dest = new File(uploadRealDir, saved);
        file.transferTo(dest);

        String url = uploadUrlDir + saved;

        String title = (original == null || original.isBlank()) ? "portfolio" : original;
        long sizeBytes = file.getSize();

        if (existing == null) {
            FreelancerPortfolioVO vo = FreelancerPortfolioVO.builder()
                    .freelancerId(userId)
                    .title(title)
                    .description(null)
                    .portfolioUrl(url)
                    .fileSize(sizeBytes)
                    .isPublic(true)
                    .build();
            freelancerProfileBasicMapper.insertPortfolio(vo);
        } else {
            existing.setTitle(title);
            existing.setDescription(null);
            existing.setPortfolioUrl(url);
            existing.setFileSize(sizeBytes);
            existing.setIsPublic(existing.getIsPublic() == null ? true : existing.getIsPublic());
            freelancerProfileBasicMapper.updatePortfolio(existing);
        }
    }

    @Override
    @Transactional
    public void deletePortfolio(Integer userId, Integer portfolioId) {
        if (portfolioId == null) return;

        FreelancerPortfolioVO vo = freelancerProfileBasicMapper.selectPortfolioById(portfolioId);
        if (vo != null && vo.getPortfolioUrl() != null) {
            deletePhysicalFileByUrl(vo.getPortfolioUrl());
        }
        freelancerProfileBasicMapper.deletePortfolio(portfolioId, userId);
    }
}
