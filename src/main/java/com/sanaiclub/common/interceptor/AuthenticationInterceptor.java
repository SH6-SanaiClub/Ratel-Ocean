package com.sanaiclub.common.interceptor;

import com.sanaiclub.common.dto.AuthenticatedUser;
import com.sanaiclub.common.util.AuthContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// 인증/권한 인터셉터
public class AuthenticationInterceptor implements HandlerInterceptor {

    private static final Logger logger = LoggerFactory.getLogger(AuthenticationInterceptor.class);

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {

        String requestURI = request.getRequestURI();
        String contextPath = request.getContextPath();
        String path = requestURI.substring(contextPath.length());

        logger.debug("===== 인증 인터셉터 시작: {} =====", path);

        // 1. 비로그인 허용 URL
        if (isPublicUrl(path)) {
            logger.debug("비로그인 허용 URL - 통과: {}", path);
            return true;
        }

        // 2. 로그인 필수 URL
        AuthenticatedUser currentUser = AuthContext.getCurrentUser();

        if (currentUser == null) {
            logger.warn("로그인 필요 - 리다이렉트: {} → /login", path);
            response.sendRedirect(contextPath + "/login");
            return false;
        }

        // 3. 프리랜서 전용 URL
        if (isFreelancerOnlyUrl(path)) {
            if (!currentUser.isFreelancer()) {
                logger.warn("프리랜서 전용 URL - 접근 거부: userId={}, userType={}, path={}",
                        currentUser.getUserId(), currentUser.getUserType(), path);
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "프리랜서만 접근 가능합니다.");
                return false;
            }
            logger.debug("프리랜서 전용 URL - 인증 성공: {}", path);
            return true;
        }

        // 4. 클라이언트 전용 URL
        if (isClientOnlyUrl(path)) {
            if (!currentUser.isClient()) {
                logger.warn("클라이언트 전용 URL - 접근 거부: userId={}, userType={}, path={}",
                        currentUser.getUserId(), currentUser.getUserType(), path);
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "클라이언트만 접근 가능합니다.");
                return false;
            }
            logger.debug("클라이언트 전용 URL - 인증 성공: {}", path);
            return true;
        }

        // 5. 공통 로그인 필수 URL (유형 무관)
        logger.debug("인증 성공 - 통과: userId={}, userType={}, path={}",
                currentUser.getUserId(), currentUser.getUserType(), path);

        return true;
    }

    /**
     * 비로그인 허용 URL 확인
     * - 로그인 페이지, 회원가입, 정적 리소스 등
     */
    private boolean isPublicUrl(String path) {
        return path.equals("/") ||
                path.equals("/login") ||
                path.startsWith("/join/") ||
                path.equals("/test") ||
                path.equals("/api/test") ||
                path.equals("/db/test") ||
                path.startsWith("/resources/") ||
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

    /**
     * 프리랜서 전용 URL 확인
     */
    private boolean isFreelancerOnlyUrl(String path) {
        return path.startsWith("/freelancer/");
    }

    /**
     * 클라이언트 전용 URL 확인
     */
    private boolean isClientOnlyUrl(String path) {
        return path.startsWith("/client/");
    }
}