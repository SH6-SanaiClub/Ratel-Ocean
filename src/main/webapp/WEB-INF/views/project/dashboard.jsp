<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="사용자 대시보드">
    <meta name="author" content="SanaiClub">
    <title>대시보드 - RatelOcean</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Malgun Gothic', sans-serif;
        }
        .layout {
            display: flex;
        }
        main {
            flex: 1;
            padding: 30px;
            background: #f8f9fa;
            min-height: calc(100vh - 60px);
        }
        .placeholder {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            text-align: center;
            color: #666;
            line-height: 1.6;
        }
    </style>
</head>

<body>

    <!-- 
        ─────────────────────────────────────────────────────────────
        1️⃣ 헤더 포함
        ─────────────────────────────────────────────────────────────
        header.jsp에는 다음이 포함됨:
        - 로고/프로젝트명
        - 사용자 메뉴 (프로필, 설정)
        - 로그아웃 버튼
    -->
    <%@ include file="/WEB-INF/views/common/header.jsp" %>

    <!-- 
        ─────────────────────────────────────────────────────────────
        2️⃣ 전체 레이아웃 (플렉스 박스로 좌우 분할)
        ─────────────────────────────────────────────────────────────
    -->
    <div class="layout">

        <!-- 
            ─────────────────────────────────────────────────────────
            2-1️⃣ 좌측 사이드바 포함
            ─────────────────────────────────────────────────────────
            sidebar.jsp에는 다음 메뉴가 포함됨:
            - 프로젝트
            - 큐
            - 계약
            - 채팅
            - 지갑
            - 경력
            - 기술스택
            - 설정
        -->
        <%@ include file="/WEB-INF/views/common/sidebar.jsp" %>

        <!-- 
            ─────────────────────────────────────────────────────────
            2-2️⃣ 우측 메인 콘텐츠 영역
            ─────────────────────────────────────────────────────────
            향후 다음 내용이 들어갈 예정:
            - 사용자 통계 (수익, 진행 중인 프로젝트 수 등)
            - 최근 활동
            - 추천 프로젝트
        -->
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
