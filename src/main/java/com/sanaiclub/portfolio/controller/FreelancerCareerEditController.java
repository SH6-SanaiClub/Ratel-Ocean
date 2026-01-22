package com.sanaiclub.portfolio.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.portfolio.model.vo.FreelancerCareerVO;
import com.sanaiclub.portfolio.service.FreelancerCareerEditService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequiredArgsConstructor
@RequestMapping("/freelancer/profile/edit")
public class FreelancerCareerEditController {

    private final FreelancerCareerEditService freelancerCareerEditService;

    // 경력
    @PostMapping("/career/add")
    public String addCareer(@ModelAttribute FreelancerCareerVO vo, RedirectAttributes ra) {
        Integer freelancerId = AuthContext.getCurrentUserId();
        vo.setFreelancerId(freelancerId);

        freelancerCareerEditService.addCareer(vo);
        ra.addFlashAttribute("msg", "경력이 추가되었습니다.");
        return "redirect:/freelancer/profile/edit?tab=career";
    }

    @PostMapping("/career/update")
    public String updateCareer(@ModelAttribute FreelancerCareerVO vo, RedirectAttributes ra) {
        Integer freelancerId = AuthContext.getCurrentUserId();
        vo.setFreelancerId(freelancerId);

        freelancerCareerEditService.updateCareer(vo);
        ra.addFlashAttribute("msg", "경력이 수정되었습니다.");
        return "redirect:/freelancer/profile/edit?tab=career";
    }

    @PostMapping("/career/delete")
    public String deleteCareer(@RequestParam Integer careerId, RedirectAttributes ra) {
        Integer freelancerId = AuthContext.getCurrentUserId();

        freelancerCareerEditService.deleteCareer(careerId, freelancerId);
        ra.addFlashAttribute("msg", "경력이 삭제되었습니다.");
        return "redirect:/freelancer/profile/edit?tab=career";
    }

}
