<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>프로젝트 대시보드</title>

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
        }

        .search-box input[type="text"]{
            width: 340px;
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

        /* 리스트(한 줄 한 카드) */
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
        }

        /* 카드 전체를 링크로 쓸 때 */
        .project-link{
            display:block;
            text-decoration:none;
            color: inherit;
        }
        .project-link:focus-visible{
            outline: 3px solid rgba(92,60,206,0.25);
            border-radius: var(--radius);
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

        .meta{
            display:flex;
            gap: 12px;
            flex-wrap:wrap;
            font-size: 13px;
            color: #4b5563;
            font-weight: 800;
        }

        /* 오른쪽 영역 */
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

        .right-top{
            width:100%;
            display:flex;
            justify-content:flex-end;
            align-items:center;
            gap:10px;
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
        /* 북마크 활성화(나중에 JS/서버 연동 시 클래스만 붙이면 됨) */
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

        /* 페이징 */
        .pagination{
            display:flex;
            justify-content:center;
            align-items:center;
            gap:6px;
            margin: 24px 0 6px;
            flex-wrap:wrap;
        }

        .page-link{
            display:inline-flex;
            align-items:center;
            justify-content:center;
            height:36px;
            min-width:36px;
            padding:0 12px;
            border-radius:12px;
            border:1px solid #e5e7eb;
            background:#fff;
            color:#111827;
            font-weight:900;
            text-decoration:none;
        }

        .page-link:hover{ border-color:#c7d2fe; }
        .page-link.active{
            background: var(--primary);
            border-color: var(--primary);
            color:#fff;
        }
        .page-link.disabled{
            opacity:.45;
            pointer-events:none;
        }

        .hint{
            text-align:center;
            color:#6b7280;
            font-size:12px;
            font-weight:800;
            margin-bottom: 14px;
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
            .right-top{ justify-content:flex-end; }
            .right-mid{ align-items:flex-start; }
            .right-bottom{ justify-content:space-between; }
        }

        /* 상단 요약 카드 */
        .summary-grid{
            display:grid;
            grid-template-columns: 1fr 1fr;
            gap:14px;
            margin: 6px 0 18px;
        }

        .summary-card{
            background: var(--card);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            padding: 18px 20px;
            display:flex;
            justify-content:space-between;
            align-items:center;
        }

        .summary-title{
            font-size: 13px;
            font-weight: 900;
            color: var(--muted);
            margin-bottom: 6px;
        }

        .summary-value{
            font-size: 34px;
            font-weight: 950;
            letter-spacing: -0.6px;
        }

        .summary-unit{
            font-size: 14px;
            font-weight: 900;
            color: var(--muted);
            margin-left: 6px;
        }

        .summary-badge{
            width: 38px;
            height: 38px;
            border-radius: 14px;
            display:flex;
            align-items:center;
            justify-content:center;
            font-weight: 950;
            border: 1px solid #e5e7eb;
            background:#fff;
        }

        .summary-badge.danger{
            border-color: rgba(220,38,38,0.25);
            color: var(--danger);
        }

        @media (max-width: 860px){
            .summary-grid{ grid-template-columns: 1fr; }
        }


        /* 요약카드 클릭/선택 강조 */
        .summary-link{ text-decoration:none; color:inherit; display:block; }
        .summary-card.is-active{
            border: 2px solid rgba(92,60,206,0.35);
            box-shadow: 0 14px 34px rgba(92,60,206,0.12);
            transform: translateY(-1px);
        }
        .summary-card.is-active .summary-title{ color: #4f46e5; }
        .summary-card.is-active .summary-badge{
            border-color: rgba(92,60,206,0.35);
        }

        /* 회사 / 개인 표시 */
        .owner-name{
            margin-bottom: 4px;
        }

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

        .register-area { display: flex; justify-content: flex-end; margin-bottom: 20px; }
        .btn-register {
            padding: 12px 24px; background: var(--primary); color: #fff;
            border-radius: 14px; text-decoration: none; font-weight: 900;
        }

    </style>
</head>

<body>

<div class="dashboard-wrap">
    <c:if test="${isClient}">
        <div class="register-area">
            <a href="${pageContext.request.contextPath}/project/create" class="btn-register">
                프로젝트 등록하기
            </a>
        </div>
    </c:if>

    <!--  상단 요약 -->
    <div class="summary-grid">

        <!-- today 토글 -->
        <a class="summary-link"
           href="${pageContext.request.contextPath}/project/dashboard?summary=${summary eq 'today' ? 'all' : 'today'}&page=1&size=${size}&onlyActive=${onlyActive}&keyword=${fn:escapeXml(keyword)}">
            <div class="summary-card ${summary eq 'today' ? 'is-active' : ''}">
                <div>
                    <div class="summary-title">오늘의 신규 프로젝트</div>
                    <div>
                        <span class="summary-value">${empty todayNewCount ? 0 : todayNewCount}</span>
                        <span class="summary-unit">건</span>
                    </div>
                </div>
                <div class="summary-badge">+</div>
            </div>
        </a>
        <!-- deadline7 토글 -->
        <a class="summary-link"
           href="${pageContext.request.contextPath}/project/dashboard?summary=${summary eq 'deadline7' ? 'all' : 'deadline7'}&page=1&size=${size}&onlyActive=${onlyActive}&keyword=${fn:escapeXml(keyword)}">
            <div class="summary-card ${summary eq 'deadline7' ? 'is-active' : ''}">
                <div>
                    <div class="summary-title">마감 임박 (7일 이내)</div>
                    <div>
                    <span class="summary-value" style="color:var(--danger);">
                        ${empty deadline7Count ? 0 : deadline7Count}
                    </span>
                        <span class="summary-unit">건</span>
                    </div>
                </div>
                <div class="summary-badge danger">!</div>
            </div>
        </a>

    </div>



    <!-- 검색 -->
    <form class="search-box" method="get" action="${pageContext.request.contextPath}/project/dashboard">
        <input type="text"
               name="keyword"
               placeholder="프로젝트 제목 검색"
               value="${fn:escapeXml(keyword)}"/>

        <label>
            <input type="checkbox" name="onlyActive" value="true"
                   <c:if test="${onlyActive}">checked</c:if> />
            마감된 프로젝트 보기
        </label>

        <input type="hidden" name="size" value="${empty size ? 10 : size}"/>
        <input type="hidden" name="summary" value="${empty summary ? 'all' : summary}"/>

        <button type="submit">검색</button>
    </form>

    <!-- 리스트 -->
    <div class="project-list">

        <c:if test="${empty projectList}">
            <div class="empty">조건에 맞는 프로젝트가 없습니다.</div>
        </c:if>

        <c:forEach var="p" items="${projectList}">

                <div class="project-card" onclick="location.href='${pageContext.request.contextPath}/project/detail?projectId=${p.projectId}&page=${page}&size=${size}&onlyActive=${onlyActive}&keyword=${fn:escapeXml(keyword)}'">

                    <!-- LEFT -->
                    <div class="left">

                        <!-- 회사명 / 개인 클라이언트 -->
                        <div class="owner-name">
                            <c:choose>
                                <c:when test="${not empty p.companyName}">
                                    <span class="badge company">🏢 ${p.companyName}</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge personal">👤 ${p.clientName}</span>
                                </c:otherwise>
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

                        <!-- 예상기간(예산 왼쪽) + 예산(우측 아래) -->
                        <div class="right-bottom">
                            <div class="duration">예상 기간<br/>${p.estDuration}</div>
                            <div class="budget">
                                <fmt:formatNumber value="${p.budget / 10000}"
                                                  maxFractionDigits="0"/>만원
                            </div>
                        </div>

                    </div>

                </div>
<%--            </a>--%>
        </c:forEach>

    </div>

    <!-- 페이징 -->
    <c:if test="${totalPages > 1}">
        <div class="pagination">

            <!-- « 이전 블록 -->
            <c:choose>
                <c:when test="${hasPrevBlock}">
                    <a class="page-link"
                       href="${pageContext.request.contextPath}/project/dashboard?page=${prevBlockPage}&size=${size}&onlyActive=${onlyActive}&keyword=${fn:escapeXml(keyword)}&summary=${summary}">&laquo;</a>
                </c:when>
                <c:otherwise>
                    <span class="page-link disabled">&laquo;</span>
                </c:otherwise>
            </c:choose>

            <!-- ‹ 이전 페이지 -->
            <c:choose>
                <c:when test="${page > 1}">
                    <a class="page-link"
                       href="${pageContext.request.contextPath}/project/dashboard?page=${page-1}&size=${size}&onlyActive=${onlyActive}&keyword=${fn:escapeXml(keyword)}&summary=${summary}">&lsaquo;</a>
                </c:when>
                <c:otherwise>
                    <span class="page-link disabled">&lsaquo;</span>
                </c:otherwise>
            </c:choose>

            <!-- 페이지 번호 -->
            <c:forEach var="pno" begin="${startPage}" end="${endPage}">
                <a class="page-link ${pno == page ? 'active' : ''}"
                   href="${pageContext.request.contextPath}/project/dashboard?page=${pno}&size=${size}&onlyActive=${onlyActive}&keyword=${fn:escapeXml(keyword)}&summary=${summary}">${pno}</a>
            </c:forEach>

            <!-- › 다음 페이지 -->
            <c:choose>
                <c:when test="${page < totalPages}">
                    <a class="page-link"
                       href="${pageContext.request.contextPath}/project/dashboard?page=${page+1}&size=${size}&onlyActive=${onlyActive}&keyword=${fn:escapeXml(keyword)}&summary=${summary}">&rsaquo;</a>
                </c:when>
                <c:otherwise>
                    <span class="page-link disabled">&rsaquo;</span>
                </c:otherwise>
            </c:choose>

            <!-- » 다음 블록 -->
            <c:choose>
                <c:when test="${hasNextBlock}">
                    <a class="page-link"
                       href="${pageContext.request.contextPath}/project/dashboard?page=${nextBlockPage}&size=${size}&onlyActive=${onlyActive}&keyword=${fn:escapeXml(keyword)}&summary=${summary}">&raquo;</a>
                </c:when>
                <c:otherwise>
                    <span class="page-link disabled">&raquo;</span>
                </c:otherwise>
            </c:choose>

        </div>

        <div class="hint">${page} / ${totalPages} 페이지</div>
    </c:if>


</div>

<script>
    document.addEventListener("DOMContentLoaded", () => {
        // 서버에서 넘어온 알림 메시지가 있으면 실행
        const alertMsg = "${alertMsg}";
        if (alertMsg) {
            alert(alertMsg);
        }

        document.querySelectorAll(".bookmark-btn").forEach((btn) => {
            btn.addEventListener("click", async (e) => {
                e.preventDefault();
                e.stopPropagation();

                const projectId = btn.dataset.projectId;
                console.log("bookmark clicked", projectId);

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
