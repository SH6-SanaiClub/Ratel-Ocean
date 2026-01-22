package com.sanaiclub.portfolio.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.portfolio.model.vo.FreelancerProjectExperienceVO;
import com.sanaiclub.portfolio.service.FreelancerProjectExperienceEditService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequiredArgsConstructor
@RequestMapping("/freelancer/profile")
public class FreelancerProjectExperienceEditController {

    private final FreelancerProjectExperienceEditService freelancerProjectExperienceEditService;

    // 외부 프로젝트 경험
    @PostMapping("/experience/add")
    public String addExperience(@ModelAttribute FreelancerProjectExperienceVO vo, RedirectAttributes ra) {
        Integer freelancerId = AuthContext.getCurrentUserId();
        vo.setFreelancerId(freelancerId);

        freelancerProjectExperienceEditService.addExperience(vo);
        ra.addFlashAttribute("msg", "프로젝트 경험이 추가되었습니다.");
        return "redirect:/freelancer/mypage?tab=external";

    }

    @PostMapping("/experience/update")
    public String updateExperience(@ModelAttribute FreelancerProjectExperienceVO vo, RedirectAttributes ra) {
        Integer freelancerId = AuthContext.getCurrentUserId();
        vo.setFreelancerId(freelancerId);

        freelancerProjectExperienceEditService.updateExperience(vo);
        ra.addFlashAttribute("msg", "프로젝트 경험이 수정되었습니다.");
        return "redirect:/freelancer/mypage?tab=external";

    }

    @PostMapping("/experience/delete")
    public String deleteExperience(@RequestParam Integer experienceId, RedirectAttributes ra) {
        Integer freelancerId = AuthContext.getCurrentUserId();

        freelancerProjectExperienceEditService.deleteExperience(experienceId, freelancerId);
        ra.addFlashAttribute("msg", "프로젝트 경험이 삭제되었습니다.");
        return "redirect:/freelancer/mypage?tab=external";

    }
}
