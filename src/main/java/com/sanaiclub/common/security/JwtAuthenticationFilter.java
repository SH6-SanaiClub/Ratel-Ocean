package com.sanaiclub.common.security;

import com.sanaiclub.common.dto.AuthenticatedUser;
import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.common.util.CookieUtil;
import com.sanaiclub.user.dao.UserMapper;
import com.sanaiclub.user.model.vo.UserStatus;
import com.sanaiclub.user.model.vo.UserType;
import com.sanaiclub.user.model.vo.UserVO;
import com.sanaiclub.user.service.LoginService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

// JWT 인증 필터
public class JwtAuthenticationFilter implements Filter {

    private static final Logger logger = LoggerFactory.getLogger(JwtAuthenticationFilter.class);

    private static final String ACCESS_TOKEN_COOKIE = "accessToken";
    private static final String REFRESH_TOKEN_COOKIE = "refreshToken";

    // Spring Bean 의존성
    private JwtTokenProvider jwtTokenProvider;
    private LoginService loginService;
    private UserMapper userMapper;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        logger.info("===== JwtAuthenticationFilter 초기화 =====");

        // Spring ApplicationContext에서 Bean 가져오기
        ServletContext servletContext = filterConfig.getServletContext();
        WebApplicationContext context = WebApplicationContextUtils
                .getRequiredWebApplicationContext(servletContext);

        this.jwtTokenProvider = context.getBean(JwtTokenProvider.class);
        this.loginService = context.getBean(LoginService.class);
        this.userMapper = context.getBean(UserMapper.class);

        logger.info("JwtAuthenticationFilter 초기화 완료");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String path = requestURI.substring(contextPath.length());

        logger.debug("===== JWT 인증 필터 시작: {} =====", path);

        try {
            // 1. 정적 리소스는 필터 건너뛰기
            if (isStaticResource(path)) {
                logger.debug("정적 리소스 요청 - 필터 건너뛰기: {}", path);
                chain.doFilter(request, response);
                return;
            }

            // 2. Access Token 검증 및 인증 처리
            authenticateRequest(httpRequest, httpResponse);

            // 3. 다음 필터/서블릿으로 전달
            chain.doFilter(request, response);

        } finally {
            // 4. 요청 종료 시 ThreadLocal 정리 (메모리 누수 방지)
            AuthContext.clear();
            logger.debug("===== JWT 인증 필터 종료: {} =====", path);
        }
    }

    /**
     * 요청 인증 처리
     */
    private void authenticateRequest(HttpServletRequest request, HttpServletResponse response) {
        // 1. 쿠키에서 Access Token 추출
        String accessToken = CookieUtil.getCookieValue(request, ACCESS_TOKEN_COOKIE);

        // 2. Access Token이 없으면 인증 실패 (Interceptor에서 처리)
        if (accessToken == null || accessToken.isEmpty()) {
            logger.debug("Access Token 없음 - 비로그인 상태");
            return;
        }

        // 3. Access Token 검증
        if (jwtTokenProvider.validateToken(accessToken)) {
            // 3-1. 유효한 토큰 → AuthContext에 사용자 정보 저장
            setAuthContext(accessToken);
            logger.debug("Access Token 유효 - 인증 성공: userId={}", AuthContext.getCurrentUserId());
            return;
        }

        // 4. Access Token 만료 → Refresh Token으로 재발급 시도
        logger.debug("Access Token 만료 - Refresh Token으로 재발급 시도");
        boolean refreshed = tryRefreshAccessToken(request, response);

        if (refreshed) {
            logger.info("Access Token 자동 재발급 성공");
        } else {
            logger.warn("Access Token 재발급 실패 - 재로그인 필요");
        }
    }

    /**
     * Access Token에서 사용자 정보 추출 → AuthContext 저장
     */
    private void setAuthContext(String accessToken) {
        try {
            // JWT에서 사용자 정보 추출
            Integer userId = jwtTokenProvider.getUserId(accessToken);
            String loginId = jwtTokenProvider.getLoginId(accessToken);
            UserType userType = jwtTokenProvider.getUserType(accessToken);

            // AuthenticatedUser 생성
            AuthenticatedUser user = AuthenticatedUser.builder()
                    .userId(userId)
                    .loginId(loginId)
                    .userType(userType)
                    .build();

            // ThreadLocal에 저장
            AuthContext.setCurrentUser(user);

            logger.debug("AuthContext 저장 완료: {}", user);

        } catch (Exception e) {
            logger.error("AuthContext 저장 실패", e);
        }
    }

    /**
     * Refresh Token으로 Access Token 자동 재발급
     *
     * @return 재발급 성공 여부
     */
    private boolean tryRefreshAccessToken(HttpServletRequest request, HttpServletResponse response) {
        try {
            // 1. 쿠키에서 Refresh Token 추출
            String refreshToken = CookieUtil.getCookieValue(request, REFRESH_TOKEN_COOKIE);

            if (refreshToken == null || refreshToken.isEmpty()) {
                logger.debug("Refresh Token 없음 - 재발급 불가");
                return false;
            }

            // 2. Refresh Token 유효성 검증
            if (!jwtTokenProvider.validateToken(refreshToken)) {
                logger.warn("Refresh Token 유효하지 않음 - 재발급 불가");
                // Refresh Token도 만료 → 쿠키 삭제
                CookieUtil.deleteCookie(response, ACCESS_TOKEN_COOKIE);
                CookieUtil.deleteCookie(response, REFRESH_TOKEN_COOKIE);
                return false;
            }

            // 3. DB에서 Refresh Token 확인
            UserVO user = userMapper.findByRefreshToken(refreshToken);

            if (user == null) {
                logger.warn("DB에 일치하는 Refresh Token 없음 - 재발급 불가");
                return false;
            }

            // 4. 계정 상태 확인
            if (!UserStatus.ACTIVE.equals(user.getStatus())) {
                logger.warn("비활성 계정 - 재발급 불가: userId={}, status={}",
                        user.getUserId(), user.getStatus());
                return false;
            }

            // 5. 새 Access Token 발급
            String newAccessToken = jwtTokenProvider.createAccessToken(
                    user.getUserId(),
                    user.getLoginId(),
                    user.getUserType()
            );

            // 6. 새 Access Token 쿠키에 저장
            long expiresIn = jwtTokenProvider.getAccessTokenValidityInSeconds();
            CookieUtil.addCookie(response, ACCESS_TOKEN_COOKIE, newAccessToken, (int) expiresIn);

            // 7. AuthContext에 사용자 정보 저장
            setAuthContext(newAccessToken);

            logger.info("Access Token 자동 재발급 성공: userId={}", user.getUserId());

            return true;

        } catch (Exception e) {
            logger.error("Access Token 재발급 중 오류", e);
            return false;
        }
    }

    /**
     * 정적 리소스 요청인지 확인
     */
    private boolean isStaticResource(String path) {
        return path.startsWith("/resources/") ||
                path.startsWith("/css/") ||
                path.startsWith("/js/") ||
                path.startsWith("/images/") ||
                path.endsWith(".css") ||
                path.endsWith(".js") ||
                path.endsWith(".png") ||
                path.endsWith(".jpg") ||
                path.endsWith(".jpeg") ||
                path.endsWith(".gif") ||
                path.endsWith(".ico");
    }

    @Override
    public void destroy() {
        logger.info("JwtAuthenticationFilter 종료");
    }
}