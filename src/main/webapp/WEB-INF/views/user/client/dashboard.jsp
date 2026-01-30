<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>클라이언트 대시보드 - Ratel-Ocean</title>

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

        /* 섹션 카드 */
        .section-card {
            background: white;
            padding: 1.5rem;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            margin-bottom: 1.5rem;
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

        /* 프로젝트/지원자 리스트 */
        .item-list {
            list-style: none;
        }

        .item {
            padding: 1.25rem;
            border-bottom: 1px solid #e2e8f0;
            transition: background 0.2s;
        }

        .item:last-child {
            border-bottom: none;
        }

        .item:hover {
            background: var(--light);
        }

        .item-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 0.75rem;
        }

        .item-title {
            font-weight: 600;
            color: var(--dark);
            font-size: 0.95rem;
            flex: 1;
        }

        .item-badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            background: var(--secondary);
            color: var(--dark);
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 500;
        }

        .item-badge.status-active {
            background: #dcfce7;
            color: #166534;
        }

        .item-badge.status-pending {
            background: #fef3c7;
            color: #92400e;
        }

        .item-meta {
            display: flex;
            gap: 1rem;
            color: var(--muted);
            font-size: 0.85rem;
        }

        .applicant-info {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .applicant-avatar {
            width: 36px;
            height: 36px;
            background: var(--secondary);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            color: var(--dark);
        }

        .applicant-name {
            font-weight: 600;
            color: var(--dark);
        }

        .applicant-role {
            color: var(--muted);
            font-size: 0.85rem;
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
        <p class="page-subtitle">프로젝트와 지원자 현황을 한눈에 확인하세요</p>
    </div>

    <!-- 통계 카드 -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-header">
                <span class="stat-title">등록한 프로젝트</span>
                <div class="stat-icon">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                        <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
                    </svg>
                </div>
            </div>
            <div class="stat-value">${totalProjects}</div>
            <div class="stat-label">프로젝트</div>
        </div>

        <div class="stat-card">
            <div class="stat-header">
                <span class="stat-title">진행중인 계약</span>
                <div class="stat-icon">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                        <polyline points="14 2 14 8 20 8"></polyline>
                        <line x1="16" y1="13" x2="8" y2="13"></line>
                        <line x1="16" y1="17" x2="8" y2="17"></line>
                    </svg>
                </div>
            </div>
            <div class="stat-value">${activeContracts}</div>
            <div class="stat-label">건</div>
        </div>

        <div class="stat-card">
            <div class="stat-header">
                <span class="stat-title">받은 지원</span>
                <div class="stat-icon">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                        <circle cx="9" cy="7" r="4"></circle>
                        <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                        <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                    </svg>
                </div>
            </div>
            <div class="stat-value">${totalApplicants}</div>
            <div class="stat-label">명</div>
        </div>

        <div class="stat-card">
            <div class="stat-header">
                <span class="stat-title">완료된 프로젝트</span>
                <div class="stat-icon">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                        <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                        <polyline points="22 4 12 14.01 9 11.01"></polyline>
                    </svg>
                </div>
            </div>
            <div class="stat-value">${completedProjects}</div>
            <div class="stat-label">프로젝트</div>
        </div>
    </div>

    <!-- 차트 섹션 -->
    <div class="chart-section">
        <div class="chart-card">
            <div class="chart-header">
                <h2 class="chart-title">월별 프로젝트 지출 현황</h2>
                <p class="chart-subtitle">최근 6개월 지출 추이</p>
            </div>
            <canvas id="spendingChart"></canvas>
        </div>

        <div class="chart-card">
            <div class="chart-header">
                <h2 class="chart-title">프로젝트 상태</h2>
                <p class="chart-subtitle">전체 프로젝트 분포</p>
            </div>
            <canvas id="statusChart"></canvas>
        </div>
    </div>

    <!-- 최근 등록한 프로젝트 -->
    <div class="section-card">
        <div class="section-header">
            <h2 class="section-title">최근 등록한 프로젝트</h2>
            <a href="${pageContext.request.contextPath}/client/projects" class="view-all-link">전체 보기 →</a>
        </div>
        <ul class="item-list">
            <li class="item">
                <div class="item-header">
                    <div class="item-title">웹사이트 리뉴얼 프로젝트</div>
                    <span class="item-badge status-active">진행중</span>
                </div>
                <div class="item-meta">
                    <span>₩6,000,000</span>
                    <span>•</span>
                    <span>3개월</span>
                    <span>•</span>
                    <span>지원자 12명</span>
                </div>
            </li>
            <li class="item">
                <div class="item-header">
                    <div class="item-title">모바일 앱 개발</div>
                    <span class="item-badge status-active">진행중</span>
                </div>
                <div class="item-meta">
                    <span>₩12,000,000</span>
                    <span>•</span>
                    <span>5개월</span>
                    <span>•</span>
                    <span>지원자 8명</span>
                </div>
            </li>
            <li class="item">
                <div class="item-header">
                    <div class="item-title">백엔드 API 구축</div>
                    <span class="item-badge status-pending">모집중</span>
                </div>
                <div class="item-meta">
                    <span>₩10,000,000</span>
                    <span>•</span>
                    <span>3개월</span>
                    <span>•</span>
                    <span>지원자 3명</span>
                </div>
            </li>
        </ul>
    </div>

    <!-- 새로운 지원자 -->
    <div class="section-card">
        <div class="section-header">
            <h2 class="section-title">새로운 지원자</h2>
            <a href="${pageContext.request.contextPath}/client/applicants" class="view-all-link">전체 보기 →</a>
        </div>
        <ul class="item-list">
            <li class="item">
                <div class="applicant-info">
                    <div class="applicant-avatar">김</div>
                    <div>
                        <div class="applicant-name">김개발</div>
                        <div class="applicant-role">Backend Developer • 경력 5년</div>
                    </div>
                </div>
                <div class="item-meta" style="margin-top: 0.5rem;">
                    <span>웹사이트 리뉴얼 프로젝트</span>
                    <span>•</span>
                    <span>평점 4.9</span>
                </div>
            </li>
            <li class="item">
                <div class="applicant-info">
                    <div class="applicant-avatar">이</div>
                    <div>
                        <div class="applicant-name">이디자이너</div>
                        <div class="applicant-role">UI/UX Designer • 경력 3년</div>
                    </div>
                </div>
                <div class="item-meta" style="margin-top: 0.5rem;">
                    <span>모바일 앱 개발</span>
                    <span>•</span>
                    <span>평점 4.8</span>
                </div>
            </li>
            <li class="item">
                <div class="applicant-info">
                    <div class="applicant-avatar">박</div>
                    <div>
                        <div class="applicant-name">박풀스택</div>
                        <div class="applicant-role">Full-stack Developer • 경력 7년</div>
                    </div>
                </div>
                <div class="item-meta" style="margin-top: 0.5rem;">
                    <span>백엔드 API 구축</span>
                    <span>•</span>
                    <span>평점 5.0</span>
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

    // 월별 지출 차트
    const spendingCtx = document.getElementById('spendingChart').getContext('2d');
    new Chart(spendingCtx, {
        type: 'bar',
        data: {
            labels: ['8월', '9월', '10월', '11월', '12월', '1월'],
            datasets: [{
                label: '월별 지출 (만원)',
                data: [450, 380, 520, 600, 480, 720],
                backgroundColor: '#1F7A8C',
                borderRadius: 6
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

    // 프로젝트 상태 차트
    const statusCtx = document.getElementById('statusChart').getContext('2d');
    new Chart(statusCtx, {
        type: 'doughnut',
        data: {
            labels: ['완료', '진행중', '모집중'],
            datasets: [{
                data: [4, 2, 2],
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
