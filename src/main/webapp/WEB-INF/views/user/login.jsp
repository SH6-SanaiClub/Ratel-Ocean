<%@ page contentType="text/html;charset=UTF-8" %>
<!--
    ═══════════════════════════════════════════════════════════════════════
    login.jsp - 로그인 페이지
    ═══════════════════════════════════════════════════════════════════════
    
    [설명]
    사용자가 시스템에 로그인하는 페이지입니다.
    아이디/비밀번호를 입력하여 인증을 수행합니다.
    
    [연결되는 컨트롤러]
    LoginController.java > login() 메서드
    @GetMapping({"/login", "/login.do"})
    
    [로그인 흐름]
    1. GET /login.do
       └─ 이 페이지 표시
    
    2. POST /login.do (향후 구현)
       └─ 사용자 입력값 검증
       └─ 데이터베이스에서 사용자 확인
       └─ 비밀번호 검증
       └─ 세션 생성
       └─ /dashboard로 리다이렉트
    
    [입력 필드]
    - 아이디 (아이콘 포함: 👤)
    - 비밀번호 (마스크 처리: ••••)
    - 자동 로그인 체크박스
    - 로그인 버튼
    
    [추가 링크]
    - 비밀번호 찾기 (향후 구현)
    - 회원가입 링크 (/join/select-role.do)
    - 고객 지원 링크
    
    [헤더 구성]
    - FreelanceHub 로고
    - 네비게이션: 서비스 소개, 문의하기
    
    [향후 개선 사항]
    1. OAuth 통합 (Google, GitHub, Naver 로그인)
    2. 2단계 인증 (2FA)
    3. 비밀번호 재설정 기능
    4. 로그인 기록 및 보안 알림
    5. 세션 관리 (여러 디바이스 동시 로그인)
    
    @version 1.0 (2026-01-13)
-->
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>로그인 - FreelanceHub</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/login.css">
</head>
<body>
<!-- 상단 헤더: 로고 및 네비게이션 -->
<header class="site-header">
    <div class="container header-inner">
        <a class="logo" href="${pageContext.request.contextPath}/">
            <img src="${pageContext.request.contextPath}/resources/images/freelancehub-logo.svg" alt="FreelanceHub 로고">
        </a>
        <nav class="top-nav">
            <a href="${pageContext.request.contextPath}/service">서비스 소개</a>
            <a href="${pageContext.request.contextPath}/support">문의하기</a>
        </nav>
    </div>
</header>

<!-- 로그인 페이지 메인 콘텐츠 -->
<main class="login-page">
    <div class="container login-center">
        <!-- 페이지 제목 -->
        <div class="title-area">
            <h1 class="page-title">로그인</h1>
            <p class="page-sub">전문 프리랜서를 위한 비즈니스 파트너</p>
        </div>

        <!-- 로그인 카드 -->
        <div class="login-card">
            <!-- 로그인 폼 -->
            <form class="login-form" action="#" method="post" novalidate>
                <!-- 아이디 입력 필드 -->
                <label class="field" for="username">
                    <div class="label">아이디</div>
                    <div class="input-with-icon">
                        <svg class="icon user" viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><path d="M12 12c2.761 0 5-2.239 5-5s-2.239-5-5-5-5 2.239-5 5 2.239 5 5 5zM4 20c0-4 4-6 8-6s8 2 8 6v1H4v-1z" fill="currentColor"/></svg>
                        <input id="username" name="username" class="input" placeholder="아이디를 입력하세요" autocomplete="username" />
                    </div>
                </label>

                <!-- 비밀번호 입력 필드 -->
                <label class="field" for="password">
                    <div class="label">비밀번호</div>
                    <div class="input-with-icon">
                        <svg class="icon lock" viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><path d="M6 10V8a6 6 0 1112 0v2h1a1 1 0 011 1v9a1 1 0 01-1 1H5a1 1 0 01-1-1v-9a1 1 0 011-1h1zm2 0h8V8a4 4 0 00-8 0v2z" fill="currentColor"/></svg>
                        <input id="password" name="password" type="password" class="input" placeholder="비밀번호를 입력하세요" autocomplete="current-password" />
                    </div>
                </label>

                <div class="actions">
                    <button type="submit" class="btn primary block">로그인 →</button>
                </div>

                <div class="links">
                    <a href="#" class="muted">아이디 찾기</a>
                    <span class="sep">|</span>
                    <a href="#" class="muted">비밀번호 찾기</a>
                    <span class="sep">|</span>
                    <a href="${pageContext.request.contextPath}/join/select-role.do" class="signup-link">회원가입</a>
                </div>

                <div class="security-note">
                    <div class="shield">
                        <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true"><path d="M12 2l7 3v5c0 5-3.58 9.74-7 12-3.42-2.26-7-7-7-12V5l7-3z" fill="currentColor"/></svg>
                    </div>
                    <div class="text">최신 보안 엔진이 적용된 안전한 접속 환경입니다.</div>
                </div>

            </form>
        </div>

    </div>
</main>

<footer class="site-footer">
    <div class="container">© 2026 Sanayi CLUB. All rights reserved.</div>
</footer>

</body>
</html>