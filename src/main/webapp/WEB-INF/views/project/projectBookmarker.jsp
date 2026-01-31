<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>북마크한 프로젝트</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        :root{

            --primary:#173160;
            --text:#0f172a;
            --bg:#f6f6f8;

            --card:#ffffff;
            --muted:#64748b;
            --line:#d7dee8;
            --line-soft:#e6ebf2;
            --danger:#dc2626;

            --accent-bd: rgba(59,111,220,.22);
            --accent-bg: rgba(59,111,220,.10);

            --ghost-bg:#e5e7eb;
            --ghost-fg:#111827;
            --ghost-bd:#cbd5e1;

            --shadow: 0 10px 26px rgba(15,23,42,.08);
            --shadow2: 0 12px 30px rgba(15,23,42,.10);

            --r-lg: 12px;
            --r-md: 10px;
            --r-sm: 8px;
            --pill: 999px;
        }

        *{ box-sizing:border-box; }
        html, body{ height:100%; }
        body{
            margin:0;
            background: var(--bg);
            color: var(--text);
            font-family:-apple-system,BlinkMacSystemFont,"Apple SD Gothic Neo","Noto Sans KR",Segoe UI,Roboto,Helvetica,Arial,sans-serif;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }


        .bm-wrap{
            max-width: 1200px;
            margin: 28px auto 70px;
            padding: 0 16px;
        }

        .bm-head{
            display:flex;
            align-items:flex-end;
            justify-content:space-between;
            gap:14px;
            margin-bottom: 25px;
            flex-wrap:wrap;
        }

        .bm-title{
            display:flex;
            flex-direction:column;
            gap:6px;
            min-width: 220px;
        }
        .bm-title h1{
            margin:0;
            font-size: 20px;
            font-weight: 950;
            letter-spacing: -0.2px;
        }
        .bm-sub{
            margin:0;
            color: var(--muted);
            font-size: 13px;
            font-weight: 800;
        }


        .bm-search{
            display:flex;
            align-items:center;
            gap:10px;
            flex-wrap:wrap;
            justify-content:flex-end;
            min-width: 280px;
        }
        .bm-search .bm-input{
            width: 420px;
            max-width: 100%;
            padding: 11px 12px;
            border-radius: var(--r-md);
            border: 1px solid var(--line);
            background:#fff;
            outline:none;
            font-weight: 800;
            box-shadow: var(--shadow);
        }
        .bm-search .bm-input::placeholder{
            color:#94a3b8;
            font-weight:800;
        }
        .bm-search .bm-input:focus{
            border-color: rgba(23,49,96,.35);
            box-shadow: 0 0 0 4px rgba(23,49,96,.12), var(--shadow);
        }
        .bm-search .bm-btn{
            height: 42px;
            padding: 0 16px;
            border: 1px solid rgba(15,23,42,.08);
            border-radius: var(--r-md);
            background: var(--primary);
            color:#fff;
            font-weight: 950;
            cursor:pointer;
            box-shadow: 0 10px 20px rgba(23,49,96,.18);
            transition: transform .08s ease, filter .12s ease;
            white-space:nowrap;
        }
        .bm-search .bm-btn:hover{ filter: brightness(.98); }
        .bm-search .bm-btn:active{ transform: translateY(1px); }


        .bm-grid{
            display:grid;
            grid-template-columns: repeat(2, minmax(0,1fr));
            gap: 16px;
            margin-top: 10px;
        }

        .bm-card{
            background: var(--card);
            border-radius: var(--r-lg);
            box-shadow: var(--shadow);
            border: 1px solid var(--line-soft);
            padding: 16px 16px 14px;
            cursor:pointer;
            position:relative;
            overflow:hidden;
            transition: transform .12s ease, box-shadow .12s ease, border-color .12s ease;
            min-height: 170px;
        }
        .bm-card:hover{
            transform: translateY(-2px);
            box-shadow: var(--shadow2);
            border-color: var(--accent-bd);
        }

        .bm-card::before{
            content:"";
            position:absolute;
            left:0; top:0;
            width:100%; height:3px;
            background: #0f172a;
            opacity:.9;
        }

        .bm-top{
            display:flex;
            align-items:flex-start;
            justify-content:space-between;
            gap:10px;
            margin-bottom: 10px;
        }

        .bm-owner{
            display:flex;
            align-items:center;
            gap:8px;
            min-width:0;
        }

        .bm-owner-badge{
            display:inline-flex;
            align-items:center;
            gap:6px;
            padding: 6px 10px;
            border-radius: var(--pill);
            font-size:12px;
            font-weight: 950;
            border:1px solid var(--line);
            background: #fff;
            color: var(--text);
            white-space:nowrap;
            max-width: 320px;
            overflow:hidden;
            text-overflow:ellipsis;
        }
        .bm-owner-badge.company{
            border-color: var(--accent-bd);
            /*background: var(--accent-bg);*/
            color: rgba(17,24,39,.92);
        }
        .bm-owner-badge.personal{
            border-color: rgba(23,49,96,.14);
            /*background: rgba(23,49,96,.06);*/
            color: rgba(23,49,96,.92);
        }

        .bm-bookmark-btn{
            width: 38px;
            height: 38px;
            border-radius: var(--r-sm);
            border: 1px solid var(--line);
            background:#fff;
            display:inline-flex;
            align-items:center;
            justify-content:center;
            cursor:pointer;
            transition: all .15s ease;
            flex:0 0 auto;
        }
        .bm-bookmark-btn:hover{
            border-color: rgba(23,49,96,.25);
            background: rgba(23,49,96,.06);
            transform: translateY(-1px);
        }
        .bm-bookmark-btn svg{
            width: 18px;
            height: 18px;
            fill: none;
            stroke: #64748b;
            stroke-width: 2;
        }
        .bm-bookmark-btn.is-active{
            border-color: rgba(23,49,96,.28);
            background: rgba(23,49,96,.10);
        }
        .bm-bookmark-btn.is-active svg{
            fill: var(--primary);
            stroke: var(--primary);
        }

        .bm-project-title{
            margin: 6px 0 10px;
            font-size: 18px;
            font-weight: 950;
            letter-spacing: -0.2px;
            line-height: 1.25;
            display:-webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow:hidden;
            min-height: 44px;
            color: var(--text);
        }

        .bm-chips{
            display:flex;
            flex-wrap:wrap;
            gap:6px;
            margin-bottom: 10px;
        }
        .bm-chip{
            padding: 6px 10px;
            border-radius: var(--pill);
            font-size: 12px;
            font-weight: 900;
            background: rgba(59,111,220,.10);
            border: 1px solid rgba(59,111,220,.22);
            color: rgba(17,24,39,.92);
            white-space:nowrap;
        }
        .bm-chip.pos{
            background: rgba(23,49,96,.06);
            border-color: rgba(23,49,96,.14);
            color: rgba(23,49,96,.92);
        }
        .bm-chip.skill{
            background: rgba(59,111,220,.10);
            border-color: rgba(59,111,220,.22);
            color: rgba(17,24,39,.92);
        }

        .bm-bottom{
            display:flex;
            align-items:flex-end;
            justify-content:space-between;
            gap:10px;
            border-top: 1px dashed var(--line-soft);
            padding-top: 12px;
            margin-top: 8px;
        }

        .bm-meta{
            display:flex;
            flex-direction:column;
            gap:6px;
            min-width:0;
        }
        .bm-dday{
            font-weight: 950;
            font-size: 13px;
            color: var(--danger);
            display:inline-flex;
            align-items:center;
            gap:8px;
        }
        .bm-applicants{
            font-weight: 900;
            font-size: 12px;
            color: var(--muted);
        }
        .bm-duration{
            font-weight: 900;
            font-size: 12px;
            color: var(--muted);
            line-height: 1.2;
            white-space:nowrap;
        }

        .bm-budget{
            text-align:right;
            display:flex;
            flex-direction:column;
            gap:4px;
            flex:0 0 auto;
        }
        .bm-budget .label{
            font-size: 11px;
            font-weight: 950;
            color: var(--muted);
            letter-spacing: .15px;
        }
        .bm-budget .value{
            font-size: 20px;
            font-weight: 950;
            letter-spacing: -0.3px;
            white-space:nowrap;
            color: var(--text);
        }

        .bm-empty{
            background:#fff;
            padding: 28px 18px;
            border-radius: var(--r-lg);
            box-shadow: var(--shadow);
            border: 1px solid var(--line-soft);
            font-weight: 950;
            color: var(--muted);
            text-align:center;
        }
        .bm-empty .mini{
            margin-top: 6px;
            font-size: 13px;
            font-weight: 850;
            color:#9ca3af;
        }

        @media (max-width: 980px){
            .bm-grid{ grid-template-columns: 1fr; }
            .bm-search{ justify-content:flex-start; }
            .bm-project-title{ min-height:auto; }
        }
    </style>
</head>

<body>
<jsp:include page="/WEB-INF/views/common/headerBase.jsp" />

<div class="bm-wrap">

    <div class="bm-head">
        <div class="bm-title">
            <h1>북마크한 프로젝트</h1>
            <p class="bm-sub">저장해둔 프로젝트를 한 번에 확인하고, 마음이 바뀌면 바로 해제할 수 있어요.</p>
        </div>

        <form class="bm-search" method="get" action="${pageContext.request.contextPath}/project/bookmark">
            <input class="bm-input" type="text"
                   name="keyword"
                   placeholder="프로젝트 제목 검색"
                   value="${fn:escapeXml(keyword)}"/>
            <button class="bm-btn" type="submit">검색</button>
        </form>
    </div>

    <div class="bm-grid">

        <c:if test="${empty projectList}">
            <div class="bm-empty" style="grid-column: 1 / -1;">
                북마크한 프로젝트가 없습니다.
                <div class="mini">관심 있는 프로젝트를 북마크해두면 여기서 모아볼 수 있어요.</div>
            </div>
        </c:if>

        <c:forEach var="p" items="${projectList}">
            <div class="bm-card"
                 onclick="location.href='${pageContext.request.contextPath}/project/detail?projectId=${p.projectId}'">

                <div class="bm-top">
                    <div class="bm-owner">
                        <c:choose>
                            <c:when test="${not empty p.companyName}">
                                <span class="bm-owner-badge company">🏢 ${fn:escapeXml(p.companyName)}</span>
                            </c:when>
                            <c:when test="${not empty p.clientName}">
                                <span class="bm-owner-badge personal">👤 ${fn:escapeXml(p.clientName)}</span>
                            </c:when>
                            <c:otherwise>
                                <span class="bm-owner-badge">👤 클라이언트</span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- 북마크 -->
                    <button type="button"
                            class="bm-bookmark-btn ${p.bookmarked ? 'is-active' : ''}"
                            data-project-id="${p.projectId}"
                            title="북마크"
                            onclick="event.preventDefault(); event.stopPropagation();">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M6 3h12a1 1 0 0 1 1 1v17l-7-4-7 4V4a1 1 0 0 1 1-1z"></path>
                        </svg>
                    </button>
                </div>

                <!-- 포지션 -->
                <div class="bm-chips">
                    <c:if test="${not empty p.stacks}">
                        <c:forEach var="s" items="${p.stacks}">
                            <c:if test="${not empty s.category and s.category eq 'POSITION'}">
                                <span class="bm-chip pos">${fn:escapeXml(s.stackName)}</span>
                            </c:if>
                        </c:forEach>
                    </c:if>
                </div>

                <div class="bm-project-title">${fn:escapeXml(p.title)}</div>

                <!-- 스킬 -->
                <div class="bm-chips">
                    <c:if test="${not empty p.stacks}">
                        <c:forEach var="s" items="${p.stacks}">
                            <c:if test="${not empty s.category and s.category eq 'SKILL'}">
                <span class="bm-chip skill">
                  ${fn:escapeXml(s.stackName)}
                  <c:if test="${s.stackLevel != null}">
                      Lv.${s.stackLevel}
                  </c:if>
                </span>
                            </c:if>
                        </c:forEach>
                    </c:if>
                </div>

                <div class="bm-bottom">
                    <div class="bm-meta">
                        <div class="bm-dday">
                            <c:choose>
                                <c:when test="${p.dday >= 0}">마감 D-${p.dday}</c:when>
                                <c:otherwise>마감</c:otherwise>
                            </c:choose>
                        </div>

                        <div class="bm-applicants">지원자 ${p.applicantCount}명</div>
                        <div class="bm-duration">예상 기간 · ${fn:escapeXml(p.estDuration)}</div>
                    </div>

                    <div class="bm-budget">
                        <div class="label">예산</div>
                        <div class="value">
                            <fmt:formatNumber value="${p.budget / 10000}" maxFractionDigits="0"/>만원
                        </div>
                    </div>
                </div>

            </div>
        </c:forEach>

    </div>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function(){
        var ctx = "${pageContext.request.contextPath}";

        document.querySelectorAll(".bm-bookmark-btn").forEach(function(btn){
            btn.addEventListener("click", async function(e){
                e.preventDefault();
                e.stopPropagation();

                var projectId = btn.getAttribute("data-project-id");

                try {
                    var res = await fetch(ctx + "/project/bookmark/toggle", {
                        method: "POST",
                        headers: {"Content-Type":"application/x-www-form-urlencoded; charset=UTF-8"},
                        body: new URLSearchParams({ projectId: projectId })
                    });

                    var data = await res.json();
                    if (!data.ok) {
                        alert(data.message === "LOGIN_REQUIRED" ? "로그인이 필요합니다." : "실패");
                        return;
                    }

                    // 북마크 페이지에서는 해제되면 카드 제거
                    if (!data.bookmarked) {
                        var card = btn.closest(".bm-card");
                        if (card) card.remove();

                        // 다 지워졌으면 empty 메시지 표시
                        if (document.querySelectorAll(".bm-card").length === 0) {
                            var grid = document.querySelector(".bm-grid");
                            if(grid){
                                grid.innerHTML =
                                    '<div class="bm-empty" style="grid-column: 1 / -1;">' +
                                    '북마크한 프로젝트가 없습니다.' +
                                    '<div class="mini">관심 있는 프로젝트를 북마크해두면 여기서 모아볼 수 있어요.</div>' +
                                    '</div>';
                            }
                        }
                        return;
                    }

                    btn.classList.toggle("is-active", !!data.bookmarked);
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
