<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>계약 전송 완료 - Ratel-Ocean</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/contract/contract-result.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
    <div class="result-page-container">
        <div class="result-card">
            <c:choose>
                <c:when test="${not empty message and (fn:contains(message, '성공') or fn:contains(message, '저장') or fn:contains(message, '수정'))}">
                    <!-- 성공 케이스 -->
                    <div class="result-icon-wrapper success">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <h1 class="result-title">✅ 계약서 전송 완료</h1>
                    <p class="result-message success">
                        ${message}
                    </p>
                    <div class="result-info-box">
                        <div class="result-info-box-title">
                            <i class="fas fa-info-circle"></i>
                            다음 단계
                        </div>
                        <div class="result-info-box-content">
                            프리랜서가 계약서를 검토한 후 수락 또는 거절할 수 있습니다.<br>
                            계약 관리 페이지에서 진행 상황을 확인하실 수 있습니다.
                        </div>
                    </div>
                    <div class="result-button-group">
                        <a href="${pageContext.request.contextPath}/client/contract/management" class="btn btn-primary">
                            <i class="fas fa-file-contract"></i>
                            계약 관리로 이동
                        </a>
                        <a href="${pageContext.request.contextPath}/" class="btn btn-secondary">
                            <i class="fas fa-home"></i>
                            메인으로 이동
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- 에러 케이스 -->
                    <div class="result-icon-wrapper error">
                        <i class="fas fa-exclamation-circle"></i>
                    </div>
                    <h1 class="result-title">⚠️ 계약서 전송 실패</h1>
                    <p class="result-message error">
                        ${not empty message ? message : '계약서 전송 중 오류가 발생했습니다.'}
                    </p>
                    <div class="result-info-box">
                        <div class="result-info-box-title">
                            <i class="fas fa-exclamation-triangle"></i>
                            확인 사항
                        </div>
                        <div class="result-info-box-content">
                            • 모든 필수 항목이 입력되었는지 확인해주세요.<br>
                            • 마일스톤 금액 합계가 총 계약금액과 일치하는지 확인해주세요.<br>
                            • 문제가 계속되면 고객센터로 문의해주세요.
                        </div>
                    </div>
                    <div class="result-button-group">
                        <a href="javascript:history.back()" class="btn btn-primary">
                            <i class="fas fa-arrow-left"></i>
                            이전으로 돌아가기
                        </a>
                        <a href="${pageContext.request.contextPath}/" class="btn btn-secondary">
                            <i class="fas fa-home"></i>
                            메인으로 이동
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</body>
</html>
