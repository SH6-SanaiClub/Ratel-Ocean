<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>내 프로젝트 관리 - 프리랜서</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: Pretendard, Arial, sans-serif;
            background: #f8fafc;
            color: #111827;
        }
        .container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 16px;
        }
        .empty-state {
            background: white;
            border-radius: 18px;
            padding: 60px 20px;
            text-align: center;
            box-shadow: 0 10px 28px rgba(15,23,42,0.08);
            color: #6b7280;
        }
        .empty-state h2 {
            font-size: 24px;
            margin-bottom: 12px;
            color: #111827;
        }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/views/common/freelancer_header.jsp" %>

<div class="container">
    <div class="empty-state">
        <h2>진행 중인 프로젝트</h2>
        <p>현재 진행 중인 프로젝트가 없습니다.</p>
        <p style="margin-top: 16px; font-size: 14px;">
            <a href="${pageContext.request.contextPath}/freelancer/projects" style="color: #5c3cce; text-decoration: none;">
                프로젝트 찾기 →
            </a>
        </p>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

</body>
</html>
