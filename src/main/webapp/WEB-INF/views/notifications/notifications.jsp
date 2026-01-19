<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>알림</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: Pretendard, Arial, sans-serif;
            background: #f8fafc;
            color: #111827;
        }
        .container {
            max-width: 800px;
            margin: 40px auto;
            padding: 0 16px;
        }
        .notification-item {
            background: white;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 12px;
            border-left: 4px solid #5c3cce;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .notification-content {
            flex: 1;
        }
        .notification-title {
            font-weight: 900;
            margin-bottom: 4px;
            font-size: 15px;
        }
        .notification-time {
            font-size: 13px;
            color: #6b7280;
        }
        .empty {
            background: white;
            border-radius: 12px;
            padding: 40px 20px;
            text-align: center;
            color: #6b7280;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        .tabs {
            display: flex;
            gap: 20px;
            margin-bottom: 24px;
            border-bottom: 2px solid #eef2f7;
        }
        .tab {
            padding: 12px 0;
            font-weight: 900;
            cursor: pointer;
            border-bottom: 3px solid transparent;
            color: #6b7280;
            transition: all 0.2s ease;
            margin-bottom: -2px;
        }
        .tab.active {
            color: #5c3cce;
            border-bottom-color: #5c3cce;
        }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="container">
    <h1 style="font-size: 28px; margin-bottom: 24px; font-weight: 950;">알림</h1>

    <div class="tabs">
        <div class="tab active">전체</div>
        <div class="tab">프로젝트</div>
        <div class="tab">메시지</div>
        <div class="tab">계정</div>
    </div>

    <div class="empty">
        아직 알림이 없습니다.
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

</body>
</html>
