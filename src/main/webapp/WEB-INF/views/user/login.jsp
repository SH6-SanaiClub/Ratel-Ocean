<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>로그인 - Ratel-Ocean</title>
    <style>
        /* ===== RESET ===== */
        *{ margin:0; padding:0; box-sizing:border-box; }

        /* ===== THEME (요청하신 팔레트 반영) ===== */
        :root{
            /* 핵심 */
            --primary:#173160;      /* 메인 네이비 */
            --text:#0f172a;         /* 본문 텍스트 */
            --bg:#f6f6f8;           /* 페이지 배경 */

            /* 보조(요청하신 rgba 기반) */
            --accent:#3B6FDC;                       /* 59,111,220 */
            --line:rgba(59,111,220,.22);            /* border-color */
            --accent-weak:rgba(59,111,220,.10);     /* background weak */

            /* 중립 */
            --paper:#ffffff;
            --muted:#64748b;
            --dark:#111827;

            /* 입력/컨트롤(요청값 반영) */
            --control-bg:#e5e7eb;
            --control-fg:#111827;
            --control-bd:#cbd5e1;

            /* 상태 */
            --danger-bg:#fee;
            --danger-fg:#c33;
        }

        /* ===== BASE ===== */
        body{
            font-family:'Malgun Gothic', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: var(--primary);
            min-height:100vh;
            display:flex;
            flex-direction:column;
            color:var(--text);
        }

        .header{
            position: sticky; top:0;
            height:64px;
            background:#ffffff;
            color:#111827;
            z-index:1000;
            border-bottom:1px solid #e5e7eb;
        }
        .header-inner{
            height:64px;
            max-width:1200px;
            margin:0 auto;
            padding:0 24px;
            display:grid;
            grid-template-columns: 1fr auto 1fr;
            align-items:center;
            column-gap:16px;
        }

        .logo a{
            color:#111827;
            text-decoration:none;
            font-weight:800;
            letter-spacing:.3px;
            font-size:20px;
        }

        .logo-icon{
            width:32px;
            height:32px;
            background: var(--primary);
            border-radius: 8px;
            display:flex;
            align-items:center;
            justify-content:center;
            color:#fff;
            font-weight:900;
        }

        /* ===== MAIN ===== */
        .main-content{
            flex:1;
            display:flex;
            align-items:center;
            justify-content:center;
            padding:2rem;
        }

        .login-container{
            background: var(--paper);
            padding: 3rem;
            border-radius: 20px;
            box-shadow: 0 22px 70px rgba(15,23,42,0.22);
            width:100%;
            max-width:450px;
            border: 1px solid rgba(255,255,255,0.6);
        }

        .login-header{
            text-align:center;
            margin-bottom:2rem;
        }

        .login-title{
            font-size:2rem;
            color:var(--dark);
            margin-bottom:.5rem;
            letter-spacing:-.4px;
        }

        .login-subtitle{
            color:var(--muted);
            font-size:.95rem;
        }

        /* ===== FORM ===== */
        .form-group{ margin-bottom: 1.5rem; }

        .form-label{
            display:block;
            color:var(--dark);
            font-weight:650;
            margin-bottom:.5rem;
            font-size:.95rem;
        }

        .input-wrapper{ position:relative; }

        .input-icon{
            position:absolute;
            left:1rem;
            top:50%;
            transform:translateY(-50%);
            color:var(--muted);
        }

        .form-input{
            width:100%;
            padding: .875rem 1rem .875rem 3rem;
            border: 2px solid var(--control-bd);   /* 요청: border-color #cbd5e1 */
            border-radius: 12px;
            font-size:1rem;
            transition: border-color .2s, background .2s, transform .2s;
            background: #fff;
            color: var(--text);
        }

        .form-input::placeholder{ color: rgba(15,23,42,0.45); }

        .form-input:focus{
            outline:none;
            border-color: var(--line);             /* 요청: rgba(59,111,220,.22) */
            box-shadow: none;                      /* 요청: box-shadow none */
        }

        /* ===== BUTTON ===== */
        .btn-login{
            width:100%;
            padding:1rem;
            background: var(--primary);
            color:#fff;
            border: 1px solid rgba(255,255,255,0.12);
            border-radius: 12px;
            font-size: 1.05rem;
            font-weight: 800;
            cursor:pointer;
            transition: transform .2s, box-shadow .2s, filter .2s;
            margin-top:1rem;
        }

        .btn-login:hover{
            filter: brightness(1.06);
            transform: translateY(-2px);
            box-shadow: 0 10px 24px rgba(23,49,96,0.35);
        }

        .btn-login:active{
            transform: translateY(0);
            box-shadow: none;
        }

        /* ===== LINKS ===== */
        .links{
            text-align:center;
            margin-top:1.5rem;
            padding-top:1.5rem;
            border-top: 1px solid rgba(15,23,42,0.08);
        }

        .link-item{
            color: var(--muted);
            text-decoration:none;
            font-size:.9rem;
            transition: color .15s;
        }

        .link-item:hover{ color: var(--primary); }

        .link-separator{
            color: rgba(15,23,42,0.25);
            margin: 0 .5rem;
        }

        .signup-link{
            color: var(--primary);
            font-weight: 800;
        }

        /* ===== SECURITY NOTE ===== */
        .security-note{
            margin-top:1.5rem;
            padding:1rem;
            background: var(--accent-weak);          /* 요청: rgba(59,111,220,.10) */
            border: 1px solid var(--line);           /* 요청: rgba(59,111,220,.22) */
            border-radius: 12px;
            display:flex;
            align-items:center;
            gap:.75rem;
        }

        .shield-icon{
            color: var(--primary);
            font-size:1.25rem;
        }

        .security-text{
            color: var(--text);                      /* 요청: color var(--text) */
            font-size:.85rem;
            line-height:1.4;
        }

        /* ===== ERROR ===== */
        .error-message{
            background: var(--danger-bg);
            color: var(--danger-fg);
            padding: .875rem;
            border-radius: 10px;
            margin-bottom: 1rem;
            font-size: .9rem;
            display:none;
            border: 1px solid rgba(204,51,51,0.25);
        }

        .error-message.show{ display:block; }

        /* ===== FOOTER ===== */
        .footer{
            text-align:center;
            padding: 1.5rem;
            color: rgba(255,255,255,0.92);
            font-size: .9rem;
            background: rgba(0,0,0,0.12);
            border-top: 1px solid rgba(255,255,255,0.10);
        }

        /* ===== RESPONSIVE ===== */
        @media (max-width: 640px){
            .login-container{ padding: 2rem 1.5rem; }
            .login-title{ font-size: 1.5rem; }
        }

    </style>
</head>
<body>
<!-- 헤더 -->
<header class="header">
    <div class="header-inner">
        <div class="logo">
            <a href="${pageContext.request.contextPath}/">RatelOcean</a>
        </div>
    </div>
</header>

<!-- 메인 콘텐츠 -->
<main class="main-content">
    <div class="login-container">
        <!-- 로그인 헤더 -->
        <div class="login-header">
            <h1 class="login-title">Ratel Ocean</h1>
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
        var ctx = '${pageContext.request.contextPath}';
        const loginId = document.getElementById('loginId').value.trim();
        const password = document.getElementById('password').value.trim();
        const errorMessage = document.getElementById('errorMessage');
        // 입력값 검증
        if (!loginId || !password) {
            showError('아이디와 비밀번호를 입력해주세요.');
            return;
        }
        try {
            const response = await fetch(ctx + '/login', {
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
                    window.location.href = ctx + '/freelancer/dashboard';
                } else if (userType === 'CLIENT') {
                    window.location.href = ctx + '/client/dashboard';
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