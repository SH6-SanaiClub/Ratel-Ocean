<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
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
      --primary: #173160;
      --accent: #6d4dfd;
      --primary-bg: rgba(109, 77, 253, 0.12);
      --danger: #dc2626;
      --danger-bg: #fee2e2;
      --dark: #0f172a;
      --muted: #64748b;
      --light: #f6f6f8;
      --card-bg: #ffffff;
      --line: #e5e7eb;
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
<jsp:include page="/WEB-INF/views/common/headerBase.jsp" />

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
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
            <line x1="9" y1="9" x2="15" y2="9"></line>
            <line x1="9" y1="15" x2="15" y2="15"></line>
          </svg>
        </div>
      </div>
      <div class="stat-value">${stat.ongoingProjects}</div>
      <div class="stat-label">건</div>
    </div>

    <div class="stat-card">
      <div class="stat-header">
        <span class="stat-title">총 수익금</span>
        <div class="stat-icon">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="12" y1="1" x2="12" y2="23"></line>
            <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
          </svg>
        </div>
      </div>
      <div class="stat-value">
        <fmt:formatNumber value="${stat.totalEarnings}" type="currency" currencySymbol="₩"/>
      </div>
      <div class="stat-label">누적 수익</div>
    </div>

    <div class="stat-card">
      <div class="stat-header">
        <span class="stat-title">지원 대기중</span>
        <div class="stat-icon">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="12" cy="12" r="10"></circle>
            <polyline points="12 6 12 12 16 14"></polyline>
          </svg>
        </div>
      </div>
      <div class="stat-value">${stat.pendingApplications}</div>
      <div class="stat-label">건</div>
    </div>

    <div class="stat-card">
      <div class="stat-header">
        <span class="stat-title">내 지갑</span>
        <div class="stat-icon">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M20 12V8H6a2 2 0 0 1-2-2c0-1.1.9-2 2-2h12v4"></path>
            <path d="M4 6v12c0 1.1.9 2 2 2h14v-4"></path>
            <path d="M18 12a2 2 0 0 0-2 2c0 1.1.9 2 2 2h4v-4h-4z"></path>
          </svg>
        </div>
      </div>
      <div class="stat-value" style="color: var(--primary);">
        <fmt:formatNumber value="${stat.walletBalance}" type="currency" currencySymbol="₩"/>
      </div>
      <div class="stat-label">출금 가능 잔액</div>
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

  <div class="projects-section">
    <div class="section-header">
      <h2 class="section-title">최근 지원한 프로젝트</h2>
      <a href="${pageContext.request.contextPath}/freelancer/project/manage?tab=applied" class="view-all-link">전체 보기 →</a>
    </div>
    <ul class="project-list">
      <c:choose>
        <c:when test="${empty stat.recentProjects}">
          <li class="project-item" style="text-align: center; color: var(--muted);">지원한 내역이 없습니다.</li>
        </c:when>
        <c:otherwise>
          <c:forEach var="project" items="${stat.recentProjects}">
            <li class="project-item">
              <div class="project-title">${project.title}</div>
              <div class="project-meta">
                <span><fmt:formatNumber value="${project.budget}" type="currency" currencySymbol="₩"/></span>
                <span>•</span>
                <span>예상 기간: ${project.estDuration}</span>
                <span>•</span>
                  <%-- 지원 상태에 따른 뱃지 표시 --%>
                <c:choose>
                  <c:when test="${project.applicationStatus eq 'PENDING'}">
                    <span class="project-badge status-PENDING">지원 대기중</span>
                  </c:when>
                  <c:when test="${project.applicationStatus eq 'ACCEPTED'}">
                    <span class="project-badge status-ACCEPTED">합격</span>
                  </c:when>
                  <c:when test="${project.applicationStatus eq 'REJECTED'}">
                    <span class="project-badge status-REJECTED">불합격</span>
                  </c:when>
                  <c:otherwise>
                    <span class="project-badge">${project.applicationStatus}</span>
                  </c:otherwise>
                </c:choose>
              </div>
            </li>
          </c:forEach>
        </c:otherwise>
      </c:choose>
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

  // [차트 데이터 바인딩]
  const earningsLabels = [
    <c:forEach items="${stat.monthlyLabels}" var="label" varStatus="s">
    '${label}'${!s.last ? ',' : ''}
    </c:forEach>
  ];
  const earningsData = [
    <c:forEach items="${stat.monthlyData}" var="val" varStatus="s">
    ${val}${!s.last ? ',' : ''}
    </c:forEach>
  ];

  const statusData = [
    <c:forEach items="${stat.statusCounts}" var="val" varStatus="s">
    ${val}${!s.last ? ',' : ''}
    </c:forEach>
  ];

  // 월별 수익 차트 (Line)
  const earningsCtx = document.getElementById('earningsChart').getContext('2d');
  new Chart(earningsCtx, {
    type: 'line',
    data: {
      labels: earningsLabels,
      datasets: [{
        label: '월별 수익',
        data: earningsData,
        borderColor: '#173160', // --primary
        backgroundColor: 'rgba(109, 77, 253, 0.1)', // --primary-bg
        pointBackgroundColor: '#6d4dfd', // --accent
        borderWidth: 2,
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
              if(value >= 10000) return (value/10000) + '만원';
              return value + '원';
            }
          }
        }
      },
      plugins: { legend: { display: false } }
    }
  });

  // 프로젝트 완료율 차트 (Doughnut)
  const completionCtx = document.getElementById('completionChart').getContext('2d');
  new Chart(completionCtx, {
    type: 'doughnut',
    data: {
      labels: ['완료', '진행중', '취소'],
      datasets: [{
        data: statusData,
        backgroundColor: [
          '#173160', // 완료 (Primary)
          '#6d4dfd', // 진행중 (Accent)
          '#64748b'  // 취소 (Muted)
        ],
        borderWidth: 0
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: true,
      aspectRatio: 1.5,
      plugins: {
        legend: { position: 'bottom' }
      }
    }
  });
</script>
</body>
</html>

