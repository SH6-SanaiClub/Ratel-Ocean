<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>금융 관리 - 프리랜서</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: Pretendard, Arial, sans-serif;
            background: #f8fafc;
            color: #111827;
        }
        .container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 16px;
        }
        .finance-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .card {
            background: white;
            border-radius: 18px;
            padding: 24px;
            box-shadow: 0 10px 28px rgba(15,23,42,0.08);
        }
        .card-title {
            font-size: 14px;
            font-weight: 800;
            color: #6b7280;
            margin-bottom: 12px;
        }
        .card-value {
            font-size: 32px;
            font-weight: 950;
            color: #111827;
            letter-spacing: -0.5px;
        }
        .card-unit {
            font-size: 13px;
            color: #6b7280;
            margin-top: 4px;
        }
        .status-positive { color: #059669; }
        .status-negative { color: #dc2626; }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/views/common/freelancer_header.jsp" %>

<div class="container">
    <h1 style="font-size: 28px; margin-bottom: 24px; font-weight: 950;">금융 관리</h1>
    
    <!-- 요약 카드 -->
    <div class="finance-grid">
        <div class="card">
            <div class="card-title">총 수입</div>
            <div class="card-value">₩0</div>
            <div class="card-unit">이번 달</div>
        </div>
        <div class="card">
            <div class="card-title">정산 대기 중</div>
            <div class="card-value">₩0</div>
            <div class="card-unit">예정 정산액</div>
        </div>
        <div class="card">
            <div class="card-title">정산 완료</div>
            <div class="card-value">₩0</div>
            <div class="card-unit">누적</div>
        </div>
    </div>

    <!-- 상세 내역 (추후 구현) -->
    <div class="card" style="margin-bottom: 20px;">
        <h2 style="font-size: 18px; margin-bottom: 20px; font-weight: 900;">거래 내역</h2>
        <p style="color: #6b7280; text-align: center; padding: 40px 0;">
            거래 내역이 없습니다.
        </p>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

</body>
</html>
