<%@ page contentType="text/html;charset=UTF-8" %>
<!--
    ═══════════════════════════════════════════════════════════════════════
    selectRole.jsp - 회원 역할 선택 페이지
    ═══════════════════════════════════════════════════════════════════════
    
    [설명]
    회원가입 첫 단계에서 사용자가 프리랜서 또는 클라이언트 중
    어떤 역할로 가입할지 선택하는 페이지입니다.
    
    [연결되는 컨트롤러]
    JoinController.java > selectRolePage() 메서드
    @GetMapping("/select-role.do")
    
    [회원 역할 설명]
    1. 프리랜서 (Freelancer)
       - 자신의 기술을 팔아서 용역비를 받는 사람
       - 프로필: 기술스택, 경력, 포트폴리오, 시간 단가
       - 기능: 프로젝트 입찰, 계약, 외주 수행
       - 수익: 완료된 프로젝트당 수익
    
    2. 클라이언트 (Client)
       - 프로젝트를 발주하여 프리랜서를 고용하는 기업/개인
       - 프로필: 회사 정보, 발주 기록, 신용도
       - 기능: 프로젝트 등록, 프리랜서 선정, 계약 관리
       - 비용: 프리랜서 비용 + 시스템 수수료
    
    [사용 기술]
    - React 18 (동적 UI)
    - Tailwind CSS (스타일링)
    - 커스텀 색상 테마
    
    [클라이언트 요소]
    - 두 개의 카드형 선택 버튼
    - 각 역할별 상세 설명
    - 하단 "다음" 버튼
    - 뒤로가기 링크
    
    [사용자 선택 흐름]
    1. 이 페이지에서 역할 선택
    2. POST /join/select-role.do로 선택값 전송
    3. 서버가 세션에 역할 저장
    4. /join/signup.do로 자동 리다이렉트
    5. 회원정보 입력 페이지로 이동
    
    [향후 개선 사항]
    - 역할별 비디오 튜토리얼
    - 각 역할의 장점 상세 설명
    - FAQ 섹션
    - 역할 변경 가능 옵션 (가입 후)
    
    @version 1.0 (2026-01-13)
-->
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>회원 유형 선택</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/select-role.css">
    <!-- Tailwind (CDN) with brand colors configured -->
    <script>
      window.tailwind = window.tailwind || {}
      window.tailwind.config = {
        theme: {
          extend: {
            colors: {
              'brand-dark': '#2B2B2B',
              'brand-muted': '#6F7272',
              'brand-offwhite': '#F1F6EE',
              'brand-mint': '#A9D9DB',
              'brand-teal': '#1F7A8C'
            }
          }
        }
      }
    </script>
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- React (CDN) -->
    <script crossorigin src="https://unpkg.com/react@18/umd/react.production.min.js"></script>
    <script crossorigin src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js"></script>
</head>
<body>
<header class="site-header">
    <div class="container header-inner">
        <a class="logo" href="${pageContext.request.contextPath}/">
            <img src="${pageContext.request.contextPath}/resources/images/ratelogo.png" alt="Ratel Ocean 로고">
        </a>
        <nav class="top-nav">
            <a href="${pageContext.request.contextPath}/service">서비스 소개</a>
            <a href="${pageContext.request.contextPath}/support">고객센터</a>
        </nav>
    </div>
</header>

<main class="select-role">
    <div class="container">
        <p class="eyebrow">JOIN US</p>
        <h1 class="title">회원 유형 선택</h1>
        <p class="subtitle">어떤 유형으로 가입하시겠습니까? 전문 프리랜서와 클라이언트를 위한 안전한 계약 플랫폼입니다.</p>

        <form method="post" action="${pageContext.request.contextPath}/join/select-role.do" class="role-form">
            <!-- React root: the JS will mount the interactive components here. Fallback/non-JS users still submit. -->
            <div id="join-root" class="cards"></div>
        </form>

        <!-- App bundle (no build step; uses CDN React + this script) -->
        <script src="${pageContext.request.contextPath}/resources/js/joinApp.js"></script>
    </div>
</main>

<section class="login-banner">
    <div class="container">
        이미 계정이 있으신가요? <a class="login-btn" href="${pageContext.request.contextPath}/login">로그인</a>
    </div>
</section>

<footer class="site-footer">
    <div class="container">© 2024 Ratel Ocean. All rights reserved.</div>
</footer>

</body>
</html>
