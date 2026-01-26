<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>결제 완료 | Ratel Ocean</title>
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
    .icon-check {
      font-size: 60px; color: #28a745; margin-bottom: 20px; display: block;
    }
    h2 { margin: 0 0 15px 0; color: #333; }
    p { color: #666; margin-bottom: 40px; line-height: 1.5; }

    .btn-home {
      display: inline-block;
      padding: 12px 30px;
      background-color: #007bff;
      color: #fff;
      text-decoration: none;
      border-radius: 6px;
      font-weight: 600;
    }
    .btn-home:hover { background-color: #0056b3; }
  </style>
</head>
<body>
<header class="simple-header">
  <a href="${pageContext.request.contextPath}/">
    <img src="${pageContext.request.contextPath}/resources/images/RatelOceanLOGO.png" alt="Ratel Ocean Logo">
  </a>
</header>

<div class="result-wrapper">
  <span class="icon-check">✔</span>
  <h2>결제가 완료되었습니다!</h2>
  <p>
    계약 금액이 에스크로 계좌에 안전하게 예치되었습니다.<br>
    이제 프로젝트를 본격적으로 시작하실 수 있습니다.
  </p>

  <a href="${pageContext.request.contextPath}/project/client/dashboard" class="btn-home">
    내 프로젝트 보러가기
  </a>
</div>
</body>
</html>