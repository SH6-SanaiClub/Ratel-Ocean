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

    <style>
        :root{
            --bm-bg:#f6f7fb;
            --bm-card:#ffffff;
            --bm-text:#111827;
            --bm-muted:#6b7280;
            --bm-line:#e5e7eb;

            --bm-primary:#6d4dfd;
            --bm-primary-weak: rgba(109,77,253,.12);

            --bm-danger:#dc2626;
            --bm-shadow: 0 18px 55px rgba(17,24,39,.10);
            --bm-shadow2: 0 10px 22px rgba(17,24,39,.08);
            --bm-radius: 18px;
        }

        *{ box-sizing:border-box; }
        body{
            margin:0;
            background: var(--bm-bg);
            color: var(--bm-text);
            font-family: -apple-system, BlinkMacSystemFont, "Apple SD Gothic Neo", "Noto Sans KR",
            Segoe UI, Roboto, Helvetica, Arial, sans-serif;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }

        /* ===== Page ===== */
        .bm-wrap{
            max-width: 1200px;
            margin: 26px auto 70px;
            padding: 0 16px;
        }

        .bm-head{
            display:flex;
            align-items:flex-end;
            justify-content:space-between;
            gap:14px;
            margin-bottom: 14px;
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
            color: var(--bm-muted);
            font-size: 13px;
            font-weight: 800;
        }

        /* ===== Search ===== */
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
            border-radius: 14px;
            border:1px solid rgba(229,231,235,.95);
            background:#fff;
            outline:none;
            font-weight: 850;
            box-shadow: 0 8px 22px rgba(17,24,39,.06);
        }
        .bm-search .bm-input:focus{
            border-color: rgba(109,77,253,.45);
            box-shadow: 0 0 0 4px rgba(109,77,253,.12), 0 8px 22px rgba(17,24,39,.06);
        }
        .bm-search .bm-btn{
            padding: 11px 14px;
            border:none;
            border-radius: 14px;
            background: var(--bm-primary);
            color:#fff;
            font-weight: 950;
            cursor:pointer;
            box-shadow: 0 14px 28px rgba(109,77,253,.22);
            transition: transform .08s ease, filter .12s ease;
        }
        .bm-search .bm-btn:active{ transform: translateY(1px); }
        .bm-search .bm-btn:hover{ filter: brightness(.98); }

        /* ===== List grid ===== */
        .bm-grid{
            display:grid;
            grid-template-columns: repeat(2, minmax(0,1fr));
            gap: 16px;
            margin-top: 10px;
        }

        /* ===== Card ===== */
        .bm-card{
            background: var(--bm-card);
            border-radius: var(--bm-radius);
            box-shadow: var(--bm-shadow2);
            border: 1px solid rgba(229,231,235,.8);
            padding: 16px 16px 14px;
            cursor:pointer;
            position:relative;
            overflow:hidden;
            transition: transform .12s ease, box-shadow .12s ease, border-color .12s ease;
            min-height: 170px;
        }
        .bm-card:hover{
            transform: translateY(-2px);
            box-shadow: var(--bm-shadow);
            border-color: rgba(109,77,253,.22);
        }

        /* subtle accent */
        .bm-card::before{
            content:"";
            position:absolute;
            left:0; top:0;
            width:100%; height:3px;
            background: linear-gradient(90deg, rgba(109,77,253,.55), rgba(34,211,238,.45), rgba(16,185,129,.35));
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
            border-radius: 999px;
            font-size:12px;
            font-weight: 950;
            border:1px solid rgba(229,231,235,.9);
            background: #f9fafb;
            white-space:nowrap;
            max-width: 320px;
            overflow:hidden;
            text-overflow:ellipsis;
        }
        .bm-owner-badge.company{
            background: rgba(109,77,253,.10);
            border-color: rgba(109,77,253,.22);
            color: #3b2bd8;
        }
        .bm-owner-badge.personal{
            background: rgba(16,185,129,.10);
            border-color: rgba(16,185,129,.20);
            color: #0f766e;
        }

        /* Bookmark button */
        .bm-bookmark-btn{
            width: 38px;
            height: 38px;
            border-radius: 14px;
            border: 1px solid rgba(229,231,235,.95);
            background:#fff;
            display:inline-flex;
            align-items:center;
            justify-content:center;
            cursor:pointer;
            transition: all .15s ease;
            flex:0 0 auto;
        }
        .bm-bookmark-btn:hover{
            border-color: rgba(109,77,253,.35);
            box-shadow: 0 10px 20px rgba(17,24,39,.10);
            transform: translateY(-1px);
        }
        .bm-bookmark-btn svg{
            width: 18px;
            height: 18px;
            fill: none;
            stroke: #6b7280;
            stroke-width: 2;
        }
        .bm-bookmark-btn.is-active{
            background: rgba(109,77,253,.10);
            border-color: rgba(109,77,253,.25);
        }
        .bm-bookmark-btn.is-active svg{
            fill: #6d4dfd;
            stroke: #6d4dfd;
        }

        /* Title */
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
        }

        /* chips rows */
        .bm-chips{
            display:flex;
            flex-wrap:wrap;
            gap:6px;
            margin-bottom: 10px;
        }
        .bm-chip{
            padding: 6px 10px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 950;
            background: rgba(109,77,253,.10);
            border: 1px solid rgba(109,77,253,.18);
            color: #2f22c9;
        }
        .bm-chip.pos{
            background: rgba(34,211,238,.10);
            border: 1px solid rgba(34,211,238,.20);
            color: #0f766e;
        }
        .bm-chip.skill{
            background: rgba(99,102,241,.10);
            border: 1px solid rgba(99,102,241,.18);
            color: #3730a3;
        }

        /* Bottom stats */
        .bm-bottom{
            display:flex;
            align-items:flex-end;
            justify-content:space-between;
            gap:10px;
            border-top: 1px dashed rgba(229,231,235,.95);
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
            color: var(--bm-danger);
            display:inline-flex;
            align-items:center;
            gap:8px;
        }
        .bm-applicants{
            font-weight: 850;
            font-size: 12px;
            color: var(--bm-muted);
        }
        .bm-duration{
            font-weight: 850;
            font-size: 12px;
            color: var(--bm-muted);
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
            color: var(--bm-muted);
            letter-spacing: .15px;
        }
        .bm-budget .value{
            font-size: 20px;
            font-weight: 950;
            letter-spacing: -0.3px;
            white-space:nowrap;
        }

        /* Empty state */
        .bm-empty{
            background:#fff;
            padding: 28px 18px;
            border-radius: var(--bm-radius);
            box-shadow: var(--bm-shadow2);
            border: 1px solid rgba(229,231,235,.9);
            font-weight: 950;
            color:#6b7280;
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
                                <span class="bm-owner-badge company">🏢 ${p.companyName}</span>
                            </c:when>
                            <c:when test="${not empty p.clientName}">
                                <span class="bm-owner-badge personal">👤 ${p.clientName}</span>
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
                                <span class="bm-chip pos">${s.stackName}</span>
                            </c:if>
                        </c:forEach>
                    </c:if>
                </div>

                <div class="bm-project-title">${p.title}</div>

                <!-- 스킬 -->
                <div class="bm-chips">
                    <c:if test="${not empty p.stacks}">
                        <c:forEach var="s" items="${p.stacks}">
                            <c:if test="${not empty s.category and s.category eq 'SKILL'}">
                <span class="bm-chip skill">
                  ${s.stackName}
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
                        <div class="bm-duration">예상 기간 · ${p.estDuration}</div>
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
    document.addEventListener("DOMContentLoaded", () => {
        document.querySelectorAll(".bm-bookmark-btn").forEach((btn) => {
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
                        const card = btn.closest(".bm-card");
                        if (card) card.remove();

                        // 다 지워졌으면 empty 메시지 표시
                        if (document.querySelectorAll(".bm-card").length === 0) {
                            const grid = document.querySelector(".bm-grid");
                            grid.innerHTML =
                                '<div class="bm-empty" style="grid-column: 1 / -1;">북마크한 프로젝트가 없습니다.<div class="mini">관심 있는 프로젝트를 북마크해두면 여기서 모아볼 수 있어요.</div></div>';
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
