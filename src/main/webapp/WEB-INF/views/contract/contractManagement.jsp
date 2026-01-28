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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/payment/payment-modal.css"/>
    
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <!-- 포트원 SDK -->
    <script src="https://cdn.iamport.kr/v1/iamport.js"></script>
    <!-- 결제 모달 JavaScript -->
    <script src="${pageContext.request.contextPath}/resources/js/payment/payment-modal.js"></script>
</head>
<body>
    <div class="container">
        <div class="page-header">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                <div>
                    <h1>📋 계약 관리</h1>
                    <p>제안한 계약서를 확인하고 관리하세요</p>
                </div>
                <a href="${pageContext.request.contextPath}/client/dashboard" 
                   class="btn btn-secondary" 
                   style="text-decoration: none; white-space: nowrap;">
                    🏠 메인으로
                </a>
            </div>
        </div>
        
        <c:if test="${not empty successMessage}">
            <div class="message-success">
                ✅ ${successMessage}
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="message-error">
                ❌ ${errorMessage}
            </div>
        </c:if>

        <div class="main-layout">
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
                            <span class="status-text">결제 대기</span>
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
                                        <c:out value="${contract.counterpartName != null ? contract.counterpartName : '프리랜서 정보 없음'}"/>
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
                                                    승인대기 ${contract.requestedMilestones}건
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
                                        <c:out value="${contract.counterpartName != null ? contract.counterpartName : '프리랜서 정보 없음'}"/>
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
                                        <c:out value="${contract.counterpartName != null ? contract.counterpartName : '프리랜서 정보 없음'}"/>
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
                
                <!-- 2-1. 전송됨 (WAITING) - 프리랜서 수락 대기 -->
                <c:if test="${not empty contractsByStatus['WAITING']}">
                    <div class="status-section priority-medium">
                        <div class="status-title" onclick="toggleSection(this)">
                            <span class="toggle-icon">▼</span>
                            <span class="status-icon">📤</span>
                            <span class="status-text">프리랜서 승인 대기</span>
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
                                        <c:out value="${contract.counterpartName != null ? contract.counterpartName : '프리랜서 정보 없음'}"/>
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
                                        <c:out value="${contract.counterpartName != null ? contract.counterpartName : '프리랜서 정보 없음'}"/>
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
                                        <span class="status-text">프리랜서가 거절함</span>
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
                                                    <c:out value="${contract.counterpartName != null ? contract.counterpartName : '프리랜서 정보 없음'}"/>
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
                                        <span class="status-text">내가 취소함</span>
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
                                                    <c:out value="${contract.counterpartName != null ? contract.counterpartName : '프리랜서 정보 없음'}"/>
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
                                                    <c:out value="${contract.counterpartName != null ? contract.counterpartName : '프리랜서 정보 없음'}"/>
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
                                            <c:when test="${selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'SIGNED' or selectedContract.contractStatus.name() eq 'signed')}">✅ 프리랜서 승인 완료 (지급 대기 중)</c:when>
                                            <c:when test="${selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'PAID' or selectedContract.contractStatus.name() eq 'paid')}">
                                                <c:choose>
                                                    <c:when test="${selectedContract.requestedMilestones > 0}">
                                                        ✅ 최종 승인 대기 (지급 요청 대기: ${selectedContract.requestedMilestones}건)
                                                    </c:when>
                                                    <c:when test="${selectedContract.depositedMilestones > 0}">
                                                        ✅ 최종 승인 대기 (입금 완료: ${selectedContract.depositedMilestones}건)
                                                    </c:when>
                                                    <c:when test="${selectedContract.paidMilestones > 0}">
                                                        ✅ 최종 승인 대기 (지급 진행 중: ${selectedContract.paidMilestones}/${selectedContract.totalMilestones})
                                                    </c:when>
                                                    <c:otherwise>
                                                        ✅ 최종 승인 대기
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
                                                        <span class="status-rejected">🚫 프리랜서가 거절함</span>
                                                    </c:when>
                                                    <c:when test="${fn:startsWith(selectedContract.cancelReason, '[취소]')}">
                                                        <span class="status-cancelled">❌ 내가 취소함</span>
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
                                                <span style="color: #dc2626; font-weight: 600;">🚫 프리랜서가 거절함</span>
                                            </c:when>
                                            <c:when test="${fn:startsWith(selectedContract.cancelReason, '[취소]')}">
                                                <span style="color: #d97706; font-weight: 600;">❌ 내가 취소함</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: #6b7280; font-weight: 600;">⚠️ 중도 종료</span>
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
                        </div>

                        <!-- PDF 표시 (클라이언트는 항상 볼 수 있음) -->
                        <c:choose>
                            <c:when test="${not empty selectedContract.originContractUrl}">
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
                                                    document.getElementById('pdfViewer').src = '${pageContext.request.contextPath}/client/contract/file/' + encodedPath;
                                                } else {
                                                    document.getElementById('pdfViewer').src = '${pageContext.request.contextPath}/client/contract/file/' + encodeURIComponent(pdfPath);
                                                }
                                            }
                                        })();
                                    </script>
                                </div>
                                <div style="margin-bottom: 24px;">
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
                                                    downloadUrl = '${pageContext.request.contextPath}/client/contract/file/' + dirPath + encodeURIComponent(fileName);
                                                } else {
                                                    downloadUrl = '${pageContext.request.contextPath}/client/contract/file/' + encodeURIComponent(pdfPath);
                                                }
                                                document.write('<a href="' + downloadUrl + '" download class="btn btn-secondary">📥 PDF 다운로드</a>');
                                            }
                                        })();
                                    </script>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="section-title">📄 계약서 PDF</div>
                                <div class="payment-warning-section" style="text-align: center; padding: 24px;">
                                    <p class="payment-warning-text-large">⚠️ 계약서 PDF가 등록되지 않았습니다.</p>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <!-- 일시지급 수락/거부 버튼 (일시지급이고 cancel_reason이 "[지급요청]"인 경우, COMPLETED가 아닌 경우) -->
                        <c:if test="${(empty milestones or milestones.size() eq 0) 
                            and (selectedContract.paymentMethod eq 'FIXED' or selectedContract.paymentMethod eq 'FULL') 
                            and selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'PAID' or selectedContract.contractStatus.name() eq 'paid')
                            and selectedContract.cancelReason eq '[지급요청]'}">
                            <div class="section-title">💰 일시지급 요청</div>
                            <div class="payment-request-section">
                                <p class="payment-request-text">프리랜서가 일시지급을 요청했습니다. 수락하거나 거부할 수 있습니다.</p>
                                <form method="post" action="${pageContext.request.contextPath}/client/contract/management/approve-payment" class="form-inline-margin">
                                    <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                    <button type="submit" class="btn btn-success" onclick="return confirm('일시지급을 수락하시겠습니까?')">
                                        ✅ 지급 수락
                                    </button>
                                </form>
                                <form method="post" action="${pageContext.request.contextPath}/client/contract/management/reject-payment" class="form-inline">
                                    <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                    <button type="submit" class="btn btn-danger" onclick="return confirm('일시지급을 거부하시겠습니까?')">
                                        ❌ 지급 거부
                                    </button>
                                </form>
                            </div>
                        </c:if>
                        
                        <!-- 일시지급 요청 대기 중 (아직 요청하지 않은 경우, COMPLETED가 아닌 경우) -->
                        <c:if test="${(empty milestones or milestones.size() eq 0) 
                            and (selectedContract.paymentMethod eq 'FIXED' or selectedContract.paymentMethod eq 'FULL') 
                            and selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'PAID' or selectedContract.contractStatus.name() eq 'paid')
                            and selectedContract.cancelReason ne '[지급요청]'}">
                            <div class="section-title">💰 일시지급 요청</div>
                            <div class="payment-request-section">
                                <p class="payment-waiting-text">⏳ 프리랜서의 지급 요청을 기다리는 중입니다.</p>
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
                                        <th style="text-align: right;">지급금액</th>
                                        <th>작업 내용</th>
                                        <th>상태</th>
                                        <th>액션</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="m" items="${milestones}" varStatus="status">
                                        <tr>
                                            <td style="text-align: center; font-weight: bold;">${status.index + 1}단계</td>
                                            <td><c:out value="${m.title}" default="-"/></td>
                                            <td style="text-align: right;">
                                                <c:choose>
                                                    <c:when test="${m.amount != null}">
                                                        <fmt:formatNumber value="${m.amount}" pattern="#,###"/>원
                                                    </c:when>
                                                    <c:otherwise>-</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td><c:out value="${m.description}" default="-"/></td>
                                            <td style="text-align: center;">
                                                <c:choose>
                                                    <c:when test="${m.status != null and (m.status.name() eq 'WAITING' or m.status.name() eq 'waiting')}">⏳ 대기 중</c:when>
                                                    <c:when test="${m.status != null and (m.status.name() eq 'REQUESTED' or m.status.name() eq 'requested')}">📤 지급 요청</c:when>
                                                    <c:when test="${m.status != null and (m.status.name() eq 'DEPOSITED' or m.status.name() eq 'deposited')}">💳 입금 완료</c:when>
                                                    <c:when test="${m.status != null and (m.status.name() eq 'PAID' or m.status.name() eq 'paid')}">✅ 지급 완료</c:when>
                                                    <c:otherwise>${m.status != null ? m.status.name() : '-'}</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="text-align: center;">
                                                <c:if test="${selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'PAID' or selectedContract.contractStatus.name() eq 'paid' or selectedContract.contractStatus.name() eq 'COMPLETED' or selectedContract.contractStatus.name() eq 'completed') and m.status != null and (m.status.name() eq 'REQUESTED' or m.status.name() eq 'requested')}">
                                                    <form method="post" action="${pageContext.request.contextPath}/client/contract/management/approve-payment" style="display: inline;">
                                                        <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                                        <input type="hidden" name="step" value="${m.step}" />
                                                        <button type="submit" class="btn btn-success btn-sm" onclick="return confirm('${m.step}단계 마일스톤 지급을 수락하시겠습니까?')">
                                                            ✅ 지급 수락
                                                        </button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/client/contract/management/reject-payment" style="display: inline; margin-left: 8px;">
                                                        <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                                        <input type="hidden" name="step" value="${m.step}" />
                                                        <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('${m.step}단계 마일스톤 지급을 거부하시겠습니까?')">
                                                            ❌ 지급 거부
                                                        </button>
                                                    </form>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:if>

                        <!-- 액션 버튼 (SIGNED 상태일 때만) -->
                        <c:if test="${selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'SIGNED' or selectedContract.contractStatus.name() eq 'signed')}">
                            <div class="action-buttons">
                                <button type="button" class="btn btn-primary" onclick="openPaymentModalForContract(${selectedContract.contractId}, ${selectedContract.totalBudget}, '${selectedContract.projectTitle != null ? fn:replace(selectedContract.projectTitle, "'", "\\'") : "프로젝트"}', '${selectedContract.freelancerName != null ? fn:replace(selectedContract.freelancerName, "'", "\\'") : "프리랜서"}')">
                                    💰 계약 결제 완료
                                </button>
                                <form method="post" action="${pageContext.request.contextPath}/client/contract/management/cancel" class="cancel-form" style="display: inline;">
                                    <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                    <input type="text" name="reason" placeholder="취소 사유를 입력하세요" required 
                                           class="form-input" />
                                    <button type="submit" class="btn btn-danger" onclick="return confirm('계약을 취소하시겠습니까?')">
                                        ❌ 계약 취소
                                    </button>
                                </form>
                            </div>
                        </c:if>
                        
                        <%-- 일시지급 수락 버튼 제거: 
                             - 일시지급 계약은 513-534 라인에서 처리됨
                             - 마일스톤 계약은 595-609 라인에서 각 마일스톤별로 처리됨
                             - 이 버튼은 중복이며 마일스톤 계약에서 불필요함 --%>
                        
                        <!-- 액션 버튼 (PAID 상태일 때만, 일시지급이 아닌 경우만) -->
                        <!-- 마일스톤 계약: 중도 종료 버튼만 표시 (계약 정산 완료는 자동 처리되므로 제거) -->
                        <c:if test="${selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'PAID' or selectedContract.contractStatus.name() eq 'paid')
                            and not ((selectedContract.paymentMethod eq 'FIXED' or selectedContract.paymentMethod eq 'FULL') 
                            and (selectedContract.totalMilestones == null or selectedContract.totalMilestones == 0))}">
                            <div class="action-buttons">
                                <!-- "계약 정산 완료" 버튼 제거 -->
                                <!-- 모든 마일스톤이 PAID가 되면 자동으로 COMPLETED가 되므로 수동 버튼 불필요 -->
                                
                                <!-- 중도 종료 버튼만 유지 -->
                                <form method="post" action="${pageContext.request.contextPath}/client/contract/management/cancel" class="cancel-form" style="display: inline;">
                                    <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                    <input type="text" name="reason" placeholder="중도 종료 사유를 입력하세요" required 
                                           class="form-input" />
                                    <button type="submit" class="btn btn-danger" onclick="return confirm('계약을 중도 종료하시겠습니까?')">
                                        ❌ 계약 중도 종료
                                    </button>
                                </form>
                            </div>
                        </c:if>
                        
                        <!-- 중도 종료 버튼만 (일시지급이고 PAID 상태일 때) -->
                        <c:if test="${selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'PAID' or selectedContract.contractStatus.name() eq 'paid')
                            and (selectedContract.paymentMethod eq 'FIXED' or selectedContract.paymentMethod eq 'FULL') 
                            and (selectedContract.totalMilestones == null or selectedContract.totalMilestones == 0)}">
                            <div class="action-buttons">
                                <form method="post" action="${pageContext.request.contextPath}/client/contract/management/cancel" class="cancel-form" style="display: inline;">
                                    <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                    <input type="text" name="reason" placeholder="중도 종료 사유를 입력하세요" required 
                                           class="form-input" />
                                    <button type="submit" class="btn btn-danger" onclick="return confirm('계약을 중도 종료하시겠습니까?')">
                                        ❌ 계약 중도 종료
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
        
        // 결제 모달 열기 함수 (계약 정보 기반)
        function openPaymentModalForContract(contractId, totalBudget, projectTitle, freelancerName) {
            <c:if test="${not empty selectedContract and not empty clientUser}">
            const buyerName = '<c:out value="${clientUser.name}" default="클라이언트"/>';
            const buyerEmail = '<c:out value="${clientUser.email}" default=""/>';
            const buyerTel = '<c:out value="${clientUser.phone}" default=""/>';
            
            openPaymentModal(
                contractId,
                totalBudget,
                projectTitle || '프로젝트',
                freelancerName || '프리랜서',
                buyerName,
                buyerEmail,
                buyerTel
            );
            </c:if>
            <c:if test="${empty clientUser}">
            // 사용자 정보가 없으면 기본값 사용
            openPaymentModal(
                contractId,
                totalBudget,
                projectTitle || '프로젝트',
                freelancerName || '프리랜서',
                '클라이언트',
                '',
                ''
            );
            </c:if>
        }
    </script>
    
    <!-- 결제 모달 HTML -->
    <div class="payment-modal-overlay">
        <div class="payment-modal-container">
            <div class="payment-modal-header">
                <button type="button" class="payment-modal-close" onclick="closePaymentModal()">×</button>
                <h2 class="payment-modal-title">💳 안전한 결제</h2>
                <p class="payment-modal-subtitle">에스크로 시스템으로 보호되는 결제입니다</p>
            </div>
            
            <div class="payment-modal-body">
                <div class="payment-info-section">
                    <h3 class="payment-info-title">📋 결제 정보</h3>
                    <div class="payment-info-grid">
                        <div class="payment-info-item">
                            <span class="payment-info-label">프로젝트</span>
                            <span class="payment-info-value" id="payment-project-title">-</span>
                        </div>
                        <div class="payment-info-item">
                            <span class="payment-info-label">프리랜서</span>
                            <span class="payment-info-value" id="payment-freelancer-name">-</span>
                        </div>
                        <div class="payment-info-item">
                            <span class="payment-info-label">계약 ID</span>
                            <span class="payment-info-value" id="payment-contract-id">-</span>
                        </div>
                    </div>
                    
                    <div class="payment-amount-highlight">
                        <div class="payment-amount-label">최종 결제 금액</div>
                        <div class="payment-amount-value" id="payment-total-amount">-</div>
                    </div>
                </div>
                
                <div class="payment-notice">
                    <h4 class="payment-notice-title">🔒 안전한 에스크로 결제</h4>
                    <ul class="payment-notice-list">
                        <li>결제 금액은 프로젝트 완료 시까지 안전하게 보관됩니다</li>
                        <li>프리랜서가 작업을 완료하면 자동으로 지급됩니다</li>
                        <li>문제 발생 시 환불이 가능합니다</li>
                    </ul>
                </div>
                
                <div class="payment-modal-buttons">
                    <button type="button" class="payment-modal-btn payment-modal-btn-primary" id="payment-submit-btn" onclick="startPayment()">
                        💳 결제하기
                    </button>
                    <button type="button" class="payment-modal-btn payment-modal-btn-secondary" onclick="closePaymentModal()">
                        취소
                    </button>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
