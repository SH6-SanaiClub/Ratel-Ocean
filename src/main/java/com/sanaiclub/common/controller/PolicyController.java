package com.sanaiclub.common.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * PolicyController - 정책 페이지 라우팅
 * 
 * [엔드포인트]
 * - GET /policy/terms: 이용약관
 * - GET /policy/privacy: 개인정보처리방침
 */
@Controller
@RequestMapping("/policy")
public class PolicyController {

    /**
     * GET /policy/terms
     * 이용약관 페이지
     */
    @GetMapping("/terms")
    public String showTerms() {
        return "policy/terms";
    }

    /**
     * GET /policy/privacy
     * 개인정보처리방침 페이지
     */
    @GetMapping("/privacy")
    public String showPrivacy() {
        return "policy/privacy";
    }
}
