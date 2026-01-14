<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Dashboard</title>
</head>

<body>

    <!-- 1️⃣ 헤더 -->
    <%@ include file="/WEB-INF/views/common/freelancer_header.jsp" %>

    <!-- 2️⃣ 전체 레이아웃 -->
    <div class="layout">

        <!-- 2-1️⃣ 사이드바 -->
        <%@ include file="/WEB-INF/views/common/sidebar.jsp" %>

        <!-- 2-2️⃣ 메인 콘텐츠 -->
        <main>
            <h2>프리랜서 대시보드</h2>

            <div class="placeholder">
                여기는 메인 대시보드 영역입니다.<br>
                (추후 요약 카드, 통계, 알림 등이 들어올 예정)
            </div>
        </main>

    </div>

</body>
</html>
