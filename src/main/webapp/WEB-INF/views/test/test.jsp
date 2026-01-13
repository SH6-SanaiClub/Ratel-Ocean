<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>테스트 페이지</title>
  <style>
    body {
      font-family: 'Malgun Gothic', sans-serif;
      padding: 50px;
      background-color: #f5f5f5;
    }

    .test-container {
      max-width: 800px;
      margin: 0 auto;
      background: white;
      padding: 40px;
      border-radius: 15px;
      box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }

    h1 {
      color: #667eea;
      border-bottom: 3px solid #667eea;
      padding-bottom: 15px;
      margin-bottom: 30px;
    }

    .status-box {
      background: #d1fae5;
      border-left: 4px solid #22c55e;
      padding: 20px;
      margin: 20px 0;
      border-radius: 5px;
    }

    .status-title {
      font-size: 20px;
      color: #22c55e;
      font-weight: bold;
      margin-bottom: 10px;
    }

    .status-message {
      color: #166534;
      font-size: 16px;
    }

    .test-list {
      list-style: none;
      padding: 0;
    }

    .test-item {
      padding: 15px;
      margin: 10px 0;
      background: #f8f9fa;
      border-radius: 8px;
      display: flex;
      align-items: center;
    }

    .test-item::before {
      content: "✅";
      margin-right: 15px;
      font-size: 20px;
    }

    .back-link {
      display: inline-block;
      margin-top: 30px;
      padding: 12px 30px;
      background: #667eea;
      color: white;
      text-decoration: none;
      border-radius: 8px;
      transition: all 0.3s;
    }

    .back-link:hover {
      background: #5568d3;
      transform: translateY(-2px);
    }

    .info-table {
      width: 100%;
      border-collapse: collapse;
      margin: 20px 0;
    }

    .info-table th,
    .info-table td {
      padding: 12px;
      text-align: left;
      border-bottom: 1px solid #e2e8f0;
    }

    .info-table th {
      background: #f8f9fa;
      font-weight: bold;
      color: #334155;
    }

    .info-table td {
      color: #64748b;
    }
  </style>
</head>
<body>
<div class="test-container">
  <h1>🧪 개발 환경 테스트</h1>

  <div class="status-box">
    <div class="status-title">상태: ${status}</div>
    <div class="status-message">${message}</div>
  </div>

  <h2>✅ 동작 확인 항목</h2>
  <ul class="test-list">
    <li class="test-item">Spring MVC DispatcherServlet 정상 작동</li>
    <li class="test-item">Controller 매핑 정상 작동</li>
    <li class="test-item">ViewResolver JSP 렌더링 성공</li>
    <li class="test-item">JSTL 및 EL 표현식 정상 작동</li>
    <li class="test-item">UTF-8 인코딩 정상 작동</li>
    <li class="test-item">정적 리소스 매핑 정상 작동</li>
  </ul>

  <h2>📊 시스템 정보</h2>
  <table class="info-table">
    <tr>
      <th>항목</th>
      <th>값</th>
    </tr>
    <tr>
      <td>JSP 버전</td>
      <td>2.3</td>
    </tr>
    <tr>
      <td>Servlet 버전</td>
      <td>4.0</td>
    </tr>
    <tr>
      <td>Spring Version</td>
      <td>5.3.33</td>
    </tr>
    <tr>
      <td>인코딩</td>
      <td>UTF-8</td>
    </tr>
    <tr>
      <td>Context Path</td>
      <td>${pageContext.request.contextPath}</td>
    </tr>
  </table>

  <a href="${pageContext.request.contextPath}/" class="back-link">
    ← 홈으로 돌아가기
  </a>
</div>
</body>
</html>