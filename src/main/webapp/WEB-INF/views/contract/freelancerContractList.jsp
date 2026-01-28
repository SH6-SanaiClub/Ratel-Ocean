<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>계약 관리 - Ratel-Ocean</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/contract/contract-common.css"/>
    
    <style>
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
            <a href="${pageContext.request.contextPath}/freelancer/contract/list" class="nav-link active">내 계약 관리</a>
            <a href="${pageContext.request.contextPath}/freelancer/project/manage" class="nav-link">내 프로젝트 관리</a>
            <a href="${pageContext.request.contextPath}/profile/${userId != null ? userId : ''}" class="nav-link">내 프로필</a>
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
                    <span>${loginId != null ? loginId : '사용자'}</span>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                        <polyline points="6 9 12 15 18 9"></polyline>
                    </svg>
                </button>

                <div id="dropdownMenu" class="dropdown-menu">
                    <a href="${pageContext.request.contextPath}/freelancer/profile/edit" class="dropdown-item">마이페이지</a>
                    <a href="${pageContext.request.contextPath}/freelancer/wallet" class="dropdown-item">지갑</a>
                    <a href="${pageContext.request.contextPath}/freelancer/earnings" class="dropdown-item">수익 관리</a>
                    <div class="dropdown-divider"></div>
                    <a href="#" onclick="logout(event)" class="dropdown-item">로그아웃</a>
                </div>
            </div>
        </div>
    </div>
</header>
    <div class="container">
        <div class="page-header">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                <div>
                    <h1>📋 계약 관리</h1>
                    <p>받은 계약서를 확인하고 관리하세요</p>
                </div>
                <a href="${pageContext.request.contextPath}/freelancer/dashboard" 
                   class="btn btn-secondary" 
                   style="text-decoration: none; white-space: nowrap;">
                    🏠 메인으로
                </a>
            </div>
        </div>

        <div class="main-layout layout-3col">
            <!-- 왼쪽 사이드바: 상태별 계약 목록 -->
            <div class="sidebar sidebar-slim">
                <!-- 검색 기능 -->
                <div class="sidebar-search">
                    <div class="sidebar-search-wrapper">
                        <input id="contractSearch" type="search" placeholder="프로젝트 검색..." oninput="filterContracts()" />
                    </div>
                </div>
                
                <%-- 상태 지표 계산 --%>
                <c:set var="totalRequested" value="0"/><!-- 작업중 마일스톤 수 (리스트에 표시되는 "작업중 X건"의 합계) -->
                <c:set var="totalInProgress" value="0"/><!-- SIGNED + PAID + WAITING -->
                <c:set var="totalPaymentRequest" value="0"/><!-- 승인 요청 건수 -->
                <c:set var="totalTerminated" value="0"/>
                <c:forEach var="statusEntry" items="${contractsByStatus}">
                    <c:forEach var="contract" items="${statusEntry.value}">
                        <%-- 작업중 마일스톤 수: 계약 리스트에 "작업중 X건"으로 표시되는 조건과 동일 --%>
                        <%-- 조건: requestedMilestones == 0 AND depositedMilestones > 0 AND totalMilestones > 0 --%>
                        <c:if test="${contract.requestedMilestones == 0 and contract.depositedMilestones > 0 and contract.totalMilestones > 0}">
                            <c:set var="totalRequested" value="${totalRequested + contract.depositedMilestones}"/>
                        </c:if>
                        <%-- 승인 요청 건수 --%>
                        <c:if test="${contract.requestedMilestones > 0}">
                            <c:set var="totalPaymentRequest" value="${totalPaymentRequest + contract.requestedMilestones}"/>
                        </c:if>
                        <%-- 진행 중 상태 (SIGNED, PAID, WAITING) --%>
                        <c:if test="${statusEntry.key eq 'PAID' or statusEntry.key eq 'SIGNED' or statusEntry.key eq 'WAITING'}">
                            <c:set var="totalInProgress" value="${totalInProgress + 1}"/>
                        </c:if>
                        <%-- 종료된 계약 수 --%>
                        <c:if test="${statusEntry.key eq 'TERMINATED'}">
                            <c:set var="totalTerminated" value="${totalTerminated + 1}"/>
                        </c:if>
                    </c:forEach>
                </c:forEach>
                <c:set var="totalCompleted" value="${not empty contractsByStatus['COMPLETED_HISTORY'] ? fn:length(contractsByStatus['COMPLETED_HISTORY']) : 0}"/>
                <c:set var="totalWaiting" value="${not empty contractsByStatus['WAITING'] ? fn:length(contractsByStatus['WAITING']) : 0}"/>
                <c:set var="totalAll" value="${totalInProgress + totalCompleted + totalTerminated}"/>
                
                <!-- 상단 상태 지표 -->
                <div class="sidebar-stats">
                    <div class="sidebar-stat-item">
                        <span class="sidebar-stat-value">${totalRequested}</span>
                        <span class="sidebar-stat-label">작업중</span>
                        </div>
                    <div class="sidebar-stat-item">
                        <span class="sidebar-stat-value">${totalInProgress}</span>
                        <span class="sidebar-stat-label">작업 진행</span>
                    </div>
                    <div class="sidebar-stat-item">
                        <span class="sidebar-stat-value">${totalPaymentRequest}</span>
                        <span class="sidebar-stat-label">승인 요청</span>
                    </div>
                </div>
                
                <!-- 필터 버튼 (전체 / 진행 중 / 검토 대기 / 완료 / 종료) -->
                <div class="sidebar-filters">
                    <button class="sidebar-filter-btn" data-filter="all" onclick="setFilter('all', true)">
                        전체<span class="count">${totalAll}</span>
                    </button>
                    <button class="sidebar-filter-btn" data-filter="progress" onclick="setFilter('progress', true)">
                        진행 중<span class="count">${totalInProgress}</span>
                    </button>
                    <button class="sidebar-filter-btn" data-filter="waiting" onclick="setFilter('waiting', true)">
                        검토 대기<span class="count">${totalWaiting}</span>
                    </button>
                    <button class="sidebar-filter-btn" data-filter="completed" onclick="setFilter('completed', true)">
                        완료<span class="count">${totalCompleted}</span>
                    </button>
                    <button class="sidebar-filter-btn" data-filter="terminated" onclick="setFilter('terminated', true)">
                        종료<span class="count">${totalTerminated}</span>
                    </button>
                </div>
                
                <!-- 계약 리스트 (필터별로 표시) -->
                <ul class="sidebar-contract-list" id="contractList">
                    <%-- 진행 중 계약 (SIGNED + PAID) --%>
                    <c:forEach var="contract" items="${contractsByStatus['SIGNED']}">
                        <li class="sidebar-contract-item filter-all filter-progress ${selectedContract.contractId eq contract.contractId ? 'active' : ''}"
                            onclick="selectContract('${contract.contractId}')">
                            <div class="sidebar-contract-item-header">
                                <div class="sidebar-contract-title">
                                    <c:out value="${contract.projectTitle != null ? contract.projectTitle : '프로젝트 정보 없음'}"/>
                                </div>
                                <span class="sidebar-contract-badge progress">결제대기</span>
                            </div>
                            <div class="sidebar-contract-meta">
                                <span class="sidebar-contract-days">${contract.counterpartName != null ? contract.counterpartName : '클라이언트 정보 없음'}</span>
                            </div>
                        </li>
                    </c:forEach>
                    <c:forEach var="contract" items="${contractsByStatus['PAID']}">
                        <li class="sidebar-contract-item filter-all filter-progress ${selectedContract.contractId eq contract.contractId ? 'active' : ''}"
                            onclick="selectContract('${contract.contractId}')">
                            <div class="sidebar-contract-item-header">
                                <div class="sidebar-contract-title">
                                    <c:out value="${contract.projectTitle != null ? contract.projectTitle : '프로젝트 정보 없음'}"/>
                                </div>
                                <span class="sidebar-contract-badge ${contract.requestedMilestones > 0 ? 'approval-pending' : 'progress'}">
                                    <c:choose>
                                        <c:when test="${contract.requestedMilestones > 0}">승인대기 ${contract.requestedMilestones}건</c:when>
                                        <c:when test="${contract.depositedMilestones > 0 and contract.totalMilestones > 0}">작업중 ${contract.depositedMilestones}건</c:when>
                                        <c:when test="${contract.paidMilestones > 0 and contract.totalMilestones > 0}">진행 ${contract.paidMilestones}/${contract.totalMilestones}</c:when>
                                        <c:otherwise>진행중</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                            <div class="sidebar-contract-meta">
                                <span class="sidebar-contract-days">${contract.counterpartName != null ? contract.counterpartName : '클라이언트 정보 없음'}</span>
                            </div>
                        </li>
                    </c:forEach>
                    
                    <%-- 검토 대기 (WAITING) - 진행 중에도 포함 --%>
                    <c:forEach var="contract" items="${contractsByStatus['WAITING']}">
                        <li class="sidebar-contract-item filter-all filter-waiting ${selectedContract.contractId eq contract.contractId ? 'active' : ''}"
                            onclick="selectContract('${contract.contractId}')">
                            <div class="sidebar-contract-item-header">
                                <div class="sidebar-contract-title">
                                    <c:out value="${contract.projectTitle != null ? contract.projectTitle : '프로젝트 정보 없음'}"/>
                                </div>
                                <span class="sidebar-contract-badge progress">검토중</span>
                            </div>
                            <div class="sidebar-contract-meta">
                                <span class="sidebar-contract-days">${contract.counterpartName != null ? contract.counterpartName : '클라이언트 정보 없음'}</span>
                            </div>
                        </li>
                    </c:forEach>
                    
                    <%-- 완료 (COMPLETED_HISTORY) --%>
                    <c:forEach var="contract" items="${contractsByStatus['COMPLETED_HISTORY']}">
                        <li class="sidebar-contract-item filter-all filter-completed ${selectedContract.contractId eq contract.contractId ? 'active' : ''}"
                            onclick="selectContract('${contract.contractId}')">
                            <div class="sidebar-contract-item-header">
                                <div class="sidebar-contract-title">
                                    <c:out value="${contract.projectTitle != null ? contract.projectTitle : '프로젝트 정보 없음'}"/>
                                </div>
                                <span class="sidebar-contract-badge completed">완료</span>
                            </div>
                            <div class="sidebar-contract-meta">
                                <span class="sidebar-contract-days">${contract.counterpartName != null ? contract.counterpartName : '클라이언트 정보 없음'}</span>
                            </div>
                        </li>
                    </c:forEach>
                    
                    <%-- 종료된 계약 (TERMINATED) - 모든 종류 포함 --%>
                    <c:forEach var="statusEntry" items="${contractsByStatus}">
                        <c:if test="${statusEntry.key eq 'TERMINATED'}">
                            <%-- 거절됨 --%>
                            <c:forEach var="contract" items="${statusEntry.value}">
                                <c:if test="${fn:startsWith(contract.cancelReason, '[거절]')}">
                                    <li class="sidebar-contract-item filter-all filter-terminated ${selectedContract.contractId eq contract.contractId ? 'active' : ''}"
                                        onclick="selectContract('${contract.contractId}')">
                                        <div class="sidebar-contract-item-header">
                                            <div class="sidebar-contract-title">
                                                <c:out value="${contract.projectTitle != null ? contract.projectTitle : '프로젝트 정보 없음'}"/>
                                            </div>
                                            <span class="sidebar-contract-badge urgent">거절됨</span>
                                        </div>
                                        <div class="sidebar-contract-meta">
                                            <span class="sidebar-contract-days">${contract.counterpartName != null ? contract.counterpartName : '클라이언트 정보 없음'}</span>
                                        </div>
                                    </li>
                                </c:if>
                            </c:forEach>
                            <%-- 취소됨 --%>
                            <c:forEach var="contract" items="${statusEntry.value}">
                                <c:if test="${fn:startsWith(contract.cancelReason, '[취소]')}">
                                    <li class="sidebar-contract-item filter-all filter-terminated ${selectedContract.contractId eq contract.contractId ? 'active' : ''}"
                                        onclick="selectContract('${contract.contractId}')">
                                        <div class="sidebar-contract-item-header">
                                            <div class="sidebar-contract-title">
                                                <c:out value="${contract.projectTitle != null ? contract.projectTitle : '프로젝트 정보 없음'}"/>
                                            </div>
                                            <span class="sidebar-contract-badge urgent">취소됨</span>
                                        </div>
                                        <div class="sidebar-contract-meta">
                                            <span class="sidebar-contract-days">${contract.counterpartName != null ? contract.counterpartName : '클라이언트 정보 없음'}</span>
                                        </div>
                                    </li>
                                </c:if>
                            </c:forEach>
                            <%-- 중도 종료 --%>
                            <c:forEach var="contract" items="${statusEntry.value}">
                                <c:if test="${!fn:startsWith(contract.cancelReason, '[거절]') && !fn:startsWith(contract.cancelReason, '[취소]')}">
                                    <li class="sidebar-contract-item filter-all filter-terminated ${selectedContract.contractId eq contract.contractId ? 'active' : ''}"
                                        onclick="selectContract('${contract.contractId}')">
                                        <div class="sidebar-contract-item-header">
                                            <div class="sidebar-contract-title">
                                                <c:out value="${contract.projectTitle != null ? contract.projectTitle : '프로젝트 정보 없음'}"/>
                                            </div>
                                            <span class="sidebar-contract-badge urgent">중도종료</span>
                                        </div>
                                        <div class="sidebar-contract-meta">
                                            <span class="sidebar-contract-days">${contract.counterpartName != null ? contract.counterpartName : '클라이언트 정보 없음'}</span>
                                        </div>
                                    </li>
                                </c:if>
                            </c:forEach>
                        </c:if>
                    </c:forEach>
                </ul>
                    </div>

            <!-- 중앙: 선택한 계약 상세 정보 -->
            <div class="content-area">
                <c:choose>
                    <c:when test="${not empty selectedContract}">
                        <%-- KPI 계산 (MVC2 유지: View에서 파생 값만 계산) --%>
                        <c:set var="kpiTotal" value="${not empty milestones ? fn:length(milestones) : 0}"/>
                        <c:set var="kpiPaid" value="0"/>
                        <c:set var="kpiDeposited" value="0"/>
                        <c:set var="kpiDepositedAmount" value="0"/>
                        <c:forEach var="m" items="${milestones}">
                            <c:if test="${m.status != null and (m.status.name() eq 'PAID' or m.status.name() eq 'paid')}">
                                <c:set var="kpiPaid" value="${kpiPaid + 1}"/>
                                </c:if>
                            <c:if test="${m.status != null and (m.status.name() eq 'DEPOSITED' or m.status.name() eq 'deposited')}">
                                <c:set var="kpiDeposited" value="${kpiDeposited + 1}"/>
                                <c:set var="kpiDepositedAmount" value="${kpiDepositedAmount + (m.amount != null ? m.amount : 0)}"/>
                                                </c:if>
                                            </c:forEach>
                        <c:set var="kpiRemaining" value="${kpiTotal - kpiPaid}"/>

                        <!-- 프로젝트 오버뷰 -->
                        <div class="project-overview">
                            <div class="project-overview-header">
                                <div>
                                    <div style="font-size: 12px; color: #6b7280; font-weight: 600; margin-bottom: 4px;">
                                        Project #${selectedContract.contractId} • 계약일: ${selectedContract.contractedAt}
                                    </div>
                                    <h2 class="project-overview-title">
                                        <c:out value="${selectedContract.projectTitle != null ? selectedContract.projectTitle : '프로젝트 정보 없음'}"/>
                                    </h2>
                                    <div class="project-overview-meta">
                                        <span>클라이언트: <strong><c:out value="${selectedContract.clientName != null ? selectedContract.clientName : (selectedContract.counterpartName != null ? selectedContract.counterpartName : '정보 없음')}"/></strong></span>
                                        <span>|</span>
                                        <span>프리랜서: <strong><c:out value="${selectedContract.freelancerName != null ? selectedContract.freelancerName : '정보 없음'}"/></strong></span>
                                                        </div>
                                                    </div>
                                <div class="project-overview-budget">
                                    <div class="project-overview-budget-label">총 계약 예산</div>
                                    <div class="project-overview-budget-value">
                                        <fmt:formatNumber value="${selectedContract.totalBudget}" pattern="#,###"/>원
                                                    </div>
                                                    </div>
                                </div>
                            <c:if test="${not empty milestones}">
                                <c:set var="totalMilestones" value="${fn:length(milestones)}"/>
                                <c:set var="paidCount" value="0"/>
                                <c:forEach var="m" items="${milestones}">
                                    <c:if test="${m.status != null and (m.status.name() eq 'PAID' or m.status.name() eq 'paid')}">
                                        <c:set var="paidCount" value="${paidCount + 1}"/>
                                </c:if>
                            </c:forEach>
                                <c:set var="overallProgress" value="${(paidCount * 100) / totalMilestones}"/>
                                <div class="overall-progress-section">
                                    <div class="overall-progress-label">
                                        <span>전체 진행률</span>
                                        <span>${paidCount} / ${totalMilestones} 단계 완료</span>
                                    </div>
                                    <div class="overall-progress-bar">
                                        <div class="overall-progress-fill" style="width: ${overallProgress}%"></div>
                                                        </div>
                                                    </div>
                                                        </c:if>
            </div>

                        <!-- 계약 정보 (접을 수 있는 카드) -->
                        <div class="contract-meta-card" onclick="toggleContractMeta(this)">
                            <div class="contract-meta-header">
                                <span class="contract-meta-title">📄 계약 정보</span>
                                <span class="contract-meta-toggle">▼</span>
                            </div>
                            <div class="contract-meta-body">
                        <div class="info-grid">
                            <div class="info-item">
                                <div class="info-label">계약 ID</div>
                                <div class="info-value">#${selectedContract.contractId}</div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">계약 상태</div>
                                <div class="info-value">
                                    <span class="status-indicator ${selectedContract.contractStatus != null ? fn:toLowerCase(selectedContract.contractStatus.name()) : ''}">
                                        <c:choose>
                                            <c:when test="${selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'WAITING' or selectedContract.contractStatus.name() eq 'waiting')}">⏳ 전송됨</c:when>
                                            <c:when test="${selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'SIGNED' or selectedContract.contractStatus.name() eq 'signed')}">✅ 내가 수락함 (클라이언트 결제 대기 중)</c:when>
                                            <c:when test="${selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'PAID' or selectedContract.contractStatus.name() eq 'paid')}">
                                                <c:choose>
                                                    <c:when test="${selectedContract.requestedMilestones > 0}">
                                                        💰 결제 완료 (지급 요청 중: ${selectedContract.requestedMilestones}건)
                                                    </c:when>
                                                    <c:when test="${selectedContract.depositedMilestones > 0}">
                                                        💰 결제 완료 (입금 완료: ${selectedContract.depositedMilestones}건)
                                                    </c:when>
                                                    <c:when test="${selectedContract.paidMilestones > 0}">
                                                        💰 결제 완료 (수령 진행 중: ${selectedContract.paidMilestones}/${selectedContract.totalMilestones})
                                                    </c:when>
                                                    <c:otherwise>
                                                        💰 결제 완료 (수령 대기 중)
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:when test="${selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'COMPLETED' or selectedContract.contractStatus.name() eq 'completed')}">
                                                <c:choose>
                                                    <%-- 마일스톤이 없는 경우 (일시지급) --%>
                                                    <c:when test="${selectedContract.totalMilestones == null || selectedContract.totalMilestones == 0}">
                                                        ✅ 완료 내역
                                                    </c:when>
                                                    <%-- 마일스톤이 있는 경우 (MILESTONE) --%>
                                                    <c:otherwise>
                                                        <c:choose>
                                                            <c:when test="${selectedContract.paidMilestones == selectedContract.totalMilestones}">
                                                                ✅ 완료 내역
                                                            </c:when>
                                                            <c:otherwise>
                                                                🎉 정산 대기
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:when test="${selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'TERMINATED' or selectedContract.contractStatus.name() eq 'terminated')}">
                                                <c:choose>
                                                    <c:when test="${fn:startsWith(selectedContract.cancelReason, '[거절]')}">
                                                        <span class="status-rejected">🚫 내가 거절함</span>
                                                    </c:when>
                                                    <c:when test="${fn:startsWith(selectedContract.cancelReason, '[취소]')}">
                                                        <span class="status-cancelled">❌ 클라이언트가 취소함</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="status-terminated">⚠️ 중도 종료</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:otherwise>${selectedContract.contractStatus != null ? selectedContract.contractStatus.name() : '-'}</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">프로젝트명</div>
                                <div class="info-value">
                                    <c:choose>
                                        <c:when test="${not empty project and not empty project.projectId and not empty project.title}">
                                            <a href="${pageContext.request.contextPath}/project/detail?projectId=${project.projectId}" 
                                               class="status-link"
                                               onmouseover="this.style.textDecoration='underline'"
                                               onmouseout="this.style.textDecoration='none'">
                                                <c:out value="${project.title}"/>
                                            </a>
                                        </c:when>
                                        <c:when test="${not empty selectedContract.projectTitle}">
                                            <c:choose>
                                                <c:when test="${not empty selectedContract.projectId}">
                                                    <a href="${pageContext.request.contextPath}/project/detail?projectId=${selectedContract.projectId}" 
                                                       class="status-link"
                                                       onmouseover="this.style.textDecoration='underline'"
                                                       onmouseout="this.style.textDecoration='none'">
                                                        <c:out value="${selectedContract.projectTitle}"/>
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:out value="${selectedContract.projectTitle}"/>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:otherwise>
                                            <c:out value="${project.title}" default="-"/>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            <c:if test="${not empty client}">
                                <div class="info-item">
                                    <div class="info-label">클라이언트</div>
                                    <div class="info-value"><c:out value="${client.clientName}" default="-"/></div>
                                </div>
                                <div class="info-item">
                                    <div class="info-label">이메일</div>
                                    <div class="info-value"><c:out value="${client.email}" default="-"/></div>
                                </div>
                                <div class="info-item">
                                    <div class="info-label">연락처</div>
                                    <div class="info-value"><c:out value="${client.phone}" default="-"/></div>
                                </div>
                            </c:if>
                            <div class="info-item">
                                <div class="info-label">계약 시작일</div>
                                <div class="info-value"><c:out value="${selectedContract.contractStartDate}" default="-"/></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">계약 종료일</div>
                                <div class="info-value"><c:out value="${selectedContract.contractEndDate}" default="-"/></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">총 예산</div>
                                <div class="info-value"><fmt:formatNumber value="${selectedContract.totalBudget}" pattern="#,###"/>원</div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">지급 방식</div>
                                <div class="info-value">
                                    <c:choose>
                                        <c:when test="${selectedContract.paymentMethod eq 'FULL'}">일시 지급</c:when>
                                        <c:when test="${selectedContract.paymentMethod eq 'MILESTONE'}">분할 지급 (마일스톤별)</c:when>
                                        <c:otherwise>${selectedContract.paymentMethod}</c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">계약 생성일</div>
                                <div class="info-value"><c:out value="${selectedContract.contractedAt}" default="-"/></div>
                            </div>
                            <!-- 종료 사유 표시 (TERMINATED 상태일 때만) -->
                            <c:if test="${selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'TERMINATED' or selectedContract.contractStatus.name() eq 'terminated') and not empty selectedContract.cancelReason}">
                                <div class="info-item info-item-full-width">
                                    <div class="info-label">종료 유형</div>
                                    <div class="info-value">
                                        <c:choose>
                                            <c:when test="${fn:startsWith(selectedContract.cancelReason, '[거절]')}">
                                                <span class="status-rejected-text">🚫 내가 거절함</span>
                                            </c:when>
                                            <c:when test="${fn:startsWith(selectedContract.cancelReason, '[취소]')}">
                                                <span class="status-cancelled-text">❌ 클라이언트가 취소함</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-terminated-text">⚠️ 중도 종료</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                                <div class="info-item info-item-full-width">
                                    <div class="info-label">사유</div>
                                    <div class="info-value info-value-error">
                                        <c:out value="${fn:replace(fn:replace(selectedContract.cancelReason, '[거절] ', ''), '[취소] ', '')}"/>
                                    </div>
                                </div>
                            </c:if>
                            
                            <!-- AI 계약 분석 버튼 (WAITING 상태일 때만) -->
                            <c:if test="${selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'WAITING' or selectedContract.contractStatus.name() eq 'waiting')}">
                                <div class="info-item info-item-full-width info-item-right-align">
                                    <button type="button" 
                                            class="btn btn-primary btn-ai-analysis" 
                                            onclick="openContractAnalysis(${selectedContract.contractId})">
                                        🤖 AI 계약 분석
                                    </button>
                                </div>
                            </c:if>
                        </div>
                                </div>
                                </div>

                        <!-- 마일스톤 (일시지급도 마일스톤 1개가 생성되므로 여기서 처리) -->
                        <c:if test="${not empty milestones}">
                            <div class="section-title">📍 마일스톤 상세 타임라인</div>
                            
                            <!-- 마일스톤 진행률 표시 -->
                            <c:set var="totalMilestones" value="${fn:length(milestones)}"/>
                            <c:set var="paidCount" value="0"/>
                            <c:set var="depositedCount" value="0"/>
                            <c:set var="requestedCount" value="0"/>
                            <c:set var="waitingCount" value="0"/>
                            <c:forEach var="m" items="${milestones}">
                                <c:choose>
                                    <c:when test="${m.status != null and (m.status.name() eq 'PAID' or m.status.name() eq 'paid')}">
                                        <c:set var="paidCount" value="${paidCount + 1}"/>
                                    </c:when>
                                    <c:when test="${m.status != null and (m.status.name() eq 'DEPOSITED' or m.status.name() eq 'deposited')}">
                                        <c:set var="depositedCount" value="${depositedCount + 1}"/>
                                    </c:when>
                                    <c:when test="${m.status != null and (m.status.name() eq 'REQUESTED' or m.status.name() eq 'requested')}">
                                        <c:set var="requestedCount" value="${requestedCount + 1}"/>
                                    </c:when>
                                    <c:when test="${m.status != null and (m.status.name() eq 'WAITING' or m.status.name() eq 'waiting')}">
                                        <c:set var="waitingCount" value="${waitingCount + 1}"/>
                                    </c:when>
                                </c:choose>
                            </c:forEach>
                            <c:set var="progressPercentage" value="${(paidCount * 100) / totalMilestones}"/>
                            
                            <div class="milestone-progress-section">
                                <div class="milestone-progress-bar">
                                    <div class="progress-fill" style="width: ${progressPercentage}%"></div>
                                    <span class="progress-text">${paidCount}/${totalMilestones} 완료</span>
                                </div>
                                <div class="milestone-summary">
                                    <span class="milestone-summary-item">
                                        <span class="summary-label">✅ 지급 완료:</span>
                                        <span class="summary-value">${paidCount}개</span>
                                    </span>
                                    <span class="milestone-summary-item">
                                        <span class="summary-label">💳 작업 가능:</span>
                                        <span class="summary-value">${depositedCount}개</span>
                                    </span>
                                    <span class="milestone-summary-item">
                                        <span class="summary-label">📤 승인 대기:</span>
                                        <span class="summary-value">${requestedCount}개</span>
                                    </span>
                                    <span class="milestone-summary-item">
                                        <span class="summary-label">⏳ 대기 중:</span>
                                        <span class="summary-value">${waitingCount}개</span>
                                    </span>
                                </div>
                            </div>
                            
                            <div class="milestone-list milestone-timeline">
                                <c:forEach var="m" items="${milestones}" varStatus="status">
                                    <div class="milestone-card milestone-${fn:toLowerCase(m.status.name())} ${m.status != null and (m.status.name() eq 'DEPOSITED' or m.status.name() eq 'deposited') ? 'is-current' : ''} compact" 
                                         onclick="toggleMilestoneCard(this, event)" 
                                         data-step="${m.step}">
                                        <div class="milestone-card-header">
                                            <div class="milestone-step-badge">${m.step}단계</div>
                                            <h4 class="milestone-title"><c:out value="${m.title}" default="마일스톤 ${m.step}"/></h4>
                                            <div class="milestone-status-badge status-${fn:toLowerCase(m.status.name())}">
                                                <c:choose>
                                                    <c:when test="${m.status != null and (m.status.name() eq 'WAITING' or m.status.name() eq 'waiting')}">
                                                        ⏳ 대기 중
                                                    </c:when>
                                                    <c:when test="${m.status != null and (m.status.name() eq 'DEPOSITED' or m.status.name() eq 'deposited')}">
                                                        💳 입금 완료 (작업 가능)
                                                    </c:when>
                                                    <c:when test="${m.status != null and (m.status.name() eq 'REQUESTED' or m.status.name() eq 'requested')}">
                                                        📤 지급 요청 중 (클라이언트 승인 대기)
                                                    </c:when>
                                                    <c:when test="${m.status != null and (m.status.name() eq 'PAID' or m.status.name() eq 'paid')}">
                                                        ✅ 지급 완료
                                                    </c:when>
                                                    <c:when test="${m.status != null and (m.status.name() eq 'CANCELED' or m.status.name() eq 'canceled')}">
                                                        ❌ 취소됨
                                                    </c:when>
                                                    <c:otherwise>${m.status != null ? m.status.name() : '-'}</c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                        
                                        <div class="milestone-card-content">
                                            <p class="milestone-description"><c:out value="${m.description}" default="작업 내용 없음"/></p>
                                        </div>
                                        <div class="milestone-amount">
                                            <fmt:formatNumber value="${m.amount != null ? m.amount : 0}" pattern="#,###"/>원
                                        </div>
                                        
                                        <!-- 프리랜서 액션 버튼 -->
                                        <c:if test="${selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'PAID' or selectedContract.contractStatus.name() eq 'paid' or selectedContract.contractStatus.name() eq 'COMPLETED' or selectedContract.contractStatus.name() eq 'completed')}">
                                            <div class="milestone-actions" onclick="event.stopPropagation()">
                                                <c:choose>
                                                    <c:when test="${m.status != null and (m.status.name() eq 'DEPOSITED' or m.status.name() eq 'deposited')}">
                                                        <!-- 작업 완료 후 검수/지급 요청 (주요 CTA) -->
                                                        <form method="post" action="${pageContext.request.contextPath}/freelancer/contract/request-payment" class="form-inline-display">
                                                            <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                                            <input type="hidden" name="step" value="${m.step}" />
                                                            <button type="submit" class="btn-cta" onclick="return confirm('${m.step}단계 마일스톤 작업이 완료되었나요? 검수 및 지급을 요청하시겠습니까?')">
                                                                검수 요청
                                                            </button>
                                                        </form>
                                                    </c:when>
                                                    <c:when test="${m.status != null and (m.status.name() eq 'REQUESTED' or m.status.name() eq 'requested')}">
                                                        <div class="milestone-status-message">
                                                            <span class="status-waiting">⏳ 클라이언트의 승인을 기다리는 중입니다...</span>
                                                        </div>
                                                    </c:when>
                                                    <c:when test="${m.status != null and (m.status.name() eq 'PAID' or m.status.name() eq 'paid')}">
                                                        <div class="milestone-status-message">
                                                            <span class="status-completed">✅ 지급이 완료되었습니다.</span>
                                                        </div>
                                                    </c:when>
                                                    <c:when test="${m.status != null and (m.status.name() eq 'CANCELED' or m.status.name() eq 'canceled')}">
                                                        <div class="milestone-status-message">
                                                            <span class="status-cancelled">❌ 이 마일스톤은 취소되었습니다.</span>
                                                        </div>
                                                    </c:when>
                                                </c:choose>
                                            </div>
                                        </c:if>
                                    </div>
                            </c:forEach>
                </ul>
            </div>
                        </c:if>

                        <!-- 액션 버튼 (WAITING 상태일 때만) -->
                        <c:if test="${selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'WAITING' or selectedContract.contractStatus.name() eq 'waiting')}">
                            <div class="action-buttons">
                                <form method="post" action="${pageContext.request.contextPath}/freelancer/contract/accept" class="form-inline-display">
                                    <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                    <c:if test="${not empty project.projectId}">
                                        <input type="hidden" name="projectId" value="${project.projectId}" />
                                    </c:if>
                                    <button type="submit" class="btn btn-primary" onclick="return confirm('계약을 수락하시겠습니까?')">
                                        ✅ 계약 수락
                                    </button>
                                </form>
                                <form method="post" action="${pageContext.request.contextPath}/freelancer/contract/reject" class="reject-form form-inline-display">
                                    <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                    <c:if test="${not empty project.projectId}">
                                        <input type="hidden" name="projectId" value="${project.projectId}" />
                                    </c:if>
                                    <input type="text" name="reason" placeholder="거절 사유를 입력하세요" required 
                                           class="reject-form-input" />
                                    <button type="submit" class="btn btn-danger" onclick="return confirm('계약을 거절하시겠습니까?')">
                                        ❌ 계약 거절
                                    </button>
                                </form>
                            </div>
                        </c:if>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state">
                            <div class="empty-state-icon">📋</div>
                            <div class="empty-state-text">왼쪽에서 계약을 선택하세요</div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
            
            <!-- 우측: 계약서 미리보기 및 다운로드 패널 -->
            <aside class="summary-panel">
                <div class="summary-card">
                    <div class="summary-title">계약서</div>
                    <c:choose>
                        <c:when test="${not empty selectedContract and not empty selectedContract.originContractUrl}">
                            <!-- 계약서 미리보기 -->
                            <div class="contract-preview-container">
                                <iframe id="contractPreviewFrame" src=""></iframe>
                            </div>
                            
                            <!-- 계약서 액션 버튼 -->
                            <div style="margin-top: 16px; display: grid; gap: 10px;">
                                <button type="button" class="btn btn-primary btn-block" onclick="openPdfModal()">
                                    📄 계약서 원본 보기
                                </button>
                                <a id="pdfDownloadLink" class="btn btn-secondary btn-block" href="#" download style="text-decoration: none; text-align: center;">
                                    📥 PDF 다운로드
                                </a>
                            </div>
                        </c:when>
                        <c:when test="${not empty selectedContract}">
                            <div class="contract-preview-empty">
                                <p class="summary-help-text" style="text-align: center; padding: 40px 20px;">
                                    계약서 PDF가 등록되지 않았습니다.
                                </p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="contract-preview-empty">
                                <p class="summary-help-text" style="text-align: center; padding: 40px 20px;">
                                    왼쪽에서 계약을 선택하면<br/>계약서를 바로 확인할 수 있어요.
                                </p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </aside>
        </div>
    </div>
    
    <!-- PDF 모달 -->
    <div id="pdfModal" class="pdf-modal" onclick="if(event.target.id==='pdfModal'){ closePdfModal(); }">
        <div class="pdf-modal-card" onclick="event.stopPropagation()">
            <div class="pdf-modal-head">
                <div class="title">📄 계약서 원본</div>
                <button type="button" class="pdf-modal-close" onclick="closePdfModal()">×</button>
            </div>
            <div class="pdf-modal-body">
                <iframe id="pdfModalFrame" src=""></iframe>
            </div>
        </div>
    </div>
    
    <script>
        // 계약 정보 카드 토글 기능
        function toggleContractMeta(card) {
            card.classList.toggle('collapsed');
            const toggle = card.querySelector('.contract-meta-toggle');
            if (toggle) {
                toggle.textContent = card.classList.contains('collapsed') ? '▶' : '▼';
            }
        }
        
        // 사이드바 토글 기능
        function toggleSection(element) {
            const section = element.closest('.status-section');
            const list = section.querySelector('.contract-list');
            const icon = element.querySelector('.toggle-icon');
            
            if (list) {
                if (list.style.display === 'none') {
                    list.style.display = 'block';
                    icon.textContent = '▼';
                    section.classList.remove('collapsed');
                } else {
                    list.style.display = 'none';
                    icon.textContent = '▶';
                    section.classList.add('collapsed');
                }
            }
        }
        
        // 현재 활성 필터를 저장할 변수
        let currentActiveFilter = 'all';
        
        // 계약 클릭 시 필터 상태 유지
        function selectContract(contractId) {
            // 현재 활성 필터 사용 (전역 변수에서 읽기)
            const filterToUse = currentActiveFilter || 'all';
            console.log('selectContract - contractId:', contractId, 'currentFilter:', filterToUse);
            location.href = '?contractId=' + contractId + '&filter=' + filterToUse;
        }
        
        // 페이지 로드 시 초기화
        document.addEventListener('DOMContentLoaded', function() {
            console.log('DOMContentLoaded - initializing');
            
            // URL 파라미터에서 필터 읽기
            const urlParams = new URLSearchParams(window.location.search);
            const savedFilter = urlParams.get('filter') || 'all';
            
            // 전역 변수에 저장
            currentActiveFilter = savedFilter;
            
            // 초기에는 모든 항목 표시 (필터 적용 전)
            document.querySelectorAll('.sidebar-contract-item').forEach(li => {
                li.style.display = '';
            });
            
            // 저장된 필터 적용 (URL 업데이트 없이)
            setFilter(savedFilter, false);
            
            // PDF 다운로드 링크 설정
            setupPdfDownloadLink();
            
            // 모든 마일스톤 카드를 compact 모드로 초기화
            document.querySelectorAll('.milestone-list.milestone-timeline .milestone-card').forEach(card => {
                if (!card.classList.contains('expanded')) {
                    card.classList.add('compact');
                    card.classList.remove('expanded');
                }
            });
        });
        
        // 필터 설정 (전체 / 진행 중 / 검토 대기 / 완료 / 종료)
        function setFilter(filterType, updateUrl) {
            console.log('setFilter called:', filterType);
            
            // 전역 변수에 현재 필터 저장
            currentActiveFilter = filterType;
            
            // 필터 버튼 활성화 상태 변경 (버튼이 존재할 때까지 대기)
            const activateFilterButton = () => {
                const allButtons = document.querySelectorAll('.sidebar-filter-btn');
                if (allButtons.length === 0) {
                    // 버튼이 아직 없으면 잠시 후 재시도
                    setTimeout(activateFilterButton, 50);
                    return;
                }
                
                allButtons.forEach(btn => {
                    btn.classList.remove('active');
                });
                
                // 사용 가능한 필터 값들 확인
                const availableFilters = Array.from(allButtons).map(btn => ({
                    filter: btn.dataset.filter,
                    text: btn.textContent.trim()
                }));
                console.log('Available filters:', availableFilters);
                
                const activeBtn = document.querySelector(`.sidebar-filter-btn[data-filter="${filterType}"]`);
                if (activeBtn) {
                    activeBtn.classList.add('active');
                    console.log('Filter button activated:', filterType, activeBtn);
                } else {
                    console.warn('Filter button not found for:', filterType);
                    console.warn('Trying to find button with text content...');
                    // 대체 방법: 텍스트 내용으로 찾기
                    const filterTextMap = {
                        'all': '전체',
                        'progress': '진행 중',
                        'waiting': '검토 대기',
                        'completed': '완료',
                        'terminated': '종료'
                    };
                    const targetText = filterTextMap[filterType];
                    if (targetText) {
                        const btnByText = Array.from(allButtons).find(btn => 
                            btn.textContent.includes(targetText)
                        );
                        if (btnByText) {
                            btnByText.classList.add('active');
                            console.log('Filter button activated by text:', filterType, btnByText);
                        }
                    }
                }
            };
            
            activateFilterButton();
            
            // 필터 타입을 직접 전달하여 검색 필터 적용
            filterContracts(filterType);
            
            // URL 업데이트 (updateUrl이 true일 때만, 또는 계약이 선택되지 않았을 때)
            if (updateUrl !== false) {
                const urlParams = new URLSearchParams(window.location.search);
                const contractId = urlParams.get('contractId');
                
                if (contractId) {
                    // 계약이 선택된 상태면 필터만 URL에 추가
                    const newUrl = '?contractId=' + contractId + '&filter=' + filterType;
                    window.history.pushState({filter: filterType}, '', newUrl);
                } else {
                    // 계약이 선택되지 않은 상태면 필터만 URL에 추가
                    const newUrl = '?filter=' + filterType;
                    window.history.pushState({filter: filterType}, '', newUrl);
                }
            }
        }
        
        // 검색 + 상태 필터링
        function filterContracts(forceFilterType) {
            const q = (document.getElementById('contractSearch')?.value || '').trim().toLowerCase();
            
            // forceFilterType이 있으면 사용, 없으면 활성 버튼에서 읽기
            let activeFilter;
            if (forceFilterType) {
                activeFilter = forceFilterType;
            } else {
                const activeFilterBtn = document.querySelector('.sidebar-filter-btn.active');
                activeFilter = activeFilterBtn ? activeFilterBtn.dataset.filter : 'all';
            }
            
            console.log('filterContracts - activeFilter:', activeFilter, 'search:', q);
            
            let visibleCount = 0;
            document.querySelectorAll('.sidebar-contract-item').forEach(li => {
                // 필터 체크
                let filterMatch = false;
                if (activeFilter === 'all') {
                    // 전체: 모든 항목 표시
                    filterMatch = true;
                } else if (activeFilter === 'progress') {
                    // 진행 중: SIGNED, PAID, WAITING
                    filterMatch = li.classList.contains('filter-progress') || li.classList.contains('filter-waiting');
                } else if (activeFilter === 'waiting') {
                    // 검토 대기: WAITING만
                    filterMatch = li.classList.contains('filter-waiting');
                } else if (activeFilter === 'completed') {
                    // 완료: COMPLETED_HISTORY만
                    filterMatch = li.classList.contains('filter-completed');
                } else if (activeFilter === 'terminated') {
                    // 종료: TERMINATED만
                    filterMatch = li.classList.contains('filter-terminated');
                }
                
                // 검색어 체크
                const titleEl = li.querySelector('.sidebar-contract-title');
                const metaEl = li.querySelector('.sidebar-contract-meta');
                const title = titleEl ? titleEl.textContent.trim().toLowerCase() : '';
                const meta = metaEl ? metaEl.textContent.trim().toLowerCase() : '';
                const searchMatch = !q || title.includes(q) || meta.includes(q);
                
                const shouldShow = filterMatch && searchMatch;
                li.style.display = shouldShow ? '' : 'none';
                if (shouldShow) visibleCount++;
            });
            
            console.log('Visible items:', visibleCount);
        }
        
        // 계약 카운트 업데이트
        function updateContractCount() {
            // 필터에 따라 카운트 업데이트는 setFilter에서 처리
        }
        
        // 마일스톤 카드 확대/축소 토글
        function toggleMilestoneCard(card, event) {
            // 버튼 클릭은 이벤트 전파 방지
            if (event && event.target && (event.target.tagName === 'BUTTON' || event.target.closest('form'))) {
                return;
            }
            
            const isExpanded = card.classList.contains('expanded');
            
            // 모든 마일스톤 카드를 축소
            document.querySelectorAll('.milestone-list.milestone-timeline .milestone-card').forEach(c => {
                c.classList.remove('expanded');
                c.classList.add('compact');
            });
            
            // 클릭한 카드만 확대
            if (!isExpanded) {
                card.classList.remove('compact');
                card.classList.add('expanded');
                
                // 확대된 카드로 스크롤
                setTimeout(() => {
                    card.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                }, 100);
            }
        }
        
        // PDF 다운로드 링크 및 미리보기 설정
        function setupPdfDownloadLink() {
            <c:if test="${not empty selectedContract and not empty selectedContract.originContractUrl}">
            const pdfPath = '<c:out value="${selectedContract.originContractUrl}" />';
            if (pdfPath) {
                const normalized = pdfPath.replace(/\\/g, '/');
                const lastSlash = normalized.lastIndexOf('/');
                const dir = lastSlash >= 0 ? normalized.substring(0, lastSlash + 1) : '';
                const file = lastSlash >= 0 ? normalized.substring(lastSlash + 1) : normalized;
                const base = '${pageContext.request.contextPath}/freelancer/contract/file/';
                const pdfUrl = base + dir + encodeURIComponent(file);
                
                // 다운로드 링크 설정 (다운로드 전용 엔드포인트 사용)
                const downloadBase = '${pageContext.request.contextPath}/freelancer/contract/download/';
                const downloadUrl = downloadBase + dir + encodeURIComponent(file);
                const link = document.getElementById('pdfDownloadLink');
                if (link) {
                    link.href = downloadUrl;
                }
                
                // 우측 패널 미리보기 iframe 설정
                const previewFrame = document.getElementById('contractPreviewFrame');
                if (previewFrame) {
                    previewFrame.src = pdfUrl;
                }
                
                // 전역 변수로 저장 (모달에서 사용)
                window.__pdfUrl = pdfUrl;
            }
            </c:if>
        }
        
        // PDF 모달 열기
        function openPdfModal() {
            <c:if test="${not empty selectedContract and not empty selectedContract.originContractUrl}">
            const pdfPath = '<c:out value="${selectedContract.originContractUrl}" />';
            if (!pdfPath) {
                alert('계약서 PDF가 등록되지 않았습니다.');
                return;
            }
            
            const normalized = pdfPath.replace(/\\/g, '/');
            const lastSlash = normalized.lastIndexOf('/');
            const dir = lastSlash >= 0 ? normalized.substring(0, lastSlash + 1) : '';
            const file = lastSlash >= 0 ? normalized.substring(lastSlash + 1) : normalized;
            const base = '${pageContext.request.contextPath}/freelancer/contract/file/';
            const pdfUrl = base + dir + encodeURIComponent(file);
            
            const modal = document.getElementById('pdfModal');
            const frame = document.getElementById('pdfModalFrame');
            if (modal && frame) {
                frame.src = pdfUrl;
                modal.classList.add('show');
                document.body.style.overflow = 'hidden';
            }
            </c:if>
            <c:if test="${empty selectedContract or empty selectedContract.originContractUrl}">
            alert('계약서 PDF가 등록되지 않았습니다.');
            </c:if>
        }
        
        // PDF 모달 닫기
        function closePdfModal() {
            const modal = document.getElementById('pdfModal');
            const frame = document.getElementById('pdfModalFrame');
            if (modal && frame) {
                modal.classList.remove('show');
                frame.src = '';
                document.body.style.overflow = '';
            }
        }
        
        // ESC 키로 모달 닫기
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closePdfModal();
            }
        });
        
        // AI 계약 분석 새 창 열기
        function openContractAnalysis(contractId) {
            const analysisUrl = '${pageContext.request.contextPath}/freelancer/contract/analyze?contractId=' + contractId;
            
            // 새 창 열기
            const analysisWindow = window.open('', 'contractAnalysis', 'width=1400,height=900,scrollbars=yes,resizable=yes');
            
            // 즉시 로딩 화면 표시
            var loadingHtml = '<!DOCTYPE html>' +
                '<html>' +
                '<head>' +
                '<meta charset="UTF-8">' +
                '<title>AI 계약 분석 중...</title>' +
                '<style>' +
                '* { margin: 0; padding: 0; box-sizing: border-box; }' +
                'body { margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; height: 100vh; background: #f5f5f5; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }' +
                '.loading-container { text-align: center; }' +
                '.spinner { border: 4px solid #f3f3f3; border-top: 4px solid #667eea; border-radius: 50%; width: 50px; height: 50px; animation: spin 1s linear infinite; margin: 0 auto 20px; }' +
                '@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }' +
                '.loading-text { font-size: 18px; color: #333; margin-bottom: 8px; }' +
                '.loading-subtext { font-size: 14px; color: #666; }' +
                '</style>' +
                '</head>' +
                '<body>' +
                '<div class="loading-container">' +
                '<div class="spinner"></div>' +
                '<div class="loading-text">AI가 계약을 분석하고 있어요</div>' +
                '<div class="loading-subtext">잠시만 기다려주세요...</div>' +
                '</div>' +
                '</body>' +
                '</html>';
            
            analysisWindow.document.write(loadingHtml);
            analysisWindow.document.close();
            
            // 로딩 화면 표시 후 서버 요청
            setTimeout(function() {
                analysisWindow.location.href = analysisUrl;
            }, 100);
        }
        
        // 드롭다운 토글
        function toggleDropdown() {
            const dropdown = document.getElementById('dropdownMenu');
            dropdown.classList.toggle('show');
        }

        // 외부 클릭 시 드롭다운 닫기
        document.addEventListener('click', function(e) {
            const profileDropdown = document.querySelector('.profile-dropdown');
            if (profileDropdown && !profileDropdown.contains(e.target)) {
                const dropdownMenu = document.getElementById('dropdownMenu');
                if (dropdownMenu) {
                    dropdownMenu.classList.remove('show');
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
</body>
</html>
