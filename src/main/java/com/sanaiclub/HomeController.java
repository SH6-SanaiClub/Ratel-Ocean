package com.sanaiclub;

import org.mybatis.spring.SqlSessionTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.sql.DataSource;
import java.sql.Connection;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@Controller
public class HomeController {

    private static final Logger logger = LoggerFactory.getLogger(HomeController.class);

    //DB 연결 테스트용
    @Autowired
    private DataSource dataSource;

    //DB 연결 테스트용
    @Autowired
    private SqlSessionTemplate sqlSession;

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

    /**
     * DB 연결 테스트 (NEW!)
     * URL: http://localhost:8080/ratelocean/db/test
     */
    @GetMapping("/db/test")
    @ResponseBody
    public Map<String, Object> dbTest() {
        logger.info("===== DB 연결 테스트 시작 =====");

        Map<String, Object> result = new HashMap<>();

        try {
            // 1. DataSource 연결 테스트
            Connection conn = dataSource.getConnection();
            boolean isValid = conn.isValid(3); // 3초 타임아웃
            String dbUrl = conn.getMetaData().getURL();
            String dbUser = conn.getMetaData().getUserName();
            conn.close();

            logger.info("DataSource 연결 성공!");
            logger.info("DB URL: {}", dbUrl);
            logger.info("DB User: {}", dbUser);

            // 2. MyBatis 테스트 (현재 시간 조회)
            String currentTime = sqlSession.selectOne("testMapper.selectNow");
            logger.info("MyBatis 쿼리 실행 성공! 현재 시간: {}", currentTime);

            // 3. 응답 데이터 구성
            result.put("success", true);
            result.put("message", "DB 연결 성공!");
            result.put("dataSource", "연결 성공");
            result.put("dbUrl", dbUrl);
            result.put("dbUser", dbUser);
            result.put("myBatis", "쿼리 실행 성공");
            result.put("currentTime", currentTime);

        } catch (Exception e) {
            logger.error("DB 연결 실패!", e);
            result.put("success", false);
            result.put("message", "DB 연결 실패: " + e.getMessage());
            result.put("error", e.getClass().getSimpleName());
        }

        return result;
    }
}
