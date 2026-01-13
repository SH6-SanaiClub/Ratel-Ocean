<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="프리랜서와 클라이언트를 연결하는 플랫폼">
    <meta name="author" content="SanaiClub">
    <title>RatelOcean - 프리랜서 매칭 플랫폼</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Malgun Gothic', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        .container {
            text-align: center;
            background: white;
            padding: 60px 50px;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            max-width: 600px;
            width: 90%;
        }
        
        h1 {
            color: #333;
            margin-bottom: 15px;
            font-size: 36px;
        }
        
        .subtitle {
            color: #666;
            margin-bottom: 10px;
            font-size: 18px;
        }
        
        .time {
            color: #999;
            font-size: 14px;
            margin-bottom: 30px;
        }
        
        .info-section {
            text-align: left;
            background: #f9f9f9;
            padding: 20px;
            margin: 20px 0;
            border-radius: 10px;
            border-left: 4px solid #667eea;
        }
        
        .info-section h3 {
            color: #667eea;
            margin-bottom: 15px;
            font-size: 16px;
        }
        
        .tech-stack {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            text-align: left;
        }
        
        .tech-item {
            padding: 10px;
            background: white;
            border-radius: 5px;
            font-size: 14px;
            border: 1px solid #ddd;
        }
        
        .tech-item strong {
            color: #667eea;
        }
        
        .button-group {
            display: flex;
            gap: 10px;
            justify-content: center;
            margin-top: 30px;
            flex-wrap: wrap;
        }
        
        a.btn {
            display: inline-block;
            padding: 12px 30px;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
            transition: all 0.3s ease;
        }
        
        a.btn-primary {
            background: #667eea;
            color: white;
        }
        
        a.btn-primary:hover {
            background: #5568d3;
            transform: translateY(-2px);
        }
        
        a.btn-secondary {
            background: white;
            color: #667eea;
            border: 2px solid #667eea;
        }
        
        a.btn-secondary:hover {
            background: #f9f9f9;
        }
        
        .footer-text {
            color: #999;
            font-size: 12px;
            margin-top: 30px;
        }
    </style>
</head>

<body>
    <div class="container">
        <!-- 제목 영역 -->
        <h1>RatelOcean</h1>
        <p class="subtitle">프리랜서와 클라이언트를 연결하는 플랫폼</p>
        <p class="time">서버 시간: <span id="currentTime"></span></p>
        
        <!-- 기술 스택 정보 -->
        <div class="info-section">
            <h3>🛠️ 기술 스택</h3>
            <div class="tech-stack">
                <div class="tech-item"><strong>언어:</strong> Java 11</div>
                <div class="tech-item"><strong>프레임워크:</strong> Spring 5.3.33</div>
                <div class="tech-item"><strong>뷰:</strong> JSP 2.3 + JSTL</div>
                <div class="tech-item"><strong>ORM:</strong> MyBatis 3.5.13</div>
                <div class="tech-item"><strong>DB:</strong> MySQL 8.0</div>
                <div class="tech-item"><strong>서버:</strong> Jetty 9.4.53</div>
                <div class="tech-item"><strong>로깅:</strong> SLF4J + Logback</div>
                <div class="tech-item"><strong>빌드:</strong> Maven 3.x</div>
            </div>
        </div>
        
        <!-- 주요 기능 -->
        <div class="info-section">
            <h3>✨ 주요 기능</h3>
            <ul style="text-align: left; padding-left: 20px;">
                <li>프리랜서와 클라이언트 회원가입</li>
                <li>프로젝트 등록 및 검색</li>
                <li>프로젝트 입찰 및 계약 체결</li>
                <li>대시보드 및 통계</li>
                <li>계좌 등록 및 정산</li>
            </ul>
        </div>
        
        <!-- 버튼 그룹 -->
        <div class="button-group">
            <a href="${pageContext.request.contextPath}/login.do" class="btn btn-primary">로그인</a>
            <a href="${pageContext.request.contextPath}/join/select-role.do" class="btn btn-primary">회원가입</a>
            <a href="${pageContext.request.contextPath}/test" class="btn btn-secondary">테스트</a>
        </div>
        
        <p class="footer-text">© 2026 SanaiClub. 신한DS 금융 SW 아카데미</p>
    </div>
    
    <script>
        // 현재 시간 표시
        function updateTime() {
            const now = new Date();
            const timeString = now.toLocaleString('ko-KR');
            document.getElementById('currentTime').textContent = timeString;
        }
        
        updateTime();
        setInterval(updateTime, 1000);
    </script>
</body>
</html>
        }

        .info-box {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 12px;
            margin: 25px 0;
        }

        .info-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin: 12px 0;
            padding: 10px;
            background: white;
            border-radius: 8px;
        }

        .info-label {
            color: #666;
            font-weight: bold;
        }

        .info-value {
            color: #22c55e;
            font-weight: bold;
        }

        .button-group {
            display: flex;
            gap: 15px;
            margin-top: 30px;
        }

        .btn {
            flex: 1;
            padding: 15px 30px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }

        .btn-primary {
            background: #667eea;
            color: white;
        }

        .btn-primary:hover {
            background: #5568d3;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }

        .btn-secondary {
            background: #e2e8f0;
            color: #334155;
        }

        .btn-secondary:hover {
            background: #cbd5e1;
            transform: translateY(-2px);
        }

        .emoji {
            font-size: 48px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
<div class="container">
    <div class="emoji">🎉</div>
    <h1>${projectName}</h1>
    <p class="subtitle">${team}</p>
    <p class="time">⏰ ${currentTime}</p>

    <div class="info-box">
        <div class="info-item">
            <span class="info-label">Java</span>
            <span class="info-value">11</span>
        </div>
        <div class="info-item">
            <span class="info-label">Spring Framework</span>
            <span class="info-value">5.3.33</span>
        </div>
        <div class="info-item">
            <span class="info-label">MyBatis</span>
            <span class="info-value">3.5.13</span>
        </div>
        <div class="info-item">
            <span class="info-label">MySQL</span>
            <span class="info-value">8.0</span>
        </div>
        <div class="info-item">
            <span class="info-label">Tomcat</span>
            <span class="info-value">9.0.112</span>
        </div>
    </div>

    <div class="button-group">
        <a href="${pageContext.request.contextPath}/test" class="btn btn-primary">
            테스트 페이지
        </a>
        <a href="${pageContext.request.contextPath}/api/test" class="btn btn-secondary">
            API 테스트
        </a>
    </div>
</div>
</body>
</html>