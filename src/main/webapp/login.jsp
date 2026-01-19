<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>로그인 - RatelOcean</title>
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

        .login-container {
            background: white;
            padding: 50px 40px;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            max-width: 420px;
            width: 90%;
        }

        .logo-area {
            text-align: center;
            margin-bottom: 30px;
        }

        .logo {
            font-size: 28px;
            font-weight: bold;
            color: #667eea;
            margin-bottom: 8px;
        }

        .subtitle {
            color: #666;
            font-size: 14px;
        }

        .login-form {
            margin-top: 30px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: bold;
            font-size: 14px;
        }

        .form-input {
            width: 100%;
            padding: 14px 16px;
            border: 1px solid #d1d5db;
            border-radius: 10px;
            font-size: 15px;
            transition: all 0.3s;
            outline: none;
        }

        .form-input:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .form-options {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            font-size: 14px;
        }

        .remember-me {
            display: flex;
            align-items: center;
            gap: 6px;
            color: #666;
        }

        .remember-me input {
            width: 16px;
            height: 16px;
            cursor: pointer;
        }

        .find-link {
            color: #667eea;
            text-decoration: none;
            transition: color 0.3s;
        }

        .find-link:hover {
            color: #5568d3;
        }

        .btn-login {
            width: 100%;
            padding: 16px;
            border: none;
            border-radius: 10px;
            background: #667eea;
            color: white;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s;
        }

        .btn-login:hover {
            background: #5568d3;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }

        .divider {
            text-align: center;
            margin: 30px 0;
            position: relative;
        }

        .divider::before {
            content: '';
            position: absolute;
            left: 0;
            top: 50%;
            width: 100%;
            height: 1px;
            background: #e5e7eb;
        }

        .divider-text {
            position: relative;
            display: inline-block;
            padding: 0 15px;
            background: white;
            color: #999;
            font-size: 14px;
        }

        .signup-section {
            text-align: center;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 10px;
        }

        .signup-text {
            color: #666;
            margin-bottom: 12px;
            font-size: 14px;
        }

        .btn-signup {
            display: inline-block;
            padding: 12px 30px;
            border: 2px solid #667eea;
            border-radius: 8px;
            color: #667eea;
            text-decoration: none;
            font-weight: bold;
            transition: all 0.3s;
        }

        .btn-signup:hover {
            background: #667eea;
            color: white;
            transform: translateY(-2px);
        }

        .error-message {
            background: #fee2e2;
            border-left: 4px solid #dc2626;
            padding: 12px 15px;
            margin-bottom: 20px;
            border-radius: 5px;
            color: #991b1b;
            font-size: 14px;
        }
    </style>
</head>
<body>

<div class="login-container">
    <div class="logo-area">
        <div class="logo">🌊 RatelOcean</div>
        <p class="subtitle">프리랜서 프로젝트 매칭 플랫폼</p>
    </div>

    <!-- 로그인 에러 메시지 표시 -->
    <c:if test="${not empty error}">
        <div class="error-message">
            ${error}
        </div>
    </c:if>

    <form class="login-form" action="${pageContext.request.contextPath}/login" method="post">
        <div class="form-group">
            <label class="form-label" for="email">이메일</label>
            <input 
                type="email" 
                id="email" 
                name="email" 
                class="form-input" 
                placeholder="이메일을 입력하세요"
                required
                autocomplete="email"
            />
        </div>

        <div class="form-group">
            <label class="form-label" for="password">비밀번호</label>
            <input 
                type="password" 
                id="password" 
                name="password" 
                class="form-input" 
                placeholder="비밀번호를 입력하세요"
                required
                autocomplete="current-password"
            />
        </div>

        <div class="form-options">
            <label class="remember-me">
                <input type="checkbox" name="remember" />
                <span>로그인 유지</span>
            </label>
            <a href="${pageContext.request.contextPath}/find-password" class="find-link">
                비밀번호 찾기
            </a>
        </div>

        <button type="submit" class="btn-login">
            로그인
        </button>
    </form>

    <div class="divider">
        <span class="divider-text">또는</span>
    </div>

    <div class="signup-section">
        <p class="signup-text">아직 계정이 없으신가요?</p>
        <a href="${pageContext.request.contextPath}/join/select-role.do" class="btn-signup">
            회원가입 하기
        </a>
    </div>
</div>

</body>
</html>