<%--
  Created by IntelliJ IDEA.
  User: kimyoungbeen
  Date: 2026. 1. 19.
  Time: 09:32
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>프리랜서 대시보드 - Ratel-Ocean</title>

  <!-- Chart.js -->
  <script src="https://cdn.jsdelivr.net/npm/chart.js@2.9.4/dist/Chart.min.js"></script>

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
      background: var(--light);
      color: var(--dark);
    }

    /* 헤더 네비게이션 */
    .header {
      background: white;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
      position: sticky;
      top: 0;
      z-index: 100;
    }

    .header-inner {
      max-width: 1400px;
      margin: 0 auto;
      padding: 0 2rem;
      display: flex;
      align-items: center;
      gap: 2rem;
    }

    .logo {
      font-size: 1.25rem;
      font-weight: bold;
      color: var(--primary);
      text-decoration: none;
      padding: 1rem 0;
      display: flex;
      align-items: center;
      gap: 0.5rem;
    }

    .logo-icon {
      width: 28px;
      height: 28px;
      background: var(--primary);
      border-radius: 6px;
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      font-size: 0.9rem;
      font-weight: bold;
    }

    .nav-menu {
      display: flex;
      gap: 0.5rem;
      flex: 1;
    }

    .nav-link {
      color: var(--dark);
      text-decoration: none;
      padding: 1rem 1.25rem;
      border-bottom: 3px solid transparent;
      transition: all 0.2s;
      font-weight: 500;
      font-size: 0.95rem;
    }

    .nav-link:hover {
      color: var(--primary);
    }

    .nav-link.active {
      color: var(--primary);
      border-bottom-color: var(--primary);
    }

    .nav-icons {
      display: flex;
      align-items: center;
      gap: 1rem;
    }

    .icon-btn {
      width: 40px;
      height: 40px;
      display: flex;
      align-items: center;
      justify-content: center;
      background: var(--light);
      border: none;
      border-radius: 50%;
      cursor: pointer;
      transition: all 0.2s;
      position: relative;
    }

    .icon-btn:hover {
      background: var(--secondary);
    }

    .icon-btn .badge {
      position: absolute;
      top: 5px;
      right: 5px;
      width: 8px;
      height: 8px;
      background: #ef4444;
      border-radius: 50%;
    }

    .profile-dropdown {
      position: relative;
    }

    .profile-btn {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      padding: 0.5rem 1rem;
      background: var(--light);
      border: none;
      border-radius: 20px;
      cursor: pointer;
      font-weight: 500;
      transition: all 0.2s;
    }

    .profile-btn:hover {
      background: var(--secondary);
    }

    .dropdown-menu {
      display: none;
      position: absolute;
      top: 100%;
      right: 0;
      margin-top: 0.5rem;
      background: white;
      border-radius: 10px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.15);
      min-width: 180px;
      overflow: hidden;
    }

    .dropdown-menu.show {
      display: block;
    }

    .dropdown-item {
      display: block;
      padding: 0.875rem 1.25rem;
      color: var(--dark);
      text-decoration: none;
      transition: background 0.2s;
    }

    .dropdown-item:hover {
      background: var(--light);
    }

    .dropdown-divider {
      height: 1px;
      background: #e2e8f0;
      margin: 0.5rem 0;
    }

    /* 메인 콘텐츠 */
    .main-content {
      max-width: 1400px;
      margin: 0 auto;
      padding: 2rem;
    }

    .page-header {
      margin-bottom: 2rem;
    }

    .page-title {
      font-size: 1.75rem;
      color: var(--dark);
      margin-bottom: 0.5rem;
    }

    .page-subtitle {
      color: var(--muted);
      font-size: 0.95rem;
    }

    /* 통계 카드 */
    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 1.5rem;
      margin-bottom: 2rem;
    }

    .stat-card {
      background: white;
      padding: 1.5rem;
      border-radius: 12px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.05);
      transition: all 0.3s;
    }

    .stat-card:hover {
      box-shadow: 0 4px 16px rgba(0,0,0,0.1);
      transform: translateY(-2px);
    }

    .stat-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 1rem;
    }

    .stat-title {
      color: var(--muted);
      font-size: 0.9rem;
      font-weight: 500;
    }

    .stat-icon {
      width: 40px;
      height: 40px;
      background: var(--light);
      border-radius: 10px;
      display: flex;
      align-items: center;
      justify-content: center;
      color: var(--primary);
    }

    .stat-value {
      font-size: 2rem;
      font-weight: 700;
      color: var(--dark);
      margin-bottom: 0.25rem;
    }

    .stat-label {
      color: var(--muted);
      font-size: 0.85rem;
    }

    /* 차트 섹션 */
    .chart-section {
      display: grid;
      grid-template-columns: 2fr 1fr;
      gap: 1.5rem;
      margin-bottom: 2rem;
    }

    .chart-card {
      background: white;
      padding: 1.5rem;
      border-radius: 12px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.05);
    }

    .chart-header {
      margin-bottom: 1.5rem;
    }

    .chart-title {
      font-size: 1.1rem;
      font-weight: 600;
      color: var(--dark);
    }

    .chart-subtitle {
      color: var(--muted);
      font-size: 0.85rem;
      margin-top: 0.25rem;
    }

    /* 프로젝트 리스트 */
    .projects-section {
      background: white;
      padding: 1.5rem;
      border-radius: 12px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.05);
    }

    .section-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 1.5rem;
    }

    .section-title {
      font-size: 1.1rem;
      font-weight: 600;
      color: var(--dark);
    }

    .view-all-link {
      color: var(--primary);
      text-decoration: none;
      font-size: 0.9rem;
      font-weight: 500;
    }

    .project-list {
      list-style: none;
    }

    .project-item {
      padding: 1.25rem;
      border-bottom: 1px solid #e2e8f0;
      transition: background 0.2s;
    }

    .project-item:last-child {
      border-bottom: none;
    }

    .project-item:hover {
      background: var(--light);
    }

    .project-title {
      font-weight: 600;
      color: var(--dark);
      margin-bottom: 0.5rem;
      font-size: 0.95rem;
    }

    .project-meta {
      display: flex;
      gap: 1rem;
      color: var(--muted);
      font-size: 0.85rem;
    }

    .project-badge {
      display: inline-block;
      padding: 0.25rem 0.75rem;
      background: var(--secondary);
      color: var(--dark);
      border-radius: 20px;
      font-size: 0.75rem;
      font-weight: 500;
    }

    /* 반응형 */
    @media (max-width: 1024px) {
      .chart-section {
        grid-template-columns: 1fr;
      }
    }

    @media (max-width: 768px) {
      .header-inner {
        padding: 0 1rem;
      }

      .nav-menu {
        display: none;
      }

      .main-content {
        padding: 1rem;
      }

      .stats-grid {
        grid-template-columns: repeat(2, 1fr);
      }
    }

    @media (max-width: 640px) {
      .stats-grid {
        grid-template-columns: 1fr;
      }
    }
  </style>
</head>
<body>
<!-- 헤더 네비게이션 -->
<header class="header">
  <div class="header-inner">
    <a href="${pageContext.request.contextPath}/freelancer/dashboard" class="logo">
      <div class="logo-icon">R</div>
      <span>Ratel-Ocean</span>
    </a>

    <nav class="nav-menu">
      <a href="${pageContext.request.contextPath}/project/dashboard" class="nav-link">프로젝트 찾기</a>
      <a href="${pageContext.request.contextPath}/freelancer/finance" class="nav-link">내 금융 관리</a>
      <a href="${pageContext.request.contextPath}/freelancer/career" class="nav-link">내 프로젝트 관리</a>
      <a href="${pageContext.request.contextPath}/freelancer/career" class="nav-link">내 프로필</a>
    </nav>

    <div class="nav-icons">
      <!-- 알림 -->
      <button class="icon-btn" title="알림">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
          <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
        </svg>
        <span class="badge"></span>
      </button>

      <!-- 채팅 -->
      <button class="icon-btn" title="채팅">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
        </svg>
      </button>

      <!-- 프로필 드롭다운 -->
      <div class="profile-dropdown">
        <button class="profile-btn" onclick="toggleDropdown()">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
            <circle cx="12" cy="7" r="4"></circle>
          </svg>
          <span>${loginId}</span>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <polyline points="6 9 12 15 18 9"></polyline>
          </svg>
        </button>

        <div id="dropdownMenu" class="dropdown-menu">
          <a href="${pageContext.request.contextPath}/freelancer/mypage" class="dropdown-item">마이페이지</a>
          <a href="${pageContext.request.contextPath}/freelancer/wallet" class="dropdown-item">지갑</a>
          <a href="${pageContext.request.contextPath}/freelancer/earnings" class="dropdown-item">수익 관리</a>
          <div class="dropdown-divider"></div>
          <a href="#" onclick="logout(event)" class="dropdown-item">로그아웃</a>
        </div>
      </div>
    </div>
  </div>
</header>

<!-- 메인 콘텐츠 -->
<main class="main-content">
  <!-- 페이지 헤더 -->
  <div class="page-header">
    <h1 class="page-title">대시보드</h1>
    <p class="page-subtitle">프리랜서 활동 현황을 한눈에 확인하세요</p>
  </div>

  <!-- 통계 카드 -->
  <div class="stats-grid">
    <div class="stat-card">
      <div class="stat-header">
        <span class="stat-title">진행중인 프로젝트</span>
        <div class="stat-icon">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
            <line x1="9" y1="9" x2="15" y2="9"></line>
            <line x1="9" y1="15" x2="15" y2="15"></line>
          </svg>
        </div>
      </div>
      <div class="stat-value">${ongoingProjects}</div>
      <div class="stat-label">프로젝트</div>
    </div>

    <div class="stat-card">
      <div class="stat-header">
        <span class="stat-title">총 수익금</span>
        <div class="stat-icon">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <line x1="12" y1="1" x2="12" y2="23"></line>
            <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
          </svg>
        </div>
      </div>
      <div class="stat-value">₩${totalEarnings}</div>
      <div class="stat-label">누적 수익</div>
    </div>

    <div class="stat-card">
      <div class="stat-header">
        <span class="stat-title">지원 대기중</span>
        <div class="stat-icon">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <circle cx="12" cy="12" r="10"></circle>
            <polyline points="12 6 12 12 16 14"></polyline>
          </svg>
        </div>
      </div>
      <div class="stat-value">${pendingApplications}</div>
      <div class="stat-label">건</div>
    </div>

    <div class="stat-card">
      <div class="stat-header">
        <span class="stat-title">프로필 완성도</span>
        <div class="stat-icon">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
            <polyline points="22 4 12 14.01 9 11.01"></polyline>
          </svg>
        </div>
      </div>
      <div class="stat-value">${profileCompletion}%</div>
      <div class="stat-label">완료</div>
    </div>
  </div>

  <!-- 차트 섹션 -->
  <div class="chart-section">
    <div class="chart-card">
      <div class="chart-header">
        <h2 class="chart-title">월별 수익 현황</h2>
        <p class="chart-subtitle">최근 6개월 수익 추이</p>
      </div>
      <canvas id="earningsChart"></canvas>
    </div>

    <div class="chart-card">
      <div class="chart-header">
        <h2 class="chart-title">프로젝트 완료율</h2>
        <p class="chart-subtitle">전체 프로젝트 대비</p>
      </div>
      <canvas id="completionChart"></canvas>
    </div>
  </div>

  <!-- 최근 지원한 프로젝트 -->
  <div class="projects-section">
    <div class="section-header">
      <h2 class="section-title">최근 지원한 프로젝트</h2>
      <a href="${pageContext.request.contextPath}/freelancer/applications" class="view-all-link">전체 보기 →</a>
    </div>
    <ul class="project-list">
      <li class="project-item">
        <div class="project-title">AI 기반 챗봇 상담 솔루션 프론트엔드 개발</div>
        <div class="project-meta">
          <span>₩6,500,000</span>
          <span>•</span>
          <span>예상 기간: 2개월</span>
          <span>•</span>
          <span class="project-badge">지원 대기중</span>
        </div>
      </li>
      <li class="project-item">
        <div class="project-title">헬스케어 모바일 앱 UX/UI 디자인 리뉴얼</div>
        <div class="project-meta">
          <span>₩8,000,000</span>
          <span>•</span>
          <span>예상 기간: 1.5개월</span>
          <span>•</span>
          <span class="project-badge">검토중</span>
        </div>
      </li>
      <li class="project-item">
        <div class="project-title">사내 인트라넷 보안 패치 및 데이터베이스 최적화</div>
        <div class="project-meta">
          <span>₩4,000,000</span>
          <span>•</span>
          <span>예상 기간: 3주</span>
          <span>•</span>
          <span class="project-badge">지원 대기중</span>
        </div>
      </li>
    </ul>
  </div>
</main>

<!-- JavaScript -->
<script>
  // 드롭다운 토글
  function toggleDropdown() {
    const dropdown = document.getElementById('dropdownMenu');
    dropdown.classList.toggle('show');
  }

  // 외부 클릭 시 드롭다운 닫기
  document.addEventListener('click', function(e) {
    const profileDropdown = document.querySelector('.profile-dropdown');
    if (!profileDropdown.contains(e.target)) {
      document.getElementById('dropdownMenu').classList.remove('show');
    }
  });

  // 로그아웃
  async function logout(e) {
    e.preventDefault();

    try {
      const response = await fetch('${pageContext.request.contextPath}/logout', {
        method: 'POST'
      });

      if (response.ok) {
        window.location.href = '${pageContext.request.contextPath}/login';
      }
    } catch (error) {
      console.error('로그아웃 오류:', error);
      alert('로그아웃에 실패했습니다.');
    }
  }

  // 월별 수익 차트
  const earningsCtx = document.getElementById('earningsChart').getContext('2d');
  new Chart(earningsCtx, {
    type: 'line',
    data: {
      labels: ['8월', '9월', '10월', '11월', '12월', '1월'],
      datasets: [{
        label: '월별 수익 (만원)',
        data: [180, 220, 190, 250, 280, 320],
        borderColor: '#1F7A8C',
        backgroundColor: 'rgba(31, 122, 140, 0.1)',
        tension: 0.4,
        fill: true
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: true,
      aspectRatio: 2.5,
      scales: {
        y: {
          beginAtZero: true,
          ticks: {
            callback: function(value) {
              return value + '만원';
            }
          }
        }
      },
      plugins: {
        legend: {
          display: false
        }
      }
    }
  });

  // 프로젝트 완료율 차트
  const completionCtx = document.getElementById('completionChart').getContext('2d');
  new Chart(completionCtx, {
    type: 'doughnut',
    data: {
      labels: ['완료', '진행중', '취소'],
      datasets: [{
        data: [15, 3, 2],
        backgroundColor: [
          '#1F7A8C',
          '#A9D9DB',
          '#6F7272'
        ],
        borderWidth: 0
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: true,
      aspectRatio: 1.5,
      plugins: {
        legend: {
          position: 'bottom'
        }
      }
    }
  });
</script>
</body>
</html>

