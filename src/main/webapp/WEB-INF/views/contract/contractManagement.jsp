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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/payment/payment-modal.css"/>
    
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <!-- 포트원 SDK -->
    <script src="https://cdn.iamport.kr/v1/iamport.js"></script>
    <!-- 결제 모달 JavaScript -->
    <script src="${pageContext.request.contextPath}/resources/js/payment/payment-modal.js"></script>
    
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

    </style>
</head>
<body>
<c:set var="activeMenu" value="contracts" scope="request"/>
<c:set var="userType" value="CLIENT" scope="request"/>
<jsp:include page="/WEB-INF/views/common/headerBase.jsp" />
    <div class="container">
        <div class="page-header">
            <div style="text-align: center;">
                <h1>📋 계약 관리</h1>
                <p>제안한 계약서를 확인하고 관리하세요</p>
                <a href="${pageContext.request.contextPath}/client/contract/form" 
                   class="btn btn-primary" 
                   style="text-decoration: none; white-space: nowrap; margin-top: 18px;">
                    ✏️ 계약서 작성하기
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

        <div class="main-layout layout-3col">
            <div class="sidebar sidebar-slim">
                <!-- 검색 기능 -->
                <div class="sidebar-search">
                    <div class="sidebar-search-wrapper">
                        <input id="contractSearch" type="search" placeholder="프로젝트 검색..." oninput="filterContracts()" />
                    </div>
                </div>
                
                <%-- 상태 지표 계산 --%>
                <c:set var="totalRequested" value="0"/><!-- 작업중 마일스톤 수 -->
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
                        <%-- 진행 중으로 보는 상태 (SIGNED, PAID, WAITING) --%>
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
                                <span class="sidebar-contract-days">${contract.counterpartName != null ? contract.counterpartName : '프리랜서 정보 없음'}</span>
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
                                <span class="sidebar-contract-days">${contract.counterpartName != null ? contract.counterpartName : '프리랜서 정보 없음'}</span>
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
                                <span class="sidebar-contract-days">${contract.counterpartName != null ? contract.counterpartName : '프리랜서 정보 없음'}</span>
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
                                <span class="sidebar-contract-days">${contract.counterpartName != null ? contract.counterpartName : '프리랜서 정보 없음'}</span>
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
                                            <span class="sidebar-contract-days">${contract.counterpartName != null ? contract.counterpartName : '프리랜서 정보 없음'}</span>
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
                                            <span class="sidebar-contract-days">${contract.counterpartName != null ? contract.counterpartName : '프리랜서 정보 없음'}</span>
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
                                            <span class="sidebar-contract-days">${contract.counterpartName != null ? contract.counterpartName : '프리랜서 정보 없음'}</span>
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
                        <c:set var="kpiRequested" value="0"/>
                        <c:set var="kpiRequestedAmount" value="0"/>
                        <c:forEach var="m" items="${milestones}">
                            <c:if test="${m.status != null and (m.status.name() eq 'PAID' or m.status.name() eq 'paid')}">
                                <c:set var="kpiPaid" value="${kpiPaid + 1}"/>
                            </c:if>
                            <c:if test="${m.status != null and (m.status.name() eq 'REQUESTED' or m.status.name() eq 'requested')}">
                                <c:set var="kpiRequested" value="${kpiRequested + 1}"/>
                                <c:set var="kpiRequestedAmount" value="${kpiRequestedAmount + (m.amount != null ? m.amount : 0)}"/>
                            </c:if>
                        </c:forEach>
                        <c:set var="kpiRemaining" value="${kpiTotal - kpiPaid}"/>

                        <!-- 프로젝트 오버뷰 (중복된 텍스트 통합 헤더) -->
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
                                        <span>클라이언트: <strong><c:out value="${selectedContract.clientName != null ? selectedContract.clientName : '정보 없음'}"/></strong></span>
                                        <span>|</span>
                                        <span>프리랜서: <strong><c:out value="${selectedContract.freelancerName != null ? selectedContract.freelancerName : (selectedContract.counterpartName != null ? selectedContract.counterpartName : '정보 없음')}"/></strong></span>
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
                        
                        <!-- 계약 세부 정보 (요약 카드, 접기 가능) -->
                        <div class="contract-meta-card" onclick="toggleContractMeta(this)">
                            <div class="contract-meta-header">
                                <div class="contract-meta-title">
                                    📄 계약 세부 정보
                                </div>
                                <div class="contract-meta-toggle">펼치기/접기</div>
                            </div>
                            <div class="contract-meta-body">
                        <div class="info-grid">
                            <div class="info-item">
                                <div class="info-label">계약 ID</div>
                                <div class="info-value">#${selectedContract.contractId}</div>
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
                            </div>
                        </div>

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
                                    <span class="progress-text">${paidCount}/${totalMilestones} 지급 완료</span>
                                </div>
                                <div class="milestone-summary">
                                    <span class="milestone-summary-item">
                                        <span class="summary-label">✅ 지급 완료:</span>
                                        <span class="summary-value">${paidCount}개</span>
                                    </span>
                                    <span class="milestone-summary-item">
                                        <span class="summary-label">📤 승인 대기:</span>
                                        <span class="summary-value requested-highlight">${requestedCount}개</span>
                                    </span>
                                    <span class="milestone-summary-item">
                                        <span class="summary-label">💳 작업 진행:</span>
                                        <span class="summary-value">${depositedCount}개</span>
                                    </span>
                                    <span class="milestone-summary-item">
                                        <span class="summary-label">⏳ 대기 중:</span>
                                        <span class="summary-value">${waitingCount}개</span>
                                    </span>
                                </div>
                            </div>
                            
                            <div class="milestone-list milestone-timeline">
                                <c:forEach var="m" items="${milestones}" varStatus="status">
                                    <div class="milestone-card milestone-${fn:toLowerCase(m.status.name())} ${m.status != null and (m.status.name() eq 'REQUESTED' or m.status.name() eq 'requested') ? 'is-current' : ''} compact" 
                                         onclick="toggleMilestoneCard(this, event)" 
                                         data-step="${m.step}">
                                        <div class="milestone-card-header">
                                            <div class="milestone-step-badge">${m.step}</div>
                                            <h4 class="milestone-title"><c:out value="${m.title}" default="마일스톤 ${m.step}"/></h4>
                                            <div class="milestone-status-badge status-${fn:toLowerCase(m.status.name())}">
                                                <c:choose>
                                                    <c:when test="${m.status != null and (m.status.name() eq 'WAITING' or m.status.name() eq 'waiting')}">
                                                        ⏳ 대기 중
                                                    </c:when>
                                                    <c:when test="${m.status != null and (m.status.name() eq 'DEPOSITED' or m.status.name() eq 'deposited')}">
                                                        💳 입금 완료 (프리랜서 작업 진행 중)
                                                    </c:when>
                                                    <c:when test="${m.status != null and (m.status.name() eq 'REQUESTED' or m.status.name() eq 'requested')}">
                                                        📤 지급 요청됨 (승인 대기)
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
                                        
                                        <!-- 클라이언트 액션 버튼 -->
                                        <c:if test="${selectedContract.contractStatus != null and (selectedContract.contractStatus.name() eq 'PAID' or selectedContract.contractStatus.name() eq 'paid' or selectedContract.contractStatus.name() eq 'COMPLETED' or selectedContract.contractStatus.name() eq 'completed')}">
                                            <div class="milestone-actions" onclick="event.stopPropagation()">
                                                <c:choose>
                                                    <c:when test="${m.status != null and (m.status.name() eq 'REQUESTED' or m.status.name() eq 'requested')}">
                                                        <!-- 작업 확인 및 수락/거부 -->
                                                    <form method="post" action="${pageContext.request.contextPath}/client/contract/management/approve-payment" style="display: inline;">
                                                        <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                                        <input type="hidden" name="step" value="${m.step}" />
                                                            <button type="submit" class="btn btn-success" onclick="return confirm('${m.step}단계 마일스톤 작업을 확인하셨나요? 지급을 수락하시겠습니까?')">
                                                                ✅ 작업 확인 및 지급 수락
                                                        </button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/client/contract/management/reject-payment" style="display: inline; margin-left: 8px;">
                                                        <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                                        <input type="hidden" name="step" value="${m.step}" />
                                                            <button type="submit" class="btn btn-danger" onclick="return confirm('${m.step}단계 마일스톤 지급을 거부하시겠습니까? 프리랜서가 다시 요청할 수 있습니다.')">
                                                            ❌ 지급 거부
                                                        </button>
                                                    </form>
                                                    </c:when>
                                                    <c:when test="${m.status != null and (m.status.name() eq 'DEPOSITED' or m.status.name() eq 'deposited')}">
                                                        <div class="milestone-status-message">
                                                            <span class="status-info">💼 프리랜서가 작업을 진행 중입니다...</span>
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
                            </div>
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
        
        // 필터 설정 (전체, 진행 중, 검토 대기, 완료, 종료)
        function setFilter(filterType, updateUrl) {
            console.log('setFilter called:', filterType);
            
            // 전역 변수에 현재 필터 저장
            currentActiveFilter = filterType;
            
            // 필터 버튼 active 토글 (버튼이 존재할 때까지 대기)
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
            
            // 필터 타입을 직접 전달하여 실제 필터링 적용
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
                    // 전체: 모든 계약
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
        
        // 계약 카운트 업데이트
        function updateContractCount() {
            // 필터에 따라 카운트 업데이트는 setFilter에서 처리
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
                const base = '${pageContext.request.contextPath}/client/contract/file/';
                const pdfUrl = base + dir + encodeURIComponent(file);
                
                // 다운로드 링크 설정 (다운로드 전용 엔드포인트 사용)
                const downloadBase = '${pageContext.request.contextPath}/client/contract/download/';
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
            const base = '${pageContext.request.contextPath}/client/contract/file/';
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

        // 계약 세부 정보 접기/펼치기
        function toggleContractMeta(card) {
            if (card && card.classList) {
                card.classList.toggle('collapsed');
            }
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
