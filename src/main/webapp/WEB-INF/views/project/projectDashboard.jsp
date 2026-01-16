<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>프로젝트 대시보드</title>

    <style>
        body{
            font-family: Pretendard, Arial, sans-serif;
            background:#f8fafc;
            margin:0;
        }

        .dashboard-wrap{
            max-width:1200px;
            margin:40px auto;
            padding:0 16px;
        }

        .search-box{
            display:flex;
            gap:8px;
            margin-bottom:20px;
        }

        .search-box input{
            width:320px;
            padding:10px 12px;
            border-radius:8px;
            border:1px solid #ddd;
            outline:none;
            background:#fff;
        }

        .search-box button{
            padding:10px 14px;
            border:none;
            border-radius:8px;
            background:#5c3cce;
            color:#fff;
            font-weight:700;
            cursor:pointer;
        }

        .project-grid{
            display:grid;
            grid-template-columns: repeat(auto-fill, minmax(360px, 1fr));
            gap:20px;
        }

        .project-card{
            background:#fff;
            border-radius:12px;
            padding:20px;
            box-shadow:0 4px 12px rgba(0,0,0,0.06);
            display:flex;
            flex-direction:column;
            gap:14px;
        }

        .project-title{
            font-size:18px;
            font-weight:800;
            color:#111827;
            line-height:1.3;
        }

        .chips{
            display:flex;
            flex-wrap:wrap;
            gap:6px;
        }

        .chip{
            background:#eef2ff;
            color:#3730a3;
            padding:4px 10px;
            border-radius:999px;
            font-size:12px;
            font-weight:700;
            white-space:nowrap;
        }

        .chip.position{
            background:#ecfeff;
            color:#0f766e;
        }

        .meta{
            font-size:13px;
            color:#555;
            display:flex;
            flex-wrap:wrap;
            gap:12px;
        }

        .footer{
            margin-top:auto;
            display:flex;
            justify-content:space-between;
            align-items:center;
            font-size:14px;
        }

        .dday{
            font-weight:900;
            color:#dc2626;
        }

        .budget{
            font-weight:900;
            color:#111827;
        }

        .empty{
            padding:18px;
            color:#6b7280;
            font-weight:700;
        }
    </style>
</head>

<body>
<div class="dashboard-wrap">

    <!-- 🔍 검색 -->
    <form class="search-box" method="get"
          action="${pageContext.request.contextPath}/project/dashboard">
        <input type="text"
               name="keyword"
               placeholder="프로젝트 제목 검색"
               value="${fn:escapeXml(keyword)}" />
        <button type="submit">검색</button>
    </form>

    <!-- 📋 프로젝트 카드 리스트 -->
    <div class="project-grid">

        <c:if test="${empty projectList}">
            <div class="empty">조건에 맞는 프로젝트가 없습니다.</div>
        </c:if>

        <c:forEach var="p" items="${projectList}">
            <div class="project-card">

                <!-- 제목 -->
                <div class="project-title">${p.title}</div>

                <!-- 포지션 (CATEGORY = POSITION) -->
                <div class="chips">
                    <c:forEach var="s" items="${p.stacks}">
                        <c:if test="${s.category eq 'POSITION'}">
              <span class="chip position">
                ${s.stackName}
                <c:if test="${s.stackLevel != null}">
                    (Lv.${s.stackLevel})
                </c:if>
              </span>
                        </c:if>
                    </c:forEach>
                </div>

                <!-- 기술 스택 (CATEGORY = SKILL) -->
                <div class="chips">
                    <c:forEach var="s" items="${p.stacks}">
                        <c:if test="${s.category eq 'SKILL'}">
              <span class="chip">
                ${s.stackName}
                <c:if test="${s.stackLevel != null}">
                    Lv.${s.stackLevel}
                </c:if>
              </span>
                        </c:if>
                    </c:forEach>
                </div>

                <!-- 메타 정보 -->
                <div class="meta">
                    <span>예상기간: ${p.estDuration}</span>
                    <span>지원자: ${p.applicantCount}명</span>
                    <span>마감일: ${p.deadlineDate}</span>
                </div>

                <!-- 하단 -->
                <div class="footer">
                    <div class="dday">D-${p.dday}</div>
                    <div class="budget">₩${p.budget}</div>
                </div>

            </div>
        </c:forEach>

    </div>
</div>
</body>
</html>
