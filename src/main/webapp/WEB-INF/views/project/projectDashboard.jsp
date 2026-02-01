<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>프로젝트 대시보드</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        :root{
            --primary:#173160;
            --text:#0f172a;
            --bg: #f6f6f8;

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
            --r-lg: 12px;
            --r-md: 10px;
            --r-sm: 8px;
            --pill: 999px;
        }

        *{ box-sizing:border-box; }
        html, body{ height:100%; }
        body{
            margin:0;
            font-family:-apple-system,BlinkMacSystemFont,"Apple SD Gothic Neo","Noto Sans KR",Segoe UI,Roboto,Helvetica,Arial,sans-serif;
            background: var(--bg);
            color: var(--text);
        }

        .pd-wrap{
            max-width: 1200px;
            margin: 28px auto 70px;
            padding: 0 16px;
        }

        .pageTitle{
            display:flex;
            align-items:flex-start;
            justify-content:space-between;
            gap:16px;
            margin-bottom:16px;
        }
        .titleBox{ display:flex; flex-direction:column; gap:6px; }
        .titleBox h1{
            margin:0;
            font-size:24px;
            font-weight:900;
            letter-spacing:-.6px;
            color:var(--text);
        }
        .titleBox .bm-sub{
            margin:0;
            color:var(--muted);
            font-weight:800;
            line-height:1.45;
            font-size:13px;
        }



        .pd-register{
            display:flex;
            justify-content:flex-end;
            margin: 4px 0 14px;
        }
        .pd-btn-primary{
            display:inline-flex;
            align-items:center;
            justify-content:center;
            height: 42px;
            padding: 0 18px;
            border-radius: var(--r-md);
            background: var(--primary);
            color:#fff;
            text-decoration:none;
            font-weight: 900;
            border: 1px solid rgba(15,23,42,.08);
            box-shadow: 0 10px 20px rgba(23,49,96,.18);
            cursor:pointer;
            white-space: nowrap;
        }
        .pd-btn-primary:hover{ filter:brightness(.98); }

        .pd-summary{
            display:grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
            margin: 6px 0 14px;
        }
        .pd-summary a{ text-decoration:none; color:inherit; display:block; }
        .pd-scard{
            background: var(--card);
            border: 1px solid var(--line-soft);
            border-radius: var(--r-lg);
            box-shadow: var(--shadow);
            padding: 16px 18px;
            display:flex;
            justify-content:space-between;
            align-items:center;
            min-height: 86px;
        }
        .pd-scard.pd-active{
            border-color: var(--accent-bd);
            background: var(--accent-bg);
            box-shadow:none;
        }
        .pd-stitle{
            font-size: 12px;
            font-weight: 900;
            color: var(--muted);
            margin-bottom: 6px;
            letter-spacing: -.2px;
        }
        .pd-scard.pd-active .pd-stitle{ color: var(--text); }
        .pd-svalue{
            font-size: 30px;
            font-weight: 950;
            letter-spacing: -.6px;
            line-height: 1;
        }
        .pd-sunit{
            font-size: 13px;
            font-weight: 900;
            color: var(--muted);
            margin-left: 6px;
        }
        .pd-sbadge{
            width: 36px; height: 36px;
            border-radius: var(--r-sm);
            display:flex; align-items:center; justify-content:center;
            font-weight: 950;
            border: 1px solid var(--line);
            background:#fff;
            color: var(--text);
        }
        .pd-sbadge.pd-danger{
            border-color: rgba(220,38,38,.25);
            color: var(--danger);
        }
        @media (max-width: 860px){
            .pd-summary{ grid-template-columns: 1fr; }
        }

        .pd-bar{
            display:flex;
            align-items:center;
            gap: 14px;
            flex-wrap: wrap;
            margin: 10px 0 10px;
            background: #fff;
            border: 1px solid var(--line-soft);
            border-radius: var(--r-lg);
            box-shadow: var(--shadow);
            padding: 12px 14px;
        }
        .pd-btn-toggle{
            height: 40px;
            padding: 0 14px;
            border-radius: var(--r-md);
            border: 1px solid var(--line);
            background: #fff;
            color: var(--text);
            font-weight: 900;
            cursor:pointer;
            display:inline-flex;
            align-items:center;
            gap: 8px;
            white-space: nowrap;
        }
        .pd-btn-toggle:hover{ background:#f8fafc; }
        .pd-btn-toggle.pd-active{
            border-color: var(--accent-bd);
            background: var(--accent-bg);
            box-shadow:none;
        }

        .pd-check{
            display:flex;
            align-items:center;
            gap:8px;
            height: 40px;
            font-size: 13px;
            font-weight: 800;
            color:#334155;
            user-select:none;
            white-space: nowrap;
        }
        .pd-check input{ width:16px; height:16px; accent-color: var(--primary); }

        .pd-bar-right{
            margin-left:auto;
            display:flex;
            align-items:center;
            gap:10px;
            flex-wrap: wrap;
        }
        .pd-select{
            height: 40px;
            padding: 0 34px 0 12px;
            border: 1px solid var(--line);
            border-radius: var(--r-md);
            font-weight: 800;
            color: var(--text);
            outline:none;
            cursor:pointer;
            background:#fff;
        }
        .pd-search{
            display:flex;
            align-items:center;
        }
        .pd-input{
            height: 40px;
            width: 280px;
            padding: 0 12px;
            border: 1px solid var(--line);
            border-right:none;
            border-radius: var(--r-md) 0 0 var(--r-md);
            outline:none;
            font-size: 13px;
            font-weight: 800;
            color: var(--text);
            background:#fff;
        }
        .pd-input::placeholder{ color:#94a3b8; font-weight:800; }
        .pd-btn-search{
            height: 40px;
            padding: 0 16px;
            background: var(--primary);
            color:#fff;
            border: 1px solid var(--primary);
            border-radius: 0 var(--r-md) var(--r-md) 0;
            font-weight: 900;
            cursor:pointer;
            font-size: 13px;
            white-space: nowrap;
            box-shadow: 0 10px 18px rgba(23,49,96,.16);
        }

        .pd-tags{
            display:flex;
            flex-wrap: wrap;
            gap: 8px;
            margin: 10px 0 16px;
            padding: 0 2px;
        }
        .pd-tag{
            display:inline-flex;
            align-items:center;
            gap:8px;
            padding: 8px 12px;
            border-radius: var(--pill);
            background: var(--primary);
            color:#fff;
            font-size: 12px;
            font-weight: 900;
            user-select:none;
        }
        .pd-tag i{ cursor:pointer; opacity:.85; }
        .pd-tag i:hover{ opacity:1; }

        .pd-panel{
            display:none;
            background:#fff;
            border: 1px solid var(--line-soft);
            border-radius: var(--r-lg);
            box-shadow: var(--shadow);
            overflow:hidden;
            margin-bottom: 18px;
        }
        .pd-panel.pd-open{ display:block; }

        .pd-panel-body{ display:flex; min-height: 330px; }
        .pd-side{
            width: 170px;
            background:#f8fafc;
            border-right: 1px solid var(--line-soft);
        }
        .pd-tab{
            padding: 16px 14px;
            font-weight: 900;
            color:#64748b;
            cursor:pointer;
            border-bottom: 1px solid #eef2f7;
            font-size: 13px;
        }
        .pd-tab.pd-active{
            background:#fff;
            color: var(--text);
            border-left: 4px solid var(--primary);
        }
        .pd-content{ flex:1; padding: 18px; }
        .pd-pane{ display:none; }
        .pd-pane.pd-active{ display:block; }

        .pd-chip-search{
            width:100%;
            height: 40px;
            padding: 0 12px;
            margin-bottom: 14px;
            border: 1px solid var(--line);
            border-radius: var(--r-md);
            font-size: 13px;
            font-weight: 800;
            outline:none;
        }
        .pd-chip-search:focus{
            border-color: rgba(23,49,96,.35);
            box-shadow: 0 0 0 3px rgba(23,49,96,.12);
        }

        .pd-chiplist{
            display:flex;
            flex-wrap: wrap;
            gap: 8px;
            max-height: 220px;
            overflow-y: auto;
            padding-right: 4px;
        }
        .pd-chiplist::-webkit-scrollbar{ width: 8px; }
        .pd-chiplist::-webkit-scrollbar-thumb{ background:#cbd5e1; border-radius:999px; }
        .pd-chiplist::-webkit-scrollbar-track{ background:#eef2f7; border-radius:999px; }

        .pd-fchip{
            padding: 8px 12px;
            border: 1px solid var(--line);
            border-radius: var(--pill);
            font-size: 12px;
            font-weight: 900;
            color:#475569;
            background:#fff;
            cursor:pointer;
            transition: all .15s ease;
            display:inline-flex;
            align-items:center;
            user-select:none;
        }
        .pd-fchip:hover{ background:#f8fafc; }
        .pd-fchip.pd-selected{
            border-color: var(--accent-bd);
            background: var(--accent-bg);
            color: var(--text);
            box-shadow:none;
        }
        .pd-fchip input{ display:none; }

        .pd-budget-row{
            display:flex;
            align-items:center;
            gap: 12px;
            margin-top: 10px;
            flex-wrap: wrap;
        }
        .pd-budget{
            padding: 12px;
            border: 1px solid var(--line);
            border-radius: var(--r-md);
            width: 180px;
            text-align:center;
            font-weight: 900;
            font-size: 13px;
            outline:none;
            background:#fff;
        }
        .pd-budget:focus{
            border-color: rgba(23,49,96,.35);
            box-shadow: 0 0 0 3px rgba(23,49,96,.12);
        }

        .pd-panel-foot{
            padding: 12px 14px;
            border-top: 1px solid var(--line-soft);
            display:flex;
            justify-content:space-between;
            align-items:center;
            background:#fff;
        }
        .pd-btn-ghost{
            height: 40px;
            padding: 0 14px;
            background: var(--ghost-bg);
            color: var(--ghost-fg);
            border: 1px solid var(--ghost-bd);
            border-radius: var(--r-md);
            font-weight: 900;
            font-size: 13px;
            cursor:pointer;
            display:inline-flex;
            align-items:center;
            gap: 8px;
            white-space: nowrap;
        }

        .pd-list{
            display:flex;
            flex-direction: column;
            gap: 12px;
            margin-top: 10px;
        }
        .pd-empty{
            background:#fff;
            border: 1px solid var(--line-soft);
            border-radius: var(--r-lg);
            box-shadow: var(--shadow);
            padding: 18px;
            font-weight: 900;
            color: var(--muted);
            text-align:center;
        }

        .pd-card{
            width:100%;
            background: var(--card);
            border: 1px solid var(--line-soft);
            border-radius: var(--r-lg);
            box-shadow: var(--shadow);
            padding: 14px 16px;
            display:flex;
            gap: 16px;
            align-items: stretch;
            cursor:pointer;
        }
        .pd-card:hover{ filter:brightness(.995); }

        .pd-left{
            flex:1;
            min-width:0;
            display:flex;
            flex-direction: column;
            gap: 8px;
        }

        .pd-owner{ display:block; margin:0; padding:0; }
        .pd-owner-badge{
            display:inline-flex;
            align-items:center;
            gap:6px;
            padding: 6px 10px;
            border-radius: var(--pill);
            font-size: 12px;
            font-weight: 950;
            white-space: nowrap;
            border: 1px solid var(--line);
            background:#fff;
            color: var(--text);
        }
        .pd-owner-badge.pd-company{
            /*border-color: rgba(59,111,220,.22);*/
            /*background: rgba(59,111,220,.10);*/
            margin-bottom: 5px;
        }
        .pd-owner-badge.pd-personal{
            /*border-color: rgba(23,49,96,.18);*/
            /*background: rgba(23,49,96,.08);*/
            margin-bottom: 5px;
        }

        .pd-chips{
            display:flex;
            flex-wrap: wrap;
            gap: 6px;
        }
        .pd-chip{
            padding: 6px 10px;
            border-radius: var(--pill);
            font-size: 12px;
            font-weight: 900;
            background: rgba(59, 111, 220, .10);
            border-color: rgba(59, 111, 220, .22);
            color: rgba(17, 24, 39, .92);
            white-space: nowrap;
        }
        .pd-chip.pd-pos{
            background: rgba(23, 49, 96, .06);
            border-color: rgba(23, 49, 96, .14);
            color: rgba(23, 49, 96, .92);
        }

        .pd-title{
            font-size: 18px;
            font-weight: 950;
            line-height: 1.3;
            white-space: nowrap;
            overflow:hidden;
            text-overflow: ellipsis;
            letter-spacing: -.2px;
            margin-top:5px;
            margin-bottom: 20px;
        }

        .pd-right{
            width: 250px;
            border-left: 1px solid var(--line-soft);
            padding-left: 14px;
            display:flex;
            flex-direction: column;
            justify-content: space-between;
            align-items:flex-end;
            gap: 10px;
        }

        .pd-bm{
            width: 34px;
            height: 34px;
            border-radius: var(--r-sm);
            border: 1px solid var(--line);
            background:#fff;
            display:inline-flex;
            align-items:center;
            justify-content:center;
            cursor:pointer;
            transition: all .15s ease;
        }
        .pd-bm:hover{
            border-color: rgba(23,49,96,.25);
            background: rgba(23,49,96,.06);
            transform: translateY(-1px);
        }
        .pd-bm svg{
            width: 18px; height: 18px;
            fill:none;
            stroke:#64748b;
            stroke-width:2;
        }
        .pd-bm.pd-active{
            border-color: rgba(23,49,96,.28);
            background: rgba(23,49,96,.10);
        }
        .pd-bm.pd-active svg{
            fill: var(--primary);
            stroke: var(--primary);
        }

        .pd-rmid{
            width:100%;
            display:flex;
            flex-direction: column;
            align-items:flex-end;
            gap: 4px;
        }
        .pd-dday{ font-weight: 950; font-size: 14px; color: var(--danger); }
        .pd-app{ font-weight: 900; font-size: 12px; color: var(--muted); }

        .pd-rbot{
            width:100%;
            display:flex;
            justify-content: space-between;
            align-items:flex-end;
            gap: 10px;
        }
        .pd-dur{ font-weight: 900; font-size: 12px; color: var(--muted); line-height:1.2; white-space: nowrap; }
        .pd-money{ font-weight: 950; font-size: 18px; letter-spacing:-.2px; white-space: nowrap; }

        .pd-page{
            display:flex;
            justify-content:center;
            align-items:center;
            gap: 6px;
            margin: 18px 0 6px;
            flex-wrap: wrap;
        }
        .pd-plink{
            display:inline-flex;
            align-items:center;
            justify-content:center;
            height: 34px;
            min-width: 34px;
            padding: 0 12px;
            border-radius: var(--r-md);
            border: 1px solid var(--line);
            background:#fff;
            color: var(--text);
            font-weight: 950;
            text-decoration:none;
            cursor:pointer;
        }
        .pd-plink:hover{
            border-color: rgba(23,49,96,.22);
            background: rgba(23,49,96,.06);
        }
        .pd-plink.pd-active{
            background: var(--primary);
            border-color: var(--primary);
            color:#fff;
        }
        .pd-plink.pd-disabled{
            opacity:.45;
            pointer-events:none;
        }
        .pd-hint{
            text-align:center;
            color: var(--muted);
            font-size: 12px;
            font-weight: 800;
            margin-bottom: 12px;
        }

        @media (max-width: 860px){
            .pd-card{ flex-direction: column; }
            .pd-right{
                width: 100%;
                border-left:none;
                border-top: 1px solid var(--line-soft);
                padding-left:0;
                padding-top: 12px;
                align-items:flex-start;
            }
            .pd-rmid{ align-items:flex-start; }
        }
    </style>
</head>

<body>
<jsp:include page="/WEB-INF/views/common/headerBase.jsp" />

<div class="pd-wrap">


    <div class="pageTitle">
        <div class="titleBox">
            <h1>프로젝트 찾기</h1>
            <p class="bm-sub">프로젝트를 찾을 수 있긔</p>
        </div>

        <c:if test="${isClient}">
            <div class="pd-register">
                <a href="${pageContext.request.contextPath}/project/create" class="pd-btn-primary">프로젝트 등록하기</a>
            </div>
        </c:if>
    </div>


    <!-- SUMMARY -->
    <div class="pd-summary">
        <a href="${pageContext.request.contextPath}/project/dashboard?summary=${summary eq 'today' ? 'all' : 'today'}&page=1&size=${size}&onlyActive=${onlyActive}&sort=${sort}&keyword=${fn:escapeXml(keyword)}">
            <div class="pd-scard ${summary eq 'today' ? 'pd-active' : ''}">
                <div>
                    <div class="pd-stitle">오늘의 신규 프로젝트</div>
                    <div>
                        <span class="pd-svalue">${empty todayNewCount ? 0 : todayNewCount}</span>
                        <span class="pd-sunit">건</span>
                    </div>
                </div>
                <div class="pd-sbadge">+</div>
            </div>
        </a>

        <a href="${pageContext.request.contextPath}/project/dashboard?summary=${summary eq 'deadline7' ? 'all' : 'deadline7'}&page=1&size=${size}&onlyActive=${onlyActive}&sort=${sort}&keyword=${fn:escapeXml(keyword)}">
            <div class="pd-scard ${summary eq 'deadline7' ? 'pd-active' : ''}">
                <div>
                    <div class="pd-stitle">마감 임박 (7일 이내)</div>
                    <div>
                        <span class="pd-svalue" style="color:var(--danger);">${empty deadline7Count ? 0 : deadline7Count}</span>
                        <span class="pd-sunit">건</span>
                    </div>
                </div>
                <div class="pd-sbadge pd-danger">!</div>
            </div>
        </a>
    </div>

    <!-- FILTER FORM -->
    <form id="pdForm" method="get" action="${pageContext.request.contextPath}/project/dashboard">
        <div class="pd-bar">
            <button type="button" class="pd-btn-toggle" id="pdToggleBtn">
                <i class="fa-solid fa-sliders"></i> 필터 옵션
            </button>

            <label class="pd-check">
                <input type="checkbox" name="onlyActive" value="true" <c:if test="${onlyActive}">checked</c:if>>
                마감된 프로젝트 보기
            </label>

            <div class="pd-bar-right">
                <select name="sort" class="pd-select">
                    <option value="latest" ${sort == 'latest' ? 'selected' : ''}>등록일순</option>
                    <option value="budget_desc" ${sort == 'budget_desc' ? 'selected' : ''}>예산순</option>
                    <option value="deadline_asc" ${sort == 'deadline_asc' ? 'selected' : ''}>마감임박순</option>
                </select>

                <div class="pd-search">
                    <input type="text" name="keyword" class="pd-input" placeholder="프로젝트 제목 검색" value="${fn:escapeXml(keyword)}">
                    <button type="submit" class="pd-btn-search">검색</button>
                </div>
            </div>
        </div>

        <div class="pd-tags" id="pdTags"></div>

        <div class="pd-panel" id="pdPanel">
            <div class="pd-panel-body">
                <div class="pd-side">
                    <div class="pd-tab pd-active" data-target="pdPanePos">포지션</div>
                    <div class="pd-tab" data-target="pdPaneSkill">스킬</div>
                    <div class="pd-tab" data-target="pdPaneBudget">예산</div>
                </div>

                <div class="pd-content">
                    <!-- POSITION -->
                    <div id="pdPanePos" class="pd-pane pd-active">
                        <input type="text" class="pd-chip-search" placeholder="포지션 검색...">
                        <div class="pd-chiplist" data-chiplist="position">
                            <c:forEach var="pos" items="${positionList}">
                                <c:set var="isPosChecked" value="false"/>
                                <c:if test="${not empty paramValues.positionIds}">
                                    <c:forEach var="pid" items="${paramValues.positionIds}">
                                        <c:if test="${pid eq pos.stackId}"><c:set var="isPosChecked" value="true"/></c:if>
                                    </c:forEach>
                                </c:if>

                                <label class="pd-fchip ${isPosChecked ? 'pd-selected' : ''}"
                                       data-name="${fn:escapeXml(pos.stackName)}">
                                        ${fn:escapeXml(pos.stackName)}
                                    <input type="checkbox" name="positionIds" value="${pos.stackId}" ${isPosChecked ? 'checked' : ''}>
                                </label>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- SKILL -->
                    <div id="pdPaneSkill" class="pd-pane">
                        <input type="text" class="pd-chip-search" placeholder="기술 스택 검색...">
                        <div class="pd-chiplist" data-chiplist="skill">
                            <c:forEach var="skill" items="${skillList}">
                                <c:set var="isSkillChecked" value="false"/>
                                <c:if test="${not empty paramValues.stackIds}">
                                    <c:forEach var="sid" items="${paramValues.stackIds}">
                                        <c:if test="${sid eq skill.stackId}"><c:set var="isSkillChecked" value="true"/></c:if>
                                    </c:forEach>
                                </c:if>

                                <label class="pd-fchip ${isSkillChecked ? 'pd-selected' : ''}"
                                       data-name="${fn:escapeXml(skill.stackName)}">
                                        ${fn:escapeXml(skill.stackName)}
                                    <input type="checkbox" name="stackIds" value="${skill.stackId}" ${isSkillChecked ? 'checked' : ''}>
                                </label>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- BUDGET -->
                    <div id="pdPaneBudget" class="pd-pane">
                        <h4 style="margin:0 0 10px; font-weight:950; color:var(--text); font-size:13px;">예산 범위 (원)</h4>
                        <div class="pd-budget-row">
                            <input type="text" name="minBudget" class="pd-budget" placeholder="최소금액" value="${minBudget}">
                            <span style="font-weight:950; color:#94a3b8;">—</span>
                            <input type="text" name="maxBudget" class="pd-budget" placeholder="최대금액" value="${maxBudget}">
                        </div>
                    </div>

                </div>
            </div>

            <div class="pd-panel-foot">
                <button type="button" class="pd-btn-ghost" id="pdResetBtn">
                    <i class="fa-solid fa-rotate-right"></i> 필터 초기화
                </button>
                <button type="submit" class="pd-btn-primary" style="height:40px;">적용하기</button>
            </div>
        </div>

        <input type="hidden" name="page" id="pdPage" value="${page}"/>
        <input type="hidden" name="size" value="${empty size ? 10 : size}"/>
        <input type="hidden" name="summary" value="${empty summary ? 'all' : summary}"/>
    </form>

    <!-- LIST -->
    <div class="pd-list">
        <c:if test="${empty projectList}">
            <div class="pd-empty">조건에 맞는 프로젝트가 없습니다.</div>
        </c:if>

        <c:forEach var="p" items="${projectList}">
            <div class="pd-card"
                 onclick="location.href='${pageContext.request.contextPath}/project/detail?projectId=${p.projectId}&page=${page}&size=${size}&onlyActive=${onlyActive}&sort=${sort}&summary=${summary}&keyword=${fn:escapeXml(keyword)}'">

                <div class="pd-left">

                    <div class="pd-owner">
                        <c:choose>
                            <c:when test="${not empty p.companyName}">
                                <span class="pd-owner-badge pd-company">🏢 ${fn:escapeXml(p.companyName)}</span>
                            </c:when>
                            <c:otherwise>
                                <span class="pd-owner-badge pd-personal">👤 ${fn:escapeXml(p.clientName)}</span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="pd-chips">
                        <c:if test="${not empty p.stacks}">
                            <c:forEach var="s" items="${p.stacks}">
                                <c:if test="${not empty s.category and s.category eq 'POSITION'}">
                                    <span class="pd-chip pd-pos">${fn:escapeXml(s.stackName)}</span>
                                </c:if>
                            </c:forEach>
                        </c:if>
                    </div>

                    <div class="pd-title">${fn:escapeXml(p.title)}</div>

                    <div class="pd-chips">
                        <c:if test="${not empty p.stacks}">
                            <c:forEach var="s" items="${p.stacks}">
                                <c:if test="${not empty s.category and s.category eq 'SKILL'}">
                                    <span class="pd-chip">${fn:escapeXml(s.stackName)}
                                    <c:if test="${s.stackLevel != null}">
                                        Lv.${s.stackLevel}
                                    </c:if>
                                    </span>

                                </c:if>
                            </c:forEach>
                        </c:if>
                    </div>
                </div>

                <div class="pd-right">
                    <button type="button"
                            class="pd-bm ${p.bookmarked ? 'pd-active' : ''}"
                            data-project-id="${p.projectId}"
                            onclick="event.preventDefault(); event.stopPropagation();">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M6 3h12a1 1 0 0 1 1 1v17l-7-4-7 4V4a1 1 0 0 1 1-1z"></path>
                        </svg>
                    </button>

                    <div class="pd-rmid">
                        <div class="pd-dday">
                            <c:choose>
                                <c:when test="${p.dday >= 0}">마감 D-${p.dday}</c:when>
                                <c:otherwise>마감</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="pd-app">지원자 ${p.applicantCount}명</div>
                    </div>

                    <div class="pd-rbot">
                        <div class="pd-dur">예상 기간<br/>${fn:escapeXml(p.estDuration)}</div>
                        <div class="pd-money">
                            <fmt:formatNumber value="${p.budget / 10000}" maxFractionDigits="0"/>만원
                        </div>
                    </div>
                </div>

            </div>
        </c:forEach>
    </div>

    <!-- PAGINATION -->
    <c:if test="${totalPages > 1}">
        <div class="pd-page">
            <c:choose>
                <c:when test="${hasPrevBlock}">
                    <span class="pd-plink" onclick="pdGoPage(${prevBlockPage})">&laquo;</span>
                </c:when>
                <c:otherwise>
                    <span class="pd-plink pd-disabled">&laquo;</span>
                </c:otherwise>
            </c:choose>

            <c:choose>
                <c:when test="${page > 1}">
                    <span class="pd-plink" onclick="pdGoPage(${page-1})">&lsaquo;</span>
                </c:when>
                <c:otherwise>
                    <span class="pd-plink pd-disabled">&lsaquo;</span>
                </c:otherwise>
            </c:choose>

            <c:forEach var="pno" begin="${startPage}" end="${endPage}">
                <span class="pd-plink ${pno == page ? 'pd-active' : ''}" onclick="pdGoPage(${pno})">${pno}</span>
            </c:forEach>

            <c:choose>
                <c:when test="${page < totalPages}">
                    <span class="pd-plink" onclick="pdGoPage(${page+1})">&rsaquo;</span>
                </c:when>
                <c:otherwise>
                    <span class="pd-plink pd-disabled">&rsaquo;</span>
                </c:otherwise>
            </c:choose>

            <c:choose>
                <c:when test="${hasNextBlock}">
                    <span class="pd-plink" onclick="pdGoPage(${nextBlockPage})">&raquo;</span>
                </c:when>
                <c:otherwise>
                    <span class="pd-plink pd-disabled">&raquo;</span>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="pd-hint">${page} / ${totalPages} 페이지</div>
    </c:if>

</div>

<script>
    (function(){

        function pdUncomma(str){ return String(str || "").replace(/[^\d]+/g, ""); }
        function pdComma(str){
            str = String(str || "");
            return str.replace(/(\d)(?=(?:\d{3})+(?!\d))/g, "$1,");
        }
        function getChipName(chip){
            var dn = (chip && chip.getAttribute("data-name")) ? chip.getAttribute("data-name") : "";
            dn = (dn || "").trim();
            if(dn) return dn;
            return (chip ? chip.textContent : "").replace(/\s+/g," ").trim();
        }


        window.pdGoPage = function(pageNo){
            var pageInput = document.getElementById("pdPage");
            if(pageInput) pageInput.value = pageNo;
            window.pdSubmit();
        }
        window.pdSubmit = function(){
            document.querySelectorAll(".pd-budget").forEach(function(el){
                el.value = pdUncomma(el.value);
            });
            var form = document.getElementById("pdForm");
            if(form) form.submit();
        }

        document.addEventListener("DOMContentLoaded", function(){

            var alertMsg = "<c:out value='${alertMsg}'/>";
            if(alertMsg && alertMsg !== "null") alert(alertMsg);

            var toggleBtn = document.getElementById("pdToggleBtn");
            var panel = document.getElementById("pdPanel");
            var tabs = document.querySelectorAll(".pd-tab");
            var panes = document.querySelectorAll(".pd-pane");
            var tags = document.getElementById("pdTags");
            var resetBtn = document.getElementById("pdResetBtn");

            // panel toggle
            if(toggleBtn && panel){
                toggleBtn.addEventListener("click", function(e){
                    e.preventDefault();
                    panel.classList.toggle("pd-open");
                    toggleBtn.classList.toggle("pd-active");
                });
            }

            // tab switch
            tabs.forEach(function(t){
                t.addEventListener("click", function(){
                    var targetId = t.getAttribute("data-target");
                    tabs.forEach(function(x){ x.classList.remove("pd-active"); });
                    panes.forEach(function(p){ p.classList.remove("pd-active"); });
                    t.classList.add("pd-active");
                    var target = document.getElementById(targetId);
                    if(target) target.classList.add("pd-active");
                });
            });

            // chip search
            document.querySelectorAll(".pd-chip-search").forEach(function(input){
                input.addEventListener("input", function(){
                    var val = (input.value || "").toLowerCase();
                    var chipList = input.nextElementSibling;
                    if(!chipList) return;
                    chipList.querySelectorAll(".pd-fchip").forEach(function(chip){
                        var name = (chip.getAttribute("data-name") || "").toLowerCase();
                        chip.style.display = (name.indexOf(val) >= 0) ? "inline-flex" : "none";
                    });
                });
            });

            // render tags
            function renderTags(){
                if(!tags) return;
                tags.innerHTML = "";

                // position/skill
                document.querySelectorAll(".pd-fchip input[type='checkbox']").forEach(function(chk){
                    if(!chk.checked) return;

                    var chip = chk.closest(".pd-fchip");
                    var name = getChipName(chip);
                    var type = chk.name; // positionIds / stackIds
                    var prefix = (type === "positionIds") ? "포지션" : (type === "stackIds" ? "스킬" : "필터");

                    var tag = document.createElement("span");
                    tag.className = "pd-tag";

                    var text = document.createElement("span");
                    text.textContent = prefix + ": " + name;

                    var icon = document.createElement("i");
                    icon.className = "fa-solid fa-xmark";
                    icon.addEventListener("click", function(e){
                        e.preventDefault(); e.stopPropagation();
                        chk.checked = false;
                        if(chip) chip.classList.remove("pd-selected");
                        renderTags();
                    });

                    tag.appendChild(text);
                    tag.appendChild(icon);
                    tags.appendChild(tag);
                });

                // budget
                var minEl = document.querySelector("input[name='minBudget']");
                var maxEl = document.querySelector("input[name='maxBudget']");
                var minV = (minEl && minEl.value) ? minEl.value.trim() : "";
                var maxV = (maxEl && maxEl.value) ? maxEl.value.trim() : "";

                if(minV || maxV){
                    var minText = minV ? pdComma(pdUncomma(minV)) : "0";
                    var maxText = maxV ? pdComma(pdUncomma(maxV)) : "무제한";

                    var tagB = document.createElement("span");
                    tagB.className = "pd-tag";

                    var textB = document.createElement("span");
                    textB.textContent = "예산: " + minText + " ~ " + maxText;

                    var iconB = document.createElement("i");
                    iconB.className = "fa-solid fa-xmark";
                    iconB.addEventListener("click", function(e){
                        e.preventDefault(); e.stopPropagation();
                        if(minEl) minEl.value = "";
                        if(maxEl) maxEl.value = "";
                        renderTags();
                    });

                    tagB.appendChild(textB);
                    tagB.appendChild(iconB);
                    tags.appendChild(tagB);
                }

                // keyword
                var kwEl = document.querySelector("input[name='keyword']");
                var kw = (kwEl && kwEl.value) ? kwEl.value.trim() : "";
                if(kw){
                    var tagK = document.createElement("span");
                    tagK.className = "pd-tag";

                    var textK = document.createElement("span");
                    textK.textContent = "검색: " + kw;

                    var iconK = document.createElement("i");
                    iconK.className = "fa-solid fa-xmark";
                    iconK.addEventListener("click", function(e){
                        e.preventDefault(); e.stopPropagation();
                        if(kwEl) kwEl.value = "";
                        renderTags();
                    });

                    tagK.appendChild(textK);
                    tagK.appendChild(iconK);
                    tags.appendChild(tagK);
                }
            }

            // chip click
            document.querySelectorAll(".pd-fchip").forEach(function(chip){
                var chk = chip.querySelector("input[type='checkbox']");
                if(!chk) return;

                chip.classList.toggle("pd-selected", chk.checked);

                chip.addEventListener("click", function(e){
                    e.preventDefault(); e.stopPropagation();
                    chk.checked = !chk.checked;
                    chip.classList.toggle("pd-selected", chk.checked);
                    renderTags();
                });
            });

            // budget formatting
            document.querySelectorAll(".pd-budget").forEach(function(el){
                if(el.value) el.value = pdComma(pdUncomma(el.value));
                el.addEventListener("input", function(){
                    var raw = pdUncomma(el.value);
                    el.value = raw ? pdComma(raw) : "";
                    renderTags();
                });
            });

            // keyword update
            var kwEl2 = document.querySelector("input[name='keyword']");
            if(kwEl2) kwEl2.addEventListener("input", renderTags);

            // reset
            if(resetBtn){
                resetBtn.addEventListener("click", function(){
                    document.querySelectorAll(".pd-fchip input[type='checkbox']").forEach(function(chk){ chk.checked = false; });
                    document.querySelectorAll(".pd-fchip").forEach(function(chip){ chip.classList.remove("pd-selected"); });

                    document.querySelectorAll(".pd-budget").forEach(function(el){ el.value = ""; });
                    if(kwEl2) kwEl2.value = "";

                    document.querySelectorAll(".pd-chip-search").forEach(function(si){
                        si.value = "";
                        var chipList = si.nextElementSibling;
                        if(chipList){
                            chipList.querySelectorAll(".pd-fchip").forEach(function(ch){ ch.style.display = "inline-flex"; });
                        }
                    });

                    renderTags();
                });
            }

            // bookmark
            var ctx = "${pageContext.request.contextPath}";
            document.querySelectorAll(".pd-bm").forEach(function(btn){
                btn.addEventListener("click", async function(e){
                    e.preventDefault(); e.stopPropagation();
                    var projectId = btn.getAttribute("data-project-id");
                    try{
                        var res = await fetch(ctx + "/project/bookmark/toggle", {
                            method:"POST",
                            headers:{ "Content-Type":"application/x-www-form-urlencoded; charset=UTF-8" },
                            body: new URLSearchParams({ projectId: projectId })
                        });
                        var data = await res.json();
                        if(!data.ok){
                            alert(data.message === "LOGIN_REQUIRED" ? "로그인이 필요합니다." : "실패");
                            return;
                        }
                        btn.classList.toggle("pd-active", !!data.bookmarked);
                    }catch(err){
                        console.error(err);
                        alert("북마크 처리 중 오류");
                    }
                });
            });

            // initial
            renderTags();
        });
    })();
</script>

</body>
</html>
