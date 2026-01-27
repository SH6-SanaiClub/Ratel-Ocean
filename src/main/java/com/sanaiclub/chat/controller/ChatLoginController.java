package com.sanaiclub.chat.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpSession;

@Controller
public class ChatLoginController {

    @GetMapping("/login")
    public String loginPage() {
        return "chatTest/login"; // login.jsp로 이동
    }

    @PostMapping("/login")
    public String login(@RequestParam(required = false) Integer userId, HttpSession session) {
        if (userId == null) {
            return "redirect:/login?error=empty";
        }

        // 입력받은 유저 ID를 세션에 저장
        session.setAttribute("loginUserId", userId);
        // 채팅 목록 페이지로 이동
        return "redirect:/chat";
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }
}