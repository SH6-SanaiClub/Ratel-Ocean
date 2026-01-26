package com.sanaiclub.portfolio.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.portfolio.service.FreelancerProfileViewService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/freelancer/profile")
@RequiredArgsConstructor
public class FreelancerProfileViewController {

    private final FreelancerProfileViewService freelancerProfileViewService;

    // /freelancer/profile/123
    @GetMapping("/{freelancerId}")
    public String view(@PathVariable("freelancerId") Integer freelancerId, Model model) {
        Integer viewerId = AuthContext.getCurrentUserId(); // 비로그인일 수 있으면 null 가능
        var profile = freelancerProfileViewService.getProfile(freelancerId, viewerId);

        model.addAttribute("p", profile);
        return "user/freelancer/freelancerProfileView";
    }
}
