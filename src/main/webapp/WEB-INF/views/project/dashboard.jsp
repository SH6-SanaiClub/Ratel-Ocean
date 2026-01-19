<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

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

        .header-action {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
        }

        .new-project-btn {
            padding: 12px 20px;
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 12px;
            font-weight: 900;
            cursor: pointer;
            font-size: 14px;
        }

        .new-project-btn:hover {
            opacity: 0.9;
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
            text-decoration:none;
            color:inherit;
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

    </style>
</head>

<body>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="dashboard-wrap">

    <!-- ✅ 상단 요약 -->
    <div class="summary-grid">
        <div class="summary-card">
            <div>
                <div class="summary-title">오늘의 신규 프로젝트</div>
                <div>
                    <span class="summary-value">${empty todayNewCount ? 0 : todayNewCount}</span>
                    <span class="summary-unit">건</span>
                </div>
            </div>
            <div class="summary-badge">+</div>
        </div>

        <div class="summary-card">
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
    </div>


    <!-- 상단 액션 버튼 -->
    <div class="header-action">
        <h1 style="font-size: 28px; font-weight: 950; margin: 0;">프로젝트 찾기</h1>
        <button class="new-project-btn" onclick="location.href='${pageContext.request.contextPath}/project/create'">새 프로젝트 등록</button>
    </div>

    <!-- 🔍 검색 -->
    <form class="search-box" method="get" action="${pageContext.request.contextPath}/project/dashboard">
        <input type="text"
               name="keyword"
               placeholder="프로젝트 제목 검색"
               value="${fn:escapeXml(keyword)}"/>

        <label>
            <input type="checkbox" name="onlyActive" value="true"
                   <c:if test="${onlyActive}">checked</c:if> />
            마감 전만 보기
        </label>

        <input type="hidden" name="size" value="${empty size ? 10 : size}"/>
        <button type="submit">검색</button>
    </form>

    <!-- 📋 리스트 -->
    <div class="project-list">

        <c:if test="${empty projectList}">
            <div class="empty">조건에 맞는 프로젝트가 없습니다.</div>
        </c:if>

        <c:forEach var="p" items="${projectList}">
            <a class="project-card" href="${pageContext.request.contextPath}/project/${p.projectId}">

                <!-- LEFT -->
                <div class="left">



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

                    <!-- 우측 상단: 북마크 -->
                    <div class="right-top">
                        <!-- 북마크: 일단 UI만 (나중에 클릭 이벤트/서버연동하면 됨) -->
                        <button type="button" class="bookmark-btn" title="북마크">
                            <!-- bookmark icon -->
                            <svg viewBox="0 0 24 24" aria-hidden="true">
                                <path d="M6 3h12a1 1 0 0 1 1 1v17l-7-4-7 4V4a1 1 0 0 1 1-1z"></path>
                            </svg>
                        </button>
                    </div>

                    <!-- 우측 중앙: D-day + 지원자 -->
                    <div class="right-mid">
                        <div class="dday">
                            <c:choose>
                                <c:when test="${p.dday >= 0}">마감 D-${p.dday}</c:when>
                                <c:otherwise>마감</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="applicants">지원자 ${p.applicantCount}명</div>
                    </div>

                    <!-- 우측 하단: 예상기간(작게, 예산 왼쪽) + 예산(크게, 우측 아래) -->
                    <div class="right-bottom">
                        <div class="duration">예상 기간<br/>${p.estDuration}</div>
                        <div class="budget">₩${p.budget}</div>
                    </div>

                </div>

            </a>
        </c:forEach>

    </div>

    <!-- ✅ 페이징 -->
    <c:if test="${totalPages > 1}">
        <div class="pagination">

            <!-- « 이전 블록 -->
            <c:choose>
                <c:when test="${hasPrevBlock}">
                    <a class="page-link"
                       href="${pageContext.request.contextPath}/project/dashboard?page=${prevBlockPage}&size=${size}&onlyActive=${onlyActive}&keyword=${fn:escapeXml(keyword)}">&laquo;</a>
                </c:when>
                <c:otherwise>
                    <span class="page-link disabled">&laquo;</span>
                </c:otherwise>
            </c:choose>

            <!-- ‹ 이전 페이지 -->
            <c:choose>
                <c:when test="${page > 1}">
                    <a class="page-link"
                       href="${pageContext.request.contextPath}/project/dashboard?page=${page-1}&size=${size}&onlyActive=${onlyActive}&keyword=${fn:escapeXml(keyword)}">&lsaquo;</a>
                </c:when>
                <c:otherwise>
                    <span class="page-link disabled">&lsaquo;</span>
                </c:otherwise>
            </c:choose>

            <!-- 페이지 번호 -->
            <c:forEach var="pno" begin="${startPage}" end="${endPage}">
                <a class="page-link ${pno == page ? 'active' : ''}"
                   href="${pageContext.request.contextPath}/project/dashboard?page=${pno}&size=${size}&onlyActive=${onlyActive}&keyword=${fn:escapeXml(keyword)}">${pno}</a>
            </c:forEach>

            <!-- › 다음 페이지 -->
            <c:choose>
                <c:when test="${page < totalPages}">
                    <a class="page-link"
                       href="${pageContext.request.contextPath}/project/dashboard?page=${page+1}&size=${size}&onlyActive=${onlyActive}&keyword=${fn:escapeXml(keyword)}">&rsaquo;</a>
                </c:when>
                <c:otherwise>
                    <span class="page-link disabled">&rsaquo;</span>
                </c:otherwise>
            </c:choose>

            <!-- » 다음 블록 -->
            <c:choose>
                <c:when test="${hasNextBlock}">
                    <a class="page-link"
                       href="${pageContext.request.contextPath}/project/dashboard?page=${nextBlockPage}&size=${size}&onlyActive=${onlyActive}&keyword=${fn:escapeXml(keyword)}">&raquo;</a>
                </c:when>
                <c:otherwise>
                    <span class="page-link disabled">&raquo;</span>
                </c:otherwise>
            </c:choose>

        </div>

        <div class="hint">${page} / ${totalPages} 페이지</div>
    </c:if>

</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

</body>
</html>
