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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/project/create.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/project/detail.css">
</head>
<body>

<div class="detail-container">

    <div class="detail-main">
        <div class="project-header">
            <div class="badge-wrap">
                <jsp:useBean id="now" class="java.util.Date" />
                <fmt:parseNumber value="${now.time / (1000*60*60*24)}" integerOnly="true" var="nowDays" />

                <c:choose>
                    <c:when test="${not empty project.deadlineDate}">
                        <fmt:parseNumber value="${project.deadlineDate.time / (1000*60*60*24)}" integerOnly="true" var="deadlineDays" />
                        <c:set var="dDay" value="${deadlineDays - nowDays}" />

                        <span class="d-badge">
                            <c:choose>
                                <c:when test="${dDay < 0}">마감됨</c:when>
                                <c:when test="${dDay == 0}">오늘 마감</c:when>
                                <c:otherwise>D-${dDay}</c:otherwise>
                            </c:choose>
                        </span>
                    </c:when>
                    <c:otherwise>
                        <span class="d-badge" style="background:#eee; color:#555;">상시 모집</span>
                    </c:otherwise>
                </c:choose>

                <span class="c-badge">프로젝트</span>
            </div>

            <h1 class="detail-title">${project.title}</h1>

            <div class="detail-meta">
                <span class="meta-item"><i class="fa-regular fa-building"></i> 클라이언트 (ID: ${project.clientId})</span>
                <span class="meta-item">
                    <i class="fa-regular fa-calendar"></i> 등록일 ${fn:replace(fn:substring(project.createdAt, 0, 10), '-', '.')}
                </span>
            </div>
        </div>

        <div class="summary-grid" style="grid-template-columns: 1fr 1fr 1fr;">
            <div class="sum-box">
                <span class="sum-label"><i class="fa-solid fa-coins"></i> 예상 예산</span>
                <span class="sum-value"><fmt:formatNumber value="${project.budget}" type="number"/>원</span>
                <c:if test="${project.budgetNegotiable}"><span class="sum-sub">(협의 가능)</span></c:if>
            </div>
            <div class="sum-box" style="border-right: 1px solid #eee;">
                <span class="sum-label"><i class="fa-regular fa-calendar"></i> 예상 기간</span>
                <span class="sum-value">${project.estDuration}</span>
                <c:if test="${project.durationNegotiable}"><span class="sum-sub">(협의 가능)</span></c:if>
            </div>
            <div class="sum-box">
                <span class="sum-label"><i class="fa-solid fa-rocket"></i> 시작 예정일</span>
                <span class="sum-value">
                    <c:choose>
                        <c:when test="${empty project.startDate}">ASAP (즉시 착수)</c:when>
                        <c:otherwise>${project.startDate}</c:otherwise>
                    </c:choose>
                </span>
            </div>
        </div>

        <div class="detail-section">
            <h3 class="sec-title"><i class="fa-solid fa-circle-info"></i> 프로젝트 내용</h3>
            <div class="content-view">
                <c:out value="${project.description}" escapeXml="false"/>
            </div>
        </div>

        <div class="detail-section">
            <h3 class="sec-title"><i class="fa-solid fa-code"></i> 필요 기술 및 숙련도</h3>
            <div class="skill-grid">
                <span class="skill-tag" style="background:#f8f9fa; border:1px solid #ddd; color:#666;">
                    <i class="fa-solid fa-check"></i> 상세 내용 및 클라이언트 협의 필요
                </span>
            </div>
        </div>

        <div class="detail-section">
            <h3 class="sec-title"><i class="fa-solid fa-file-contract"></i> 계약 및 작업 조건</h3>
            <ul class="contract-info-list" style="list-style:none; padding:0; color:#555; font-size: 15px; line-height: 2;">
                <li>
                    <span style="font-weight:600; margin-right:10px; min-width:80px; display:inline-block;">• 미팅 방식:</span>
                    <c:choose>
                        <c:when test="${project.communicateMethod == 'ONLINE'}">온라인 (화상/메신저)</c:when>
                        <c:when test="${project.communicateMethod == 'OFFLINE'}">오프라인 (대면)</c:when>
                        <c:otherwise>${project.communicateMethod}</c:otherwise>
                    </c:choose>
                </li>
                <li>
                    <span style="font-weight:600; margin-right:10px; min-width:80px; display:inline-block;">• 대금 지급:</span>
                    <c:choose>
                        <c:when test="${project.paymentMethod == 'LUMP_SUM'}">일괄 지급 (종료 후)</c:when>
                        <c:when test="${project.paymentMethod == 'INSTALLMENT'}">분할 지급 (단계별)</c:when>
                        <c:otherwise>${project.paymentMethod}</c:otherwise>
                    </c:choose>
                </li>
                <li>
                    <span style="font-weight:600; margin-right:10px; min-width:80px; display:inline-block;">• 수정 횟수:</span>
                    총 ${project.maxRevisionCount}회 무료 수정 가능
                </li>
            </ul>

            <c:if test="${not empty project.changePolicy}">
                <div style="margin-top:15px; padding:20px; background:#f9f9f9; border-radius:8px; font-size:14px; color:#666; line-height:1.6;">
                    <strong style="display:block; margin-bottom:5px; color:#333;">[수정 및 재진행 정책]</strong>
                    <c:out value="${project.changePolicy}" escapeXml="false"/>
                </div>
            </c:if>
        </div>

        <c:if test="${not empty project.planUrl}">
            <div class="detail-section">
                <h3 class="sec-title"><i class="fa-solid fa-paperclip"></i> 첨부 파일</h3>
                <div class="preview-file-card" onclick="location.href='${project.planUrl}'">
                    <div class="pf-icon"><i class="fa-solid fa-file-arrow-down"></i></div>
                    <div class="pf-info">
                        <div class="pf-name">첨부파일 다운로드</div>
                        <div class="pf-sub">클릭하여 확인하세요</div>
                    </div>
                    <div class="pf-action"><i class="fa-solid fa-download"></i></div>
                </div>
            </div>
        </c:if>
    </div>

    <div class="detail-sidebar">
        <div class="sidebar-card">
            <div class="status-row">
                <div>
                    <span class="status-label">현재 지원 현황</span>
                    <span class="status-val">${project.applicantCount}명 지원 중</span>
                </div>
                <span class="view-count">조회수 <fmt:formatNumber value="${project.viewCount}"/></span>
            </div>

            <div class="action-btns">
                <c:choose>
                    <%-- 비로그인 --%>
                    <c:when test="${empty sessionScope.loginMember}">
                        <button type="button" class="btn-apply" onclick="alert('로그인이 필요한 서비스입니다.'); location.href='/login';">
                            <i class="fa-solid fa-paper-plane"></i> 지원하기
                        </button>
                    </c:when>

                    <%-- 클라이언트 --%>
                    <c:when test="${sessionScope.loginMember.type == 'CLIENT'}">
                        <c:choose>
                            <c:when test="${sessionScope.loginMember.id == project.clientId}">
                                <button type="button" class="btn-apply" style="background:#333;" onclick="location.href='/project/edit/${project.projectId}'">
                                    <i class="fa-solid fa-gear"></i> 프로젝트 관리
                                </button>
                            </c:when>
                            <c:otherwise>
                                <button type="button" class="btn-apply" onclick="alert('클라이언트는 프로젝트에 지원할 수 없습니다. (프리랜서 계정 필요)');">
                                    <i class="fa-solid fa-paper-plane"></i> 지원하기
                                </button>
                            </c:otherwise>
                        </c:choose>
                    </c:when>

                    <%-- 프리랜서 --%>
                    <c:when test="${sessionScope.loginMember.type == 'FREELANCER'}">
                        <c:choose>
                            <c:when test="${isApplied}">
                                <button type="button" class="btn-apply cancel" id="btnApplyToggle" onclick="toggleApply()">
                                    <i class="fa-solid fa-xmark"></i> 지원 취소
                                </button>
                                <button type="button" class="btn-propose show" id="btnPropose" onclick="openProposalModal()">
                                    <i class="fa-solid fa-handshake"></i> 클라이언트에게 제안하기
                                </button>
                            </c:when>
                            <c:otherwise>
                                <button type="button" class="btn-apply" id="btnApplyToggle" onclick="toggleApply()">
                                    <i class="fa-solid fa-paper-plane"></i> 지원하기
                                </button>
                                <button type="button" class="btn-propose" id="btnPropose" onclick="alert('먼저 프로젝트에 지원해야 제안을 보낼 수 있습니다.');">
                                    <i class="fa-solid fa-handshake"></i> 클라이언트에게 제안하기
                                </button>
                            </c:otherwise>
                        </c:choose>
                    </c:when>
                </c:choose>

                <button type="button" class="btn-chat" onclick="openChat('${project.clientId}')">
                    <i class="fa-regular fa-comments"></i> 클라이언트와 채팅하기
                </button>
            </div>

            <div class="wish-wrapper">
                <button type="button" class="btn-wish ${isWishlisted ? 'active' : ''}" onclick="toggleWish(this)">
                    <i class="${isWishlisted ? 'fa-solid' : 'fa-regular'} fa-heart"></i>
                    <span>나중에 보기 (찜하기)</span>
                </button>
            </div>

            <div class="client-info">
                <img src="https://via.placeholder.com/50?text=Client" class="client-img" alt="클라이언트">
                <div class="client-text">
                    <div>클라이언트 (ID: ${project.clientId})</div>
                    <span style="color:#888; font-size:13px;">신뢰할 수 있는 파트너</span>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/project/detail.js"></script>

</body>
</html>