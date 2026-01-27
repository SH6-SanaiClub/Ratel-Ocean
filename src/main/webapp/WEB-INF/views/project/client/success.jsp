<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>프로젝트 등록 완료 | Ratel Ocean</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/project/create.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/project/success.css">
</head>
<body>

<div class="wrapper">
    <div class="success-card">
        <div class="icon-circle">
            <i class="fa-solid fa-check"></i>
        </div>

        <h1 class="success-title">프로젝트 등록이 완료되었습니다!</h1>

        <div class="success-message">
            성공적인 프로젝트 진행을 응원합니다.<br>
        </div>

        <div class="info-box">
            <p><i class="fa-solid fa-circle-info"></i> <strong>다음 단계 안내</strong></p>
            <ul class="info-list">
                <li>이제 실력 있는 전문가들이 회원님의 프로젝트를 검토합니다.</li>
                <li>지원자가 발생하면 알림을 보내드립니다.</li>
                <li>'내 프로젝트' 메뉴에서 실시간 지원 현황을 확인하세요.</li>
            </ul>
        </div>

        <div class="btn-area-center">
            <a href="${pageContext.request.contextPath}/project/dashboard" class="btn btn-home">메인으로 이동</a>
            <a href="${pageContext.request.contextPath}/client/manage" class="btn btn-submit">내 프로젝트 확인</a>
        </div>
    </div>
</div>

</body>
</html>