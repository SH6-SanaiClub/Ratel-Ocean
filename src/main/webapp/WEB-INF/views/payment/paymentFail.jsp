<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>결제 실패 | Ratel Ocean</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/landing.css">

  <style>
    body { background-color: #f4f6f9; margin: 0; font-family: 'Pretendard', sans-serif; }
    .simple-header {
      background: #fff; padding: 15px 40px; border-bottom: 1px solid #ddd;
    }
    .simple-header img { height: 40px; }

    .result-wrapper {
      max-width: 500px;
      margin: 80px auto;
      text-align: center;
      background: #fff;
      padding: 50px;
      border-radius: 12px;
      box-shadow: 0 4px 15px rgba(0,0,0,0.05);
    }
    .icon-fail {
      font-size: 60px; color: #dc3545; margin-bottom: 20px; display: block;
    }
    h2 { margin: 0 0 15px 0; color: #dc3545; }
    .error-message {
      background: #f8d7da;
      color: #721c24;
      padding: 15px;
      border-radius: 6px;
      margin-bottom: 30px;
      font-size: 14px;
    }
    .btn-back {
      display: inline-block;
      padding: 12px 30px;
      background-color: #6c757d;
      color: #fff;
      text-decoration: none;
      border-radius: 6px;
      font-weight: 600;
      cursor: pointer;
      border: none;
    }
    .btn-back:hover { background-color: #5a6268; }
  </style>
</head>
<body>
<header class="simple-header">
  <a href="${pageContext.request.contextPath}/">
    <img src="${pageContext.request.contextPath}/resources/images/RatelOceanLOGO.png" alt="Ratel Ocean Logo">
  </a>
</header>

<div class="result-wrapper">
  <span class="icon-fail">✖</span>
  <h2>결제에 실패하였습니다</h2>
  <p>요청하신 결제를 처리하는 도중 문제가 발생했습니다.</p>

  <div class="error-message">
    오류 내용: ${errorMsg}
  </div>

  <button onclick="history.back()" class="btn-back">
    이전 페이지로 돌아가기
  </button>
</div>
</body>
</html>