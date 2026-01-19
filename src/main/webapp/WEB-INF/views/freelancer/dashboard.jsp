<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>프리랜서 대시보드 - RatelOcean</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Malgun Gothic', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 40px;
        }

        .dashboard-container {
            background: white;
            border-radius: 20px;
            padding: 60px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            max-width: 800px;
            width: 100%;
            text-align: center;
        }

        .badge {
            display: inline-block;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 8px 20px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: bold;
            margin-bottom: 20px;
        }

        h1 {
            font-size: 48px;
            color: #333;
            margin-bottom: 20px;
            font-weight: bold;
        }

        .user-info {
            background: #f8f9fa;
            padding: 30px;
            border-radius: 15px;
            margin: 30px 0;
        }

        .user-info p {
            font-size: 18px;
            color: #666;
            margin: 10px 0;
        }

        .user-info strong {
            color: #667eea;
            font-weight: bold;
        }

        .description {
            font-size: 16px;
            color: #666;
            line-height: 1.8;
            margin: 20px 0;
        }

        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 40px;
        }

        .feature-card {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 15px;
            transition: all 0.3s;
        }

        .feature-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.2);
        }

        .feature-icon {
            font-size: 40px;
            margin-bottom: 15px;
        }

        .feature-title {
            font-size: 18px;
            font-weight: bold;
            color: #333;
            margin-bottom: 10px;
        }

        .feature-desc {
            font-size: 14px;
            color: #666;
        }

        .btn-logout {
            margin-top: 30px;
            padding: 14px 40px;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }

        .btn-logout:hover {
            background: #5568d3;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/common/freelancer_header.jsp" %>
    <div class="dashboard-container">
        <div class="badge">🚀 FREELANCER</div>
        
        <h1>프리랜서 대시보드</h1>
        
        <div class="user-info">
            <p><strong>환영합니다!</strong></p>
            <p>이름: <strong>${sessionScope.userName}</strong></p>
            <p>사용자 유형: <strong>프리랜서 (FREELANCER)</strong></p>
            <p>사용자 ID: <strong>${sessionScope.userId}</strong></p>
        </div>

        <p class="description">
            이 페이지는 <strong>프리랜서 전용 대시보드</strong>입니다.<br>
            프리랜서로 로그인하셨습니다. 테스트 중인 페이지입니다.
        </p>

        <div class="features">
            <div class="feature-card">
                <div class="feature-icon">📋</div>
                <div class="feature-title">프로젝트 찾기</div>
                <div class="feature-desc">내 스킬에 맞는 프로젝트 검색</div>
            </div>
            
            <div class="feature-card">
                <div class="feature-icon">💼</div>
                <div class="feature-title">내 지원 현황</div>
                <div class="feature-desc">지원한 프로젝트 관리</div>
            </div>
            
            <div class="feature-card">
                <div class="feature-icon">⭐</div>
                <div class="feature-title">포트폴리오</div>
                <div class="feature-desc">내 작업물 관리</div>
            </div>
        </div>

        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">로그아웃</a>
    </div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

</body>
</html>
