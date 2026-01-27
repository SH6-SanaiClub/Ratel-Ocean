<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>로그인 - Ratel-Ocean</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        :root {
            --primary: #1F7A8C;
            --secondary: #A9D9DB;
            --dark: #2B2B2B;
            --muted: #6F7272;
            --light: #F1F6EE;
        }

        body {
            font-family: 'Malgun Gothic', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* 헤더 */
        .header {
            background: rgba(255, 255, 255, 0.95);
            padding: 1rem 2rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .header-inner {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .logo {
            font-size: 1.5rem;
            font-weight: bold;
            color: var(--primary);
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .logo-icon {
            width: 32px;
            height: 32px;
            background: var(--primary);
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
        }

        /* 메인 콘텐츠 */
        .main-content {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
        }

        .login-container {
            background: white;
            padding: 3rem;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            width: 100%;
            max-width: 450px;
        }

        .login-header {
            text-align: center;
            margin-bottom: 2rem;
        }

        .login-title {
            font-size: 2rem;
            color: var(--dark);
            margin-bottom: 0.5rem;
        }

        .login-subtitle {
            color: var(--muted);
            font-size: 0.95rem;
        }

        /* 폼 스타일 */
        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-label {
            display: block;
            color: var(--dark);
            font-weight: 500;
            margin-bottom: 0.5rem;
            font-size: 0.95rem;
        }

        .input-wrapper {
            position: relative;
        }

        .input-icon {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--muted);
        }

        .form-input {
            width: 100%;
            padding: 0.875rem 1rem 0.875rem 3rem;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 1rem;
            transition: all 0.3s;
        }

        .form-input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(31, 122, 140, 0.1);
        }

        .btn-login {
            width: 100%;
            padding: 1rem;
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 1.05rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            margin-top: 1rem;
        }

        .btn-login:hover {
            background: #176675;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(31, 122, 140, 0.4);
        }

        .btn-login:active {
            transform: translateY(0);
        }

        /* 링크 영역 */
        .links {
            text-align: center;
            margin-top: 1.5rem;
            padding-top: 1.5rem;
            border-top: 1px solid #e2e8f0;
        }

        .link-item {
            color: var(--muted);
            text-decoration: none;
            font-size: 0.9rem;
            transition: color 0.2s;
        }

        .link-item:hover {
            color: var(--primary);
        }

        .link-separator {
            color: var(--muted);
            margin: 0 0.5rem;
        }

        .signup-link {
            color: var(--primary);
            font-weight: 600;
        }

        /* 보안 노트 */
        .security-note {
            margin-top: 1.5rem;
            padding: 1rem;
            background: var(--light);
            border-radius: 10px;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .shield-icon {
            color: var(--primary);
            font-size: 1.25rem;
        }

        .security-text {
            color: var(--muted);
            font-size: 0.85rem;
            line-height: 1.4;
        }

        /* 에러 메시지 */
        .error-message {
            background: #fee;
            color: #c33;
            padding: 0.875rem;
            border-radius: 8px;
            margin-bottom: 1rem;
            font-size: 0.9rem;
            display: none;
        }

        .error-message.show {
            display: block;
        }

        /* 푸터 */
        .footer {
            text-align: center;
            padding: 1.5rem;
            color: white;
            font-size: 0.9rem;
            background: rgba(0,0,0,0.1);
        }

        /* 반응형 */
        @media (max-width: 640px) {
            .login-container {
                padding: 2rem 1.5rem;
            }

            .login-title {
                font-size: 1.5rem;
            }
        }
    </style>
</head>
<body>
<!-- 헤더 -->
<header class="header">
    <div class="header-inner">
        <a href="${pageContext.request.contextPath}/" class="logo">
            <div class="logo-icon">R</div>
            <span>Ratel-Ocean</span>
        </a>
    </div>
</header>

<!-- 메인 콘텐츠 -->
<main class="main-content">
    <div class="login-container">
        <!-- 로그인 헤더 -->
        <div class="login-header">
            <h1 class="login-title">로그인</h1>
            <p class="login-subtitle">프리랜서와 클라이언트를 위한 프로젝트 매칭 플랫폼</p>
        </div>

        <!-- 에러 메시지 -->
        <div id="errorMessage" class="error-message"></div>

        <!-- 로그인 폼 -->
        <form id="loginForm" novalidate>
            <div class="form-group">
                <label for="loginId" class="form-label">아이디</label>
                <div class="input-wrapper">
                    <svg class="input-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                        <circle cx="12" cy="7" r="4"></circle>
                    </svg>
                    <input
                            type="text"
                            id="loginId"
                            name="loginId"
                            class="form-input"
                            placeholder="아이디를 입력하세요"
                            autocomplete="username"
                            required
                    />
                </div>
            </div>

            <div class="form-group">
                <label for="password" class="form-label">비밀번호</label>
                <div class="input-wrapper">
                    <svg class="input-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                    </svg>
                    <input
                            type="password"
                            id="password"
                            name="password"
                            class="form-input"
                            placeholder="비밀번호를 입력하세요"
                            autocomplete="current-password"
                            required
                    />
                </div>
            </div>

            <button type="submit" class="btn-login">로그인 →</button>
        </form>

        <!-- 링크 영역 -->
        <div class="links">
            <a href="#" class="link-item">아이디 찾기</a>
            <span class="link-separator">|</span>
            <a href="#" class="link-item">비밀번호 찾기</a>
            <span class="link-separator">|</span>
            <a href="${pageContext.request.contextPath}/join/select-role" class="link-item signup-link">회원가입</a>
        </div>

        <!-- 보안 노트 -->
        <div class="security-note">
            <div class="shield-icon">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
                </svg>
            </div>
            <div class="security-text">
                최신 보안 엔진이 적용된 안전한 접속 환경입니다.
            </div>
        </div>
    </div>
</main>

<!-- 푸터 -->
<footer class="footer">
    © 2026 Ratel-Ocean. All rights reserved.
</footer>

<!-- JavaScript -->
<script>
    document.getElementById('loginForm').addEventListener('submit', async function(e) {
        e.preventDefault();

        const loginId = document.getElementById('loginId').value.trim();
        const password = document.getElementById('password').value.trim();
        const errorMessage = document.getElementById('errorMessage');

        // 입력값 검증
        if (!loginId || !password) {
            showError('아이디와 비밀번호를 입력해주세요.');
            return;
        }

        try {
            const response = await fetch('${pageContext.request.contextPath}/login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    loginId: loginId,
                    password: password
                })
            });

            const data = await response.json();

            if (data.success) {
                // 로그인 성공 - UserType에 따라 리다이렉트
                const userType = data.data.userInfo.userType;

                if (userType === 'FREELANCER') {
                    window.location.href = '${pageContext.request.contextPath}/freelancer/dashboard';
                } else if (userType === 'CLIENT') {
                    window.location.href = '${pageContext.request.contextPath}/client/dashboard';
                }
            } else {
                // 로그인 실패
                showError(data.message || '로그인에 실패했습니다.');
            }
        } catch (error) {
            console.error('로그인 오류:', error);
            showError('서버 연결에 실패했습니다. 잠시 후 다시 시도해주세요.');
        }
    });

    function showError(message) {
        const errorMessage = document.getElementById('errorMessage');
        errorMessage.textContent = message;
        errorMessage.classList.add('show');

        setTimeout(() => {
            errorMessage.classList.remove('show');
        }, 5000);
    }
</script>
</body>
</html>