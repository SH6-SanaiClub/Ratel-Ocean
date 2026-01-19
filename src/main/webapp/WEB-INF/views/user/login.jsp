<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>로그인 - RatelOcean</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Malgun Gothic', -apple-system, BlinkMacSystemFont, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        .login-container {
            background: white;
            padding: 50px 40px;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            max-width: 420px;
            width: 90%;
        }

        .logo-area {
            text-align: center;
            margin-bottom: 30px;
        }

        .logo {
            font-size: 28px;
            font-weight: bold;
            color: #667eea;
            margin-bottom: 8px;
        }

        .subtitle {
            color: #666;
            font-size: 14px;
        }

        .login-form {
            margin-top: 30px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: bold;
            font-size: 14px;
        }

        .form-input {
            width: 100%;
            padding: 14px 16px;
            border: 1px solid #d1d5db;
            border-radius: 10px;
            font-size: 15px;
            transition: all 0.3s;
            outline: none;
        }

        .form-input:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .error-message {
            background: #fee;
            color: #c33;
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
            border-left: 4px solid #c33;
            animation: shake 0.3s;
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-10px); }
            75% { transform: translateX(10px); }
        }

        .form-options {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            font-size: 14px;
        }

        .remember-me {
            display: flex;
            align-items: center;
            gap: 6px;
            color: #666;
        }

        .remember-me input {
            width: 16px;
            height: 16px;
            cursor: pointer;
        }

        .find-link {
            color: #667eea;
            text-decoration: none;
            transition: color 0.3s;
        }

        .find-link:hover {
            color: #5568d3;
        }

        .btn-login {
            width: 100%;
            padding: 16px;
            border: none;
            border-radius: 10px;
            background: #667eea;
            color: white;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s;
        }

        .btn-login:hover {
            background: #5568d3;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }

        .divider {
            text-align: center;
            margin: 30px 0;
            position: relative;
        }

        .divider::before {
            content: '';
            position: absolute;
            left: 0;
            top: 50%;
            width: 100%;
            height: 1px;
            background: #e5e7eb;
        }

        .divider-text {
            position: relative;
            display: inline-block;
            padding: 0 15px;
            background: white;
            color: #999;
            font-size: 14px;
        }

        .signup-section {
            text-align: center;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 10px;
        }

        .signup-text {
            color: #666;
            margin-bottom: 12px;
            font-size: 14px;
        }

        .btn-signup {
            display: inline-block;
            padding: 12px 30px;
            border: 2px solid #667eea;
            border-radius: 8px;
            color: #667eea;
            text-decoration: none;
            font-weight: bold;
            transition: all 0.3s;
        }

        .btn-signup:hover {
            background: #667eea;
            color: white;
            transform: translateY(-2px);
        }

        .error-message {
            background: #fee2e2;
            border-left: 4px solid #dc2626;
            padding: 12px 15px;
            margin-bottom: 20px;
            border-radius: 5px;
            color: #991b1b;
            font-size: 14px;
        }
    </style>
</head>
<body>

<div class="login-container">
    <div class="logo-area">
        <div class="logo">🌊 RatelOcean</div>
        <p class="subtitle">프리랜서 프로젝트 매칭 플랫폼</p>
    </div>

    <!-- 로그인 에러 메시지 표시 -->
    <c:if test="${not empty error}">
        <div class="error-message">
            ${error}
        </div>
    </c:if>

    <form class="login-form" action="${pageContext.request.contextPath}/login" method="post">
        <div class="form-group">
            <label class="form-label" for="email">이메일</label>
            <input 
                type="email" 
                id="email" 
                name="email" 
                class="form-input" 
                placeholder="이메일을 입력하세요"
                required
                autocomplete="email"
            />
        </div>

        <div class="form-group">
            <label class="form-label" for="password">비밀번호</label>
            <input 
                type="password" 
                id="password" 
                name="password" 
                class="form-input" 
                placeholder="비밀번호를 입력하세요"
                required
                autocomplete="current-password"
            />
        </div>

        <div class="form-options">
            <label class="remember-me">
                <input type="checkbox" name="remember" />
                <span>로그인 유지</span>
            </label>
            <a href="${pageContext.request.contextPath}/find-password" class="find-link">
                비밀번호 찾기
            </a>
        </div>

        <button type="submit" class="btn-login">
            로그인
        </button>
    </form>

    <div class="divider">
        <span class="divider-text">또는</span>
    </div>

    <div class="signup-section">
        <p class="signup-text">아직 계정이 없으신가요?</p>
        <a href="${pageContext.request.contextPath}/join/select-role.do" class="btn-signup">
            회원가입 하기
        </a>
    </div>
</div>

</body>
</html>
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