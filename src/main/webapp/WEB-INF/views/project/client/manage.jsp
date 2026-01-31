<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>프로젝트 관리 | Ratel Ocean</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/project/manage.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/headerBase.jsp" />

<div class="container">

    <div class="page-header">
        <h2 class="page-title">내 프로젝트 및 지원자 관리</h2>
        <button type="button" class="btn-new-project"
                onclick="location.href='${pageContext.request.contextPath}/project/create'">
            <i class="fa-solid fa-plus"></i> 새 프로젝트 등록
        </button>
    </div>

    <%-- [계산 로직] --%>
    <%-- 1. 새로운 지원자 수 합계 (DTO에 추가한 newApplicantCount 사용) --%>
    <c:set var="totalNewApplicants" value="0" />
    <c:forEach var="p" items="${recruitingProjects}">
        <c:set var="totalNewApplicants" value="${totalNewApplicants + (p.newApplicantCount != null ? p.newApplicantCount : 0)}" />
    </c:forEach>

    <%-- 2. 지급 요청 건수 합계 --%>
    <c:set var="totalPaymentRequests" value="0" />
    <c:forEach var="p" items="${ongoingProjects}">
        <c:if test="${p.hasPaymentRequest}">
            <c:set var="totalPaymentRequests" value="${totalPaymentRequests + 1}" />
        </c:if>
    </c:forEach>

    <%-- 3. 작성해야 할 리뷰 건수 합계 --%>
    <c:set var="totalPendingReviews" value="0" />
    <c:forEach var="p" items="${completedProjects}">
        <c:if test="${empty p.clientRating}">
            <c:set var="totalPendingReviews" value="${totalPendingReviews + 1}" />
        </c:if>
    </c:forEach>

    <div class="manage-grid-layout">

        <div class="card">
            <div class="panel-header-text" style="display:flex; justify-content:space-between; align-items:center;">
                <span>프로젝트 목록</span>
                <button type="button" class="btn-icon"
                        onclick="location.href='${pageContext.request.contextPath}/project/bookmark'"
                        title="북마크 바로가기"
                        style="width:auto; padding:0 10px; height:28px; border-radius:6px; font-size:12px; font-weight:700; gap:5px; display:flex; align-items:center; background:#fff; cursor:pointer;">
                    <i class="fa-solid fa-bookmark"></i> 북마크
                </button>
            </div>


            <div class="project-summary-bar">
                <span class="summary-item">새로운 지원자 <strong>${totalNewApplicants}</strong>명</span>
                <span class="divider">|</span>
                <span class="summary-item">지급 요청 <strong>${totalPaymentRequests}</strong>건</span>
                <span class="divider">|</span>
                <span class="summary-item">리뷰 작성 <strong>${totalPendingReviews}</strong>건</span>
            </div>

            <div class="project-tabs">
                <button type="button" class="tab-btn active" onclick="switchProjectTab('RECRUITING', this)">
                    모집 중 <span class="tab-count">${recruitingProjects.size()}</span>
                </button>
                <button type="button" class="tab-btn" onclick="switchProjectTab('ONGOING', this)">
                    진행 중 <span class="tab-count">${ongoingProjects.size()}</span>
                </button>
                <button type="button" class="tab-btn" onclick="switchProjectTab('COMPLETED', this)">
                    완료 <span class="tab-count">${completedProjects.size()}</span>
                </button>
            </div>

            <div class="scroll-container">
                <div id="list-RECRUITING" class="project-list-group">
                    <c:forEach var="p" items="${recruitingProjects}">
                        <div class="custom-list-item" onclick="loadApplicants(${p.projectId}, this)">
                            <div style="display:flex; justify-content:space-between; align-items:flex-start;">
                                <span class="status-tag tag-recruiting">D-${p.dDay}</span>

                                    <%-- New 배지 로직 --%>
                                <c:choose>
                                    <c:when test="${p.newApplicantCount > 0}">
                                        <span class="app-count-badge" style="background:#E3F2FD; color:#1F7A8C; font-weight:700;">
                                            New ${p.newApplicantCount}
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="app-count-badge">지원자 ${p.applicantCount}</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <span class="item-main-text" style="margin-top:5px;">${p.title}</span>
                        </div>
                    </c:forEach>
                    <c:if test="${empty recruitingProjects}">
                        <div class="empty-list-msg">모집 중인 프로젝트가 없습니다.</div>
                    </c:if>
                </div>

                <div id="list-ONGOING" class="project-list-group" style="display:none;">
                    <c:forEach var="p" items="${ongoingProjects}">
                        <div class="custom-list-item" onclick="loadProjectProgress(${p.projectId}, this)">
                            <div style="display:flex; align-items:center;">
                                <span class="status-tag tag-ongoing">진행중</span>
                                <c:if test="${p.hasPaymentRequest}">
                                    <span class="payment-req-badge" style="background:#FFEBEE; color:#D32F2F; font-size:11px; padding:2px 6px; border-radius:10px; font-weight:700; margin-left:5px;">
                                        💰 지급 요청
                                    </span>
                                </c:if>
                            </div>
                            <span class="item-main-text" style="margin-top:5px;">${p.title}</span>
                            <span style="font-size:12px; color:#999; display:block; margin-top:5px;">
                                계약일: ${p.createdAt.year + 1900}.${p.createdAt.month + 1 < 10 ? '0' : ''}${p.createdAt.month + 1}.${p.createdAt.date < 10 ? '0' : ''}${p.createdAt.date}
                            </span>
                        </div>
                    </c:forEach>
                    <c:if test="${empty ongoingProjects}">
                        <div class="empty-list-msg">진행 중인 프로젝트가 없습니다.</div>
                    </c:if>
                </div>

                <div id="list-COMPLETED" class="project-list-group" style="display:none;">
                    <c:forEach var="p" items="${completedProjects}">
                        <c:choose>
                            <c:when test="${empty p.clientRating}">
                                <div class="custom-list-item" onclick="loadCompletedProject(${p.projectId}, this)">
                                    <span class="status-tag tag-completed">종료됨</span>
                                    <span class="item-main-text" style="margin-top:5px; color:#aaa; text-decoration:line-through;">${p.title}</span>
                                    <div style="font-size:11px; color:#1F7A8C; margin-top:5px; font-weight:700;">
                                        <i class="fa-regular fa-pen-to-square"></i> 리뷰 작성하기
                                    </div>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="custom-list-item" style="background:#f8f9fa; border-color:#eee; cursor:default;">
                                    <div style="display:flex; justify-content:space-between;">
                                        <span class="status-tag tag-completed">종료됨</span>
                                        <span style="font-size:11px; font-weight:700; color:#4CAF50;">✔ 작성완료</span>
                                    </div>
                                    <span class="item-main-text" style="margin-top:5px; color:#aaa;">${p.title}</span>
                                    <div style="margin-top:8px; padding:8px; background:#fff; border:1px solid #eee; border-radius:6px; text-align:center;">
                                        <div style="font-size:11px; color:#666; margin-bottom:5px;">
                                            리뷰 작성 완료!<br>리뷰관리 창에서 확인해보세요.
                                        </div>
                                        <button type="button"
                                                onclick="location.href='${pageContext.request.contextPath}/client/mypage'; event.stopPropagation();"
                                                style="width:100%; padding:6px; background:#1F7A8C; color:#fff; border:none; border-radius:4px; font-size:11px; cursor:pointer; font-weight:700;">
                                            리뷰 관리로 이동
                                        </button>
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                    <c:if test="${empty completedProjects}">
                        <div class="empty-list-msg">완료된 프로젝트가 없습니다.</div>
                    </c:if>
                </div>
            </div>
        </div>

        <div class="card" id="defaultCenterPanel">
            <div class="panel-header-column">
                <div style="display:flex; justify-content:space-between; align-items:center;">
                    <span>지원자 목록</span>
                    <span id="applicantCountBadge" style="font-size:14px; color:#1F7A8C; font-weight:700;">0명</span>
                </div>
            </div>
            <div id="projectControlBar" style="display:none; background:#f9f9f9; padding:15px; border-radius:10px; margin-bottom:15px; flex-direction:column; gap:12px; border:1px solid #eee;">
                <div style="display:flex; justify-content:space-between; align-items:center;">
                    <span id="selectedProjectTitle" style="font-size:15px; font-weight:700; color:#333; max-width:260px; overflow:hidden; white-space:nowrap; text-overflow:ellipsis;"></span>
                </div>

                <div class="btn-icon-group" style="display:grid; grid-template-columns: 1fr 1fr 1fr; gap:8px; width:100%;">
                    <button class="btn-icon" onclick="goToProjectDetail()" style="width:100%; height:36px; font-size:12px; font-weight:700; gap:5px;">
                        <i class="fa-solid fa-arrow-up-right-from-square"></i> 바로가기
                    </button>
                    <button class="btn-icon" onclick="goEditProject()" style="width:100%; height:36px; font-size:12px; font-weight:700; gap:5px;">
                        <i class="fa-solid fa-pen"></i> 수정
                    </button>
                    <button class="btn-icon delete" onclick="deleteProject()" style="width:100%; height:36px; font-size:12px; font-weight:700; gap:5px;">
                        <i class="fa-regular fa-trash-can"></i> 삭제
                    </button>
                </div>
            </div>
            <div id="applicantListArea" class="scroll-container">
                <div style="text-align:center; padding-top:100px; color:#ccc;">
                    <i class="fa-regular fa-folder-open" style="font-size:48px; margin-bottom:15px;"></i>
                    <p>좌측 목록에서<br>프로젝트를 선택해주세요.</p>
                </div>
            </div>
        </div>

        <div class="card" id="defaultRightPanel">
            <div class="panel-header-text" style="display:flex; justify-content:space-between; align-items:center;">
                <span>지원자 프로필</span>
                <button type="button" class="btn-icon" id="btnGoFreelancerProfile" onclick="goFreelancerProfileDetail()"
                        title="전체 프로필 보기"
                        style="width:auto; padding:0 10px; height:28px; border-radius:6px; font-size:12px; font-weight:700; gap:5px; display:none; align-items:center; background:#fff; cursor:pointer;">
                    <i class="fa-solid fa-user-tag"></i> 프로필 상세보기
                </button>
            </div>
            <div id="applicantDetailArea" class="scroll-container">
                <div style="text-align:center; padding-top:100px; color:#ccc;">
                    <i class="fa-regular fa-user" style="font-size:48px; margin-bottom:15px;"></i>
                    <p>지원자를 선택하면<br>상세 정보가 표시됩니다.</p>
                </div>
            </div>
        </div>

        <jsp:include page="/WEB-INF/views/project/client/manageOnGoing.jsp" />
        <jsp:include page="/WEB-INF/views/project/client/manageCompleted.jsp" />

    </div>
</div>

<!-- 지급 비밀번호 인증 모달 -->
<div id="payoutModal" class="payout-modal" style="display:none;">
    <div class="payout-modal-content">
        <div class="payout-modal-header">
            <h3 id="payoutModalTitle">💰 지급 승인</h3>
            <button type="button" class="payout-modal-close" onclick="closePayoutModal()">&times;</button>
        </div>
        <div class="payout-modal-body">
            <p id="payoutModalDesc">프리랜서에게 금액을 지급합니다.</p>
            <div class="payout-input-group">
                <label for="payoutPassword">비밀번호 확인</label>
                <input type="password" id="payoutPassword" placeholder="계정 비밀번호를 입력하세요" autocomplete="off">
                <small class="payout-help-text">본인 확인을 위해 로그인 비밀번호를 입력해주세요.</small>
            </div>
        </div>
        <div class="payout-modal-footer">
            <button type="button" class="btn-cancel" onclick="closePayoutModal()">취소</button>
            <button type="button" id="payoutConfirmBtn" class="btn-confirm" onclick="confirmPayout()">확인</button>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
    const contextPath = "${pageContext.request.contextPath}";
</script>
<script src="${pageContext.request.contextPath}/resources/js/project/manage.js"></script>
</body>
</html>