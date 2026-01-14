<%@ page contentType="text/html;charset=UTF-8" %>
<!--
    ═══════════════════════════════════════════════════════════════════════
    user_header.jsp - 회원가입/로그인 공통 헤더
    ═══════════════════════════════════════════════════════════════════════
    
    [설명]
    회원가입, 로그인 등 인증 프로세스에서 사용되는 간단한 상단바입니다.
    로고와 기본 네비게이션만 표시합니다.
    
    [적용 페이지]
    - selectRole.jsp (역할 선택)
    - signup.jsp (회원가입)
    - trust-guideline.jsp (신뢰 가이드라인)
    - login.jsp (로그인)
-->
<style>
    .site-header {
        background-color: #2B2B2B;
        color: white;
        padding: 1rem 2rem;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        position: sticky;
        top: 0;
        z-index: 100;
    }

    .header-inner {
        max-width: 1200px;
        margin: 0 auto;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .site-header .logo {
        display: flex;
        align-items: center;
        gap: 0.6rem;
        text-decoration: none;
    }

    .site-header .logo img {
        height: 40px;
        object-fit: contain;
    }

    .brand-name {
        color: #94D9DB;
        font-weight: 700;
        letter-spacing: 0.06em;
        font-size: 1rem;
    }

    .top-nav {
        display: flex;
        gap: 2rem;
    }

    .top-nav a {
        color: white;
        text-decoration: none;
        font-size: 0.95rem;
        transition: opacity 0.3s ease;
    }

    .top-nav a:hover {
        opacity: 0.8;
    }
</style>

<header class="site-header">
    <div class="header-inner">
        <a class="logo" href="${pageContext.request.contextPath}/">
            <img src="${pageContext.request.contextPath}/resources/images/ratelogo.png" alt="Ratel Ocean 로고">
            <span class="brand-name">RATEL OCEAN</span>
        </a>
        <nav class="top-nav">
            <a href="${pageContext.request.contextPath}/onboarding">서비스 소개</a>
            <a href="${pageContext.request.contextPath}/contact">고객센터</a>
        </nav>
    </div>
</header>
