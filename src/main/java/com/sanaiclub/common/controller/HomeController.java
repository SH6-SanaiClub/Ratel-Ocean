package com.sanaiclub.common.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * HomeController
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [설명]
 * 프리랜서 플랫폼의 홈페이지 및 시스템 상태 점검 엔드포인트를 담당하는 컨트롤러입니다.
 * 개발/배포 후 가장 먼저 접속하는 페이지로, 시스템 상태를 빠르게 확인할 수 있습니다.
 * 
 * [위치]
 * 패키지: com.sanaiclub.common.controller
 * 파일: HomeController.java
 * 
 * [주요 기능]
 * - 홈페이지 (GET /) : 프로젝트 정보 및 기술 스택 표시
 * - 테스트 페이지 (GET /test) : 개발 환경 설정 확인 (Spring, JSP, JSTL 등)
 * - API 테스트 (GET /api/test) : JSON 응답 형식 테스트
 * 
 * [향후 계획]
 * - 실제 랜딩 페이지는 별도의 LandingPageController로 분리될 예정
 * 
 * @author Team SanaiClub (신한DS 금융 SW 아카데미)
 * @version 1.0
 * @since 2026-01-13
 */
@Controller
public class HomeController {

    private static final Logger logger = LoggerFactory.getLogger(HomeController.class);

    /**
     * ─────────────────────────────────────────────────────────────────
     * [홈 페이지]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /
     * 설명: 프로젝트의 메인 홈페이지를 로드합니다.
     *      현재 기술 스택 정보를 화면에 표시하여 개발 환경을 파악할 수 있습니다.
     * 
     * 표시 정보:
     * - Java 11
     * - Spring Framework 5.3.33
     * - MyBatis 3.5.13
     * - MySQL 8.0
     * - Apache Tomcat 9.0.112
     * 
     * @param model Spring Model 객체 - 뷰에 데이터를 전달하기 위해 사용
     * @return "index" - src/main/webapp/WEB-INF/views/index.jsp를 렌더링
     */
    @GetMapping("/")
    public String home(Model model) {
        logger.info("===== 홈 페이지 접속 =====");

        // 뷰에서 표시할 프로젝트 정보 설정
        model.addAttribute("projectName", "신한DS 프리랜서 플랫폼");
        model.addAttribute("team", "1차 프로젝트 팀");
        model.addAttribute("currentTime",
                LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));

        return "index";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [개발 환경 테스트 페이지]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /test
     * 설명: 개발 환경의 모든 요소가 올바르게 작동하는지 확인하는 페이지입니다.
     *      서버 재시작 후 가장 먼저 접속하여 상태를 확인합니다.
     * 
     * 확인 항목:
     * ✅ Spring MVC DispatcherServlet 정상 작동
     * ✅ Controller 매핑 정상 작동
     * ✅ ViewResolver JSP 렌더링 성공
     * ✅ JSTL 및 EL 표현식 정상 작동
     * ✅ UTF-8 인코딩 정상 작동
     * ✅ 정적 리소스 매핑 정상 작동
     * 
     * @param model Spring Model 객체
     * @return "test/test" - src/main/webapp/WEB-INF/views/test/test.jsp를 렌더링
     */
    @GetMapping("/test")
    public String test(Model model) {
        logger.info("===== 테스트 페이지 접속 =====");

        // 테스트 성공 메시지 설정
        model.addAttribute("message", "개발 환경 설정 완료!");
        model.addAttribute("status", "SUCCESS");

        return "test/test";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [API JSON 응답 테스트]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /api/test
     * 설명: JSON 형식의 API 응답이 정상 작동하는지 테스트합니다.
     *      프론트엔드 개발자가 AJAX 호출 테스트 시 이 엔드포인트를 사용합니다.
     * 
     * @ResponseBody 주석: 메서드 반환값을 HttpResponse Body에 직접 작성
     *                    (JSP 렌더링 없이 JSON 문자열 반환)
     * 
     * @return JSON 문자열 - {"status":"success","message":"API가 정상 작동합니다"}
     */
    @GetMapping("/api/test")
    @ResponseBody
    public String apiTest() {
        logger.info("===== API 테스트 =====");

        return "{\"status\":\"success\",\"message\":\"API가 정상 작동합니다\"}";
    }
}
