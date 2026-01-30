<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>계약 목록 - Ratel-Ocean</title>
    
    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/contract/contract-common.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/contract/clientContracts.css">
</head>
<body>
<c:set var="userType" value="FREELANCER" scope="request"/>
<jsp:include page="/WEB-INF/views/common/headerBase.jsp" />

<!-- 메인 콘텐츠 -->
<main class="main-content">
    <!-- 페이지 헤더 -->
    <div class="page-header" style="background: var(--primary); color: #fff; border-radius: 12px; padding: 16px 0 16px 24px; margin-bottom: 24px; display: flex; align-items: center; min-height: 50px;">
        <div style="display: flex; align-items: center; gap: 12px;">
            <span style="font-size: 1.5rem; background: rgba(255,255,255,0.13); border-radius: 8px; padding: 8px 12px 8px 10px; display: flex; align-items: center; justify-content: center;">
                <svg xmlns='http://www.w3.org/2000/svg' width='20' height='20' fill='none' viewBox='0 0 24 24'><rect width='24' height='24' rx='6' fill='white' fill-opacity='0.13'/><path d='M7.5 4.75A2.25 2.25 0 0 0 5.25 7v10A2.25 2.25 0 0 0 7.5 19.25h9A2.25 2.25 0 0 0 18.75 17V7A2.25 2.25 0 0 0 16.5 4.75h-9Zm0 1.5h9c.414 0 .75.336.75.75v10a.75.75 0 0 1-.75.75h-9a.75.75 0 0 1-.75-.75V7c0-.414.336-.75.75-.75Zm1.25 2.5a.75.75 0 0 0 0 1.5h6.5a.75.75 0 0 0 0-1.5h-6.5Zm-.75 3.25c0-.414.336-.75.75-.75h6.5a.75.75 0 0 1 0 1.5h-6.5a.75.75 0 0 1-.75-.75Zm.75 2.5a.75.75 0 0 0 0 1.5h4.5a.75.75 0 0 0 0-1.5h-4.5Z' fill='white'/></svg>
            </span>
            <div>
                <h1 style="font-size: 1.25rem; font-weight: 700; margin-bottom: 0.25rem; color: #fff;">계약 목록</h1>
                <p style="font-size: 0.875rem; color: #eaf7fa; font-weight: 400; margin: 0;">계약 현황과 통계를 한눈에 확인하세요</p>
            </div>
        </div>
    </div>

    <c:if test="${not empty errorMessage}">
        <div style="background: #fee2e2; color: #991b1b; padding: 1rem; border-radius: 8px; margin-bottom: 2rem;">
            ${errorMessage}
        </div>
    </c:if>

    <%-- 프리랜서 관점 핵심 지표 계산 --%>
    <c:set var="totalWaiting" value="0"/>
    <c:set var="totalSigned" value="0"/>
    <c:set var="totalPaid" value="0"/>
    <c:set var="totalCompleted" value="0"/>
    <c:set var="totalRequestedMilestones" value="0"/>
    <c:set var="totalDepositedMilestones" value="0"/>
    
    <c:forEach var="contract" items="${allContracts}">
        <c:if test="${contract.contractStatus != null and (contract.contractStatus.name() eq 'WAITING' or contract.contractStatus.name() eq 'waiting')}">
            <c:set var="totalWaiting" value="${totalWaiting + 1}"/>
        </c:if>
        <c:if test="${contract.contractStatus != null and (contract.contractStatus.name() eq 'SIGNED' or contract.contractStatus.name() eq 'signed')}">
            <c:set var="totalSigned" value="${totalSigned + 1}"/>
        </c:if>
        <c:if test="${contract.contractStatus != null and (contract.contractStatus.name() eq 'PAID' or contract.contractStatus.name() eq 'paid')}">
            <c:set var="totalPaid" value="${totalPaid + 1}"/>
        </c:if>
        <c:if test="${contract.contractStatus != null and (contract.contractStatus.name() eq 'COMPLETED' or contract.contractStatus.name() eq 'completed')}">
            <c:set var="totalCompleted" value="${totalCompleted + 1}"/>
        </c:if>
        <c:if test="${contract.requestedMilestones != null and contract.requestedMilestones > 0}">
            <c:set var="totalRequestedMilestones" value="${totalRequestedMilestones + contract.requestedMilestones}"/>
        </c:if>
        <c:if test="${contract.depositedMilestones != null and contract.depositedMilestones > 0}">
            <c:set var="totalDepositedMilestones" value="${totalDepositedMilestones + contract.depositedMilestones}"/>
        </c:if>
    </c:forEach>

    <!-- 핵심 지표 카드 (프리랜서 관점) -->
    <div class="stats-grid compact stats-grid-5">
        <c:if test="${totalRequestedMilestones > 0}">
        <div class="stat-card priority clickable" onclick="scrollToSection('requested')">
            <div class="stat-header">
                <span class="stat-title">지급 요청</span>
                <div style="display: flex; align-items: center; gap: 0.5rem;">
                    <div class="stat-icon">💰</div>
                    <span class="help-icon">?</span>
                </div>
            </div>
            <div class="stat-value">${totalRequestedMilestones}</div>
            <div class="stat-label">마일스톤</div>
            <div class="stat-badge urgent">승인 대기</div>
            <div class="tooltip">
                <div class="tooltip-title">
                    <span class="tooltip-icon">💰</span>
                    <span>지급 요청</span>
                </div>
                <div class="tooltip-description">
                    작업 완료 후 지급을 요청한 마일스톤 수입니다. 클라이언트의 승인을 기다리는 상태입니다.
                </div>
            </div>
        </div>
        </c:if>

        <div class="stat-card clickable" onclick="scrollToSection('working')">
            <div class="stat-header">
                <span class="stat-title">작업중</span>
                <div style="display: flex; align-items: center; gap: 0.5rem;">
                    <div class="stat-icon">💼</div>
                    <span class="help-icon">?</span>
                </div>
            </div>
            <div class="stat-value">${totalDepositedMilestones}</div>
            <div class="stat-label">마일스톤</div>
            <div class="tooltip">
                <div class="tooltip-title">
                    <span class="tooltip-icon">💼</span>
                    <span>작업중</span>
                </div>
                <div class="tooltip-description">
                    현재 작업을 진행 중인 마일스톤 수입니다. 입금이 완료되어 작업이 진행되고 있는 상태입니다.
                </div>
            </div>
        </div>

        <div class="stat-card clickable" onclick="scrollToSection('signed')">
            <div class="stat-header">
                <span class="stat-title">결제 대기</span>
                <div style="display: flex; align-items: center; gap: 0.5rem;">
                    <div class="stat-icon">⏳</div>
                    <span class="help-icon">?</span>
                </div>
            </div>
            <div class="stat-value">${totalSigned}</div>
            <div class="stat-label">건</div>
            <div class="tooltip">
                <div class="tooltip-title">
                    <span class="tooltip-icon">⏳</span>
                    <span>결제 대기</span>
                </div>
                <div class="tooltip-description">
                    계약서 서명이 완료되어 클라이언트의 결제를 기다리는 계약 건수입니다.
                </div>
            </div>
        </div>

        <div class="stat-card clickable" onclick="scrollToSection('waiting')">
            <div class="stat-header">
                <span class="stat-title">검토 대기</span>
                <div style="display: flex; align-items: center; gap: 0.5rem;">
                    <div class="stat-icon">👀</div>
                    <span class="help-icon">?</span>
                </div>
            </div>
            <div class="stat-value">${totalWaiting}</div>
            <div class="stat-label">건</div>
            <div class="tooltip">
                <div class="tooltip-title">
                    <span class="tooltip-icon">👀</span>
                    <span>검토 대기</span>
                </div>
                <div class="tooltip-description">
                    계약서를 검토 중인 계약 건수입니다. 수락 또는 거절을 결정해야 합니다.
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
            <div class="stat-value">${totalPaid}</div>
            <div class="stat-label">건</div>
            <div class="tooltip">
                <div class="tooltip-title">
                    <span class="tooltip-icon">📋</span>
                    <span>진행중 계약</span>
                </div>
                <div class="tooltip-description">
                    현재 진행 중인 전체 계약 건수입니다. 결제가 완료되어 작업이 진행되고 있는 계약입니다.
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
            <div class="stat-value">${totalCompleted}</div>
            <div class="stat-label">건</div>
            <div class="tooltip">
                <div class="tooltip-title">
                    <span class="tooltip-icon">✅</span>
                    <span>완료된 계약</span>
                </div>
                <div class="tooltip-description">
                    모든 마일스톤이 완료되어 정산이 완료된 계약 건수입니다.
                </div>
            </div>
        </div>
    </div>

    <!-- 지급 요청 계약 목록 -->
    <c:set var="hasRequestedContracts" value="false"/>
    <c:forEach var="contract" items="${allContracts}">
        <c:if test="${contract.requestedMilestones != null and contract.requestedMilestones > 0}">
            <c:set var="hasRequestedContracts" value="true"/>
        </c:if>
    </c:forEach>
    
    <c:if test="${hasRequestedContracts}">
    <div class="section-card alert-section priority-section" id="requested">
        <div class="section-header">
            <h2 class="section-title">
                <span class="alert-icon">💰</span>
                지급 요청 <span class="badge-count">${totalRequestedMilestones}건</span>
            </h2>
        </div>
        <ul class="contract-list compact">
            <c:forEach var="contract" items="${allContracts}">
                <c:if test="${contract.requestedMilestones != null and contract.requestedMilestones > 0}">
                    <li class="contract-item alert-item" 
                        onclick="goToContractDetail(${contract.contractId})">
                        <div class="contract-header">
                            <div class="contract-title">${contract.projectTitle != null ? contract.projectTitle : '프로젝트명 없음'}</div>
                            <span class="contract-badge status-paid">
                                마일스톤 ${contract.requestedMilestones}개 지급 요청
                            </span>
                        </div>
                        <div class="contract-meta">
                            <span class="contract-freelancer">${contract.clientName != null ? contract.clientName : '클라이언트 정보 없음'}</span>
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
                </c:if>
            </c:forEach>
        </ul>
    </div>
    </c:if>

    <!-- 작업중 계약 목록 -->
    <c:set var="hasWorkingContracts" value="false"/>
    <c:forEach var="contract" items="${allContracts}">
        <c:if test="${contract.depositedMilestones != null and contract.depositedMilestones > 0 and contract.requestedMilestones == 0}">
            <c:set var="hasWorkingContracts" value="true"/>
        </c:if>
    </c:forEach>
    
    <c:if test="${hasWorkingContracts}">
    <div class="section-card" id="working">
        <div class="section-header">
            <h2 class="section-title">💼 작업중 계약</h2>
        </div>
        <ul class="contract-list compact">
            <c:forEach var="contract" items="${allContracts}">
                <c:if test="${contract.depositedMilestones != null and contract.depositedMilestones > 0 and contract.requestedMilestones == 0}">
                    <li class="contract-item" 
                        onclick="goToContractDetail(${contract.contractId})">
                        <div class="contract-header">
                            <div class="contract-title">${contract.projectTitle != null ? contract.projectTitle : '프로젝트명 없음'}</div>
                            <span class="contract-badge status-progress">작업중 ${contract.depositedMilestones}건</span>
                        </div>
                        <div class="contract-meta">
                            <span class="contract-freelancer">${contract.clientName != null ? contract.clientName : '클라이언트 정보 없음'}</span>
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
    <c:if test="${totalSigned > 0}">
    <div class="section-card" id="signed">
        <div class="section-header">
            <h2 class="section-title">⏳ 결제 대기</h2>
        </div>
        <ul class="contract-list compact">
            <c:forEach var="contract" items="${allContracts}">
                <c:if test="${contract.contractStatus != null and (contract.contractStatus.name() eq 'SIGNED' or contract.contractStatus.name() eq 'signed')}">
                    <li class="contract-item" 
                        onclick="goToContractDetail(${contract.contractId})">
                        <div class="contract-header">
                            <div class="contract-title">${contract.projectTitle != null ? contract.projectTitle : '프로젝트명 없음'}</div>
                            <span class="contract-badge status-signed">결제 대기</span>
                        </div>
                        <div class="contract-meta">
                            <span class="contract-freelancer">${contract.clientName != null ? contract.clientName : '클라이언트 정보 없음'}</span>
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
    <c:if test="${totalWaiting > 0}">
    <div class="section-card" id="waiting">
        <div class="section-header">
            <h2 class="section-title">👀 검토 대기</h2>
        </div>
        <ul class="contract-list compact">
            <c:forEach var="contract" items="${allContracts}">
                <c:if test="${contract.contractStatus != null and (contract.contractStatus.name() eq 'WAITING' or contract.contractStatus.name() eq 'waiting')}">
                    <li class="contract-item" 
                        onclick="goToContractDetail(${contract.contractId})">
                        <div class="contract-header">
                            <div class="contract-title">${contract.projectTitle != null ? contract.projectTitle : '프로젝트명 없음'}</div>
                            <span class="contract-badge status-waiting">검토중</span>
                        </div>
                        <div class="contract-meta">
                            <span class="contract-freelancer">${contract.clientName != null ? contract.clientName : '클라이언트 정보 없음'}</span>
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
            <h2 class="section-title">📋 전체 계약</h2>
        </div>
        <c:choose>
            <c:when test="${not empty allContracts and fn:length(allContracts) > 0}">
                <ul class="contract-list">
                    <c:forEach var="contract" items="${allContracts}">
                        <li class="contract-item" onclick="goToContractDetail(${contract.contractId})">
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
                                <span class="contract-freelancer">${contract.clientName != null ? contract.clientName : '클라이언트 정보 없음'}</span>
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

    function goToContractDetail(contractId) {
        if (contractId) {
            window.location.href = '${pageContext.request.contextPath}/freelancer/contract/list?contractId=' + contractId;
        } else {
            window.location.href = '${pageContext.request.contextPath}/freelancer/contract/list';
        }
    }
</script>
</body>
</html>
