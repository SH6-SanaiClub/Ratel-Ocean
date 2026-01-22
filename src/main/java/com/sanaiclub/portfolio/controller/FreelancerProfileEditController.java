package com.sanaiclub.portfolio.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.portfolio.service.FreelancerCareerEditService;
import com.sanaiclub.portfolio.service.FreelancerProjectExperienceEditService;
import com.sanaiclub.portfolio.service.FreelancerStackProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/freelancer/profile")
@RequiredArgsConstructor
public class FreelancerProfileEditController {

    private final FreelancerProjectExperienceEditService freelancerProjectExperienceEditService;
    private final FreelancerCareerEditService freelancerCareerEditService;
    private final FreelancerStackProfileService stackService;

    @GetMapping("/edit")
    public String profileEdit(Model model) {
        if (!AuthContext.isAuthenticated()) return "redirect:/login";

        Integer freelancerId = AuthContext.getCurrentUserId();

        // 스택
        model.addAttribute("skillOptions", stackService.getSkillOptions());
        model.addAttribute("positionOptions", stackService.getPositionOptions());
        model.addAttribute("mySkills", stackService.getMySkills(freelancerId));
        model.addAttribute("myPositions", stackService.getMyPositions(freelancerId));

        // 경력 / 외부 프로젝트
        model.addAttribute("careers", freelancerCareerEditService.getCareers(freelancerId));
        model.addAttribute("experiences", freelancerProjectExperienceEditService.getExperiences(freelancerId));

        return "user/freelancer/freelancerProfileEdit";
    }
}
