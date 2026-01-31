<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <title>프리랜서 프로필</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <style>
        :root{

            --bg:    #f6f6f8;
            --paper: #ffffff;
            --text:  #111827;
            --muted: #6b7280;
            --muted2:#8b95a1;

            --line:  #d6dae1;
            --line2: #c7ccd6;


            --p50:   #eff4ff;
            --p100:  #dbe7ff;
            --p200:  #bcd3ff;
            --p500:  #3b6fdc;
            --p600: #173160;
            --p700:  #264fa8;

            --shadow: 0 2px 10px rgba(17,24,39,.06);
            --shadow2: 0 1px 6px rgba(17,24,39,.05);


            --R0: 0px;
            --Rtab: 6px;
            --Rcard: 14px;
            --Rchip: 999px;
            --Rbtn: 10px;


            --focus: 0 0 0 3px rgba(59,111,220,.22);
        }


        *{ box-sizing:border-box; }
        html, body{ height:100%; }
        body{
            margin:0;
            background: var(--bg);
            color: var(--text);
            font-family: "Pretendard GOV", Pretendard, -apple-system, BlinkMacSystemFont,
            "Apple SD Gothic Neo", "Noto Sans KR", Segoe UI, Roboto, Helvetica, Arial, sans-serif;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }
        a{ color:inherit; text-decoration:none; }
        button{ font-family:inherit; }
        .noprint{}

        .wrap{
            max-width: 1240px;
            margin: 0 auto;
            padding: 18px 18px 70px;
        }


        .frame{
            border: 1px solid var(--line);
            background: var(--paper);
            border-radius: var(--R0);
            box-shadow: var(--shadow);
            overflow:hidden;
        }

        .topbar {
            padding: 16px 18px;
            border-bottom: 1px solid var(--line);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
            background: #fafafa;
        }

        .who{ display:flex; align-items:center; gap: 12px; min-width: 0; }

        .avatar{
            width:58px; height:58px;
            border-radius: var(--Rcard);
            overflow:hidden;
            background: #f1f3f6;
            border:1px solid var(--line);
            flex: 0 0 auto;
            display:flex; align-items:center; justify-content:center;
        }
        .avatar img{ width:100%; height:100%; object-fit:cover; display:block; }
        .avatar .fallback{ font-size:22px; color: rgba(17,24,39,.35); }

        .name-row{ display:flex; align-items:baseline; gap:10px; flex-wrap:wrap; min-width:0; }
        .nickname{
            font-size:18px;
            font-weight: 850;
            letter-spacing: -.2px;
            white-space:nowrap;
            overflow:hidden;
            text-overflow:ellipsis;
            max-width: 760px;
        }
        .loginid{ font-size:12px; font-weight: 700; color: var(--muted); }

        .actions{ display:flex; gap:10px; flex:0 0 auto; align-items:center; }

        .btn{
            border:1px solid transparent;
            border-radius: var(--Rbtn);
            padding: 10px 12px;
            font-size:13px;
            font-weight: 750;
            cursor:pointer;
            line-height:1;
            user-select:none;
            background: var(--paper);
            transition: background .12s ease, border-color .12s ease, box-shadow .12s ease, transform .08s ease;
            white-space:nowrap;
        }
        .btn:active{ transform: translateY(1px); }
        .btn:focus{ outline:none; box-shadow: var(--focus); }

        .btn-ghost{
            border-color: var(--line2);
            color: var(--text);
            background: #fff;
        }
        .btn-ghost:hover{
            background: #f3f4f6;
            border-color: #b9c0cc;
        }

        .btn-primary{
            background: var(--p600);
            border-color: rgba(38,79,168,.22);
            color:#fff;
            box-shadow: 0 6px 14px rgba(47,94,197,.18);
        }
        .btn-primary:hover{ background: var(--p700); }


        .grid{
            display:grid;
            grid-template-columns: 340px 1fr;
            gap: 14px;
            padding: 14px;
            background: #fff;
        }

        @media (max-width: 980px){
            .topbar{ flex-direction:column; align-items:flex-start; }
            .actions{ width:100%; }
            .btn{ flex:1; text-align:center; }
            .grid{ grid-template-columns: 1fr; }
            .nickname{ max-width:100%; }
        }

        .side{
            position: sticky;
            top: 12px;
            display:flex;
            flex-direction:column;
            gap: 12px;
            align-self:start;
        }

        .card{
            background:#fff;
            border:1px solid var(--line);
            border-radius: var(--Rcard);
            box-shadow: var(--shadow2);
            overflow:hidden;
        }
        .card-h{
            padding: 12px 14px;
            border-bottom:1px solid var(--line);
            display:flex;
            align-items:flex-end;
            justify-content:space-between;
            gap:10px;
            background:#fafafa;
        }
        .card-title{
            margin:0;
            font-size:12px;
            font-weight: 850;
            letter-spacing:.2px;
            text-transform: uppercase;
            color: #374151;
        }
        .card-sub{
            font-size:12px;
            color: var(--muted);
            font-weight: 650;
        }
        .card-b{ padding: 14px; }

        .kv{
            display:grid;
            grid-template-columns: 92px 1fr;
            gap: 10px 10px;
            align-items:start;
        }
        .k{ font-size:12px; font-weight: 750; color: var(--muted); padding-top:2px; }
        .v{ font-size:13px; font-weight: 650; color: var(--text); word-break: break-word; line-height:1.5; }

        .link{
            color: var(--primary);
            font-weight: 750;
            border-bottom:1px solid rgba(38,79,168,.30);
        }
        .link:hover{ border-bottom-color: rgba(38,79,168,.65); }

        .empty{
            border:1px dashed #cfd4dd;
            background: #f3f4f6;
            padding: 12px;
            border-radius: var(--Rcard);
            color: var(--muted);
            font-weight: 650;
            font-size:13px;
        }

        .tabs{
            background:#fff;
            border:1px solid var(--line);
            border-radius: var(--Rtab);
            box-shadow: var(--shadow2);
            overflow:hidden;
            align-self:start;
        }

        .tabbar{
            display:flex;
            gap: 0;
            border-bottom:1px solid var(--line);
            background:#fafafa;
        }
        .tab{
            flex:1;
            padding: 12px 10px;
            border:0;
            background: transparent;
            cursor:pointer;
            font-size:12px;
            font-weight: 850;
            letter-spacing:.2px;
            color: rgba(17,24,39,.72);
            border-right:1px solid var(--line);
            transition: background .12s ease, color .12s ease, box-shadow .12s ease;
        }
        .tab:last-child{ border-right:0; }
        .tab:hover{ background: #f2f3f5; }
        .tab.is-active{
            background: #fff;
            color: rgba(17,24,39,.95);
            box-shadow: inset 0 -3px 0 var(--text);
        }
        .tab:focus{ outline:none; box-shadow: var(--focus); z-index:1; }

        .tabpanes{ padding: 16px; background:#fff; }
        .pane{ display:none; }
        .pane.is-active{ display:block; }

        .kpis{
            display:grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin-bottom: 14px;
        }
        @media (max-width: 720px){
            .kpis{ grid-template-columns: 1fr; }
        }
        .kpi{
            border:1px solid var(--line);
            border-radius: var(--Rcard);
            background:#fff;
            padding: 14px;
            box-shadow: var(--shadow2);
        }
        .kpi-label{
            font-size:12px;
            font-weight: 750;
            color: var(--muted);
            margin-bottom: 8px;
        }
        .kpi-value{
            font-size:22px;
            font-weight: 850;
            letter-spacing:-.2px;
            display:flex;
            align-items:baseline;
            gap:6px;
        }
        .kpi-value small{ font-size:12px; font-weight: 700; color: var(--muted); }

        .block{ margin: 10px 0 28px; }

        .block-title{
            margin: 0 0 10px;
            display:flex;
            align-items:center;
            justify-content:space-between;
            gap: 10px;

            font-size: 14px;
            font-weight: 900;
            letter-spacing: -.1px;
            color: rgba(17,24,39,.92);

            padding-bottom: 8px;
        }

        .block-title > span:first-child{
            display:inline-flex;
            align-items:center;
            gap: 8px;
        }
        .block-title > span:first-child::before{
            content:"";
            width:8px; height:8px;
            border-radius:999px;
            background: rgba(23,49,96,.85);
            box-shadow: 0 0 0 3px rgba(23,49,96,.10);
        }

        .block-sub{
            font-size: 11px;
            font-weight: 800;
            color: rgba(17,24,39,.45);
            letter-spacing: .12em;
            text-transform: uppercase;
            white-space:nowrap;
        }


        .section-box{
            border:1px solid var(--line);
            border-radius: var(--Rcard);
            background:#fff;
            box-shadow: var(--shadow2);
            overflow:hidden;
            padding: 14px;
        }

        .intro{
            font-size:13px;
            font-weight: 600;
            line-height: 1.75;
            white-space: pre-line;
            color: rgba(17,24,39,.92);
        }

        .chips{ display:flex; flex-wrap:wrap; gap:8px; }

        .chip{
            display:inline-flex;
            align-items:center;
            gap:8px;
            padding: 8px 10px;
            border-radius: var(--Rchip);

            background: #f3f4f6;
            /*border: 1px solid #d1d5db;*/
            color: rgba(17,24,39,.92);

            font-size:12px;
            font-weight: 800;
            line-height:1;
        }

        .chips-pos .chip{
            background: rgba(23,49,96,.06);
            border-color: rgba(23,49,96,.14);
            color: rgba(23,49,96,.92);
        }


        .chips-skill .chip{
            background: rgba(59,111,220,.10);
            border-color: rgba(59,111,220,.22);
            color: rgba(17,24,39,.92);
        }

        .lvl{ display:inline-flex; gap:8px; align-items:center; color: rgba(17,24,39,.65); font-weight: 700; }
        .bars{ display:inline-flex; gap:2px; }
        .bar{
            width:6px; height:10px;
            border-radius:3px;
            background: rgba(59,111,220,.18);
        }
        .bar.on{ background: rgba(23, 49, 96,.92); }

        .item-list{ display:flex; flex-direction:column; gap: 10px; }
        .item-card{
            border:1px solid var(--line);
            border-radius: var(--Rcard);
            background:#fff;
            box-shadow: var(--shadow2);
            padding: 12px;
        }
        /* Projects 카드: 제목 영역(프로젝트명/메타/별점) 아래 구분선 */
        #pane-projects .item-card .item-top{
            padding-bottom: 12px;
            margin-bottom: 12px;
            border-bottom: 1px dashed #cfd4dd;   /* CONTACT처럼 점선 느낌 */
        }


        .item-right{
            font-size: 12px;
            font-weight: 500;
            color: var(--muted);
            white-space: nowrap;
            line-height: 1.4;

            font-variant-numeric: tabular-nums;
            letter-spacing: 0;
        }

        .item-top{
            display:flex;
            align-items:flex-start;
            justify-content:space-between;
            gap:12px;
            flex-wrap:nowrap;
        }

        .item-title{
            font-weight: 850;
            font-size:14px;
            margin:0 0 6px;
        }
        .item-meta{
            font-size:12px;
            color: var(--muted);
            font-weight: 650;
            line-height:1.45;
        }

        .rating{
            display:inline-flex;
            align-items:center;
            gap:6px;
            padding:0;
            border:none;
            background:none;
            white-space:nowrap;
            flex: 0 0 auto;
        }
        .rating .stars{ display:inline-flex; gap:2px; line-height:1; }
        .rating .star{ color: var(--p600); font-size:16px; line-height:1; }
        .rating .star-off{ opacity:.22; }
        .rating small{ color: var(--muted); font-weight:700; font-size:12px; }

        .item-desc{
            margin-top: 10px;
            padding-top: 10px;
            border-top:1px dashed #cfd4dd;
            font-size:13px;
            font-weight: 600;
            line-height:1.65;
            white-space: pre-line;
            color: rgba(17,24,39,.86);
        }

        @media print{
            body{ background:#fff; }
            .wrap{ max-width:none; margin:0; padding:0; }
            .frame, .card, .tabs, .section-box, .item-card, .kpi{ box-shadow:none; }
            .grid{ padding:0; background:#fff; }
            .noprint{ display:none !important; }
            .side{ position: static; }
            a.link{ border:none; text-decoration: underline; }
            .card, .section-box, .item-card{ break-inside: avoid; page-break-inside: avoid; }
        }

        .stack-block{ margin-top:10px; }
        .stack-label{
            font-size:11px;
            font-weight:850;
            letter-spacing:.18em;
            color: rgba(17,24,39,.55);
            margin: 0 0 6px;
            text-transform: uppercase;
        }

        .review-title{
            font-size:12px;
            color: var(--muted);
            font-weight: 650;
        }

    </style>

    <script>
        function downloadPdf(){ window.print(); }

        function setTab(id){
            var tabs = document.querySelectorAll('.tab');
            var panes = document.querySelectorAll('.pane');
            tabs.forEach(function(t){ t.classList.toggle('is-active', t.getAttribute('data-tab') === id); });
            panes.forEach(function(p){ p.classList.toggle('is-active', p.id === id); });
        }
        document.addEventListener('DOMContentLoaded', function(){ setTab('pane-overview'); });
    </script>
</head>

<body>
<jsp:include page="/WEB-INF/views/common/headerBase.jsp" />

<div class="wrap">
    <div class="frame">

        <!-- TOP -->
        <div class="topbar">
            <div class="who">
                <div class="avatar">
                    <c:choose>
                        <c:when test="${not empty p.profileImageUrl}">
                            <img src="${pageContext.request.contextPath}${p.profileImageUrl}" alt="profile"/>
                        </c:when>
                        <c:otherwise>
                            <div class="fallback">👤</div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div>
                    <div class="name-row">
                        <div class="nickname">
                            <c:choose>
                                <c:when test="${not empty p.nickname}">
                                    <c:out value="${p.nickname}"/>
                                </c:when>
                                <c:otherwise>닉네임 미등록</c:otherwise>
                            </c:choose>
                        </div>
                        <c:if test="${not empty p.loginId}">
                            <div class="loginid">@<c:out value="${p.loginId}"/></div>
                        </c:if>
                    </div>
                </div>
            </div>

            <div class="actions noprint">
                <button class="btn btn-ghost" type="button" onclick="downloadPdf()">PDF로 다운</button>
                <c:if test="${p.owner}">
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/freelancer/profile/edit?tab=settings">
                        프로필 수정하기
                    </a>
                </c:if>
            </div>
        </div>

        <div class="grid">

            <!-- LEFT -->
            <aside class="side">

                <!-- CONTACT -->
                <div class="card">
                    <div class="card-h">
                        <div>
                            <div class="card-title">CONTACT</div>
                            <div class="card-sub">연락 및 링크</div>
                        </div>
                    </div>
                    <div class="card-b">
                        <c:if test="${empty p.email and empty p.githubUrl and empty p.websiteUrl}">
                            <div class="empty">등록된 연락처/링크가 없습니다.</div>
                        </c:if>

                        <c:if test="${not empty p.email or not empty p.githubUrl or not empty p.websiteUrl}">
                            <div class="kv">
                                <c:if test="${not empty p.email}">
                                    <div class="k">Email</div>
                                    <div class="v"><c:out value="${p.email}"/></div>
                                </c:if>

                                <c:if test="${not empty p.githubUrl}">
                                    <div class="k">GitHub</div>
                                    <div class="v">
                                        <a class="link" href="${p.githubUrl}" target="_blank" rel="noopener">
                                            <c:out value="${p.githubUrl}"/>
                                        </a>
                                    </div>
                                </c:if>

                                <c:if test="${not empty p.websiteUrl}">
                                    <div class="k">Website</div>
                                    <div class="v">
                                        <a class="link" href="${p.websiteUrl}" target="_blank" rel="noopener">
                                            <c:out value="${p.websiteUrl}"/>
                                        </a>
                                    </div>
                                </c:if>
                            </div>
                        </c:if>
                    </div>
                </div>

                <!-- EDUCATION -->
                <div class="card">
                    <div class="card-h">
                        <div>
                            <div class="card-title">EDUCATION</div>
                            <div class="card-sub">학력</div>
                        </div>
                    </div>
                    <div class="card-b">
                        <c:if test="${empty p.schoolName and empty p.major and empty p.degree and empty p.gradStatus}">
                            <div class="empty">학력 정보가 없습니다.</div>
                        </c:if>

                        <c:if test="${not empty p.schoolName or not empty p.major or not empty p.degree or not empty p.gradStatus}">
                            <div class="kv">
                                <c:if test="${not empty p.schoolName}">
                                    <div class="k">학교</div>
                                    <div class="v"><c:out value="${p.schoolName}"/></div>
                                </c:if>
                                <c:if test="${not empty p.major}">
                                    <div class="k">전공</div>
                                    <div class="v"><c:out value="${p.major}"/></div>
                                </c:if>
                                <c:if test="${not empty p.degree}">
                                    <div class="k">학위</div>
                                    <div class="v"><c:out value="${p.degree}"/></div>
                                </c:if>
                                <c:if test="${not empty p.gradStatus}">
                                    <div class="k">상태</div>
                                    <div class="v"><c:out value="${p.gradStatus}"/></div>
                                </c:if>
                            </div>
                        </c:if>
                    </div>
                </div>

                <!-- PORTFOLIO -->
                <div class="card">
                    <div class="card-h">
                        <div>
                            <div class="card-title">PORTFOLIO</div>
                            <div class="card-sub">공개 포트폴리오</div>
                        </div>
                    </div>
                    <div class="card-b">
                        <c:if test="${empty p.publicPortfolios}">
                            <div class="empty">공개 포트폴리오가 없습니다.</div>
                        </c:if>

                        <c:if test="${not empty p.publicPortfolios}">
                            <div class="item-list">
                                <c:forEach var="pf" items="${p.publicPortfolios}">
                                    <div class="item-card">
                                        <div class="item-top">
                                            <div>
                                                <div class="item-meta">
                                                    <c:if test="${not empty pf.portfolioUrl}">
                                                        <a class="link" href="${pf.portfolioUrl}" target="_blank" rel="noopener">포트폴리오 다운받기</a>
                                                    </c:if>
                                                    <c:if test="${empty pf.portfolioUrl}">링크 없음</c:if>
                                                </div>
                                            </div>
                                        </div>
                                        <c:if test="${not empty pf.description}">
                                            <div class="item-desc"><c:out value="${pf.description}"/></div>
                                        </c:if>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:if>
                    </div>
                </div>

            </aside>

            <!-- RIGHT -->
            <section class="tabs">

                <div class="tabbar noprint">
                    <button class="tab is-active" type="button" data-tab="pane-overview" onclick="setTab('pane-overview')">Overview</button>
                    <button class="tab" type="button" data-tab="pane-career" onclick="setTab('pane-career')">Career</button>
                    <button class="tab" type="button" data-tab="pane-projects" onclick="setTab('pane-projects')">Projects</button>
                </div>

                <div class="tabpanes">

                    <!-- Overview -->
                    <div class="pane is-active" id="pane-overview">

                        <div class="kpis">
                            <div class="kpi">
                                <div class="kpi-label">외부 프로젝트</div>
                                <div class="kpi-value">
                                    <c:choose>
                                        <c:when test="${not empty p.projectExperiences}">
                                            <c:out value="${fn:length(p.projectExperiences)}"/>
                                        </c:when>
                                        <c:otherwise>0</c:otherwise>
                                    </c:choose>
                                    <small>건</small>
                                </div>
                            </div>

                            <div class="kpi">
                                <div class="kpi-label">플랫폼 내 완료 프로젝트</div>
                                <div class="kpi-value">
                                    <c:choose>
                                        <c:when test="${not empty p.completedProjects}">
                                            <c:out value="${fn:length(p.completedProjects)}"/>
                                        </c:when>
                                        <c:otherwise>0</c:otherwise>
                                    </c:choose>
                                    <small>건</small>
                                </div>
                            </div>
                        </div>

                        <div class="block">
                            <div class="block-title">
                                <span>소개</span>
                                <span class="block-sub">Intro</span>
                            </div>
                            <div class="section-box">
                                <c:if test="${not empty p.introduction}">
                                    <div class="intro"><c:out value="${p.introduction}"/></div>
                                </c:if>
                                <c:if test="${empty p.introduction}">
                                    <div class="empty">소개가 아직 없습니다.</div>
                                </c:if>
                            </div>
                        </div>

                        <div class="block">
                            <div class="block-title">
                                <span>포지션</span>
                                <span class="block-sub">Position</span>
                            </div>
                            <div class="section-box">
                                <c:if test="${empty p.positions}">
                                    <div class="empty">등록된 포지션이 없습니다.</div>
                                </c:if>

                                <c:if test="${not empty p.positions}">
                                    <div class="chips">
                                        <c:forEach var="pos" items="${p.positions}">
                                            <span class="chip">
                                                <span><c:out value="${pos.stackName}"/></span>

                                                <c:if test="${pos.stackLevel ne null || (pos.stackYear ne null && pos.stackYear gt 0)}">
                                                    <span class="lvl">
                                                        <c:if test="${pos.stackLevel ne null}">
                                                            <span class="bars">
                                                                <c:forEach var="i" begin="1" end="5">
                                                                    <span class="bar ${i <= pos.stackLevel ? 'on' : ''}"></span>
                                                                </c:forEach>
                                                            </span>
                                                        </c:if>

                                                        <c:if test="${pos.stackYear ne null && pos.stackYear gt 0}">
                                                            · <c:out value="${pos.stackYear}"/>년차
                                                        </c:if>
                                                    </span>
                                                </c:if>
                                            </span>
                                        </c:forEach>
                                    </div>
                                </c:if>
                            </div>
                        </div>

                        <div class="block">
                            <div class="block-title">
                                <span>스킬</span>
                                <span class="block-sub">Skills</span>
                            </div>
                            <div class="section-box">
                                <c:if test="${empty p.skills}">
                                    <div class="empty">등록된 스킬이 없습니다.</div>
                                </c:if>

                                <c:if test="${not empty p.skills}">
                                    <div class="chips">
                                        <c:forEach var="s" items="${p.skills}">
                                            <span class="chip">
                                                <span><c:out value="${s.stackName}"/></span>
                                                <span class="lvl">
                                                    <span class="bars">
                                                        <c:forEach var="i" begin="1" end="5">
                                                            <span class="bar ${i <= s.stackLevel ? 'on' : ''}"></span>
                                                        </c:forEach>
                                                    </span>
                                                    <c:if test="${s.stackYear ne null && s.stackYear gt 0}">
                                                        · <c:out value="${s.stackYear}"/>년차
                                                    </c:if>
                                                </span>
                                            </span>
                                        </c:forEach>
                                    </div>
                                </c:if>
                            </div>
                        </div>

                    </div>

                    <!-- Career -->
                    <div class="pane" id="pane-career">

                        <div class="block">
                            <div class="block-title">
                                <span>경력</span>
                                <span class="block-sub">Career</span>
                            </div>

                            <c:if test="${empty p.careers}">
                                <div class="section-box">
                                    <div class="empty">등록된 경력이 없습니다.</div>
                                </div>
                            </c:if>

                            <c:if test="${not empty p.careers}">
                                <div class="item-list">
                                    <c:forEach var="c" items="${p.careers}">
                                        <div class="item-card">
                                            <div class="item-top">
                                                <div>
                                                    <div class="item-title"><c:out value="${c.companyName}"/></div>
                                                    <div class="item-meta"><c:out value="${c.role}"/> · <c:out value="${c.position}"/></div>
                                                </div>
                                                <div class="item-right">
                                                    <c:out value="${c.startDate}"/>
                                                    <c:if test="${not empty c.endDate}"> ~ <c:out value="${c.endDate}"/></c:if>
                                                    <c:if test="${empty c.endDate}"> ~ 재직중</c:if>
                                                </div>
                                            </div>
                                            <c:if test="${not empty c.description}">
                                                <div class="item-desc"><c:out value="${c.description}"/></div>
                                            </c:if>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>

                        <div class="block">
                            <div class="block-title">
                                <span>외부 프로젝트 경험</span>
                                <span class="block-sub">External</span>
                            </div>

                            <c:if test="${empty p.projectExperiences}">
                                <div class="section-box">
                                    <div class="empty">외부 프로젝트 경험이 없습니다.</div>
                                </div>
                            </c:if>

                            <c:if test="${not empty p.projectExperiences}">
                                <div class="item-list">
                                    <c:forEach var="e" items="${p.projectExperiences}">
                                        <div class="item-card">
                                            <div class="item-top">
                                                <div>
                                                    <div class="item-title"><c:out value="${e.title}"/></div>
                                                    <div class="item-meta">
                                                        <c:out value="${e.role}"/>
                                                        <c:if test="${not empty e.clientName}">
                                                            · <c:out value="${e.clientName}"/>
                                                        </c:if>
                                                    </div>
                                                </div>
                                                <div class="item-right">
                                                    <c:out value="${e.startDate}"/>
                                                    <c:if test="${not empty e.endDate}"> ~ <c:out value="${e.endDate}"/></c:if>
                                                    <c:if test="${empty e.endDate}"> ~ 진행중</c:if>
                                                </div>
                                            </div>
                                            <c:if test="${not empty e.description}">
                                                <div class="item-desc"><c:out value="${e.description}"/></div>
                                            </c:if>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>

                    </div>

                    <!-- Projects -->
                    <div class="pane" id="pane-projects">

                        <div class="block">
                            <div class="block-title">
                                <span>Ratel Ocean 프로젝트</span>
                                <span class="block-sub">Completed on Platform</span>
                            </div>

                            <c:if test="${empty p.completedProjects}">
                                <div class="section-box">
                                    <div class="empty">완료된 프로젝트가 아직 없습니다.</div>
                                </div>
                            </c:if>

                            <c:if test="${not empty p.completedProjects}">
                                <div class="item-list">

                                    <c:forEach var="cp" items="${p.completedProjects}">
                                        <div class="item-card">

                                            <div class="item-top">


                                                <div>
                                                    <div class="item-title">
                                                        <c:out value="${cp.projectTitle}"/></div>
                                                    <div class="item-meta">
                                                        <c:out value="${cp.clientName}"/> · 완료일 <c:out value="${cp.completedDate}"/>
                                                    </div>
                                                </div>

                                                <div class="rating">
                                                    <c:choose>
                                                        <c:when test="${cp.clientRating ne null}">
                                                            <span class="stars">
                                                                <c:forEach var="i" begin="1" end="5">
                                                                    <c:choose>
                                                                        <c:when test="${i <= cp.clientRating}">
                                                                            <span class="star">★</span>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span class="star star-off">★</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </c:forEach>
                                                            </span>
                                                            <small>(<c:out value="${cp.clientRating}"/>.0)</small>
                                                        </c:when>

                                                        <c:otherwise>
                                                            <span class="stars">
                                                                <c:forEach var="i" begin="1" end="5">
                                                                    <span class="star star-off">★</span>
                                                                </c:forEach>
                                                            </span>
                                                            <small>(미평가)</small>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <c:if test="${not empty cp.stacks}">
                                                <div style="margin-top:10px;">
                                                    <div class="stack-label"> POSITION</div>
                                                    <div class="chips chips-pos">
                                                        <c:forEach var="st" items="${cp.stacks}">
                                                            <c:if test="${st.category == 'POSITION'}">
                                                            <span class="chip">
                                                                <c:out value="${st.stackName}"/>
                                                                <c:if test="${st.isPrimary}">
                                                                    <span class="lvl">· primary</span>
                                                                </c:if>
                                                            </span>
                                                            </c:if>
                                                        </c:forEach>
                                                    </div>
                                                </div>
                                            </c:if>

                                            <c:if test="${not empty cp.stacks}">
                                                <div style="margin-top:10px;">
                                                    <div class="stack-label"> SKILL</div>
                                                    <div class="chips chips-skill">
                                                        <c:forEach var="st" items="${cp.stacks}">
                                                            <c:if test="${st.category == 'SKILL'}">
                                                            <span class="chip">
                                                                <c:out value="${st.stackName}"/>
                                                                <c:if test="${st.isPrimary}">
                                                                    <span class="lvl">· primary</span>
                                                                </c:if>
                                                            </span>
                                                            </c:if>
                                                        </c:forEach>
                                                    </div>
                                                </div>
                                            </c:if>
                                            <c:if test="${not empty cp.clientExperience}">
                                                <div class="item-desc"><div class="review-title">클라이언트 평가</div><c:out value="${cp.clientExperience}"/>
                                                </div>
                                            </c:if>

                                        </div>
                                    </c:forEach>

                                </div>
                            </c:if>
                        </div>

                    </div>

                </div>
            </section>

        </div>
    </div>
</div>

<script>
    function setTab(id){
        var tabs = document.querySelectorAll('.tab');
        var panes = document.querySelectorAll('.pane');
        tabs.forEach(function(t){ t.classList.toggle('is-active', t.getAttribute('data-tab') === id); });
        panes.forEach(function(p){ p.classList.toggle('is-active', p.id === id); });
    }
    document.addEventListener('DOMContentLoaded', function(){ setTab('pane-overview'); });
</script>

</body>
</html>
