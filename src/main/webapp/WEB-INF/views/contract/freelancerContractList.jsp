<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>계약 관리</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/contract/contract-common.css"/>
</head>
<body>
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

        <div class="main-layout">
            <!-- 왼쪽 사이드바: 상태별 계약 목록 -->
            <div class="sidebar">
                <!-- 1. 진행 중인 계약 (우선순위) -->
                <div class="sidebar-section-header">
                    <h3>📊 진행 중인 계약</h3>
                </div>
                
                <!-- 1-1. 결제 대기 중 (SIGNED) -->
                <c:if test="${not empty contractsByStatus['SIGNED']}">
                    <div class="status-section priority-high">
                        <div class="status-title" onclick="toggleSection(this)">
                            <span class="toggle-icon">▼</span>
                            <span class="status-icon">💳</span>
                            <span class="status-text">결제 대기 중</span>
                            <span class="status-badge signed">${fn:length(contractsByStatus['SIGNED'])}</span>
                        </div>
                        <ul class="contract-list">
                            <c:forEach var="contract" items="${contractsByStatus['SIGNED']}">
                                <li class="contract-item ${selectedContract.contractId eq contract.contractId ? 'active' : ''}"
                                    onclick="location.href='?contractId=${contract.contractId}'">
                                    <div class="contract-item-header">
                                        <div class="contract-item-title">
                                            <c:out value="${contract.projectTitle != null ? contract.projectTitle : '프로젝트 정보 없음'}"/>
                                        </div>
                                        <div class="contract-item-status-badge status-signed-mini">대기</div>
                                    </div>
                                    <div class="contract-item-subtitle">
                                        <c:out value="${contract.counterpartName != null ? contract.counterpartName : '클라이언트 정보 없음'}"/>
                                    </div>
                                    <div class="contract-item-meta">
                                        <span class="contract-amount">
                                            <fmt:formatNumber value="${contract.totalBudget}" pattern="#,###"/>원
                                        </span>
                                        <c:if test="${not empty contract.contractedAt}">
                                            <span class="contract-date">${contract.contractedAt}</span>
                                        </c:if>
                                    </div>
                                </li>
                            </c:forEach>
                        </ul>
                    </div>
                </c:if>
                
                <!-- 1-2. 작업 진행 중 (PAID + SETTLEMENT_PENDING) -->
                <c:set var="activePaidContracts" value="${contractsByStatus['PAID']}"/>
                <c:set var="settlementPendingContracts" value="${contractsByStatus['SETTLEMENT_PENDING']}"/>
                <c:if test="${not empty activePaidContracts or not empty settlementPendingContracts}">
                    <div class="status-section priority-high">
                        <div class="status-title" onclick="toggleSection(this)">
                            <span class="toggle-icon">▼</span>
                            <span class="status-icon">🚀</span>
                            <span class="status-text">작업 진행 중</span>
                            <span class="status-badge paid">
                                <c:set var="activeCount" value="0"/>
                                <c:if test="${not empty activePaidContracts}">
                                    <c:set var="activeCount" value="${activeCount + fn:length(activePaidContracts)}"/>
                                </c:if>
                                <c:if test="${not empty settlementPendingContracts}">
                                    <c:set var="activeCount" value="${activeCount + fn:length(settlementPendingContracts)}"/>
                                </c:if>
                                ${activeCount}
                            </span>
                        </div>
                        <ul class="contract-list">
                            <!-- PAID 상태 계약 -->
                            <c:forEach var="contract" items="${activePaidContracts}">
                                <li class="contract-item ${selectedContract.contractId eq contract.contractId ? 'active' : ''}"
                                    onclick="location.href='?contractId=${contract.contractId}'">
                                    <div class="contract-item-header">
                                        <div class="contract-item-title">
                                            <c:out value="${contract.projectTitle != null ? contract.projectTitle : '프로젝트 정보 없음'}"/>
                                        </div>
                                        <div class="contract-item-status-badge status-paid-mini">
                                            <c:choose>
                                                <c:when test="${contract.requestedMilestones > 0}">
                                                    지급요청 ${contract.requestedMilestones}건
                                                </c:when>
                                                <c:when test="${contract.depositedMilestones > 0}">
                                                    입금완료 ${contract.depositedMilestones}건
                                                </c:when>
                                                <c:when test="${contract.paidMilestones > 0 and contract.totalMilestones > 0}">
                                                    진행 ${contract.paidMilestones}/${contract.totalMilestones}
                                                </c:when>
                                                <c:otherwise>진행중</c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                    <div class="contract-item-subtitle">
                                        <c:out value="${contract.counterpartName != null ? contract.counterpartName : '클라이언트 정보 없음'}"/>
                                    </div>
                                    <div class="contract-item-meta">
                                        <span class="contract-amount">
                                            <fmt:formatNumber value="${contract.totalBudget}" pattern="#,###"/>원
                                        </span>
                                        <c:if test="${contract.totalMilestones > 0}">
                                            <span class="milestone-info">
                                                마일스톤 ${contract.totalMilestones}개
                                            </span>
                                        </c:if>
                                    </div>
                                </li>
                            </c:forEach>
                            
                            <!-- SETTLEMENT_PENDING 상태 계약 -->
                            <c:forEach var="contract" items="${settlementPendingContracts}">
                                <li class="contract-item ${selectedContract.contractId eq contract.contractId ? 'active' : ''}"
                                    onclick="location.href='?contractId=${contract.contractId}'">
                                    <div class="contract-item-header">
                                        <div class="contract-item-title">
                                            <c:out value="${contract.projectTitle != null ? contract.projectTitle : '프로젝트 정보 없음'}"/>
                                        </div>
                                        <div class="contract-item-status-badge status-settlement-mini">
                                            정산대기
                                        </div>
                                    </div>
                                    <div class="contract-item-subtitle">
                                        <c:out value="${contract.counterpartName != null ? contract.counterpartName : '클라이언트 정보 없음'}"/>
                                    </div>
                                    <div class="contract-item-meta">
                                        <span class="contract-amount">
                                            <fmt:formatNumber value="${contract.totalBudget}" pattern="#,###"/>원
                                        </span>
                                        <c:if test="${contract.totalMilestones > 0}">
                                            <span class="milestone-info">
                                                ${contract.paidMilestones}/${contract.totalMilestones} 완료
                                            </span>
                                        </c:if>
                                    </div>
                                </li>
                            </c:forEach>
                        </ul>
                    </div>
                </c:if>
                
                <!-- 2. 검토 대기 중 -->
                <div class="sidebar-section-header">
                    <h3>⏳ 검토 대기</h3>
                </div>
                
                <!-- 2-1. 전송됨 (WAITING) -->
                <c:if test="${not empty contractsByStatus['WAITING']}">
                    <div class="status-section priority-medium">
                        <div class="status-title" onclick="toggleSection(this)">
                            <span class="toggle-icon">▼</span>
                            <span class="status-icon">📨</span>
                            <span class="status-text">수락 대기</span>
                            <span class="status-badge waiting">${fn:length(contractsByStatus['WAITING'])}</span>
                        </div>
                        <ul class="contract-list">
                            <c:forEach var="contract" items="${contractsByStatus['WAITING']}">
                                <li class="contract-item ${selectedContract.contractId eq contract.contractId ? 'active' : ''}"
                                    onclick="location.href='?contractId=${contract.contractId}'">
                                    <div class="contract-item-header">
                                        <div class="contract-item-title">
                                            <c:out value="${contract.projectTitle != null ? contract.projectTitle : '프로젝트 정보 없음'}"/>
                                        </div>
                                        <div class="contract-item-status-badge status-waiting-mini">검토중</div>
                                    </div>
                                    <div class="contract-item-subtitle">
                                        <c:out value="${contract.counterpartName != null ? contract.counterpartName : '클라이언트 정보 없음'}"/>
                                    </div>
                                    <div class="contract-item-meta">
                                        <span class="contract-amount">
                                            <fmt:formatNumber value="${contract.totalBudget}" pattern="#,###"/>원
                                        </span>
                                        <c:if test="${not empty contract.contractedAt}">
                                            <span class="contract-date">${contract.contractedAt}</span>
                                        </c:if>
                                    </div>
                                </li>
                            </c:forEach>
                        </ul>
                    </div>
                </c:if>
                
                <!-- 3. 완료된 계약 -->
                <div class="sidebar-section-header">
                    <h3>✅ 완료 내역</h3>
                </div>
                
                <!-- 3-1. 완료 내역 (COMPLETED_HISTORY) -->
                <c:if test="${not empty contractsByStatus['COMPLETED_HISTORY']}">
                    <div class="status-section priority-low">
                        <div class="status-title" onclick="toggleSection(this)">
                            <span class="toggle-icon">▼</span>
                            <span class="status-icon">✅</span>
                            <span class="status-text">완료된 계약</span>
                            <span class="status-badge completed">${fn:length(contractsByStatus['COMPLETED_HISTORY'])}</span>
                        </div>
                        <ul class="contract-list">
                            <c:forEach var="contract" items="${contractsByStatus['COMPLETED_HISTORY']}">
                                <li class="contract-item ${selectedContract.contractId eq contract.contractId ? 'active' : ''}"
                                    onclick="location.href='?contractId=${contract.contractId}'">
                                    <div class="contract-item-header">
                                        <div class="contract-item-title">
                                            <c:out value="${contract.projectTitle != null ? contract.projectTitle : '프로젝트 정보 없음'}"/>
                                        </div>
                                        <div class="contract-item-status-badge status-completed-mini">완료</div>
                                    </div>
                                    <div class="contract-item-subtitle">
                                        <c:out value="${contract.counterpartName != null ? contract.counterpartName : '클라이언트 정보 없음'}"/>
                                    </div>
                                    <div class="contract-item-meta">
                                        <span class="contract-amount">
                                            <fmt:formatNumber value="${contract.totalBudget}" pattern="#,###"/>원
                                        </span>
                                        <c:if test="${not empty contract.completedAt}">
                                            <span class="contract-date">${contract.completedAt}</span>
                                        </c:if>
                                    </div>
                                </li>
                            </c:forEach>
                        </ul>
                    </div>
                </c:if>
                
                <!-- 4. 종료된 계약 -->
                <div class="sidebar-section-header">
                    <h3>❌ 종료된 계약</h3>
                </div>
                
                <!-- TERMINATED 상태 처리 -->
                <c:forEach var="statusEntry" items="${contractsByStatus}">
                    <c:if test="${statusEntry.key eq 'TERMINATED'}">
                            <!-- TERMINATED를 거절/취소로 분리 -->
                            <!-- 거절됨 섹션 -->
                            <c:set var="hasRejected" value="false"/>
                            <c:forEach var="contract" items="${statusEntry.value}">
                                <c:if test="${fn:startsWith(contract.cancelReason, '[거절]')}">
                                    <c:set var="hasRejected" value="true"/>
                                </c:if>
                            </c:forEach>
                            <c:if test="${hasRejected}">
                                <div class="status-section">
                                    <div class="status-title" onclick="toggleSection(this)">
                                        <span class="toggle-icon">▼</span>
                                        <span class="status-icon">🚫</span>
                                        <span class="status-text">내가 거절함</span>
                                        <span class="status-badge rejected">
                                            <c:set var="rejectedCount" value="0"/>
                                            <c:forEach var="contract" items="${statusEntry.value}">
                                                <c:if test="${fn:startsWith(contract.cancelReason, '[거절]')}">
                                                    <c:set var="rejectedCount" value="${rejectedCount + 1}"/>
                                                </c:if>
                                            </c:forEach>
                                            ${rejectedCount}
                                        </span>
                                    </div>
                                    <ul class="contract-list">
                                        <c:forEach var="contract" items="${statusEntry.value}">
                                            <c:if test="${fn:startsWith(contract.cancelReason, '[거절]')}">
                                                <li class="contract-item ${selectedContract.contractId eq contract.contractId ? 'active' : ''}"
                                                    onclick="location.href='?contractId=${contract.contractId}'">
                                                    <div class="contract-item-header">
                                                        <div class="contract-item-title">
                                                            <c:out value="${contract.projectTitle != null ? contract.projectTitle : '프로젝트 정보 없음'}"/>
                                                        </div>
                                                    </div>
                                                    <div class="contract-item-subtitle">
                                                        <c:out value="${contract.counterpartName != null ? contract.counterpartName : '클라이언트 정보 없음'}"/>
                                                    </div>
                                                    <div class="contract-item-meta">
                                                        <span class="contract-amount">
                                                            <fmt:formatNumber value="${contract.totalBudget}" pattern="#,###"/>원
                                                        </span>
                                                        <c:if test="${not empty contract.contractedAt}">
                                                            <span class="contract-date">${contract.contractedAt}</span>
                                                        </c:if>
                                                    </div>
                                                </li>
                                            </c:if>
                                        </c:forEach>
                                    </ul>
                                </div>
                            </c:if>
                            
                            <!-- 취소됨 섹션 -->
                            <c:set var="hasCancelled" value="false"/>
                            <c:forEach var="contract" items="${statusEntry.value}">
                                <c:if test="${fn:startsWith(contract.cancelReason, '[취소]')}">
                                    <c:set var="hasCancelled" value="true"/>
                                </c:if>
                            </c:forEach>
                            <c:if test="${hasCancelled}">
                                <div class="status-section">
                                    <div class="status-title" onclick="toggleSection(this)">
                                        <span class="toggle-icon">▼</span>
                                        <span class="status-icon">❌</span>
                                        <span class="status-text">클라이언트가 취소함</span>
                                        <span class="status-badge cancelled">
                                            <c:set var="cancelledCount" value="0"/>
                                            <c:forEach var="contract" items="${statusEntry.value}">
                                                <c:if test="${fn:startsWith(contract.cancelReason, '[취소]')}">
                                                    <c:set var="cancelledCount" value="${cancelledCount + 1}"/>
                                                </c:if>
                                            </c:forEach>
                                            ${cancelledCount}
                                        </span>
                                    </div>
                                    <ul class="contract-list">
                                        <c:forEach var="contract" items="${statusEntry.value}">
                                            <c:if test="${fn:startsWith(contract.cancelReason, '[취소]')}">
                                                <li class="contract-item ${selectedContract.contractId eq contract.contractId ? 'active' : ''}"
                                                    onclick="location.href='?contractId=${contract.contractId}'">
                                                    <div class="contract-item-header">
                                                        <div class="contract-item-title">
                                                            <c:out value="${contract.projectTitle != null ? contract.projectTitle : '프로젝트 정보 없음'}"/>
                                                        </div>
                                                    </div>
                                                    <div class="contract-item-subtitle">
                                                        <c:out value="${contract.counterpartName != null ? contract.counterpartName : '클라이언트 정보 없음'}"/>
                                                    </div>
                                                    <div class="contract-item-meta">
                                                        <span class="contract-amount">
                                                            <fmt:formatNumber value="${contract.totalBudget}" pattern="#,###"/>원
                                                        </span>
                                                        <c:if test="${not empty contract.contractedAt}">
                                                            <span class="contract-date">${contract.contractedAt}</span>
                                                        </c:if>
                                                    </div>
                                                </li>
                                            </c:if>
                                        </c:forEach>
                                    </ul>
                                </div>
                            </c:if>
                            
                            <!-- 기타 종료된 계약 (prefix가 없는 경우) -->
                            <c:set var="hasOtherTerminated" value="false"/>
                            <c:forEach var="contract" items="${statusEntry.value}">
                                <c:if test="${!fn:startsWith(contract.cancelReason, '[거절]') && !fn:startsWith(contract.cancelReason, '[취소]')}">
                                    <c:set var="hasOtherTerminated" value="true"/>
                                </c:if>
                            </c:forEach>
                            <c:if test="${hasOtherTerminated}">
                                <div class="status-section">
                                    <div class="status-title" onclick="toggleSection(this)">
                                        <span class="toggle-icon">▼</span>
                                        <span class="status-icon">⚠️</span>
                                        <span class="status-text">중도 종료</span>
                                        <span class="status-badge terminated">
                                            <c:set var="otherTerminatedCount" value="0"/>
                                            <c:forEach var="contract" items="${statusEntry.value}">
                                                <c:if test="${!fn:startsWith(contract.cancelReason, '[거절]') && !fn:startsWith(contract.cancelReason, '[취소]')}">
                                                    <c:set var="otherTerminatedCount" value="${otherTerminatedCount + 1}"/>
                                                </c:if>
                                            </c:forEach>
                                            ${otherTerminatedCount}
                                        </span>
                                    </div>
                                    <ul class="contract-list">
                                        <c:forEach var="contract" items="${statusEntry.value}">
                                            <c:if test="${!fn:startsWith(contract.cancelReason, '[거절]') && !fn:startsWith(contract.cancelReason, '[취소]')}">
                                                <li class="contract-item ${selectedContract.contractId eq contract.contractId ? 'active' : ''}"
                                                    onclick="location.href='?contractId=${contract.contractId}'">
                                                    <div class="contract-item-header">
                                                        <div class="contract-item-title">
                                                            <c:out value="${contract.projectTitle != null ? contract.projectTitle : '프로젝트 정보 없음'}"/>
                                                        </div>
                                                    </div>
                                                    <div class="contract-item-subtitle">
                                                        <c:out value="${contract.counterpartName != null ? contract.counterpartName : '클라이언트 정보 없음'}"/>
                                                    </div>
                                                    <div class="contract-item-meta">
                                                        <span class="contract-amount">
                                                            <fmt:formatNumber value="${contract.totalBudget}" pattern="#,###"/>원
                                                        </span>
                                                        <c:if test="${not empty contract.contractedAt}">
                                                            <span class="contract-date">${contract.contractedAt}</span>
                                                        </c:if>
                                                    </div>
                                                </li>
                                            </c:if>
                                        </c:forEach>
                                    </ul>
                                </div>
                            </c:if>
                        </c:if>
                    </c:forEach>
            </div>

            <!-- 오른쪽: 선택한 계약 상세 정보 -->
            <div class="content-area">
                <c:choose>
                    <c:when test="${not empty selectedContract}">
                        <!-- 계약 정보 -->
                        <div class="section-title">📄 계약 정보</div>
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

                        <!-- PDF 표시 -->
                        <c:choose>
                            <c:when test="${selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'TERMINATED' or selectedContract.contractStatus.name() eq 'terminated') 
                                            and (fn:startsWith(selectedContract.cancelReason, '[거절]') or fn:startsWith(selectedContract.cancelReason, '[취소]'))}">
                                <!-- 거절/취소된 계약: 기밀 보호를 위해 PDF 숨김 -->
                                <div class="section-title">📄 계약서 PDF</div>
                                <div class="payment-warning-section payment-warning-section-centered">
                                    <p class="payment-warning-text-large">🔒 거절/취소된 계약의 계약서는 기밀 보호를 위해 열람할 수 없습니다.</p>
                                </div>
                            </c:when>
                            <c:when test="${not empty selectedContract.originContractUrl}">
                                <!-- 진행 중/완료된 계약 및 중도 종료: PDF 표시 -->
                                <div class="section-title">📄 계약서 PDF</div>
                                <div class="pdf-viewer-container">
                                    <iframe id="pdfViewer" src=""></iframe>
                                    <script>
                                        (function() {
                                            var pdfPath = '<c:out value="${selectedContract.originContractUrl}" />';
                                            if (pdfPath) {
                                                pdfPath = pdfPath.replace(/\\/g, '/');
                                                var lastSlashIndex = pdfPath.lastIndexOf('/');
                                                if (lastSlashIndex >= 0) {
                                                    var dirPath = pdfPath.substring(0, lastSlashIndex + 1);
                                                    var fileName = pdfPath.substring(lastSlashIndex + 1);
                                                    var encodedPath = dirPath + encodeURIComponent(fileName);
                                                    document.getElementById('pdfViewer').src = '${pageContext.request.contextPath}/freelancer/contract/file/' + encodedPath;
                                                } else {
                                                    document.getElementById('pdfViewer').src = '${pageContext.request.contextPath}/freelancer/contract/file/' + encodeURIComponent(pdfPath);
                                                }
                                            }
                                        })();
                                    </script>
                                </div>
                                <div class="pdf-download-container">
                                    <script>
                                        (function() {
                                            var pdfPath = '<c:out value="${selectedContract.originContractUrl}" />';
                                            if (pdfPath) {
                                                pdfPath = pdfPath.replace(/\\/g, '/');
                                                var lastSlashIndex = pdfPath.lastIndexOf('/');
                                                var downloadUrl;
                                                if (lastSlashIndex >= 0) {
                                                    var dirPath = pdfPath.substring(0, lastSlashIndex + 1);
                                                    var fileName = pdfPath.substring(lastSlashIndex + 1);
                                                    downloadUrl = '${pageContext.request.contextPath}/freelancer/contract/file/' + dirPath + encodeURIComponent(fileName);
                                                } else {
                                                    downloadUrl = '${pageContext.request.contextPath}/freelancer/contract/file/' + encodeURIComponent(pdfPath);
                                                }
                                                document.write('<a href="' + downloadUrl + '" download class="btn btn-secondary">📥 PDF 다운로드</a>');
                                            }
                                        })();
                                    </script>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <!-- PDF가 없는 경우 -->
                                <div class="section-title">📄 계약서 PDF</div>
                                <div class="payment-warning-section payment-warning-section-centered">
                                    <p class="payment-warning-text-large">⚠️ 계약서 PDF가 등록되지 않았습니다.</p>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <!-- 일시지급 요청 버튼 (마일스톤이 없고 일시지급인 경우, 아직 요청하지 않은 경우, COMPLETED가 아닌 경우) -->
                        <c:if test="${(empty milestones or milestones.size() eq 0) 
                            and (selectedContract.paymentMethod eq 'FIXED' or selectedContract.paymentMethod eq 'FULL') 
                            and selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'PAID' or selectedContract.contractStatus.name() eq 'paid')
                            and selectedContract.cancelReason ne '[지급요청]'}">
                            <div class="section-title">💰 일시지급 요청</div>
                            <div class="payment-request-section">
                                <p class="payment-request-text-freelancer">작업이 완료되었습니다. 지급을 요청해주세요.</p>
                                <form method="post" action="${pageContext.request.contextPath}/freelancer/contract/request-payment" class="form-inline">
                                    <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                    <button type="submit" class="btn btn-success" onclick="return confirm('일시지급을 요청하시겠습니까?')">
                                        💰 일시지급 요청
                                    </button>
                                </form>
                            </div>
                        </c:if>
                        
                        <!-- 일시지급 요청 대기 중 (cancel_reason이 "[지급요청]"인 경우, COMPLETED가 아닌 경우) -->
                        <c:if test="${(empty milestones or milestones.size() eq 0) 
                            and (selectedContract.paymentMethod eq 'FIXED' or selectedContract.paymentMethod eq 'FULL') 
                            and selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'PAID' or selectedContract.contractStatus.name() eq 'paid')
                            and selectedContract.cancelReason eq '[지급요청]'}">
                            <div class="section-title">💰 일시지급 요청</div>
                            <div class="payment-warning-section">
                                <p class="payment-warning-text">📤 클라이언트의 지급 수락을 기다리는 중입니다.</p>
                            </div>
                        </c:if>
                        
                        <!-- 일시지급 완료 (COMPLETED 상태인 경우) -->
                        <c:if test="${(empty milestones or milestones.size() eq 0) 
                            and (selectedContract.paymentMethod eq 'FIXED' or selectedContract.paymentMethod eq 'FULL') 
                            and selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'COMPLETED' or selectedContract.contractStatus.name() eq 'completed')}">
                            <div class="section-title">💰 일시지급 완료</div>
                            <div class="payment-completed-section">
                                <p class="payment-completed-text">✅ 일시지급이 완료되었습니다.</p>
                            </div>
                        </c:if>

                        <!-- 마일스톤 (마일스톤이 있는 경우 표시) -->
                        <c:if test="${not empty milestones}">
                            <div class="section-title">🎯 마일스톤 내역</div>
                            <table class="milestone-table">
                                <thead>
                                    <tr>
                                        <th>단계</th>
                                        <th>마일스톤명</th>
                                        <th class="text-right">지급금액</th>
                                        <th>작업 내용</th>
                                        <th>상태</th>
                                        <th>액션</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="m" items="${milestones}" varStatus="status">
                                        <tr>
                                            <td class="text-center">${status.index + 1}단계</td>
                                            <td><c:out value="${m.title}" default="-"/></td>
                                            <td class="text-right">
                                                <c:choose>
                                                    <c:when test="${m.amount != null}">
                                                        <fmt:formatNumber value="${m.amount}" pattern="#,###"/>원
                                                    </c:when>
                                                    <c:otherwise>-</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td><c:out value="${m.description}" default="-"/></td>
                                            <td class="text-center">
                                                <c:choose>
                                                    <c:when test="${m.status != null and (m.status.name() eq 'WAITING' or m.status.name() eq 'waiting')}">⏳ 대기 중</c:when>
                                                    <c:when test="${m.status != null and (m.status.name() eq 'REQUESTED' or m.status.name() eq 'requested')}">📤 지급 요청</c:when>
                                                    <c:when test="${m.status != null and (m.status.name() eq 'DEPOSITED' or m.status.name() eq 'deposited')}">💳 입금 완료</c:when>
                                                    <c:when test="${m.status != null and (m.status.name() eq 'PAID' or m.status.name() eq 'paid')}">✅ 지급 완료</c:when>
                                                    <c:otherwise>${m.status != null ? m.status.name() : '-'}</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center">
                                                <c:if test="${selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'PAID' or selectedContract.contractStatus.name() eq 'paid' or selectedContract.contractStatus.name() eq 'COMPLETED' or selectedContract.contractStatus.name() eq 'completed') and m.status != null and (m.status.name() eq 'WAITING' or m.status.name() eq 'waiting')}">
                                                    <form method="post" action="${pageContext.request.contextPath}/freelancer/contract/request-payment" class="form-inline-display">
                                                        <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                                        <input type="hidden" name="step" value="${m.step}" />
                                                        <button type="submit" class="btn btn-success btn-sm" onclick="return confirm('${m.step}단계 마일스톤 지급을 요청하시겠습니까?')">
                                                            💰 지급 요청
                                                        </button>
                                                    </form>
                                                </c:if>
                                                <c:if test="${selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'PAID' or selectedContract.contractStatus.name() eq 'paid' or selectedContract.contractStatus.name() eq 'COMPLETED' or selectedContract.contractStatus.name() eq 'completed') and m.status != null and (m.status.name() eq 'WAITING' or m.status.name() eq 'waiting') and fn:contains(m.title, '일시지급')}">
                                                    <span class="re-request-hint">(재요청 가능)</span>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
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
        </div>
    </div>
    
    <script>
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
        
        // 페이지 로드 시 선택된 계약이 있는 섹션은 자동으로 펼치기
        document.addEventListener('DOMContentLoaded', function() {
            const activeItem = document.querySelector('.contract-item.active');
            if (activeItem) {
                const section = activeItem.closest('.status-section');
                if (section) {
                    const list = section.querySelector('.contract-list');
                    const title = section.querySelector('.status-title');
                    const icon = title.querySelector('.toggle-icon');
                    if (list) {
                        list.style.display = 'block';
                        if (icon) icon.textContent = '▼';
                        section.classList.remove('collapsed');
                    }
                }
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
    </script>
</body>
</html>
