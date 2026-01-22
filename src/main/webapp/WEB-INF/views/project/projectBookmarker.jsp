<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>북마크한 프로젝트</title>

    <!-- 대시보드와 동일 CSS 재사용: 지금은 JSP 안 style 복붙 -->
    <style>
        :root{
            --bg:#f8fafc;
            --card:#ffffff;
            --text:#111827;
            --muted:#6b7280;
            --line:#eef2f7;

            --primary:#5c3cce;
            --chip-skill-bg:#eef2ff;
            --chip-skill-fg:#3730a3;

            --chip-pos-bg:#ecfeff;
            --chip-pos-fg:#0f766e;

            --danger:#dc2626;
            --shadow:0 10px 28px rgba(15,23,42,0.08);
            --radius:18px;
        }

        *{ box-sizing:border-box; }
        body{
            margin:0;
            font-family:Pretendard, Arial, sans-serif;
            background:var(--bg);
            color:var(--text);
        }

        .dashboard-wrap{
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 16px;
        }

        /* 검색 */
        .search-box{
            display:flex;
            gap:10px;
            align-items:center;
            flex-wrap:wrap;
            margin-bottom: 18px;
            justify-content:center;
        }

        .search-box input[type="text"]{
            width: 420px;
            max-width: 100%;
            padding: 10px 12px;
            border-radius: 12px;
            border:1px solid #d1d5db;
            outline:none;
            background:#fff;
            font-weight:700;
        }

        .search-box button{
            padding: 10px 14px;
            border:none;
            border-radius: 12px;
            background: var(--primary);
            color:#fff;
            font-weight:900;
            cursor:pointer;
        }

        .search-box label{
            display:flex;
            align-items:center;
            gap:6px;
            font-size:13px;
            font-weight:800;
            color:#374151;
            user-select:none;
        }

        /* 리스트 */
        .project-list{
            display:flex;
            flex-direction:column;
            gap:16px;
        }

        .project-card{
            width:100%;
            background:var(--card);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            padding: 18px 20px;
            display:flex;
            gap: 22px;
            align-items:stretch;
            cursor:pointer;
        }

        .left{
            flex:1;
            display:flex;
            flex-direction:column;
            gap:10px;
            min-width:0;
        }

        .title{
            font-size: 23px;
            font-weight: 950;
            line-height:1.35;
            white-space:nowrap;
            overflow:hidden;
            text-overflow:ellipsis;
        }

        .chips{
            display:flex;
            flex-wrap:wrap;
            gap:6px;
        }

        .chip{
            padding: 5px 10px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 900;
            background: var(--chip-skill-bg);
            color: var(--chip-skill-fg);
        }

        .chip.position{
            background: var(--chip-pos-bg);
            color: var(--chip-pos-fg);
        }

        /* 오른쪽 */
        .right{
            width: 260px;
            border-left: 1px solid var(--line);
            padding-left: 18px;
            display:flex;
            flex-direction:column;
            justify-content:space-between;
            align-items:flex-end;
            gap: 10px;
        }

        /* 북마크 버튼 */
        .bookmark-btn{
            width: 36px;
            height: 36px;
            border-radius: 12px;
            border: 1px solid #e5e7eb;
            background:#fff;
            display:inline-flex;
            align-items:center;
            justify-content:center;
            cursor:pointer;
            transition: all .15s ease;
        }
        .bookmark-btn:hover{
            border-color:#c7d2fe;
            transform: translateY(-1px);
        }
        .bookmark-btn svg{
            width: 18px;
            height: 18px;
            fill: none;
            stroke: #6b7280;
            stroke-width: 2;
        }
        .bookmark-btn.is-active svg{
            fill: #5c3cce;
            stroke: #5c3cce;
        }

        .right-mid{
            width:100%;
            display:flex;
            flex-direction:column;
            align-items:flex-end;
            gap:6px;
        }

        .dday{
            font-weight: 950;
            font-size: 16px;
            color: var(--danger);
        }

        .applicants{
            font-weight: 900;
            font-size: 13px;
            color: #6b7280;
        }

        .right-bottom{
            width:100%;
            display:flex;
            justify-content:space-between;
            align-items:flex-end;
            gap:12px;
        }

        .duration{
            font-weight: 900;
            font-size: 12px;
            color: #6b7280;
            text-align:left;
            line-height:1.2;
            white-space:nowrap;
        }

        .budget{
            font-weight: 950;
            font-size: 22px;
            letter-spacing: -0.2px;
            white-space:nowrap;
        }

        .empty{
            background:#fff;
            padding: 22px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            font-weight: 900;
            color:#6b7280;
            text-align:center;
        }

        /* 회사/개인 배지 */
        .owner-name{ margin-bottom: 4px; }

        .badge{
            display:inline-flex;
            align-items:center;
            gap:6px;
            padding:4px 10px;
            border-radius:999px;
            font-size:12px;
            font-weight:900;
            white-space:nowrap;
        }
        .badge.company{
            background:#eef2ff;
            color:#3730a3;
            border:1px solid #c7d2fe;
        }
        .badge.personal{
            background:#ecfeff;
            color:#0f766e;
            border:1px solid #99f6e4;
        }

        @media (max-width: 860px){
            .project-card{ flex-direction:column; }
            .right{
                width:100%;
                border-left:none;
                border-top:1px solid var(--line);
                padding-left:0;
                padding-top:12px;
                align-items:flex-start;
            }
            .right-mid{ align-items:flex-start; }
            .right-bottom{ justify-content:space-between; }
            .search-box{ justify-content:flex-start; }
        }
    </style>
</head>

<body>
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
