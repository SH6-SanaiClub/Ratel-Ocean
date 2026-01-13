package com.sanaiclub;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Controller
public class HomeController {

    private static final Logger logger = LoggerFactory.getLogger(HomeController.class);

    /**
     * 홈 페이지
     */
    @GetMapping("/")
    public String home(Model model) {
        logger.info("===== 홈 페이지 접속 =====");

        model.addAttribute("projectName", "신한DS 프리랜서 플랫폼");
        model.addAttribute("team", "1차 프로젝트 팀");
        model.addAttribute("currentTime",
                LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));

        return "index";
    }

    /**
     * 테스트 페이지
     */
    @GetMapping("/test")
    public String test(Model model) {
        logger.info("===== 테스트 페이지 접속 =====");

        model.addAttribute("message", "개발 환경 설정 완료!");
        model.addAttribute("status", "SUCCESS");

        return "test/test";
    }

    /**
     * API 테스트 (JSON 응답)
     */
    @GetMapping("/api/test")
    @ResponseBody
    public String apiTest() {
        logger.info("===== API 테스트 =====");

        return "{\"status\":\"success\",\"message\":\"API가 정상 작동합니다\"}";
    }
}
