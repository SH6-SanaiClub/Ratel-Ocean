package com.sanaiclub.common.util;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * CookieUtil - 쿠키 처리 유틸리티
 *
 * [역할]
 * - 쿠키 생성, 삭제, 조회 공통 로직 제공
 * - HttpOnly, Secure, Path 등 보안 설정 통일
 *
 * [보안 설정]
 * - HttpOnly: true → JavaScript 접근 차단 (XSS 방어)
 * - Secure: false (개발), true (운영) → HTTPS 전용
 * - Path: / → 모든 경로에서 쿠키 전송
 */
public class CookieUtil {

    private static final boolean HTTP_ONLY = true; // HttpOnly 설정 (XSS 공격 방어)
    private static final boolean SECURE = false;  // TODO: 운영 배포 시 true로 변경
    private static final String PATH = "/"; // "/" : 모든경로에서 쿠키 전송

    // Private Constructor (유틸리티 클래스는 인스턴스화 방지)
    private CookieUtil() {
        throw new IllegalStateException("Utility class");
    }

    // 쿠키 추가
    public static void addCookie(HttpServletResponse response,
                                 String name,
                                 String value,
                                 int maxAge) {
        Cookie cookie = new Cookie(name, value);
        cookie.setHttpOnly(HTTP_ONLY);
        cookie.setSecure(SECURE);
        cookie.setPath(PATH);
        cookie.setMaxAge(maxAge);

        response.addCookie(cookie);
    }

    // 쿠키 삭제
    public static void deleteCookie(HttpServletResponse response, String name) {
        addCookie(response, name, null, 0);
    }

    // 쿠키 값 조회
    public static String getCookieValue(HttpServletRequest request, String name) {
        Cookie[] cookies = request.getCookies();

        if (cookies == null) {
            return null;
        }

        for (Cookie cookie : cookies) {
            if (name.equals(cookie.getName())) {
                return cookie.getValue();
            }
        }

        return null;
    }

    // 특정 쿠키 존재 여부 확인
    public static boolean hasCookie(HttpServletRequest request, String name) {
        return getCookieValue(request, name) != null;
    }
}