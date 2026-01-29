<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
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
<c:set var="userType" value="CLIENT" scope="request"/>
<jsp:include page="/WEB-INF/views/common/headerBase.jsp" />

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

    <%-- 클라이언트 관점 핵심 지표 계산 --%>
    <c:set var="totalWorkingMilestones" value="0"/>
    <c:set var="totalPaymentRequestMilestones" value="0"/>
    <c:set var="totalPaymentWaiting" value="0"/>
    <c:set var="totalReviewWaiting" value="0"/>
    
    <c:forEach var="contract" items="${recentContracts}">
        <%-- 작업중 마일스톤: requestedMilestones == 0 AND depositedMilestones > 0 AND totalMilestones > 0 --%>
        <c:if test="${contract.requestedMilestones == 0 and contract.depositedMilestones != null and contract.depositedMilestones > 0 and contract.totalMilestones != null and contract.totalMilestones > 0}">
            <c:set var="totalWorkingMilestones" value="${totalWorkingMilestones + contract.depositedMilestones}"/>
        </c:if>
        <%-- 지급 요청 마일스톤 --%>
        <c:if test="${contract.requestedMilestones != null and contract.requestedMilestones > 0}">
            <c:set var="totalPaymentRequestMilestones" value="${totalPaymentRequestMilestones + contract.requestedMilestones}"/>
        </c:if>
        <%-- 결제 대기 (SIGNED 상태) --%>
        <c:if test="${contract.contractStatus != null and (contract.contractStatus.name() eq 'SIGNED' or contract.contractStatus.name() eq 'signed')}">
            <c:set var="totalPaymentWaiting" value="${totalPaymentWaiting + 1}"/>
        </c:if>
        <%-- 검토 대기 (WAITING 상태) --%>
        <c:if test="${contract.contractStatus != null and (contract.contractStatus.name() eq 'WAITING' or contract.contractStatus.name() eq 'waiting')}">
            <c:set var="totalReviewWaiting" value="${totalReviewWaiting + 1}"/>
        </c:if>
    </c:forEach>

    <!-- 핵심 지표 카드 (클라이언트 관점) -->
    <div class="stats-grid compact">
        <div class="stat-card priority clickable" onclick="scrollToSection('payment-request')">
            <div class="stat-header">
                <span class="stat-title">지급 요청</span>
                <div style="display: flex; align-items: center; gap: 0.5rem;">
                    <div class="stat-icon">📤</div>
                    <span class="help-icon">?</span>
                </div>
            </div>
            <div class="stat-value">${totalPaymentRequestMilestones}</div>
            <div class="stat-label">마일스톤</div>
            <c:if test="${totalPaymentRequestMilestones > 0}">
                <div class="stat-badge urgent">즉시 확인 필요</div>
            </c:if>
            <div class="tooltip">
                <div class="tooltip-title">
                    <span class="tooltip-icon">📤</span>
                    <span>지급 요청</span>
                </div>
                <div class="tooltip-description">
                    프리랜서가 작업 완료 후 지급을 요청한 마일스톤 수입니다. 즉시 확인하여 승인 또는 거부 처리해주세요.
                </div>
            </div>
        </div>

        <div class="stat-card clickable" onclick="scrollToSection('working')">
            <div class="stat-header">
                <span class="stat-title">작업중</span>
                <div style="display: flex; align-items: center; gap: 0.5rem;">
                    <div class="stat-icon">💼</div>
                    <span class="help-icon">?</span>
                </div>
            </div>
            <div class="stat-value">${totalWorkingMilestones}</div>
            <div class="stat-label">마일스톤</div>
            <div class="tooltip">
                <div class="tooltip-title">
                    <span class="tooltip-icon">💼</span>
                    <span>작업중</span>
                </div>
                <div class="tooltip-description">
                    현재 프리랜서가 작업을 진행 중인 마일스톤 수입니다. 입금이 완료되어 작업이 진행되고 있는 상태입니다.
                </div>
            </div>
        </div>

        <div class="stat-card clickable" onclick="scrollToSection('payment-waiting')">
            <div class="stat-header">
                <span class="stat-title">결제 대기</span>
                <div style="display: flex; align-items: center; gap: 0.5rem;">
                    <div class="stat-icon">⏳</div>
                    <span class="help-icon">?</span>
                </div>
            </div>
            <div class="stat-value">${totalPaymentWaiting}</div>
            <div class="stat-label">건</div>
            <div class="tooltip">
                <div class="tooltip-title">
                    <span class="tooltip-icon">⏳</span>
                    <span>결제 대기</span>
                </div>
                <div class="tooltip-description">
                    계약서 서명이 완료되어 결제를 진행해야 하는 계약 건수입니다. 결제를 완료하면 작업이 시작됩니다.
                </div>
            </div>
        </div>

        <div class="stat-card clickable" onclick="scrollToSection('review-waiting')">
            <div class="stat-header">
                <span class="stat-title">검토 대기</span>
                <div style="display: flex; align-items: center; gap: 0.5rem;">
                    <div class="stat-icon">👀</div>
                    <span class="help-icon">?</span>
                </div>
            </div>
            <div class="stat-value">${totalReviewWaiting}</div>
            <div class="stat-label">건</div>
            <div class="tooltip">
                <div class="tooltip-title">
                    <span class="tooltip-icon">👀</span>
                    <span>검토 대기</span>
                </div>
                <div class="tooltip-description">
                    프리랜서가 계약서를 검토 중인 계약 건수입니다. 프리랜서의 수락 또는 거절을 기다리는 상태입니다.
                </div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-header">
                <span class="stat-title">진행중 계약</span>
                <div style="display: flex; align-items: center; gap: 0.5rem;">
                    <div class="stat-icon">📋</div>
                    <span class="help-icon">?</span>
                </div>
            </div>
            <div class="stat-value">${activeContracts}</div>
            <div class="stat-label">건</div>
            <div class="tooltip">
                <div class="tooltip-title">
                    <span class="tooltip-icon">📋</span>
                    <span>진행중 계약</span>
                </div>
                <div class="tooltip-description">
                    현재 진행 중인 전체 계약 건수입니다. 대기중, 서명완료, 결제완료 상태의 계약을 포함합니다.
                </div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-header">
                <span class="stat-title">완료된 계약</span>
                <div style="display: flex; align-items: center; gap: 0.5rem;">
                    <div class="stat-icon">✅</div>
                    <span class="help-icon">?</span>
                </div>
            </div>
            <div class="stat-value">${completedContracts}</div>
            <div class="stat-label">건</div>
            <div class="tooltip">
                <div class="tooltip-title">
                    <span class="tooltip-icon">✅</span>
                    <span>완료된 계약</span>
        </div>
                <div class="tooltip-description">
                    모든 마일스톤이 완료되어 정산이 완료된 계약 건수입니다. 프로젝트가 성공적으로 마무리된 계약입니다.
    </div>
            </div>
        </div>
        </div>


    <!-- 지급 요청 계약 목록 -->
    <c:if test="${not empty paymentPendingContracts}">
    <div class="section-card alert-section priority-section" id="payment-request">
        <div class="section-header">
            <h2 class="section-title">
                <span class="alert-icon">📤</span>
                지급 요청 <span class="badge-count">${settlementPending}건</span>
            </h2>
            <a href="${pageContext.request.contextPath}/client/contract/management" class="view-all-link">전체 보기 →</a>
        </div>
        <ul class="contract-list compact">
            <c:forEach var="contract" items="${paymentPendingContracts}">
                <li class="contract-item alert-item" 
                    onclick="location.href='${pageContext.request.contextPath}/client/contract/management?contractId=${contract.contractId}'">
                    <div class="contract-header">
                        <div class="contract-title">${contract.projectTitle != null ? contract.projectTitle : '프로젝트명 없음'}</div>
                        <span class="contract-badge status-paid">
                            <c:choose>
                                <c:when test="${contract.requestedMilestones != null && contract.requestedMilestones > 0}">
                                    마일스톤 ${contract.requestedMilestones}개 지급 요청
                                </c:when>
                                <c:otherwise>지급 요청됨</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    <div class="contract-meta">
                        <span class="contract-freelancer">${contract.freelancerName != null ? contract.freelancerName : '프리랜서 정보 없음'}</span>
                        <span>•</span>
                                <span class="amount-highlight">
                                    <fmt:formatNumber value="${contract.totalBudget != null ? contract.totalBudget : 0}" pattern="#,###" />원
                                </span>
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

    <!-- 작업중 계약 목록 -->
    <c:set var="hasWorkingContracts" value="false"/>
    <c:forEach var="contract" items="${recentContracts}">
        <c:if test="${contract.requestedMilestones == 0 and contract.depositedMilestones != null and contract.depositedMilestones > 0 and contract.totalMilestones != null and contract.totalMilestones > 0}">
            <c:set var="hasWorkingContracts" value="true"/>
        </c:if>
    </c:forEach>
    
    <c:if test="${hasWorkingContracts}">
    <div class="section-card" id="working">
        <div class="section-header">
            <h2 class="section-title">💼 작업중 계약</h2>
            <a href="${pageContext.request.contextPath}/client/contract/management" class="view-all-link">전체 보기 →</a>
        </div>
        <ul class="contract-list compact">
            <c:forEach var="contract" items="${recentContracts}">
                <c:if test="${contract.requestedMilestones == 0 and contract.depositedMilestones != null and contract.depositedMilestones > 0 and contract.totalMilestones != null and contract.totalMilestones > 0}">
                    <li class="contract-item" 
                        onclick="location.href='${pageContext.request.contextPath}/client/contract/management?contractId=${contract.contractId}'">
                        <div class="contract-header">
                            <div class="contract-title">${contract.projectTitle != null ? contract.projectTitle : '프로젝트명 없음'}</div>
                            <span class="contract-badge status-progress">작업중 ${contract.depositedMilestones}건</span>
                        </div>
                        <div class="contract-meta">
                            <span class="contract-freelancer">${contract.freelancerName != null ? contract.freelancerName : '프리랜서 정보 없음'}</span>
                            <span>•</span>
                            <span><fmt:formatNumber value="${contract.totalBudget != null ? contract.totalBudget : 0}" pattern="#,###" />원</span>
                        </div>
                    </li>
                </c:if>
            </c:forEach>
        </ul>
    </div>
    </c:if>

    <!-- 결제 대기 계약 목록 (SIGNED 상태) -->
    <c:if test="${totalPaymentWaiting > 0}">
    <div class="section-card" id="payment-waiting">
        <div class="section-header">
            <h2 class="section-title">⏳ 결제 대기</h2>
            <a href="${pageContext.request.contextPath}/client/contract/management" class="view-all-link">전체 보기 →</a>
        </div>
        <ul class="contract-list compact">
            <c:forEach var="contract" items="${recentContracts}">
                <c:if test="${contract.contractStatus != null and (contract.contractStatus.name() eq 'SIGNED' or contract.contractStatus.name() eq 'signed')}">
                    <li class="contract-item" 
                        onclick="location.href='${pageContext.request.contextPath}/client/contract/management?contractId=${contract.contractId}'">
                        <div class="contract-header">
                            <div class="contract-title">${contract.projectTitle != null ? contract.projectTitle : '프로젝트명 없음'}</div>
                            <span class="contract-badge status-signed">결제 대기</span>
                        </div>
                        <div class="contract-meta">
                            <span class="contract-freelancer">${contract.freelancerName != null ? contract.freelancerName : '프리랜서 정보 없음'}</span>
                            <span>•</span>
                            <span class="amount-highlight">
                                <fmt:formatNumber value="${contract.totalBudget != null ? contract.totalBudget : 0}" pattern="#,###" />원
                            </span>
                        </div>
                    </li>
                </c:if>
            </c:forEach>
        </ul>
    </div>
    </c:if>

    <!-- 검토 대기 계약 목록 (WAITING 상태) -->
    <c:if test="${totalReviewWaiting > 0}">
    <div class="section-card" id="review-waiting">
        <div class="section-header">
            <h2 class="section-title">👀 프리랜서 검토 중</h2>
            <a href="${pageContext.request.contextPath}/client/contract/management" class="view-all-link">전체 보기 →</a>
        </div>
        <ul class="contract-list compact">
            <c:forEach var="contract" items="${recentContracts}">
                <c:if test="${contract.contractStatus != null and (contract.contractStatus.name() eq 'WAITING' or contract.contractStatus.name() eq 'waiting')}">
                    <li class="contract-item" 
                        onclick="location.href='${pageContext.request.contextPath}/client/contract/management?contractId=${contract.contractId}'">
                        <div class="contract-header">
                            <div class="contract-title">${contract.projectTitle != null ? contract.projectTitle : '프로젝트명 없음'}</div>
                            <span class="contract-badge status-waiting">검토중</span>
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
                </c:if>
            </c:forEach>
        </ul>
    </div>
    </c:if>

    <!-- 최근 계약 목록 (전체) -->
    <div class="section-card">
        <div class="section-header">
            <h2 class="section-title">📋 최근 계약</h2>
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
                                    <c:when test="${contract.contractStatus != null and (contract.contractStatus.name() eq 'WAITING' or contract.contractStatus.name() eq 'waiting')}">
                                        <span class="contract-badge status-waiting">대기중</span>
                                    </c:when>
                                    <c:when test="${contract.contractStatus != null and (contract.contractStatus.name() eq 'SIGNED' or contract.contractStatus.name() eq 'signed')}">
                                        <span class="contract-badge status-signed">서명완료</span>
                                    </c:when>
                                    <c:when test="${contract.contractStatus != null and (contract.contractStatus.name() eq 'PAID' or contract.contractStatus.name() eq 'paid')}">
                                        <span class="contract-badge status-paid">결제완료</span>
                                    </c:when>
                                    <c:when test="${contract.contractStatus != null and (contract.contractStatus.name() eq 'COMPLETED' or contract.contractStatus.name() eq 'completed')}">
                                        <span class="contract-badge status-completed">완료</span>
                                    </c:when>
                                    <c:when test="${contract.contractStatus != null and (contract.contractStatus.name() eq 'TERMINATED' or contract.contractStatus.name() eq 'terminated')}">
                                        <span class="contract-badge status-terminated">종료</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="contract-badge">${contract.contractStatus != null ? contract.contractStatus.name() : '-'}</span>
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

    <!-- 차트 섹션 (하단으로 이동, 기본적으로 숨김) -->
    <c:if test="${not empty monthlyExpenditure or not empty statusDistribution}">
    <div class="chart-section" id="chartSection" style="display: none;">
        <c:if test="${not empty monthlyExpenditure}">
        <div class="chart-card">
            <div class="chart-header">
                <h2 class="chart-title">월별 지출 현황</h2>
                <p class="chart-subtitle">최근 6개월 지출 추이</p>
            </div>
            <canvas id="expenditureChart"></canvas>
        </div>
        </c:if>

        <c:if test="${not empty statusDistribution}">
        <div class="chart-card">
            <div class="chart-header">
                <h2 class="chart-title">계약 상태 분포</h2>
                <p class="chart-subtitle">전체 계약 대비</p>
            </div>
            <canvas id="statusChart"></canvas>
        </div>
        </c:if>
    </div>
    </c:if>
</main>

<!-- JavaScript -->
<script>

    // 섹션으로 스크롤
    function scrollToSection(sectionId) {
        const section = document.getElementById(sectionId);
        if (section) {
            section.scrollIntoView({ behavior: 'smooth', block: 'start' });
            section.style.animation = 'pulse 0.5s ease-in-out';
            setTimeout(() => {
                section.style.animation = '';
            }, 500);
        }
    }

    // 하위 호환성을 위한 함수
    function scrollToPaymentPending() {
        scrollToSection('payment-request');
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

    // 차트 섹션 토글
    function toggleChartSection() {
        const chartSection = document.getElementById('chartSection');
        const btn = document.querySelector('.floating-chart-btn');
        
        if (chartSection) {
            if (chartSection.style.display === 'none') {
                chartSection.style.display = 'grid';
                chartSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
                if (btn) btn.textContent = '✕';
            } else {
                chartSection.style.display = 'none';
                if (btn) btn.textContent = '📊';
            }
        }
    }
</script>

<!-- 플로팅 차트 버튼 -->
<c:if test="${not empty monthlyExpenditure or not empty statusDistribution}">
<button class="floating-chart-btn" onclick="toggleChartSection()" title="통계 차트 보기">
    📊
</button>
</c:if>
</body>
</html>
