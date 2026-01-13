<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>404 - 페이지를 찾을 수 없습니다</title>
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
      color: #667eea;
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
  <div class="error-code">404</div>
  <h1>페이지를 찾을 수 없습니다</h1>
  <p>요청하신 페이지가 존재하지 않거나 삭제되었습니다.</p>
  <a href="${pageContext.request.contextPath}/">홈으로 돌아가기</a>
</div>
</body>
</html>