package com.sanaiclub.portfolio.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.portfolio.model.dto.FreelancerProfileBasicSaveRequestDTO;
import com.sanaiclub.portfolio.service.FreelancerProfileBasicService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/freelancer/profile/edit")
@RequiredArgsConstructor
public class FreelancerProfileBasicController {

    private final FreelancerProfileBasicService freelancerProfileBasicService;

    @PostMapping("/education/delete")
    public String deleteEducation(RedirectAttributes ra) {
        Integer userId = AuthContext.getCurrentUserId();
        freelancerProfileBasicService.deleteEducation(userId);
        ra.addFlashAttribute("msg", "학력이 삭제되었습니다.");
        return "redirect:/freelancer/profile/edit?tap=settings";
    }

    @PostMapping("/image")
    public String uploadImage(@RequestParam("imageFile") MultipartFile imageFile,
                              RedirectAttributes ra) {
        Integer userId = AuthContext.getCurrentUserId();
        try {
            freelancerProfileBasicService.uploadProfileImage(userId, imageFile);
            ra.addFlashAttribute("msg", "프로필 이미지가 변경되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("msg", "이미지 업로드 실패");
        }
        return "redirect:/freelancer/profile/edit?tap=settings";
    }

    @PostMapping("/image/delete")
    public String deleteImage(RedirectAttributes ra) {
        Integer userId = AuthContext.getCurrentUserId();
        freelancerProfileBasicService.deleteProfileImage(userId);
        ra.addFlashAttribute("msg", "프로필 이미지가 삭제되었습니다.");
        return "redirect:/freelancer/profile/edit?tap=settings";
    }

    @PostMapping("/portfolio")
    public String uploadPortfolio(@RequestParam("portfolioFile") MultipartFile portfolioFile,
                                  RedirectAttributes ra) {
        Integer userId = AuthContext.getCurrentUserId();
        try {
            freelancerProfileBasicService.uploadPortfolio(userId, portfolioFile);
            ra.addFlashAttribute("msg", "포트폴리오가 업로드되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("msg", "포트폴리오 업로드 실패");
        }
        return "redirect:/freelancer/profile/edit?tap=settings";
    }

    @PostMapping("/portfolio/delete")
    public String deletePortfolio(@RequestParam("portfolioId") Integer portfolioId,
                                  RedirectAttributes ra) {
        Integer userId = AuthContext.getCurrentUserId();
        freelancerProfileBasicService.deletePortfolio(userId, portfolioId);
        ra.addFlashAttribute("msg", "포트폴리오가 삭제되었습니다.");
        return "redirect:/freelancer/profile/edit?tap=settings";
    }

    @PostMapping("/all/save")
    public String saveAll(
            @ModelAttribute FreelancerProfileBasicSaveRequestDTO dto,
            @RequestParam(value="profileImageFile", required=false) MultipartFile profileImageFile,
            @RequestParam(value="portfolioFile", required=false) MultipartFile portfolioFile,
            @RequestParam(value="deleteProfileImage", defaultValue="false") boolean deleteProfileImage,
            @RequestParam(value="deletePortfolio", defaultValue="false") boolean deletePortfolio,
            RedirectAttributes ra
    ) {
        Integer userId = AuthContext.getCurrentUserId();
        dto.setUserId(userId);

        try {
            // 기본 정보/학력 저장
            freelancerProfileBasicService.saveBasic(dto);

            // 프로필 이미지: 삭제 or 업로드(선택된 경우)
            if(deleteProfileImage) freelancerProfileBasicService.deleteProfileImage(userId);
            else if(profileImageFile != null && !profileImageFile.isEmpty()) freelancerProfileBasicService.uploadProfileImage(userId, profileImageFile);

            // 포트폴리오: 삭제 or 업로드(선택된 경우)
            if(deletePortfolio) {
                // 최신 1개 정책이면 latest 조회해서 삭제
                var latest = freelancerProfileBasicService.getView(userId);
                if(latest != null && latest.getPortfolioId() != null) {
                    freelancerProfileBasicService.deletePortfolio(userId, latest.getPortfolioId());
                }
            } else if(portfolioFile != null && !portfolioFile.isEmpty()) {
                freelancerProfileBasicService.uploadPortfolio(userId, portfolioFile);
            }

            ra.addFlashAttribute("msg", "저장되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("msg", "저장 실패");
        }
        return "redirect:/freelancer/profile/edit?tab=settings";
    }



}
