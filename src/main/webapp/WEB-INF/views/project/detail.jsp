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
<jsp:include page="/WEB-INF/views/common/headerBase.jsp" />
<div class="detail-container">

    <div class="detail-main">

        <div class="breadcrumb">프로젝트 찾기 &gt; 프로젝트 상세 정보</div>

        <div class="project-header">
            <div class="badge-row">
                <jsp:useBean id="now" class="java.util.Date" />
                <fmt:parseNumber value="${now.time / (1000*60*60*24)}" integerOnly="true" var="nowDays" />

                <c:choose>
                    <c:when test="${not empty project.deadlineDate}">
                        <%-- 날짜 계산 --%>
                        <fmt:parseNumber value="${project.deadlineDate.time / (1000*60*60*24)}" integerOnly="true" var="deadlineDays" />
                        <c:set var="dDay" value="${deadlineDays - nowDays}" />

                        <c:choose>
                            <c:when test="${dDay < 0}"> <c:set var="badgeClass" value="badge-gray" /> </c:when>
                            <c:when test="${dDay <= 7}"> <c:set var="badgeClass" value="badge-red" /> </c:when>
                            <c:otherwise> <c:set var="badgeClass" value="badge-blue" /> </c:otherwise>
                        </c:choose>

                        <span class="status-badge ${badgeClass}">
                            <c:choose>
                                <c:when test="${dDay < 0}">마감됨</c:when>
                                <c:when test="${dDay == 0}">오늘 마감</c:when>
                                <c:when test="${dDay <= 7}">D-${dDay} 마감임박</c:when>
                                <c:otherwise>D-${dDay}</c:otherwise>
                            </c:choose>
                        </span>
                    </c:when>

                    <c:otherwise>
                        <span class="status-badge badge-gray">상시 모집</span>
                    </c:otherwise>
                </c:choose>
            </div>

            <h1 class="project-title">${project.title}</h1>

            <div class="project-meta">
                <span>
                    <i class="fa-regular fa-building"></i>
                    클라이언트 :
                    <span style="font-weight:600; color:#333;">
                        <c:choose>
                            <c:when test="${project.clientType eq 'CORPORATION' and not empty project.companyName}">
                                ${project.companyName}
                            </c:when>
                            <c:otherwise>
                                ${project.clientName}
                            </c:otherwise>
                        </c:choose>
                    </span>
                </span>
                <span class="meta-divider"></span>
                <span><i class="fa-regular fa-calendar"></i> 등록일 ${fn:substring(project.createdAt, 0, 10)}</span>
            </div>
        </div>

        <div class="info-card-row">
            <div class="info-card">
                <span class="info-label">예상 시작일</span>
                <span class="info-value">
                    <c:set var="regDateStr" value="${fn:substring(project.createdAt, 0, 10)}" />
                    <fmt:formatDate value="${project.startDate}" pattern="yyyy-MM-dd" var="startDateStr" />
                    <c:choose>
                        <c:when test="${(regDateStr eq startDateStr) and project.durationNegotiable}">
                            <span style="font-size: 0.85em; letter-spacing: -0.5px;">협의 가능 / 즉시착수</span>
                        </c:when>
                        <c:otherwise>${startDateStr}</c:otherwise>
                    </c:choose>
                </span>
                <span class="info-sub">
                    <c:choose>
                        <c:when test="${(regDateStr eq startDateStr) and project.durationNegotiable}">일정 조율 가능</c:when>
                        <c:otherwise>-</c:otherwise>
                    </c:choose>
                </span>
            </div>

            <div class="info-card">
                <span class="info-label">예상 예산</span>
                <span class="info-value">
                    <fmt:formatNumber value="${project.budget}" type="number"/>원
                </span>
                <span class="info-sub">
                    <c:choose>
                        <c:when test="${project.budgetNegotiable}">협의 가능</c:when>
                        <c:otherwise>-</c:otherwise>
                    </c:choose>
                </span>
            </div>

            <div class="info-card">
                <span class="info-label">예상 기간</span>
                <span class="info-value">${project.estDuration}</span>
                <span class="info-sub">
                    <c:choose>
                        <c:when test="${project.durationNegotiable == true}">협의 가능</c:when>
                        <c:otherwise>-</c:otherwise>
                    </c:choose>
                </span>
            </div>
        </div>

        <div class="condition-mini-row">
            <div class="cond-mini-card">
                <div class="cond-icon-box">
                    <i class="fa-solid fa-handshake"></i>
                </div>
                <div class="cond-info-box">
                    <span class="cond-title">협업 방식</span>
                    <span class="cond-text">
                        <c:choose>
                            <c:when test="${project.communicateMethod eq 'ONLINE'}">온라인 (화상)</c:when>
                            <c:when test="${project.communicateMethod eq 'OFFLINE'}">오프라인 (대면)</c:when>
                            <c:otherwise>협의 필요</c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </div>

            <div class="cond-mini-card">
                <div class="cond-icon-box">
                    <i class="fa-solid fa-coins"></i>
                </div>
                <div class="cond-info-box">
                    <span class="cond-title">대금 지급 방법</span>
                    <span class="cond-text">
                        <c:choose>
                            <c:when test="${project.paymentMethod eq 'LUMP_SUM'}">일괄 지급</c:when>
                            <c:when test="${project.paymentMethod eq 'INSTALLMENT'}">분할 지급</c:when>
                        </c:choose>
                    </span>
                </div>
            </div>

            <div class="cond-mini-card">
                <div class="cond-icon-box">
                    <i class="fa-solid fa-pen-to-square"></i>
                </div>
                <div class="cond-info-box">
                    <span class="cond-title">무상 수정 가능 횟수</span>
                    <span class="cond-text">
                        <c:choose>
                            <c:when test="${project.maxRevisionCount > 0}">${project.maxRevisionCount}회</c:when>
                            <c:otherwise>없음</c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </div>
        </div>

        <div class="anchor-nav">
            <a href="#section-desc" class="anchor-item active">프로젝트 개요</a>
            <a href="#section-position" class="anchor-item">모집 분야</a>
            <a href="#section-skill" class="anchor-item">기술 스택</a>
        </div>

        <div id="section-desc" class="content-section">
            <h3 class="section-head"><i class="fa-solid fa-circle-info"></i> 프로젝트 개요</h3>
            <div class="section-body">
                <c:out value="${project.description}" escapeXml="false"/>
            </div>
        </div>

        <div id="section-position" class="content-section">
            <h3 class="section-head"><i class="fa-solid fa-briefcase"></i> 모집 분야</h3>
            <div class="tech-chips">
                <c:set var="hasPosition" value="false" />
                <c:if test="${not empty project.stacks}">
                    <c:forEach var="stack" items="${project.stacks}">
                        <c:if test="${stack.category eq 'POSITION'}">
                            <c:set var="hasPosition" value="true" />
                            <span class="tech-chip" style="border-color:rgba(23, 49, 96, .14);background: rgba(23, 49, 96, .06);color: rgba(23, 49, 96, .92);">
                                    ${stack.stackName}
                            </span>
                        </c:if>
                    </c:forEach>
                </c:if>
                <c:if test="${not hasPosition}">
                    <span class="tech-chip" style="background:#f5f5f5; color:#999;">기타/잘 모르겠어요(협의)</span>
                </c:if>
            </div>
        </div>

        <div id="section-skill" class="content-section">
            <h3 class="section-head"><i class="fa-solid fa-code"></i> 필요 기술 스택</h3>
            <div class="tech-chips">
                <c:set var="hasSkill" value="false" />
                <c:if test="${not empty project.stacks}">
                    <c:forEach var="stack" items="${project.stacks}">
                        <c:if test="${stack.category eq 'SKILL'}">
                            <c:set var="hasSkill" value="true" />
                            <span class="tech-chip">
                                    ${stack.stackName}
                            </span>
                        </c:if>
                    </c:forEach>
                </c:if>
                <c:if test="${not hasSkill}">
                    <span class="tech-chip" style="background:#f5f5f5; color:#999;">전문가와 협의(잘 모르겠어요)</span>
                </c:if>
            </div>
        </div>

        <div class="content-section">
            <div class="proficiency-box">
                <span>
                    <i class="fa-solid fa-user-graduate"></i>
                    <c:choose>
                        <c:when test="${project.minLevel == 1}">Lv.1 초급 (Junior)</c:when>
                        <c:when test="${project.minLevel == 2}">Lv.2 중급 (Middle)</c:when>
                        <c:when test="${project.minLevel == 3}">Lv.3 고급 (Senior)</c:when>
                        <c:when test="${project.minLevel == 4}">Lv.4 특급 (Lead)</c:when>
                        <c:when test="${project.minLevel == 5}">Lv.5 마스터 (Master)</c:when>
                        <c:otherwise>숙련도 무관</c:otherwise>
                    </c:choose>
                </span>
                <span class="proficiency-divider"></span>
                <span>
                    <i class="fa-solid fa-briefcase"></i>
                    <c:choose>
                        <c:when test="${project.minYear > 0}">${project.minYear}년 이상</c:when>
                        <c:otherwise>경력 무관</c:otherwise>
                    </c:choose>
                </span>
            </div>
        </div>

        <div id="section-condition" class="content-section">
            <h3 class="section-head"><i class="fa-solid fa-file-contract"></i> 수정 및 재진행 정책</h3>
            <div class="policy-box">
                <span class="policy-label">[정책 내용]</span>
                <c:out value="${not empty project.changePolicy ? project.changePolicy : '별도의 수정 정책이 기재되지 않았습니다.'}" escapeXml="false"/>
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
                    <span class="status-count">
                        <span id="applyCount">${project.applicantCount}</span>명 지원 중
                    </span>
                </div>
            </div>

            <c:choose>
                <c:when test="${empty loginUserId}">
                    <button type="button" class="btn-primary" onclick="alert('로그인이 필요한 서비스입니다.'); location.href='/login';">
                        <i class="fa-solid fa-paper-plane"></i> 지원하기
                    </button>
                </c:when>
                <c:when test="${loginUserType eq 'CLIENT'}">
                    <c:choose>
                        <c:when test="${loginUserId eq project.clientId}">
                            <button type="button" class="btn-primary" style="background:#333;" onclick="location.href='${pageContext.request.contextPath}/client/manage'">
                                <i class="fa-solid fa-gear"></i> 프로젝트 관리
                            </button>
                        </c:when>
                        <c:otherwise>
                            <button type="button" class="btn-primary" onclick="alert('클라이언트는 프로젝트에 지원할 수 없습니다.');">
                                <i class="fa-solid fa-paper-plane"></i> 지원하기
                            </button>
                        </c:otherwise>
                    </c:choose>
                </c:when>
                <c:when test="${loginUserType eq 'FREELANCER'}">
                    <c:choose>
                        <c:when test="${isApplied}">
                            <button type="button" class="btn-primary cancel" id="btnApplyToggle" onclick="toggleApply()">
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

            <button type="button" class="btn-outline" id="btnChat"
                    onclick="moveToChat()"
            ${isApplied ? '' : 'disabled'}>
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
                    <i class="${isWishlisted ? 'fa-solid' : 'fa-regular'} fa-bookmark"></i>
                    <span>북마크 (찜하기)</span>
                </button>
            </div>
        </div>

        <div class="sidebar-box">
            <span class="client-label">클라이언트 정보</span>
            <div class="client-profile">
                <div class="cp-img" style="position: relative; overflow: hidden;">
                    <div style="width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; position: absolute; top:0; left:0; z-index: 1;">
                        <c:choose>
                            <c:when test="${project.clientType eq 'CORPORATION'}">
                                <i class="fa-regular fa-building"></i>
                            </c:when>
                            <c:otherwise>
                                <i class="fa-solid fa-user-tie"></i>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <c:if test="${not empty project.clientProfileImageUrl}">
                        <img src="${pageContext.request.contextPath}${project.clientProfileImageUrl}"
                             alt="프로필"
                             style="width: 100%; height: 100%; object-fit: cover; position: absolute; top: 0; left: 0; z-index: 2; background-color: #fff;"
                             onerror="this.style.display='none'">
                    </c:if>
                </div>
                <div class="cp-info">
                    <div>
                        <c:choose>
                            <c:when test="${project.clientType eq 'CORPORATION' and not empty project.companyName}">
                                ${project.companyName}
                            </c:when>
                            <c:otherwise>
                                ${project.clientName}
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <span>
                        <c:choose>
                            <c:when test="${project.clientType eq 'CORPORATION'}">
                                법인 사업자 / ${not empty project.companyIndustry ? project.companyIndustry : '업종 미기재'}
                            </c:when>
                            <c:otherwise>개인 클라이언트 / -</c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </div>

            <div class="cp-stats">
                <div class="cp-stat-item">
                    <span class="cp-stat-label">누적 계약</span>
                    <span class="cp-stat-val">
                        ${not empty project.completedContractCount ? project.completedContractCount : '-'} 건
                    </span>
                </div>
                <div class="cp-stat-item" style="border-left:1px solid #eee; padding-left:12px;">
                    <span class="cp-stat-label">평점</span>
                    <span class="cp-stat-val rating">
                        <c:choose>
                            <c:when test="${not empty project.clientAvgRating and project.clientAvgRating > 0}">
                                <i class="fa-solid fa-star" style="color:#F39C12; font-size:12px;"></i> ${project.clientAvgRating}
                            </c:when>
                            <c:otherwise>
                                - / 5.0
                            </c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/project/detail.js"></script>

</body>
</html>