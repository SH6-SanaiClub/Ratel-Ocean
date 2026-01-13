package com.sanaiclub;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class DashboardController {

    // 로그인 후 메인 대시보드
    @GetMapping("/dashboard")
    public String dashboard() {
        return "dashboard";
    }

    @GetMapping("/projects")
    public String projects() {
        return "projects";
    }

    @GetMapping("/queue")
    public String queue() {
        return "queue";
    }

    @GetMapping("/finance")
    public String finance() {
        return "finance";
    }

    @GetMapping("/career")
    public String career() {
        return "career";
    }

    @GetMapping("/mypage")
    public String mypage() {
        return "mypage";
    }
}
