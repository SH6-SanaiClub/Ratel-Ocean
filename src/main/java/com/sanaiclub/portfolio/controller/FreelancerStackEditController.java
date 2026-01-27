package com.sanaiclub.portfolio.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.portfolio.model.dto.FreelancerStackSaveRequestDTO;
import com.sanaiclub.portfolio.model.dto.MyStackItemDTO;
import com.sanaiclub.portfolio.service.FreelancerStackProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequiredArgsConstructor
@RequestMapping("/freelancer/profile/edit")
public class FreelancerStackEditController {

    private final FreelancerStackProfileService freelancerStackProfileService;

    @PostMapping("/stack/save")
    public String save(
            @ModelAttribute FreelancerStackSaveRequestDTO req,
            @RequestParam(defaultValue = "skill") String tab,
            RedirectAttributes ra
    ) {
        Integer freelancerId = AuthContext.getCurrentUserId();

        // category 없으면 바로 예외 처리해서 이상한 insert 방지
        if (req.getCategory() == null || req.getCategory().isBlank()) {
            ra.addFlashAttribute("msg", "저장 실패: category 누락");
            return "redirect:/freelancer/profile/edit?tab=" + tab;
        }

        freelancerStackProfileService.save(freelancerId, req.getCategory(), req.getStacks());

        ra.addFlashAttribute("msg", "저장되었습니다.");
        return "redirect:/freelancer/profile/edit?tab=" + tab;
    }
}
