<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>500 - 서버 오류</title>
  <style>
    body {
      font-family: 'Malgun Gothic', sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
      background: #f5f5f5;
    }
    .error-container {
      text-align: center;
      padding: 50px;
    }
    .error-code {
      font-size: 120px;
      font-weight: bold;
      color: #ef4444;
      margin: 0;
    }
    h1 {
      color: #333;
      margin: 20px 0;
    }
    p {
      color: #666;
      margin: 10px 0;
    }
    a {
      display: inline-block;
      margin-top: 20px;
      padding: 12px 30px;
      background: #667eea;
      color: white;
      text-decoration: none;
      border-radius: 5px;
    }
    a:hover {
      background: #5568d3;
    }
  </style>
</head>
<body>
<div class="error-container">
  <div class="error-code">500</div>
  <h1>서버 오류가 발생했습니다</h1>
  <p>일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요.</p>
  <a href="${pageContext.request.contextPath}/">홈으로 돌아가기</a>
</div>
</body>
</html>