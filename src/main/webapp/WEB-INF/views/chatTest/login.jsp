<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>테스트 로그인</title>
    <style>
        body { background-color: #f0f2f5; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; font-family: sans-serif; }
        .login-card { background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); width: 320px; text-align: center; }
        h2 { color: #333; margin-bottom: 20px; }
        input[type="number"] { width: 100%; padding: 12px; margin-bottom: 15px; border: 1px solid #ddd; border-radius: 6px; box-sizing: border-box; font-size: 16px; }
        button { width: 100%; padding: 12px; background-color: #007bff; color: white; border: none; border-radius: 6px; font-size: 16px; cursor: pointer; transition: background 0.3s; }
        button:hover { background-color: #0056b3; }
        .info { margin-top: 15px; font-size: 0.85rem; color: #666; line-height: 1.4; }
    </style>
</head>
<body>
<div class="login-card">
    <h2>Test Login</h2>
    <form action="${pageContext.request.contextPath}/login" method="post">
        <input type="number" name="userId" placeholder="User ID 입력 (예: 1)" required min="1">
        <button type="submit">접속하기</button>
    </form>
    <div class="info">
        <p>※ <b>시크릿 창</b>을 활용해<br>각기 다른 ID로 중복 로그인 가능합니다.</p>
    </div>
</div>
</body>
</html>