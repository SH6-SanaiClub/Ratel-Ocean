<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>${project.title} | Ratel Ocean</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/project/detail.css">
</head>
<body>

<div class="detail-container">

    <div class="detail-main">

        <div class="breadcrumb">프로젝트 탐색 &gt; 프로젝트 상세 정보</div>

        <div class="project-header">
            <div class="badge-row">
                <jsp:useBean id="now" class="java.util.Date" />
                <fmt:parseNumber value="${now.time / (1000*60*60*24)}" integerOnly="true" var="nowDays" />

                <c:choose>
                    <c:when test="${not empty project.deadlineDate}">
                        <fmt:parseNumber value="${project.deadlineDate.time / (1000*60*60*24)}" integerOnly="true" var="deadlineDays" />
                        <c:set var="dDay" value="${deadlineDays - nowDays}" />
                        <span class="status-badge ${dDay < 0 ? 'badge-gray' : 'badge-red'}">
                            <c:choose>
                                <c:when test="${dDay < 0}">마감됨</c:when>
                                <c:when test="${dDay == 0}">오늘 마감</c:when>
                                <c:otherwise>D-${dDay} 마감임박</c:otherwise>
                            </c:choose>
                        </span>
                    </c:when>
                    <c:otherwise>
                        <span class="status-badge badge-gray">상시 모집</span>
                    </c:otherwise>
                </c:choose>

                <span class="status-badge badge-blue">PUBLIC CLOUD</span> </div>

            <h1 class="project-title">${project.title}</h1>

            <div class="project-meta">
                <span><i class="fa-regular fa-building"></i> 클라이언트 (ID: ${project.clientId})</span>
                <span class="meta-divider"></span>
                <span><i class="fa-regular fa-calendar"></i> 등록일 ${fn:substring(project.createdAt, 0, 10)}</span>
            </div>
        </div>

        <div class="info-card-row">
            <div class="info-card">
                <span class="info-label">예상 예산</span>
                <span class="info-value">
                    <fmt:formatNumber value="${project.budget}" type="number"/>원
                </span>
                <span class="info-sub">
                    <c:if test="${project.budgetNegotiable}">(협의 가능)</c:if>
                    <c:if test="${!project.budgetNegotiable}">-</c:if>
                </span>
            </div>
            <div class="info-card">
                <span class="info-label">예상 기간</span>
                <span class="info-value">${project.estDuration}</span>
                <span class="info-sub">
                    <c:if test="${project.durationNegotiable}">(협의 가능)</c:if>
                    <c:if test="${!project.durationNegotiable}">-</c:if>
                </span>
            </div>
        </div>

        <div class="anchor-nav">
            <a href="#section-desc" class="anchor-item active">프로젝트 개요</a>
            <a href="#section-task" class="anchor-item">상세 업무</a>
            <a href="#section-stack" class="anchor-item">기술 스택</a>
        </div>

        <div id="section-desc" class="content-section">
            <h3 class="section-head"><i class="fa-solid fa-circle-info"></i> 프로젝트 개요</h3>
            <div class="section-body">
                <c:out value="${project.description}" escapeXml="false"/>
            </div>
        </div>

        <div id="section-task" class="content-section">
            <h3 class="section-head"><i class="fa-solid fa-list-check"></i> 상세 업무 범위</h3>
            <div class="task-list">
                <div class="task-item">
                    <div class="task-icon"><i class="fa-solid fa-check-circle"></i></div>
                    <div>
                        <span class="task-title">프로젝트 상세 분석 및 설계</span>
                        <span class="task-desc">클라이언트와 협의하여 요구사항을 구체화합니다.</span>
                    </div>
                </div>
                <div class="task-item">
                    <div class="task-icon"><i class="fa-solid fa-check-circle"></i></div>
                    <div>
                        <span class="task-title">핵심 기능 개발</span>
                        <span class="task-desc">요구사항 명세서에 따른 기능 구현을 진행합니다.</span>
                    </div>
                </div>
                <div class="task-item">
                    <div class="task-icon"><i class="fa-solid fa-check-circle"></i></div>
                    <div>
                        <span class="task-title">테스트 및 안정화</span>
                        <span class="task-desc">기능 테스트 후 배포 및 인수인계를 진행합니다.</span>
                    </div>
                </div>
            </div>
        </div>

        <div id="section-stack" class="content-section">
            <h3 class="section-head"><i class="fa-solid fa-code"></i> 필요 기술 스택</h3>
            <div class="tech-chips">
                <c:choose>
                    <c:when test="${not empty project.stacks}">
                        <c:forEach var="stack" items="${project.stacks}">
                            <span class="tech-chip">
                                    ${stack.stackName}
                            </span>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <span class="tech-chip">등록된 기술 스택 없음</span>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <c:if test="${not empty project.planUrl}">
            <div class="content-section">
                <h3 class="section-head"><i class="fa-solid fa-paperclip"></i> 관련 자료</h3>
                <a href="${pageContext.request.contextPath}${project.planUrl}" class="file-card" download>
                    <i class="fa-solid fa-file-lines file-icon"></i>
                    <span class="file-name">프로젝트_기획서_및_자료 (클릭하여 다운로드)</span>
                    <i class="fa-solid fa-download"></i>
                </a>
            </div>
        </c:if>

    </div>

    <div class="detail-sidebar">

        <div class="sidebar-box">
            <div class="status-header">
                <div>
                    <span class="status-title">현재 지원 현황</span>
                    <span class="status-count">${project.applicantCount}명 지원 중</span>
                </div>
                <div class="status-views">
                    <small>조회수</small>
                    <fmt:formatNumber value="${project.viewCount}"/>
                </div>
            </div>

            <c:choose>
                <%-- 비로그인 --%>
                <c:when test="${empty sessionScope.loginMember}">
                    <button type="button" class="btn-primary" onclick="alert('로그인이 필요한 서비스입니다.'); location.href='/login';">
                        <i class="fa-solid fa-paper-plane"></i> 지원하기
                    </button>
                </c:when>

                <%-- 클라이언트 (본인 글 관리 / 타인 글 지원불가) --%>
                <c:when test="${sessionScope.loginMember.type == 'CLIENT'}">
                    <c:choose>
                        <c:when test="${sessionScope.loginMember.id == project.clientId}">
                            <button type="button" class="btn-primary" style="background:#333;" onclick="location.href='/project/edit/${project.projectId}'">
                                <i class="fa-solid fa-gear"></i> 프로젝트 관리
                            </button>
                        </c:when>
                        <c:otherwise>
                            <button type="button" class="btn-primary" onclick="alert('클라이언트는 지원할 수 없습니다.');">
                                <i class="fa-solid fa-paper-plane"></i> 지원하기
                            </button>
                        </c:otherwise>
                    </c:choose>
                </c:when>

                <%-- 프리랜서 --%>
                <c:when test="${sessionScope.loginMember.type == 'FREELANCER'}">
                    <c:choose>
                        <c:when test="${isApplied}">
                            <button type="button" class="btn-primary" style="background:#E74C3C;" id="btnApplyToggle" onclick="toggleApply()">
                                <i class="fa-solid fa-xmark"></i> 지원 취소
                            </button>
                        </c:when>
                        <c:otherwise>
                            <button type="button" class="btn-primary" id="btnApplyToggle" onclick="toggleApply()">
                                <i class="fa-solid fa-paper-plane"></i> 지원하기
                            </button>
                        </c:otherwise>
                    </c:choose>
                </c:when>
            </c:choose>

            <button type="button" class="btn-outline" onclick="openChat('${project.clientId}')">
                <i class="fa-regular fa-comments"></i> 클라이언트와 채팅하기
            </button>

            <div class="safe-banner">
                <i class="fa-solid fa-shield-halved safe-icon"></i>
                <div class="safe-text">
                    <strong>안전결제보증</strong>
                    <p>본 프로젝트는 에스크로 서비스를 통한 대금 보호를 지원합니다.</p>
                </div>
            </div>

            <div class="wish-btn-wrap">
                <button type="button" class="btn-wish-text ${isWishlisted ? 'active' : ''}" onclick="toggleWish(this)">
                    <i class="${isWishlisted ? 'fa-solid' : 'fa-regular'} fa-heart"></i>
                    <span>나중에 보기</span>
                </button>
            </div>
        </div>

        <div class="sidebar-box">
            <span class="client-label">클라이언트 정보</span>

            <div class="client-profile">
                <div class="cp-img"><i class="fa-solid fa-user-tie"></i></div>
                <div class="cp-info">
                    <div>클라이언트 ${project.clientId}</div>
                    <span>IT / 소프트웨어</span>
                </div>
            </div>

            <div class="cp-stats">
                <div class="cp-stat-item">
                    <span class="cp-stat-label">누적 계약</span>
                    <span class="cp-stat-val">- 건</span>
                </div>
                <div class="cp-stat-item" style="border-left:1px solid #eee; padding-left:12px;">
                    <span class="cp-stat-label">평점</span>
                    <span class="cp-stat-val rating">- / 5.0</span>
                </div>
            </div>
        </div>

    </div>

</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/project/detail.js"></script>

</body>
</html>