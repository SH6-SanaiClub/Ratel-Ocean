<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>북마크한 프로젝트</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/project/bookmarker.css">
</head>

<body>
<jsp:include page="/WEB-INF/views/common/headerBase.jsp" />
<div class="dashboard-wrap">

    <!-- 북마크 페이지 상단: 검색만 -->
    <form class="search-box" method="get" action="${pageContext.request.contextPath}/project/bookmark">
        <input type="text"
               name="keyword"
               placeholder="프로젝트 제목 검색"
               value="${fn:escapeXml(keyword)}"/>

        <button type="submit">검색</button>
    </form>

    <!-- 리스트 -->
    <div class="project-list">

        <c:if test="${empty projectList}">
            <div class="empty">북마크한 프로젝트가 없습니다.</div>
        </c:if>

        <c:forEach var="p" items="${projectList}">
            <div class="project-card"
                 onclick="location.href='${pageContext.request.contextPath}/project/detail?projectId=${p.projectId}'">

                <!-- LEFT -->
                <div class="left">

                    <!-- 회사명 / 개인 클라이언트 (북마크 쿼리에 companyName/clientName 없으면 아래 블록은 안 뜸) -->
                    <div class="owner-name">
                        <c:choose>
                            <c:when test="${not empty p.companyName}">
                                <span class="badge company">🏢 ${p.companyName}</span>
                            </c:when>
                            <c:when test="${not empty p.clientName}">
                                <span class="badge personal">👤 ${p.clientName}</span>
                            </c:when>
                        </c:choose>
                    </div>

                    <!-- 포지션 -->
                    <div class="chips">
                        <c:if test="${not empty p.stacks}">
                            <c:forEach var="s" items="${p.stacks}">
                                <c:if test="${not empty s.category and s.category eq 'POSITION'}">
                                    <span class="chip position">${s.stackName}</span>
                                </c:if>
                            </c:forEach>
                        </c:if>
                    </div>

                    <div class="title">${p.title}</div>

                    <!-- 스킬 -->
                    <div class="chips">
                        <c:if test="${not empty p.stacks}">
                            <c:forEach var="s" items="${p.stacks}">
                                <c:if test="${not empty s.category and s.category eq 'SKILL'}">
                                    <span class="chip">
                                        ${s.stackName}
                                        <c:if test="${s.stackLevel != null}">
                                            Lv.${s.stackLevel}
                                        </c:if>
                                    </span>
                                </c:if>
                            </c:forEach>
                        </c:if>
                    </div>

                </div>

                <!-- RIGHT -->
                <div class="right">

                    <!-- 북마크 -->
                    <button type="button"
                            class="bookmark-btn ${p.bookmarked ? 'is-active' : ''}"
                            data-project-id="${p.projectId}"
                            title="북마크"
                            onclick="event.preventDefault(); event.stopPropagation();">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M6 3h12a1 1 0 0 1 1 1v17l-7-4-7 4V4a1 1 0 0 1 1-1z"></path>
                        </svg>
                    </button>

                    <!-- D-day + 지원자 -->
                    <div class="right-mid">
                        <div class="dday">
                            <c:choose>
                                <c:when test="${p.dday >= 0}">마감 D-${p.dday}</c:when>
                                <c:otherwise>마감</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="applicants">지원자 ${p.applicantCount}명</div>
                    </div>

                    <!-- 기간 + 예산 -->
                    <div class="right-bottom">
                        <div class="duration">예상 기간<br/>${p.estDuration}</div>
                        <div class="budget">
                            <fmt:formatNumber value="${p.budget / 10000}" maxFractionDigits="0"/>만원
                        </div>
                    </div>

                </div>

            </div>
        </c:forEach>

    </div>

</div>

<script>
    document.addEventListener("DOMContentLoaded", () => {
        document.querySelectorAll(".bookmark-btn").forEach((btn) => {
            btn.addEventListener("click", async (e) => {
                e.preventDefault();
                e.stopPropagation();

                const projectId = btn.dataset.projectId;

                try {
                    const res = await fetch("${pageContext.request.contextPath}/project/bookmark/toggle", {
                        method: "POST",
                        headers: {"Content-Type":"application/x-www-form-urlencoded; charset=UTF-8"},
                        body: new URLSearchParams({ projectId })
                    });

                    const data = await res.json();
                    if (!data.ok) {
                        alert(data.message === "LOGIN_REQUIRED" ? "로그인이 필요합니다." : "실패");
                        return;
                    }

                    // 북마크 페이지에서는 해제되면 카드 제거
                    if (!data.bookmarked) {
                        const card = btn.closest(".project-card");
                        if (card) card.remove();

                        // 다 지워졌으면 empty 메시지 표시
                        if (document.querySelectorAll(".project-card").length === 0) {
                            const list = document.querySelector(".project-list");
                            list.innerHTML = '<div class="empty">북마크한 프로젝트가 없습니다.</div>';
                        }
                        return;
                    }

                    btn.classList.toggle("is-active", data.bookmarked);
                } catch (err) {
                    console.error(err);
                    alert("북마크 처리 중 오류");
                }
            });
        });
    });
</script>

</body>
</html>
