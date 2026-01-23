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
        :root {
            --bg: #f8fafc;
            --card: #ffffff;
            --text: #111827;
            --muted: #6b7280;
            --line: #eef2f7;

            --primary: #5c3cce;
            --chip-skill-bg: #eef2ff;
            --chip-skill-fg: #3730a3;

            --chip-pos-bg: #ecfeff;
            --chip-pos-fg: #0f766e;

            --danger: #dc2626;
            --shadow: 0 10px 28px rgba(15, 23, 42, 0.08);
            --radius: 18px;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Pretendard, Arial, sans-serif;
            background: var(--bg);
            color: var(--text);
        }

        .dashboard-wrap {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 16px;
        }

        /* 검색 */
        .search-box {
            display: flex;
            gap: 10px;
            align-items: center;
            flex-wrap: wrap;
            margin-bottom: 18px;
        }

        .search-box input[type="text"] {
            width: 340px;
            padding: 10px 12px;
            border-radius: 12px;
            border: 1px solid #d1d5db;
            outline: none;
            background: #fff;
            font-weight: 700;
        }

        .search-box button {
            padding: 10px 14px;
            border: none;
            border-radius: 12px;
            background: var(--primary);
            color: #fff;
            font-weight: 900;
            cursor: pointer;
        }

        .search-box label {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 13px;
            font-weight: 800;
            color: #374151;
            user-select: none;
        }

        /* 리스트(한 줄 한 카드) */
        .project-list {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .project-card {
            width: 100%;
            background: var(--card);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            padding: 18px 20px;
            display: flex;
            gap: 22px;
            align-items: stretch;
        }

        /* 카드 전체를 링크로 쓸 때 */
        .project-link {
            display: block;
            text-decoration: none;
            color: inherit;
        }

        .project-link:focus-visible {
            outline: 3px solid rgba(92, 60, 206, 0.25);
            border-radius: var(--radius);
        }


        .left {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 10px;
            min-width: 0;
        }

        .title {
            font-size: 23px;
            font-weight: 950;
            line-height: 1.35;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .chips {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
        }

        .chip {
            padding: 5px 10px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 900;
            background: var(--chip-skill-bg);
            color: var(--chip-skill-fg);
        }

        .chip.position {
            background: var(--chip-pos-bg);
            color: var(--chip-pos-fg);
        }

        .meta {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            font-size: 13px;
            color: #4b5563;
            font-weight: 800;
        }

        /* 오른쪽 영역 */
        .right {
            width: 260px;
            border-left: 1px solid var(--line);
            padding-left: 18px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            align-items: flex-end;
            gap: 10px;
        }

        .right-top {
            width: 100%;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 10px;
        }

        /* 북마크 버튼 */
        .bookmark-btn {
            width: 36px;
            height: 36px;
            border-radius: 12px;
            border: 1px solid #e5e7eb;
            background: #fff;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all .15s ease;
        }

        .bookmark-btn:hover {
            border-color: #c7d2fe;
            transform: translateY(-1px);
        }

        .bookmark-btn svg {
            width: 18px;
            height: 18px;
            fill: none;
            stroke: #6b7280;
            stroke-width: 2;
        }

        /* 북마크 활성화(나중에 JS/서버 연동 시 클래스만 붙이면 됨) */
        .bookmark-btn.is-active svg {
            fill: #5c3cce;
            stroke: #5c3cce;
        }

        .right-mid {
            width: 100%;
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            gap: 6px;
        }

        .dday {
            font-weight: 950;
            font-size: 16px;
            color: var(--danger);
        }

        .applicants {
            font-weight: 900;
            font-size: 13px;
            color: #6b7280;
        }

        .right-bottom {
            width: 100%;
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            gap: 12px;
        }

        .duration {
            font-weight: 900;
            font-size: 12px;
            color: #6b7280;
            text-align: left;
            line-height: 1.2;
            white-space: nowrap;
        }

        .budget {
            font-weight: 950;
            font-size: 22px;
            letter-spacing: -0.2px;
            white-space: nowrap;
        }

        .empty {
            background: #fff;
            padding: 22px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            font-weight: 900;
            color: #6b7280;
            text-align: center;
        }

        /* 페이징 */
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 6px;
            margin: 24px 0 6px;
            flex-wrap: wrap;
        }

        .page-link {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            height: 36px;
            min-width: 36px;
            padding: 0 12px;
            border-radius: 12px;
            border: 1px solid #e5e7eb;
            background: #fff;
            color: #111827;
            font-weight: 900;
            text-decoration: none;
        }

        .page-link:hover {
            border-color: #c7d2fe;
        }

        .page-link.active {
            background: var(--primary);
            border-color: var(--primary);
            color: #fff;
        }

        .page-link.disabled {
            opacity: .45;
            pointer-events: none;
        }

        .hint {
            text-align: center;
            color: #6b7280;
            font-size: 12px;
            font-weight: 800;
            margin-bottom: 14px;
        }

        @media (max-width: 860px) {
            .project-card {
                flex-direction: column;
            }

            .right {
                width: 100%;
                border-left: none;
                border-top: 1px solid var(--line);
                padding-left: 0;
                padding-top: 12px;
                align-items: flex-start;
            }

            .right-top {
                justify-content: flex-end;
            }

            .right-mid {
                align-items: flex-start;
            }

            .right-bottom {
                justify-content: space-between;
            }
        }

        /* 상단 요약 카드 */
        .summary-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
            margin: 6px 0 18px;
        }

        .summary-card {
            background: var(--card);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            padding: 18px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .summary-title {
            font-size: 13px;
            font-weight: 900;
            color: var(--muted);
            margin-bottom: 6px;
        }

        .summary-value {
            font-size: 34px;
            font-weight: 950;
            letter-spacing: -0.6px;
        }

        .summary-unit {
            font-size: 14px;
            font-weight: 900;
            color: var(--muted);
            margin-left: 6px;
        }

        .summary-badge {
            width: 38px;
            height: 38px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 950;
            border: 1px solid #e5e7eb;
            background: #fff;
        }

        .summary-badge.danger {
            border-color: rgba(220, 38, 38, 0.25);
            color: var(--danger);
        }

        @media (max-width: 860px) {
            .summary-grid {
                grid-template-columns: 1fr;
            }
        }


        /* 요약카드 클릭/선택 강조 */
        .summary-link {
            text-decoration: none;
            color: inherit;
            display: block;
        }

        .summary-card.is-active {
            border: 2px solid rgba(92, 60, 206, 0.35);
            box-shadow: 0 14px 34px rgba(92, 60, 206, 0.12);
            transform: translateY(-1px);
        }

        .summary-card.is-active .summary-title {
            color: #4f46e5;
        }

        .summary-card.is-active .summary-badge {
            border-color: rgba(92, 60, 206, 0.35);
        }

        /* 회사 / 개인 표시 */
        .owner-name {
            margin-bottom: 4px;
        }

        .badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 10px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 900;
            white-space: nowrap;
        }

        .badge.company {
            background: #eef2ff;
            color: #3730a3;
            border: 1px solid #c7d2fe;
        }

        .badge.personal {
            background: #ecfeff;
            color: #0f766e;
            border: 1px solid #99f6e4;
        }

        .register-area {
            display: flex;
            justify-content: flex-end;
            margin-bottom: 20px;
        }

        .btn-register {
            padding: 12px 24px;
            background: var(--primary);
            color: #fff;
            border-radius: 14px;
            text-decoration: none;
            font-weight: 900;
        }

        /* --- 통합 검색 및 필터 바 CSS (수정됨) --- */
        :root {
            --primary-purple: #5c3cce;
            --primary-light: #f3f0ff;
            --border-color: #e2e8f0;
        }

        /* 필터 바 컨테이너 */
        .filter-search-bar {
            display: flex; align-items: center; gap: 16px; margin-bottom: 12px;
            background: #fff; padding: 12px 24px; border-radius: 16px;
            border: 1px solid var(--border-color); box-shadow: 0 4px 20px rgba(0,0,0,0.02); flex-wrap: wrap;
        }

        /* 활성 태그 영역 */
        .active-tags-bar {
            display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 20px; min-height: 0; padding: 0 4px;
        }

        /* 선택된 태그 스타일 */
        .active-tag {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 8px 18px;
            background: var(--primary-purple);
            border-radius: 999px;
            font-size: 14px; font-weight: 600; color: #fff;
            box-shadow: 0 3px 6px rgba(92, 60, 206, 0.2);
            animation: popIn 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            user-select: none;
        }
        @keyframes popIn { from { transform: scale(0.8); opacity: 0; } to { transform: scale(1); opacity: 1; } }

        /* X 아이콘 스타일 */
        .active-tag i {
            cursor: pointer;
            font-size: 14px;
            color: #fff;
            opacity: 0.8;
            transition: all 0.2s;
            display: flex; align-items: center;
        }
        .active-tag i:hover { opacity: 1; transform: scale(1.2); }


        /* 필터 토글 버튼 */
        .btn-filter-toggle {
            height: 44px; padding: 0 24px; border-radius: 12px;
            border: 1px solid var(--primary-purple); background: #fff;
            font-size: 15px; font-weight: 700; color: var(--primary-purple);
            cursor: pointer; display: flex; align-items: center; gap: 8px; transition: all 0.2s;
        }
        .btn-filter-toggle:hover { background: var(--primary-light); }
        .btn-filter-toggle.active { background: var(--primary-purple); color: #fff; }

        /* 체크박스 라벨 */
        .checkbox-label {
            display: flex; align-items: center; gap: 8px; font-size: 15px; font-weight: 600; color: #333; cursor: pointer; user-select: none; height: 44px;
        }
        .checkbox-label input { width: 18px; height: 18px; accent-color: var(--primary-purple); }

        /* 검색 그룹 */
        .search-group { margin-left: auto; display: flex; align-items: center; gap: 10px; }
        .sort-select { height: 44px; padding: 0 32px 0 16px; border: 1px solid #d1d5db; border-radius: 8px; font-weight: 600; color: #333; outline: none; cursor: pointer; background: #fff; }
        .search-input-wrap { display: flex; align-items: center; }
        .search-input { height: 44px; width: 280px; padding: 0 16px; border: 1px solid #d1d5db; border-radius: 8px 0 0 8px; outline: none; font-size: 14px; }
        .search-btn { height: 44px; padding: 0 24px; background: var(--primary-purple); color: #fff; border: 1px solid var(--primary-purple); border-radius: 0 8px 8px 0; font-weight: 700; cursor: pointer; font-size: 15px; }

        /* 필터 패널 */
        .filter-panel { display: none; background: #fff; border: 1px solid var(--border-color); border-radius: 16px; margin-bottom: 24px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.08); }
        .filter-panel.open { display: block; }
        .filter-body { display: flex; min-height: 350px; }
        .filter-sidebar { width: 160px; background: #f8fafc; border-right: 1px solid var(--border-color); }
        .filter-tab { padding: 20px; font-weight: 700; color: #94a3b8; cursor: pointer; border-bottom: 1px solid #f1f5f9; text-align: center; font-size: 15px; }
        .filter-tab.active { background: #fff; color: var(--primary-purple); border-left: 5px solid var(--primary-purple); }
        .filter-content { flex: 1; padding: 30px; }
        .tab-content { display: none; }
        .tab-content.active { display: block; }

        /* 칩 스타일 */
        .stack-search-input { width: 100%; height: 46px; padding: 0 16px; margin-bottom: 24px; border: 1px solid #d1d5db; border-radius: 8px; font-size: 15px; display: block; }
        .stack-search-input:focus { border-color: var(--primary-purple); outline: none; }
        .chip-list { display: flex; flex-wrap: wrap; gap: 10px; max-height: 240px; overflow-y: auto; }
        .filter-chip { padding: 8px 20px; border: 1px solid #e2e8f0; border-radius: 24px; font-size: 14px; font-weight: 600; color: #64748b; background: #fff; cursor: pointer; transition: all 0.2s; display: inline-flex; align-items: center; }
        .filter-chip:hover { border-color: #cbd5e1; background: #f8fafc; }
        .filter-chip.selected { background: var(--primary-purple); border-color: var(--primary-purple); color: #fff; box-shadow: 0 4px 10px rgba(92, 60, 206, 0.2); }
        .filter-chip input { display: none; }
        .budget-wrap { display: flex; align-items: center; gap: 15px; margin-top: 15px; }
        .budget-field { padding: 14px; border: 1px solid #d1d5db; border-radius: 8px; width: 180px; text-align: center; font-weight: 700; font-size: 15px; }

        /* [수정] 하단 버튼 영역 (양쪽 정렬) */
        .panel-footer {
            padding: 20px 30px; border-top: 1px solid var(--border-color);
            display: flex; justify-content: space-between; /* 양쪽 끝으로 */
            align-items: center;
            background: #fff;
        }
        .btn-apply { padding: 12px 40px; background: var(--primary-purple); color: #fff; border: none; border-radius: 8px; font-weight: 700; font-size: 16px; cursor: pointer; }
        .btn-apply:hover { background: #4a2fb3; }

        /* [추가] 초기화 버튼 스타일 */
        .btn-reset {
            padding: 12px 24px;
            background: #f1f5f9;
            color: #64748b;
            border: none;
            border-radius: 8px;
            font-weight: 700;
            font-size: 15px;
            cursor: pointer;
            display: flex; align-items: center; gap: 8px;
            transition: all 0.2s;
        }
        .btn-reset:hover { background: #e2e8f0; color: #334155; }
        .btn-reset i { font-size: 14px; }

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
    <%--<form class="search-box" method="get" action="${pageContext.request.contextPath}/project/dashboard">
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
    </form>--%>

    <form id="filterForm" method="get" action="${pageContext.request.contextPath}/project/dashboard">

        <div class="filter-search-bar">
            <button type="button" class="btn-filter-toggle" id="filterToggleBtn">
                필터 옵션
            </button>

            <label class="checkbox-label" style="margin-left: 15px;">
                <input type="checkbox" name="onlyActive" value="true" <c:if test="${onlyActive}">checked</c:if>>
                마감된 프로젝트 포함
            </label>

            <div class="search-group">
                <select name="sort" class="sort-select">
                    <option value="latest" ${sort == 'latest' ? 'selected' : ''}>등록일순</option>
                    <option value="budget_desc" ${sort == 'budget_desc' ? 'selected' : ''}>예산순</option>
                    <option value="deadline_asc" ${sort == 'deadline_asc' ? 'selected' : ''}>마감임박순</option>
                </select>

                <div class="search-input-wrap">
                    <input type="text" name="keyword" class="search-input"
                           placeholder="프로젝트 제목 검색" value="${fn:escapeXml(keyword)}"/>
                    <button type="submit" class="search-btn">검색</button>
                </div>
            </div>
        </div>

        <div class="active-tags-bar" id="activeTagsContainer"></div>

        <div class="filter-panel" id="filterPanel">
            <div class="filter-body">
                <div class="filter-sidebar">
                    <div class="filter-tab active" data-target="tab-position">포지션</div>
                    <div class="filter-tab" data-target="tab-skill">스킬</div>
                    <div class="filter-tab" data-target="tab-budget">예산</div>
                </div>

                <div class="filter-content">

                    <div id="tab-position" class="tab-content active">
                        <input type="text" class="stack-search-input" placeholder="포지션 검색..."
                               onkeyup="filterChips(this)">
                        <div class="chip-list">
                            <c:forEach var="pos" items="${positionList}">
                                <c:set var="isPosChecked" value="false"/>
                                <c:if test="${not empty paramValues.positionIds}">
                                    <c:forEach var="pid" items="${paramValues.positionIds}">
                                        <c:if test="${pid eq pos.stackId}"><c:set var="isPosChecked"
                                                                                  value="true"/></c:if>
                                    </c:forEach>
                                </c:if>

                                <label class="filter-chip ${isPosChecked ? 'selected' : ''}"
                                       data-name="${pos.stackName}">
                                        ${pos.stackName}
                                    <input type="checkbox" name="positionIds"
                                           value="${pos.stackId}" ${isPosChecked ? 'checked' : ''}>
                                </label>
                            </c:forEach>
                        </div>
                    </div>

                    <div id="tab-skill" class="tab-content">
                        <input type="text" class="stack-search-input" placeholder="기술 스택 검색..."
                               onkeyup="filterChips(this)">
                        <div class="chip-list">
                            <c:forEach var="skill" items="${skillList}">
                                <c:set var="isSkillChecked" value="false"/>
                                <c:if test="${not empty paramValues.stackIds}">
                                    <c:forEach var="sid" items="${paramValues.stackIds}">
                                        <c:if test="${sid eq skill.stackId}"><c:set var="isSkillChecked" value="true"/></c:if>
                                    </c:forEach>
                                </c:if>

                                <label class="filter-chip ${isSkillChecked ? 'selected' : ''}"
                                       data-name="${skill.stackName}">
                                        ${skill.stackName}
                                    <input type="checkbox" name="stackIds"
                                           value="${skill.stackId}" ${isSkillChecked ? 'checked' : ''}>
                                </label>
                            </c:forEach>
                        </div>
                    </div>

                    <div id="tab-budget" class="tab-content">
                        <h4 style="margin-bottom:12px; font-weight:800; color:#374151;">예산 범위 (원)</h4>
                        <div class="budget-wrap">
                            <input type="text" name="minBudget" class="budget-field" placeholder="최소금액"
                                   value="${minBudget}" onkeyup="inputNumberFormat(this)">

                            <span style="font-weight:900; color:#cbd5e1;">—</span>

                            <input type="text" name="maxBudget" class="budget-field" placeholder="최대금액"
                                   value="${maxBudget}" onkeyup="inputNumberFormat(this)">
                        </div>
                    </div>

                </div>
            </div>

            <div class="panel-footer">
                <button type="button" class="btn-reset" id="resetFilterBtn">
                    <i class="fa-solid fa-rotate-right"></i> 필터 초기화
                </button>

                <button type="submit" class="btn-apply">적용하기</button>
            </div>
        </div>

        <input type="hidden" name="page" id="pageInput" value="${page}"/>

        <input type="hidden" name="size" value="${empty size ? 10 : size}"/>
        <input type="hidden" name="summary" value="${empty summary ? 'all' : summary}"/>
    </form>


    <!-- 리스트 -->
    <div class="project-list">

        <c:if test="${empty projectList}">
            <div class="empty">조건에 맞는 프로젝트가 없습니다.</div>
        </c:if>

        <c:forEach var="p" items="${projectList}">

            <div class="project-card"
                 onclick="location.href='${pageContext.request.contextPath}/project/detail?projectId=${p.projectId}&page=${page}&size=${size}&onlyActive=${onlyActive}&keyword=${fn:escapeXml(keyword)}'">

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

            <c:choose>
                <c:when test="${hasPrevBlock}">
                    <a class="page-link" href="javascript:void(0);" onclick="goPage(${prevBlockPage})">&laquo;</a>
                </c:when>
                <c:otherwise>
                    <span class="page-link disabled">&laquo;</span>
                </c:otherwise>
            </c:choose>

            <c:choose>
                <c:when test="${page > 1}">
                    <a class="page-link" href="javascript:void(0);" onclick="goPage(${page-1})">&lsaquo;</a>
                </c:when>
                <c:otherwise>
                    <span class="page-link disabled">&lsaquo;</span>
                </c:otherwise>
            </c:choose>

            <c:forEach var="pno" begin="${startPage}" end="${endPage}">
                <a class="page-link ${pno == page ? 'active' : ''}"
                   href="javascript:void(0);" onclick="goPage(${pno})">${pno}</a>
            </c:forEach>

            <c:choose>
                <c:when test="${page < totalPages}">
                    <a class="page-link" href="javascript:void(0);" onclick="goPage(${page+1})">&rsaquo;</a>
                </c:when>
                <c:otherwise>
                    <span class="page-link disabled">&rsaquo;</span>
                </c:otherwise>
            </c:choose>

            <c:choose>
                <c:when test="${hasNextBlock}">
                    <a class="page-link" href="javascript:void(0);" onclick="goPage(${nextBlockPage})">&raquo;</a>
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
    // 전역 유틸리티 함수

    // 숫자 콤마 포맷팅
    function inputNumberFormat(obj) {
        obj.value = comma(uncomma(obj.value));
    }

    function comma(str) {
        str = String(str);
        return str.replace(/(\d)(?=(?:\d{3})+(?!\d))/g, '$1,');
    }

    function uncomma(str) {
        str = String(str);
        return str.replace(/[^\d]+/g, '');
    }

    // 페이지 이동 함수
    function goPage(pageNo) {
        const pageInput = document.getElementById('pageInput');
        if (pageInput) {
            pageInput.value = pageNo;
        }
        submitForm(); // 공통 제출 함수 호출
    }

    // 폼 제출 공통 함수 (콤마 제거 후 전송)
    function submitForm() {
        // 예산 필드에서 콤마 제거
        document.querySelectorAll('.budget-field').forEach(input => {
            input.value = uncomma(input.value);
        });

        const form = document.getElementById('filterForm');
        if (form) {
            form.submit();
        }
    }

    // 내부 검색 함수 (포지션/스킬 검색)
    window.filterChips = function (searchInput) {
        const val = searchInput.value.toLowerCase();
        const list = searchInput.nextElementSibling;
        const items = list.querySelectorAll('.filter-chip');
        items.forEach(item => {
            const text = item.getAttribute('data-name').toLowerCase();
            item.style.display = text.includes(val) ? 'inline-flex' : 'none';
        });
    };



    // DOM 로드 후 실행
    document.addEventListener("DOMContentLoaded", () => {
        // 알림 및 북마크
        const alertMsg = "${alertMsg}";
        if (alertMsg) alert(alertMsg);

        document.querySelectorAll(".bookmark-btn").forEach((btn) => {
            btn.addEventListener("click", async (e) => {
                e.preventDefault(); e.stopPropagation();
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
                    btn.classList.toggle("is-active", data.bookmarked);
                } catch (err) { console.error(err); alert("북마크 처리 중 오류"); }
            });
        });

        // 필터 UI 요소 가져오기
        const filterBtn = document.getElementById('filterToggleBtn');
        const filterPanel = document.getElementById('filterPanel');
        const tabs = document.querySelectorAll('.filter-tab');
        const contents = document.querySelectorAll('.tab-content');
        const tagContainer = document.getElementById('activeTagsContainer');
        const resetBtn = document.getElementById('resetFilterBtn');
        const applyBtn = document.querySelector('.btn-apply'); // 적용하기 버튼

        // 토글 버튼 동작
        if (filterBtn) {
            filterBtn.addEventListener('click', () => {
                filterPanel.classList.toggle('open');
                filterBtn.classList.toggle('active');
            });
        }

        // 탭 전환 동작
        tabs.forEach(tab => {
            tab.addEventListener('click', () => {
                tabs.forEach(t => t.classList.remove('active'));
                contents.forEach(c => c.classList.remove('active'));
                tab.classList.add('active');
                document.getElementById(tab.getAttribute('data-target')).classList.add('active');
            });
        });

        // 태그 렌더링 함수
        function renderActiveTags() {
            if (!tagContainer) return;
            tagContainer.innerHTML = '';

            const checkedInputs = document.querySelectorAll('.filter-chip input:checked');

            checkedInputs.forEach(input => {
                const chip = input.parentElement;
                const name = chip.getAttribute('data-name');

                const tag = document.createElement('div');
                tag.className = 'active-tag';
                // FontAwesome X 아이콘
                tag.innerHTML = `<span>\${name}</span> <i class="fa-solid fa-xmark"></i>`;

                // X 클릭 시 삭제
                tag.querySelector('i').addEventListener('click', (e) => {
                    e.stopPropagation();
                    input.checked = false;
                    chip.classList.remove('selected');
                    renderActiveTags();
                });
                tagContainer.appendChild(tag);
            });
        }

        // 칩 클릭 이벤트 연결
        const chips = document.querySelectorAll('.filter-chip');
        chips.forEach(chip => {
            const input = chip.querySelector('input');

            // 로드 시 체크 상태 반영
            if (input.checked) chip.classList.add('selected');

            input.addEventListener('change', () => {
                if (input.checked) chip.classList.add('selected');
                else chip.classList.remove('selected');
                renderActiveTags();
            });
        });

        // 초기화 버튼 클릭 이벤트
        if (resetBtn) {
            resetBtn.addEventListener('click', () => {
                // 체크박스 해제
                document.querySelectorAll('.filter-chip input').forEach(input => {
                    input.checked = false;
                    input.parentElement.classList.remove('selected');
                });

                // 예산 및 검색창 초기화
                document.querySelectorAll('.budget-field').forEach(input => input.value = '');
                document.querySelectorAll('.stack-search-input').forEach(input => {
                    input.value = '';
                    window.filterChips(input);
                });

                renderActiveTags();
            });
        }

        // 적용하기 버튼 클릭 시 콤마 제거 후 전송
        if(applyBtn) {
            applyBtn.addEventListener('click', (e) => {
                e.preventDefault();
                submitForm();
            });
        }

        // 페이지 로드 시 예산 값에 콤마 찍기
        document.querySelectorAll('.budget-field').forEach(input => {
            if(input.value) {
                input.value = comma(input.value);
            }
        });

        // 페이지 로드 시 태그 그리기
        renderActiveTags();
    });
</script>
</body>

</html>
