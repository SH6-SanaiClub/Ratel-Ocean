<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>계약 확정 완료 - 라테오션</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        
        .container {
            background: white;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            max-width: 600px;
            width: 100%;
            overflow: hidden;
        }
        
        .success-header {
            background: linear-gradient(135deg, #4caf50 0%, #45a049 100%);
            color: white;
            padding: 60px 30px;
            text-align: center;
        }
        
        .success-icon {
            font-size: 80px;
            margin-bottom: 20px;
            animation: bounce 0.6s ease-in-out;
        }
        
        @keyframes bounce {
            0% {
                transform: scale(0);
                opacity: 0;
            }
            50% {
                transform: scale(1.1);
            }
            100% {
                transform: scale(1);
                opacity: 1;
            }
        }
        
        .success-title {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 10px;
        }
        
        .success-message {
            font-size: 16px;
            opacity: 0.95;
            line-height: 1.5;
        }
        
        .content {
            padding: 40px 30px;
        }
        
        .info-box {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 25px;
            border-left: 4px solid #4caf50;
        }
        
        .info-item {
            display: grid;
            grid-template-columns: 150px 1fr;
            gap: 20px;
            margin-bottom: 15px;
            align-items: center;
        }
        
        .info-item:last-child {
            margin-bottom: 0;
        }
        
        .info-label {
            font-size: 12px;
            color: #666;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .info-value {
            font-size: 16px;
            color: #333;
            font-weight: 500;
        }
        
        .contract-id-display {
            background: linear-gradient(135deg, #4caf50 0%, #45a049 100%);
            color: white;
            padding: 25px;
            border-radius: 8px;
            text-align: center;
            margin-bottom: 25px;
        }
        
        .contract-id-label {
            font-size: 12px;
            opacity: 0.9;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 10px;
            font-weight: 600;
        }
        
        .contract-id {
            font-size: 32px;
            font-weight: 700;
            font-family: 'Courier New', monospace;
            letter-spacing: 3px;
        }
        
        .status-badge {
            background: #e8f5e9;
            color: #2e7d32;
            padding: 12px 20px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            display: inline-block;
            margin-bottom: 25px;
        }
        
        .next-steps {
            background: #e3f2fd;
            border: 1px solid #bbdefb;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 25px;
        }
        
        .next-steps-title {
            font-size: 14px;
            font-weight: 600;
            color: #1565c0;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .next-steps-list {
            list-style: none;
            padding-left: 0;
        }
        
        .next-steps-list li {
            padding: 8px 0;
            padding-left: 25px;
            position: relative;
            font-size: 13px;
            color: #1565c0;
            line-height: 1.6;
        }
        
        .next-steps-list li:before {
            content: "✓";
            position: absolute;
            left: 0;
            font-weight: bold;
        }
        
        .button-group {
            display: flex;
            gap: 15px;
            justify-content: center;
        }
        
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #4caf50 0%, #45a049 100%);
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(76, 175, 80, 0.3);
        }
        
        .btn-secondary {
            background: #f0f0f0;
            color: #333;
        }
        
        .btn-secondary:hover {
            background: #e0e0e0;
        }
        
        .footer {
            background: #f5f5f5;
            padding: 20px 30px;
            text-align: center;
            color: #999;
            font-size: 12px;
            border-top: 1px solid #e0e0e0;
        }
        
        @media (max-width: 600px) {
            .success-icon {
                font-size: 60px;
            }
            
            .success-title {
                font-size: 22px;
            }
            
            .contract-id {
                font-size: 24px;
            }
            
            .button-group {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/common/header.jsp" />
    <div class="container">
        
        <!-- 성공 헤더 -->
        <div class="success-header">
            <div class="success-icon">✅</div>
            <div class="success-title">계약 확정 완료</div>
            <div class="success-message">
                계약이 성공적으로 저장되었습니다.<br>
                아래 계약 ID를 보관하세요.
            </div>
        </div>
        
        <!-- 메인 콘텐츠 -->
        <div class="content">
            
            <!-- 상태 배지 -->
            <div style="text-align: center;">
                <span class="status-badge">🟢 계약 생성됨</span>
            </div>
            
            <!-- 계약 ID 표시 -->
            <div class="contract-id-display">
                <div class="contract-id-label">계약 ID</div>
                <div class="contract-id">#${contractId}</div>
            </div>
            
            <!-- 계약 정보 -->
            <h2 style="font-size: 16px; font-weight: 600; color: #333; margin-bottom: 15px; padding-bottom: 12px; border-bottom: 2px solid #e0e0e0;">
                📋 계약 정보
            </h2>
            
            <div class="info-box">
                <div class="info-item">
                    <span class="info-label">계약 ID</span>
                    <span class="info-value">#${contractId}</span>
                </div>
                
                <div class="info-item">
                    <span class="info-label">프로젝트</span>
                    <span class="info-value">프로젝트 #${projectId}</span>
                </div>
                
                <div class="info-item">
                    <span class="info-label">계약액</span>
                    <span class="info-value">
                        <fmt:formatNumber value="${totalBudget}" type="number" groupingUsed="true" /> 원
                    </span>
                </div>
                
                <div class="info-item">
                    <span class="info-label">결제 방식</span>
                    <span class="info-value">${paymentMethod}</span>
                </div>
                
                <div class="info-item">
                    <span class="info-label">마일스톤</span>
                    <span class="info-value">${milestonesCount}단계</span>
                </div>
                
                <div class="info-item">
                    <span class="info-label">확정 시간</span>
                    <span class="info-value">
                        <fmt:formatDate value="${contractedAt}" pattern="yyyy-MM-dd HH:mm:ss" />
                    </span>
                </div>
            </div>
            
            <!-- 다음 단계 -->
            <div class="next-steps">
                <div class="next-steps-title">📌 다음 단계</div>
                <ul class="next-steps-list">
                    <li>계약 ID #${contractId}는 마일스톤 진행 및 결제에 사용됩니다.</li>
                    <li>프리랜서와 함께 마일스톤 계획을 확인하세요.</li>
                    <li>첫 번째 마일스톤 시작 전에 선금 입금을 확인하세요.</li>
                    <li>마일스톤별 진행 상황을 대시보드에서 추적하세요.</li>
                </ul>
            </div>
            
            <!-- 버튼 그룹 -->
            <div class="button-group">
                <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary">
                    📊 계약 관리로 이동
                </a>
                <a href="javascript:window.print()" class="btn btn-secondary">
                    🖨️ 계약 인쇄
                </a>
            </div>
        </div>
        
        <!-- 푸터 -->
        <div class="footer">
            <p>계약 정보는 대시보드에서 언제든지 확인할 수 있습니다. | 질문이 있으신가요? support@lateocean.com</p>
        </div>
    </div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

</body>
</html>
