<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="wrapper">
    <div class="step-section active">
        <div class="success-container">
            <div class="icon-circle">
                <i class="fa-solid fa-check"></i>
            </div>

            <h1 class="success-title">프로젝트 등록이 완료되었습니다!</h1>
            <p class="success-desc">
                작성해주신 프로젝트 내용이 정상적으로 접수되었습니다.<br>
                검토 후 빠르게 전문가를 매칭해 드리겠습니다.
            </p>

            <div class="btn-area-center">
                <button type="button" class="btn btn-submit" onclick="location.href='${pageContext.request.contextPath}/client/my-projects'">
                    내 프로젝트 목록
                </button>

                <button type="button" class="btn btn-home" onclick="location.href='${pageContext.request.contextPath}/project/dashboard'">
                    프로젝트 찾기
                </button>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

</body>
</html>