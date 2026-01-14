<%@ page pageEncoding="UTF-8" %>
<%--
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  client_header.jsp - 클라이언트 전용 공통 헤더
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[사용 방식]
  <%@ include file="/WEB-INF/views/common/client_header.jsp" %>

[구조]
  - 좌측: Ratel 브랜드 로고 (홈 이동용)
  - 중앙: 클라이언트 전용 네비게이션 메뉴
  - 우측: 알림 / 채팅 / 프로필

[링크 매핑]
  - Ratel 로고: / (홈)
  - 프로젝트 찾기: /project_dashboard
  - 내 프로젝트 관리: /myproject
  - 채팅방: /chat
  - 마이 프로필: /myprofile
  - 알림: /notifications

[정적 리소스]
  - Ratel 로고: /resources/images/ratelogo.png
  - 기본 프로필: /resources/images/default_profile.png

[디자인 원칙]
  - 프리랜서 헤더와 디자인 100% 동일
  - 차이점: 중앙 메뉴만 클라이언트용으로 변경

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--%>
<style>
/* ================================================
   헤더 컨테이너
================================================ */
.site-header {
    background-color: #2B2B2B;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
    position: sticky;
    top: 0;
    z-index: 1000;
}

/* ================================================
   헤더 내부 - 3분할 Flex 레이아웃
================================================ */
.header-inner {
    max-width: 1400px;
    height: 70px;
    margin: 0 auto;
    padding: 0 2rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
}

/* ================================================
   좌측 영역 - Ratel 브랜드 로고
================================================ */
.header-left {
    flex: 0 0 auto;
}

.header-left .brand-logo {
    display: flex;
    align-items: center;
    gap: 0.6rem;
    text-decoration: none;
}

.header-left .brand-logo img {
    height: 42px;
    object-fit: contain;
}

.header-left .brand-name {
    color: #94D9DB;
    font-weight: 700;
    letter-spacing: 0.06em;
    font-size: 1rem;
}

/* ================================================
   중앙 영역 - 클라이언트 전용 네비게이션
================================================ */
.header-center {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 3rem;
}

.header-center nav {
    display: flex;
    gap: 2rem;
}

.header-center nav a {
    color: white;
    text-decoration: none;
    font-size: 0.95rem;
    font-weight: 400;
    white-space: nowrap;
    transition: color 0.2s ease;
}

.header-center nav a:hover {
    color: #94D9DB;
}

/* ================================================
   우측 영역 - 알림 / 채팅 / 프로필
================================================ */
.header-right {
    flex: 0 0 auto;
    display: flex;
    align-items: center;
    gap: 1.2rem;
}

.header-right .icon-btn {
    position: relative;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 38px;
    height: 38px;
    text-decoration: none;
    border-radius: 50%;
    transition: background-color 0.2s ease;
}

.header-right .icon-btn:hover {
    background-color: rgba(255, 255, 255, 0.1);
}

.header-right .icon-btn svg {
    width: 22px;
    height: 22px;
    fill: white;
}

.header-right .badge {
    position: absolute;
    top: 2px;
    right: 2px;
    min-width: 18px;
    height: 18px;
    padding: 0 5px;
    border-radius: 10px;
    background-color: #94D9DB;
    color: #2B2B2B;
    font-size: 0.7rem;
    font-weight: 700;
    display: flex;
    align-items: center;
    justify-content: center;
    line-height: 1;
}

.header-right .badge:empty {
    display: none;
}

.header-right .profile-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    text-decoration: none;
}

.header-right .profile-btn img {
    width: 38px;
    height: 38px;
    border-radius: 50%;
    border: 2px solid transparent;
    object-fit: cover;
    transition: border-color 0.2s ease;
}

.header-right .profile-btn:hover img {
    border-color: #94D9DB;
}
</style>

<header class="site-header">
    <div class="header-inner">

        <!-- ========== 좌측: Ratel 브랜드 로고 ========== -->
        <div class="header-left">
            <a class="brand-logo" href="${pageContext.request.contextPath}/">
                <img src="${pageContext.request.contextPath}/resources/images/ratelogo.png" alt="Ratel Ocean">
                <span class="brand-name">RATEL OCEAN</span>
            </a>
        </div>

        <!-- ========== 중앙: 클라이언트 전용 네비게이션 ========== -->
        <div class="header-center">
            <nav>
                <a href="${pageContext.request.contextPath}/project_dashboard">프로젝트 찾기</a>
                <a href="${pageContext.request.contextPath}/myproject">내 프로젝트 관리</a>
                <a href="${pageContext.request.contextPath}/chat">채팅방</a>
                <a href="${pageContext.request.contextPath}/myprofile">마이 프로필</a>
            </nav>
        </div>

        <!-- ========== 우측: 알림 / 채팅 / 프로필 ========== -->
        <div class="header-right">
            <!-- 알림 -->
            <a class="icon-btn" href="${pageContext.request.contextPath}/notifications" aria-label="알림">
                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.9 2 2 2zm6-6v-5c0-3.07-1.63-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.64 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z"/>
                </svg>
                <span class="badge"></span>
            </a>

            <!-- 채팅 -->
            <a class="icon-btn" href="${pageContext.request.contextPath}/chat" aria-label="채팅">
                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm0 14H6l-2 2V4h16v12z"/>
                    <path d="M7 9h10v2H7zm0 4h7v2H7z"/>
                </svg>
                <span class="badge"></span>
            </a>

            <!-- 프로필 -->
            <a class="profile-btn" href="${pageContext.request.contextPath}/myprofile" aria-label="프로필">
                <img src="${pageContext.request.contextPath}/resources/images/default_profile.png" alt="프로필">
            </a>
        </div>

    </div>
</header>
