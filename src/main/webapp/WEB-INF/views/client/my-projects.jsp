<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>프로젝트 등록 및 관리 - 클라이언트</title>

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

        /* 프로젝트 리스트 */
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

        .left{
            flex:1;
            display:flex;
            flex-direction:column;
            gap:10px;
            min-width:0;
        }

        .title{
            font-size: 20px;
            font-weight: 950;
            line-height:1.35;
        }

        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 900;
            width: fit-content;
        }

        .status-active {
            background: #dcfce7;
            color: #166534;
        }

        .status-completed {
            background: #dbeafe;
            color: #0c4a6e;
        }

        .status-cancelled {
            background: #fee2e2;
            color: #991b1b;
        }

        .meta{
            display:flex;
            gap: 20px;
            flex-wrap:wrap;
            font-size: 13px;
            color: #6b7280;
            font-weight: 800;
        }

        .right {
            width: 220px;
            border-left: 1px solid var(--line);
            padding-left: 18px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            align-items: flex-end;
        }

        .budget {
            font-weight: 950;
            font-size: 22px;
            color: var(--text);
        }

        .applicant-count {
            font-size: 13px;
            color: var(--muted);
            font-weight: 900;
        }

        .action-buttons {
            display: flex;
            gap: 8px;
        }

        .action-btn {
            padding: 6px 12px;
            border: 1px solid var(--line);
            background: white;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 800;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .action-btn:hover {
            border-color: var(--primary);
            color: var(--primary);
        }

        .empty{
            background:#fff;
            padding: 40px 22px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            font-weight: 900;
            color:#6b7280;
            text-align:center;
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
        }

    </style>
</head>

<body>

<%@ include file="/WEB-INF/views/common/client_header.jsp" %>

<div class="dashboard-wrap">
    <div class="header-action">
        <h1 style="font-size: 28px; font-weight: 950; margin: 0;">내 프로젝트 관리</h1>
        <button class="new-project-btn" onclick="location.href='${pageContext.request.contextPath}/project/create'">새 프로젝트 등록</button>
    </div>

    <div class="project-list">
        <c:choose>
            <c:when test="${empty projectList}">
                <div class="empty">등록된 프로젝트가 없습니다.</div>
            </c:when>
            <c:otherwise>
                <c:forEach var="p" items="${projectList}">
                    <div class="project-card">
                        <div class="left">
                            <div class="title">${p.title}</div>

                            <div class="meta">
                                <span>예상 기간: ${p.estDuration}</span>
                                <span>마감 D-<c:out value="${p.dday}" /></span>
                                <span>지원자 ${p.applicantCount}명</span>
                            </div>

                            <div class="chips">
                                <c:if test="${not empty p.stacks}">
                                    <c:forEach var="s" items="${p.stacks}">
                                        <c:if test="${s.category eq 'POSITION'}">
                                            <span class="chip position">${s.stackName}</span>
                                        </c:if>
                                    </c:forEach>
                                </c:if>
                            </div>

                            <div class="chips">
                                <c:if test="${not empty p.stacks}">
                                    <c:forEach var="s" items="${p.stacks}">
                                        <c:if test="${s.category eq 'SKILL'}">
                                            <span class="chip">
                                                ${s.stackName}
                                                <c:if test="${s.stackLevel != null}">Lv.${s.stackLevel}</c:if>
                                            </span>
                                        </c:if>
                                    </c:forEach>
                                </c:if>
                            </div>
                        </div>

                        <div class="right">
                            <div class="budget">₩${p.budget}</div>
                            <div class="applicant-count">지원자 ${p.applicantCount}명</div>
                            <div class="action-buttons">
                                <button class="action-btn" type="button">지원자 보기</button>
                                <button class="action-btn" type="button">수정</button>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

</body>
</html>
