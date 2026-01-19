<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% if (request.getAttribute("headerRendered") == null) { request.setAttribute("headerRendered", true); %>
<style>
.site-header { background-color: #2B2B2B; box-shadow: 0 2px 8px rgba(0,0,0,0.15); position: sticky; top: 0; z-index: 1000; }
.header-inner { max-width: 1400px; height: 70px; margin: 0 auto; padding: 0 2rem; display: flex; align-items: center; justify-content: space-between; }
.header-left { flex: 0 0 auto; }
.header-left .brand-logo { display: flex; align-items: center; gap: 0.6rem; text-decoration: none; }
.header-left .brand-logo img { height: 42px; object-fit: contain; }
.header-left .brand-name { color: #94D9DB; font-weight: 700; letter-spacing: 0.06em; font-size: 1rem; }
.header-center { flex: 1; display: flex; align-items: center; justify-content: center; gap: 3rem; }
.header-center nav { display: flex; gap: 2rem; }
.header-center nav a { color: white; text-decoration: none; font-size: 0.95rem; font-weight: 400; white-space: nowrap; transition: color 0.2s ease; }
.header-center nav a:hover { color: #94D9DB; }
.header-right { flex: 0 0 auto; display: flex; align-items: center; gap: 1.2rem; }
.header-right .icon-btn { position: relative; display: inline-flex; align-items: center; justify-content: center; width: 38px; height: 38px; text-decoration: none; border-radius: 50%; transition: background-color 0.2s ease; }
.header-right .icon-btn:hover { background-color: rgba(255,255,255,0.1); }
.header-right .icon-btn svg { width: 22px; height: 22px; fill: white; }
.header-right .badge { position: absolute; top: 2px; right: 2px; min-width: 18px; height: 18px; padding: 0 5px; border-radius: 10px; background-color: #94D9DB; color: #2B2B2B; font-size: 0.7rem; font-weight: 700; display: flex; align-items: center; justify-content: center; line-height: 1; }
.header-right .badge:empty { display: none; }
.header-right .profile-dropdown { position: relative; }
.header-right .profile-btn { display: inline-flex; align-items: center; justify-content: center; text-decoration: none; cursor: pointer; }
.header-right .profile-btn img { width: 38px; height: 38px; border-radius: 50%; border: 2px solid transparent; object-fit: cover; transition: border-color 0.2s ease; }
.header-right .profile-btn:hover img { border-color: #94D9DB; }
.profile-menu { position: absolute; top: 50px; right: 0; background: white; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); min-width: 160px; opacity: 0; visibility: hidden; transform: translateY(-10px); transition: all 0.2s ease; z-index: 1001; }
.profile-dropdown:hover .profile-menu { opacity: 1; visibility: visible; transform: translateY(0); }
.profile-menu a { display: block; padding: 12px 16px; color: #2B2B2B; text-decoration: none; font-size: 0.9rem; transition: background 0.2s ease; border-bottom: 1px solid #f0f0f0; }
.profile-menu a:last-child { border-bottom: none; }
.profile-menu a:hover { background: #f8f9fa; }
.profile-menu a:first-child { border-radius: 8px 8px 0 0; }
.profile-menu a:last-child { border-radius: 0 0 8px 8px; }
.notification-dropdown { position: relative; }
.notification-menu { position: absolute; top: 50px; right: 0; background: white; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); min-width: 280px; opacity: 0; visibility: hidden; transform: translateY(-10px); transition: all 0.2s ease; z-index: 1001; max-height: 400px; overflow-y: auto; }
.notification-dropdown:hover .notification-menu { opacity: 1; visibility: visible; transform: translateY(0); }
.notification-item { padding: 12px 16px; border-bottom: 1px solid #f0f0f0; color: #2B2B2B; font-size: 0.9rem; }
.notification-item:last-child { border-bottom: none; }
.notification-item:hover { background: #f8f9fa; }
.notification-empty { padding: 20px 16px; text-align: center; color: #999; font-size: 0.9rem; }
</style>

<header class="site-header">
  <div class="header-inner">
    <!-- 좌측 로고 -->
    <div class="header-left">
      <a class="brand-logo" href="${pageContext.request.contextPath}/client/main">
        <img src="${pageContext.request.contextPath}/resources/images/ratelogo.png" alt="Ratel Ocean">
        <span class="brand-name">RATEL OCEAN</span>
      </a>
    </div>

    <!-- 중앙: 클라이언트 메뉴 -->
    <div class="header-center">
      <nav>
        <a href="${pageContext.request.contextPath}/project/dashboard">프로젝트 찾기</a>
        <a href="${pageContext.request.contextPath}/client/my-projects">내 프로젝트 관리</a>
        <a href="${pageContext.request.contextPath}/chat">채팅방</a>
      </nav>
    </div>

    <!-- 우측: 알림 / 프로필 드롭다운 -->
    <div class="header-right">
      <div class="notification-dropdown">
        <a class="icon-btn" aria-label="알림">
          <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.9 2 2 2zm6-6v-5c0-3.07-1.63-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.64 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z"/></svg>
          <span class="badge"></span>
        </a>
        <div class="notification-menu">
          <div class="notification-item">최근 알림이 없습니다.</div>
        </div>
      </div>
      <div class="profile-dropdown">
        <div class="profile-btn" aria-label="프로필">
          <img src="${pageContext.request.contextPath}/resources/images/default_profile.png" alt="프로필">
        </div>
        <div class="profile-menu">
          <a href="${pageContext.request.contextPath}/client/profile">마이 프로필</a>
          <a href="${pageContext.request.contextPath}/contact">문의하기</a>
          <a href="${pageContext.request.contextPath}/">로그아웃</a>
        </div>
      </div>
    </div>
  </div>
</header>
<% } %>