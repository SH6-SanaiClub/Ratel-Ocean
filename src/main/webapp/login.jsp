<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>로그인 - FreelanceHub</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/login.css">
</head>
<body>
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

<main class="login-page">
    <div class="container login-center">
        <div class="title-area">
            <h1 class="page-title">로그인</h1>
            <p class="page-sub">전문 프리랜서를 위한 비즈니스 파트너</p>
        </div>

        <div class="login-card">
            <form class="login-form" action="#" method="post" novalidate>
                <label class="field" for="username">
                    <div class="label">아이디</div>
                    <div class="input-with-icon">
                        <svg class="icon user" viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><path d="M12 12c2.761 0 5-2.239 5-5s-2.239-5-5-5-5 2.239-5 5 2.239 5 5 5zM4 20c0-4 4-6 8-6s8 2 8 6v1H4v-1z" fill="currentColor"/></svg>
                        <input id="username" name="username" class="input" placeholder="아이디를 입력하세요" autocomplete="username" />
                    </div>
                </label>

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