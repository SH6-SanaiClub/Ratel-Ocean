<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>안심 결제 | Ratel Ocean</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/landing.css">

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.iamport.kr/v1/iamport.js"></script>

    <style>
        /* 이 페이지 전용 스타일 */
        body { background-color: #f4f6f9; font-family: 'Pretendard', sans-serif; margin: 0; padding: 0; }

        .simple-header {
            background: #fff;
            padding: 15px 40px;
            border-bottom: 1px solid #ddd;
            display: flex;
            align-items: center;
        }
        .simple-header img { height: 40px; }

        .payment-container {
            max-width: 600px;
            margin: 60px auto;
            background: #fff;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
        }

        .payment-title { font-size: 24px; font-weight: bold; margin-bottom: 10px; text-align: center; color: #333; }
        .payment-desc { text-align: center; color: #666; margin-bottom: 40px; font-size: 14px; }

        .info-box {
            background-color: #f8f9fa;
            border: 1px solid #eee;
            border-radius: 8px;
            padding: 25px;
            margin-bottom: 30px;
        }
        .info-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
            font-size: 15px;
        }
        .info-row:last-child { margin-bottom: 0; }
        .info-label { color: #888; }
        .info-value { font-weight: 600; color: #333; }

        .total-price {
            border-top: 1px solid #ddd;
            margin-top: 15px;
            padding-top: 15px;
            font-size: 20px;
            color: #007bff;
        }

        .btn-pay {
            display: block;
            width: 100%;
            padding: 18px;
            background-color: #007bff;
            color: #fff;
            border: none;
            border-radius: 8px;
            font-size: 18px;
            font-weight: bold;
            cursor: pointer;
            transition: 0.2s;
        }
        .btn-pay:hover { background-color: #0056b3; }

        .footer-notice { margin-top: 20px; text-align: center; font-size: 12px; color: #aaa; }
    </style>
</head>
<body>

<header class="simple-header">
    <a href="${pageContext.request.contextPath}/">
        <img src="${pageContext.request.contextPath}/resources/images/RatelOceanLOGO.png" alt="Ratel Ocean Logo">
    </a>
</header>

<div class="payment-container">
    <h2 class="payment-title">프로젝트 결제</h2>
    <p class="payment-desc">
        안전한 에스크로 결제를 위해<br>결제 정보를 확인해 주세요.
    </p>

    <div class="info-box">
        <div class="info-row">
            <span class="info-label">계약 ID</span>
            <span class="info-value">#${contract.contractId}</span>
        </div>
        <div class="info-row">
            <span class="info-label">프로젝트 기간</span>
            <span class="info-value">${contract.contractStartDate} ~ ${contract.contractEndDate}</span>
        </div>
        <div class="info-row total-price">
            <span class="info-label">최종 결제 금액</span>
            <span class="info-value">
                    <fmt:formatNumber value="${contract.totalBudget}" type="number"/> 원
                </span>
        </div>
    </div>

    <button type="button" class="btn-pay" onclick="requestPayment()">
        결제하기
    </button>

    <div class="footer-notice">
        🔒 결제 금액은 프로젝트 완료 시까지 안전하게 보호됩니다.
    </div>
</div>

<script>
    // 포트원 초기화
    var IMP = window.IMP;
    IMP.init("${impCode}"); // Controller에서 넘겨준 식별코드

    // JSP 변수를 JS 변수로 변환
    var contractId = "${contract.contractId}";
    var totalAmount = ${contract.totalBudget};
    var contractName = "프로젝트 계약 대금 (계약 #" + contractId + ")";

    // 구매자 정보 바인딩
    var buyerEmail = "${buyer.email}";
    var buyerName = "${buyer.name}";
    var buyerTel = "";

    function requestPayment() {
        if(totalAmount <= 0) {
            alert("결제할 금액이 없습니다.");
            return;
        }

        // 1. 서버: 결제 사전 검증 및 Merchant UID 생성
        $.ajax({
            url: "/payment/prepare",
            method: "POST",
            contentType: "application/json",
            data: JSON.stringify({
                contractId: parseInt(contractId),
                amount: totalAmount,
                name: contractName,
                buyerEmail: buyerEmail,
                buyerName: buyerName
            }),
            success: function(data) {
                console.log("사전 검증 성공, merchantUid:", data.merchantUid);
                // 2. 포트원 결제창 호출
                launchPortone(data);
            },
            error: function(xhr) {
                alert("결제 준비 중 오류가 발생했습니다.\n" + xhr.responseText);
            }
        });
    }

    function launchPortone(data) {
        IMP.request_pay({
            pg: "html5_inicis",       // PG사 설정 (테스트용)
            pay_method: "card",       // 결제 수단
            merchant_uid: data.merchantUid, // 서버에서 받은 주문번호
            name: data.name,
            amount: data.amount,
            buyer_email: data.buyerEmail,
            buyer_name: data.buyerName,
            buyer_tel: data.buyerTel
        }, function(rsp) {
            if (rsp.success) {
                // 3. 결제 성공 시 서버 사후 검증
                verifyPayment(rsp);
            } else {
                alert("결제에 실패하였습니다.\n에러 내용: " + rsp.error_msg);
            }
        });
    }

    function verifyPayment(rsp) {
        $.ajax({
            url: "/payment/complete",
            method: "POST",
            contentType: "application/json",
            data: JSON.stringify({
                impUid: rsp.imp_uid,
                merchantUid: rsp.merchant_uid
            }),
            success: function(result) {
                if (result.success) {
                    // 성공 페이지로 이동
                    location.href = "/payment/success?contractId=" + contractId;
                } else {
                    alert("결제 검증 실패: " + result.message);
                    location.href = "/payment/fail?errorMsg=" + encodeURIComponent(result.message);
                }
            },
            error: function(xhr) {
                alert("서버 통신 오류가 발생했습니다.");
            }
        });
    }
</script>

</body>
</html>