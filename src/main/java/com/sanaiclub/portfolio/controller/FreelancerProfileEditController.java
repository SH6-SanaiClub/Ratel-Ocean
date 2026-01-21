package com.sanaiclub.portfolio.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.portfolio.model.vo.FreelancerCareerVO;
import com.sanaiclub.portfolio.model.vo.FreelancerProjectExperienceVO;
import com.sanaiclub.portfolio.service.FreelancerProfileEditService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/freelancer/profile")
public class FreelancerProfileEditController {

    private final FreelancerProfileEditService service;

    public FreelancerProfileEditController(FreelancerProfileEditService service) {
        this.service = service;
    }

    // 페이지 호출 - 저장된 값 있으면 불러오기
    @GetMapping("/edit")
    public String editPage(Model model) {
        if (!AuthContext.isAuthenticated()) return "redirect:/login";

        Integer freelancerId = AuthContext.getCurrentUserId();

        model.addAttribute("careerList", service.getCareers(freelancerId));
        model.addAttribute("experienceList", service.getExperiences(freelancerId));
        model.addAttribute("freelancerId", freelancerId);

        return "user/freelancer/freelancerProfileEdit";
    }

    // 경력
    @PostMapping("/career/add")
    public String addCareer(@ModelAttribute FreelancerCareerVO vo, RedirectAttributes ra) {
        Integer freelancerId = AuthContext.getCurrentUserId();
        vo.setFreelancerId(freelancerId);

        service.addCareer(vo);
        ra.addFlashAttribute("msg", "경력이 추가되었습니다.");
        return "redirect:/freelancer/profile/edit";
    }

    @PostMapping("/career/update")
    public String updateCareer(@ModelAttribute FreelancerCareerVO vo, RedirectAttributes ra) {
        Integer freelancerId = AuthContext.getCurrentUserId();
        vo.setFreelancerId(freelancerId);

        service.updateCareer(vo);
        ra.addFlashAttribute("msg", "경력이 수정되었습니다.");
        return "redirect:/freelancer/profile/edit";
    }

    @PostMapping("/career/delete")
    public String deleteCareer(@RequestParam Long careerId, RedirectAttributes ra) {
        Integer freelancerId = AuthContext.getCurrentUserId();

        service.deleteCareer(careerId, freelancerId);
        ra.addFlashAttribute("msg", "경력이 삭제되었습니다.");
        return "redirect:/freelancer/profile/edit";
    }

    // 외부 프로젝트 경험
    @PostMapping("/experience/add")
    public String addExperience(@ModelAttribute FreelancerProjectExperienceVO vo, RedirectAttributes ra) {
        Integer freelancerId = AuthContext.getCurrentUserId();
        vo.setFreelancerId(freelancerId);

        service.addExperience(vo);
        ra.addFlashAttribute("msg", "프로젝트 경험이 추가되었습니다.");
        return "redirect:/freelancer/profile/edit";
    }

    @PostMapping("/experience/update")
    public String updateExperience(@ModelAttribute FreelancerProjectExperienceVO vo, RedirectAttributes ra) {
        Integer freelancerId = AuthContext.getCurrentUserId();
        vo.setFreelancerId(freelancerId);

        service.updateExperience(vo);
        ra.addFlashAttribute("msg", "프로젝트 경험이 수정되었습니다.");
        return "redirect:/freelancer/profile/edit";
    }

    @PostMapping("/experience/delete")
    public String deleteExperience(@RequestParam Long experienceId, RedirectAttributes ra) {
        Integer freelancerId = AuthContext.getCurrentUserId();

        service.deleteExperience(experienceId, freelancerId);
        ra.addFlashAttribute("msg", "프로젝트 경험이 삭제되었습니다.");
        return "redirect:/freelancer/profile/edit";
    }
}
