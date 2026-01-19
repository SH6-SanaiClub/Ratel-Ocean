<%@ page contentType="text/html;charset=UTF-8" %>
<!--
    ═══════════════════════════════════════════════════════════════════════
    selectRole.jsp - 회원 역할 선택 페이지
    ═══════════════════════════════════════════════════════════════════════
    
    [설명]
    회원가입 첫 단계에서 사용자가 프리랜서 또는 클라이언트 중
    어떤 역할로 가입할지 선택하는 페이지입니다.
    
    [연결되는 컨트롤러]
    UserController.java > selectRolePage() 메서드
    @GetMapping("/join/select-role.do")
    
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
    
    [사용자 선택 흐름]
    1. 이 페이지에서 역할 선택
    2. POST /join/select-role.do로 선택값 전송
    3. 서버가 세션에 역할 저장
    4. /join/signup.do로 자동 리다이렉트
    5. 회원정보 입력 페이지로 이동
    
    @version 1.0 (2026-01-17)
-->
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>회원 유형 선택 - Ratel Ocean</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/select-role.css">
    <style>
        /* 인라인 스타일 - CSS 로드 실패 대비 */
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif; margin: 0; padding: 0; background-color: #F1F6EE; }
        .container { max-width: 1200px; margin: 0 auto; padding: 0 2rem; }
        .site-header { background-color: white; border-bottom: 1px solid #e0e0e0; padding: 1rem 0; }
        .header-inner { display: flex; justify-content: space-between; align-items: center; }
        .top-nav { display: flex; gap: 2rem; align-items: center; }
        .top-nav a { color: #2B2B2B; text-decoration: none; }
        .select-role { min-height: 60vh; padding: 4rem 0; text-align: center; }
        .eyebrow { text-transform: uppercase; letter-spacing: 0.1em; color: #6F7272; font-size: 0.875rem; margin-bottom: 1rem; }
        .title { font-size: 2.5rem; font-weight: 700; color: #2B2B2B; margin-bottom: 1rem; }
        .subtitle { font-size: 1.125rem; color: #6F7272; margin-bottom: 3rem; }
        .cards { display: flex; gap: 2rem; justify-content: center; margin: 3rem auto; max-width: 800px; flex-wrap: wrap; }
        .role-btn { 
            background-color: white; 
            border: 2px solid #e0e0e0; 
            border-radius: 12px; 
            padding: 3rem 2rem; 
            cursor: pointer; 
            transition: all 0.3s; 
            text-align: center; 
            width: 300px;
            min-height: 250px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }
        .role-btn:hover { 
            border-color: #1F7A8C; 
            box-shadow: 0 4px 12px rgba(31, 122, 140, 0.15); 
            transform: translateY(-4px); 
        }
        .role-btn .icon { font-size: 4rem; margin-bottom: 1rem; }
        .role-btn .label { font-size: 1.5rem; font-weight: 600; color: #2B2B2B; margin-bottom: 0.5rem; }
        .role-btn p { color: #6F7272; font-size: 1rem; margin: 0; }
        .login-banner { background-color: white; border-top: 1px solid #e0e0e0; padding: 2rem 0; text-align: center; color: #6F7272; }
        .login-btn { color: #1F7A8C; text-decoration: none; font-weight: 600; margin-left: 0.5rem; }
        .site-footer { background-color: #2B2B2B; color: white; padding: 2rem 0; text-align: center; font-size: 0.875rem; }
    </style>
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

        <form id="roleForm" method="post" action="${pageContext.request.contextPath}/join/select-role.do">
            <input type="hidden" name="userType" id="userTypeInput">
            <input type="hidden" name="role" id="roleInput">

            <div class="cards">
                <button type="button" class="role-btn" onclick="selectAndSubmit('FREELANCER')">
                    <div class="icon">👨‍💻</div>
                    <div class="label">프리랜서</div>
                    <p>내 기술로 프로젝트를 수행합니다.</p>
                </button>

                <button type="button" class="role-btn" onclick="selectAndSubmit('CLIENT')">
                    <div class="icon">🏢</div>
                    <div class="label">클라이언트</div>
                    <p>전문가를 고용하여 프로젝트를 맡깁니다.</p>
                </button>
            </div>
        </form>

        <script>
            function selectAndSubmit(role) {
                // AJAX로 전송해서 JSON 응답 처리
                var xhr = new XMLHttpRequest();
                xhr.open('POST', '${pageContext.request.contextPath}/join/select-role.do', true);
                xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
                
                xhr.onload = function() {
                    if (xhr.status === 200) {
                        try {
                            var response = JSON.parse(xhr.responseText);
                            if (response.success && response.redirectUrl) {
                                // JSON 응답의 redirectUrl로 이동
                                window.location.href = '${pageContext.request.contextPath}' + response.redirectUrl;
                            } else {
                                alert('오류: ' + (response.message || '알 수 없는 오류'));
                            }
                        } catch (e) {
                            // JSON 파싱 실패 시 그냥 signup 페이지로 이동
                            window.location.href = '${pageContext.request.contextPath}/join/signup.do';
                        }
                    } else {
                        alert('서버 오류가 발생했습니다.');
                    }
                };
                
                xhr.onerror = function() {
                    alert('네트워크 오류가 발생했습니다.');
                };
                
                // role과 userType 둘 다 전송
                xhr.send('role=' + encodeURIComponent(role) + '&userType=' + encodeURIComponent(role));
            }
        </script>
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
