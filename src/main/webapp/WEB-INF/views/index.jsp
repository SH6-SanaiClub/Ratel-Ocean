<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${projectName}</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Malgun Gothic', -apple-system, BlinkMacSystemFont, sans-serif;
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
            font-size: 32px;
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