package com.sanaiclub.chat.controller;

import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.user.model.vo.UserType;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/chat")
public class ChattingController {

    @GetMapping
    public String chatMain(Model model) {
        Integer loginUserId = AuthContext.getCurrentUserId();
        UserType userType = AuthContext.getCurrentUserType();

        if (loginUserId == null) {
            return "redirect:/login";
        }
        model.addAttribute("loginUserId", loginUserId);
        model.addAttribute("userType", userType != null ? userType.name() : "");
        return "chat/room";
    }
}