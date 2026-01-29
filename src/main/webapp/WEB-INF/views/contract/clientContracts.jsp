<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>계약 관리 - Ratel-Ocean</title>

    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/contract/clientContracts.css">

    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@2.9.4/dist/Chart.min.js"></script>
</head>
<body>
<c:set var="activeMenu" value="contracts" scope="request"/>
<style>
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
        color: #1F7A8C;
        text-decoration: none;
        padding: 1rem 0;
        display: flex;
        align-items: center;
        gap: 0.5rem;
    }

    .logo-icon {
        width: 28px;
        height: 28px;
        background: #1F7A8C;
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
        color: #2B2B2B;
        text-decoration: none;
        padding: 1rem 1.25rem;
        border-bottom: 3px solid transparent;
        transition: all 0.2s;
        font-weight: 500;
        font-size: 0.95rem;
    }

    .nav-link:hover {
        color: #1F7A8C;
    }

    .nav-link.active {
        color: #1F7A8C;
        border-bottom-color: #1F7A8C;
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
        background: #F1F6EE;
        border: none;
        border-radius: 50%;
        cursor: pointer;
        transition: all 0.2s;
        position: relative;
    }

    .icon-btn:hover {
        background: #A9D9DB;
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
        background: #F1F6EE;
        border: none;
        border-radius: 20px;
        cursor: pointer;
        font-weight: 500;
        transition: all 0.2s;
    }

    .profile-btn:hover {
        background: #A9D9DB;
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
        color: #2B2B2B;
        text-decoration: none;
        transition: background 0.2s;
    }

    .dropdown-item:hover {
        background: #F1F6EE;
    }

    .dropdown-divider {
        height: 1px;
        background: #e2e8f0;
        margin: 0.5rem 0;
    }
</style>

<!-- 헤더 네비게이션 -->
<header class="header">
    <div class="header-inner">
        <a href="${pageContext.request.contextPath}/" class="logo">
            <div class="logo-icon">R</div>
            <span>Ratel-Ocean</span>
        </a>

        <nav class="nav-menu">
            <a href="${pageContext.request.contextPath}/client/dashboard" class="nav-link ${requestScope.activeMenu eq 'dashboard' ? 'active' : ''}">대시보드</a>
            <a href="${pageContext.request.contextPath}/project/create" class="nav-link ${requestScope.activeMenu eq 'project-create' ? 'active' : ''}">프로젝트 등록</a>
            <a href="${pageContext.request.contextPath}/client/manage" class="nav-link ${requestScope.activeMenu eq 'manage' ? 'active' : ''}">내 프로젝트</a>
            <a href="${pageContext.request.contextPath}/client/applicants" class="nav-link ${requestScope.activeMenu eq 'applicants' ? 'active' : ''}">지원자 관리</a>
            <a href="${pageContext.request.contextPath}/client/contracts" class="nav-link ${requestScope.activeMenu eq 'contracts' ? 'active' : ''}">계약 관리</a>
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
                    <span>${sessionScope.loginId}</span>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                        <polyline points="6 9 12 15 18 9"></polyline>
                    </svg>
                </button>

                <div id="dropdownMenu" class="dropdown-menu">
                    <a href="${pageContext.request.contextPath}/client/mypage" class="dropdown-item">마이페이지</a>
                    <a href="${pageContext.request.contextPath}/client/company" class="dropdown-item">회사 정보</a>
                    <div class="dropdown-divider"></div>
                    <a href="#" onclick="logout(event)" class="dropdown-item">로그아웃</a>
                </div>
            </div>
        </div>
    </div>
</header>

<script>
// 드롭다운 토글
function toggleDropdown() {
    const dropdown = document.getElementById('dropdownMenu');
    if (dropdown) {
        dropdown.classList.toggle('show');
    }
}

// 외부 클릭 시 드롭다운 닫기
document.addEventListener('click', function(e) {
    const profileDropdown = document.querySelector('.profile-dropdown');
    if (profileDropdown && !profileDropdown.contains(e.target)) {
        const dropdown = document.getElementById('dropdownMenu');
        if (dropdown) {
            dropdown.classList.remove('show');
        }
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
</script>

<!-- 메인 콘텐츠 -->
<main class="main-content">
    <!-- 페이지 헤더 -->
    <div class="page-header">
        <h1 class="page-title">계약 관리</h1>
        <p class="page-subtitle">계약 현황과 통계를 한눈에 확인하세요</p>
    </div>

    <c:if test="${not empty errorMessage}">
        <div style="background: #fee2e2; color: #991b1b; padding: 1rem; border-radius: 8px; margin-bottom: 2rem;">
            ${errorMessage}
        </div>
    </c:if>

    <!-- 통계 카드 -->
    <div class="stats-grid">
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
                <span class="stat-title">완료된 계약</span>
                <div class="stat-icon">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                        <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                        <polyline points="22 4 12 14.01 9 11.01"></polyline>
                    </svg>
                </div>
            </div>
            <div class="stat-value">${completedContracts}</div>
            <div class="stat-label">건</div>
        </div>

        <div class="stat-card">
            <div class="stat-header">
                <span class="stat-title">총 지출금</span>
                <div class="stat-icon">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                        <line x1="12" y1="1" x2="12" y2="23"></line>
                        <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
                    </svg>
                </div>
            </div>
            <div class="stat-value">
                <fmt:formatNumber value="${totalExpenditure}" pattern="#,###" />
            </div>
            <div class="stat-label">원 (완료된 계약 기준)</div>
        </div>

        <div class="stat-card clickable" onclick="scrollToPaymentPending()">
            <div class="stat-header">
                <span class="stat-title">지급 대기</span>
                <div class="stat-icon">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                        <circle cx="12" cy="12" r="10"></circle>
                        <polyline points="12 6 12 12 16 14"></polyline>
                    </svg>
                    <c:if test="${settlementPending > 0}">
                        <span class="badge">${settlementPending}</span>
                    </c:if>
                </div>
            </div>
            <div class="stat-value">${settlementPending}</div>
            <div class="stat-label">건</div>
        </div>
    </div>

    <!-- 차트 섹션 -->
    <div class="chart-section">
        <div class="chart-card">
            <div class="chart-header">
                <h2 class="chart-title">월별 지출 현황</h2>
                <p class="chart-subtitle">최근 6개월 지출 추이</p>
            </div>
            <canvas id="expenditureChart"></canvas>
        </div>

        <div class="chart-card">
            <div class="chart-header">
                <h2 class="chart-title">계약 상태 분포</h2>
                <p class="chart-subtitle">전체 계약 대비</p>
            </div>
            <canvas id="statusChart"></canvas>
        </div>
    </div>

    <!-- 지급 대기 계약 목록 -->
    <c:if test="${not empty paymentPendingContracts}">
    <div class="section-card alert-section" id="paymentPendingSection">
        <div class="section-header">
            <h2 class="section-title">
                <span class="alert-icon">⚠️</span>
                지급 대기 계약
            </h2>
            <a href="${pageContext.request.contextPath}/client/contract/management" class="view-all-link">전체 보기 →</a>
        </div>
        <ul class="contract-list">
            <c:forEach var="contract" items="${paymentPendingContracts}">
                <li class="contract-item alert-item" 
                    onclick="location.href='${pageContext.request.contextPath}/client/contract/management?contractId=${contract.contractId}'">
                    <div class="contract-header">
                        <div class="contract-title">${contract.projectTitle != null ? contract.projectTitle : '프로젝트명 없음'}</div>
                        <span class="contract-badge status-paid">지급 요청됨</span>
                    </div>
                    <div class="contract-meta">
                        <span class="contract-freelancer">${contract.freelancerName != null ? contract.freelancerName : '프리랜서 정보 없음'}</span>
                        <span>•</span>
                        <c:choose>
                            <c:when test="${contract.requestedMilestones != null && contract.requestedMilestones > 0}">
                                <span class="amount-highlight">
                                    마일스톤 ${contract.requestedMilestones}개 지급 요청
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="amount-highlight">
                                    <fmt:formatNumber value="${contract.totalBudget != null ? contract.totalBudget : 0}" pattern="#,###" />원
                                </span>
                            </c:otherwise>
                        </c:choose>
                        <c:if test="${contract.contractedAt != null}">
                            <span>•</span>
                            <span>${contract.contractedAt}</span>
                        </c:if>
                    </div>
                </li>
            </c:forEach>
        </ul>
    </div>
    </c:if>

    <!-- 최근 계약 목록 -->
    <div class="section-card">
        <div class="section-header">
            <h2 class="section-title">최근 계약</h2>
            <a href="${pageContext.request.contextPath}/client/contract/management" class="view-all-link">전체 보기 →</a>
        </div>
        <c:choose>
            <c:when test="${not empty recentContracts}">
                <ul class="contract-list">
                    <c:forEach var="contract" items="${recentContracts}">
                        <li class="contract-item" onclick="location.href='${pageContext.request.contextPath}/client/contract/management?contractId=${contract.contractId}'">
                            <div class="contract-header">
                                <div class="contract-title">${contract.projectTitle != null ? contract.projectTitle : '프로젝트명 없음'}</div>
                                <c:choose>
                                    <c:when test="${contract.contractStatus == 'WAITING'}">
                                        <span class="contract-badge status-waiting">대기중</span>
                                    </c:when>
                                    <c:when test="${contract.contractStatus == 'SIGNED'}">
                                        <span class="contract-badge status-signed">서명완료</span>
                                    </c:when>
                                    <c:when test="${contract.contractStatus == 'PAID'}">
                                        <span class="contract-badge status-paid">결제완료</span>
                                    </c:when>
                                    <c:when test="${contract.contractStatus == 'COMPLETED'}">
                                        <span class="contract-badge status-completed">완료</span>
                                    </c:when>
                                    <c:when test="${contract.contractStatus == 'TERMINATED'}">
                                        <span class="contract-badge status-terminated">종료</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="contract-badge">${contract.contractStatus}</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="contract-meta">
                                <span class="contract-freelancer">${contract.freelancerName != null ? contract.freelancerName : '프리랜서 정보 없음'}</span>
                                <span>•</span>
                                <span><fmt:formatNumber value="${contract.totalBudget != null ? contract.totalBudget : 0}" pattern="#,###" />원</span>
                                <c:if test="${contract.contractedAt != null}">
                                    <span>•</span>
                                    <span>${contract.contractedAt}</span>
                                </c:if>
                            </div>
                        </li>
                    </c:forEach>
                </ul>
            </c:when>
            <c:otherwise>
                <div style="padding: 2rem; text-align: center; color: var(--muted);">
                    등록된 계약이 없습니다.
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<!-- JavaScript -->
<script>

    // 지급 대기 섹션으로 스크롤
    function scrollToPaymentPending() {
        const section = document.getElementById('paymentPendingSection');
        if (section) {
            section.scrollIntoView({ behavior: 'smooth', block: 'start' });
            // 시각적 강조를 위한 애니메이션
            section.style.animation = 'pulse 0.5s ease-in-out';
            setTimeout(() => {
                section.style.animation = '';
            }, 500);
        }
    }

    // 월별 지출 차트
    <c:if test="${not empty monthlyExpenditure}">
    const expenditureCtx = document.getElementById('expenditureChart').getContext('2d');
    
    // 월 이름 변환 함수
    function formatMonth(monthKey) {
        if (!monthKey) return '';
        const parts = monthKey.split('-');
        if (parts.length === 2) {
            const month = parseInt(parts[1]);
            return month + '월';
        }
        return monthKey;
    }
    
    const expenditureLabels = [];
    const expenditureData = [];
    <c:forEach var="entry" items="${monthlyExpenditure}">
    expenditureLabels.push(formatMonth('${entry.key}'));
    expenditureData.push(${entry.value});
    </c:forEach>
    
    const expenditureChartData = {
        labels: expenditureLabels,
        datasets: [{
            label: '월별 지출 (원)',
            data: expenditureData,
            backgroundColor: '#1F7A8C',
            borderColor: '#1F7A8C',
            borderWidth: 2,
            fill: false,
            tension: 0.4
        }]
    };

    new Chart(expenditureCtx, {
        type: 'line',
        data: expenditureChartData,
        options: {
            responsive: true,
            maintainAspectRatio: true,
            aspectRatio: 2.5,
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        callback: function(value) {
                            if (value >= 1000000) {
                                return (value / 1000000).toFixed(1) + 'M';
                            } else if (value >= 1000) {
                                return (value / 1000).toFixed(0) + 'K';
                            }
                            return value;
                        }
                    }
                }
            },
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            return '지출: ' + new Intl.NumberFormat('ko-KR').format(context.parsed.y) + '원';
                        }
                    }
                }
            }
        }
    });
    </c:if>

    // 계약 상태 분포 차트
    <c:if test="${not empty statusDistribution}">
    const statusCtx = document.getElementById('statusChart').getContext('2d');
    const statusLabels = [];
    const statusData = [];
    const statusColors = {
        'WAITING': '#fef3c7',
        'SIGNED': '#dbeafe',
        'PAID': '#dcfce7',
        'COMPLETED': '#e0e7ff',
        'TERMINATED': '#fee2e2',
        'UNKNOWN': '#e2e8f0'
    };
    const statusLabelsMap = {
        'WAITING': '대기중',
        'SIGNED': '서명완료',
        'PAID': '결제완료',
        'COMPLETED': '완료',
        'TERMINATED': '종료',
        'UNKNOWN': '알 수 없음'
    };

    <c:forEach var="entry" items="${statusDistribution}">
    statusLabels.push(statusLabelsMap['${entry.key}'] || '${entry.key}');
    statusData.push(${entry.value});
    </c:forEach>

    new Chart(statusCtx, {
        type: 'doughnut',
        data: {
            labels: statusLabels,
            datasets: [{
                data: statusData,
                backgroundColor: statusLabels.map(function(label) {
                    for (var key in statusLabelsMap) {
                        if (statusLabelsMap[key] === label) {
                            return statusColors[key] || '#e2e8f0';
                        }
                    }
                    return '#e2e8f0';
                }),
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
    </c:if>
</script>
</body>
</html>
