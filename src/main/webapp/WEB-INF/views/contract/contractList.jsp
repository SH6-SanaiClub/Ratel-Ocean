<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>계약 목록 - Ratel-Ocean</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/contract/contract-common.css"/>
    
    <style>
        :root {
            --primary: #1F7A8C;
            --secondary: #A9D9DB;
            --dark: #2B2B2B;
            --muted: #6F7272;
            --light: #F1F6EE;
        }

        body {
            font-family: 'Malgun Gothic', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: var(--light);
            color: var(--dark);
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 2rem;
        }

        .page-header {
            margin-bottom: 2rem;
        }

        .page-title {
            font-size: 2rem;
            font-weight: bold;
            color: var(--dark);
            margin-bottom: 0.5rem;
        }

        .page-subtitle {
            color: var(--muted);
            font-size: 1rem;
        }

        .contract-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 1.5rem;
            margin-top: 2rem;
        }

        .contract-card {
            background: white;
            border-radius: 12px;
            padding: 1.5rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            cursor: pointer;
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }

        .contract-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 4px 16px rgba(0,0,0,0.15);
            border-color: var(--primary);
        }

        .contract-card-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 1rem;
        }

        .contract-card-title {
            font-size: 1.25rem;
            font-weight: bold;
            color: var(--dark);
            margin: 0;
            flex: 1;
        }

        .contract-card-badge {
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.875rem;
            font-weight: 600;
            white-space: nowrap;
        }

        .badge-waiting {
            background: #fef3c7;
            color: #92400e;
        }

        .badge-signed {
            background: #dbeafe;
            color: #1e40af;
        }

        .badge-paid {
            background: #d1fae5;
            color: #065f46;
        }

        .badge-completed {
            background: #e0e7ff;
            color: #3730a3;
        }

        .badge-terminated {
            background: #fee2e2;
            color: #991b1b;
        }

        .contract-card-info {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
            margin-top: 1rem;
        }

        .contract-card-info-item {
            display: flex;
            justify-content: space-between;
            font-size: 0.9rem;
        }

        .contract-card-info-label {
            color: var(--muted);
        }

        .contract-card-info-value {
            color: var(--dark);
            font-weight: 600;
        }

        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            background: white;
            border-radius: 12px;
            margin-top: 2rem;
        }

        .empty-state-icon {
            font-size: 4rem;
            margin-bottom: 1rem;
        }

        .empty-state-text {
            font-size: 1.125rem;
            color: var(--muted);
        }

        .go-to-detail-btn {
            display: inline-block;
            margin-top: 1rem;
            padding: 0.75rem 1.5rem;
            background: var(--primary);
            color: white;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            transition: background 0.2s;
        }

        .go-to-detail-btn:hover {
            background: #1a6b7a;
        }
    </style>
</head>
<body>
<c:set var="userType" value="FREELANCER" scope="request"/>
<jsp:include page="/WEB-INF/views/common/headerBase.jsp" />

<div class="container">
    <div class="page-header">
        <h1 class="page-title">📋 계약 목록</h1>
        <p class="page-subtitle">계약을 클릭하면 상세 페이지로 이동합니다</p>
    </div>

    <c:if test="${not empty errorMessage}">
        <div style="background: #fee2e2; color: #991b1b; padding: 1rem; border-radius: 8px; margin-bottom: 2rem;">
            ${errorMessage}
        </div>
    </c:if>

    <c:choose>
        <c:when test="${not empty allContracts and fn:length(allContracts) > 0}">
            <div class="contract-grid">
                <c:forEach var="contract" items="${allContracts}">
                    <div class="contract-card" onclick="goToContractDetail(${contract.contractId})">
                        <div class="contract-card-header">
                            <h3 class="contract-card-title">
                                <c:out value="${contract.projectTitle != null ? contract.projectTitle : '프로젝트 정보 없음'}"/>
                            </h3>
                            <c:choose>
                                <c:when test="${contract.contractStatus != null and (contract.contractStatus.name() eq 'WAITING' or contract.contractStatus.name() eq 'waiting')}">
                                    <span class="contract-card-badge badge-waiting">검토 대기</span>
                                </c:when>
                                <c:when test="${contract.contractStatus != null and (contract.contractStatus.name() eq 'SIGNED' or contract.contractStatus.name() eq 'signed')}">
                                    <span class="contract-card-badge badge-signed">결제 대기</span>
                                </c:when>
                                <c:when test="${contract.contractStatus != null and (contract.contractStatus.name() eq 'PAID' or contract.contractStatus.name() eq 'paid')}">
                                    <span class="contract-card-badge badge-paid">진행 중</span>
                                </c:when>
                                <c:when test="${contract.contractStatus != null and (contract.contractStatus.name() eq 'COMPLETED' or contract.contractStatus.name() eq 'completed')}">
                                    <span class="contract-card-badge badge-completed">완료</span>
                                </c:when>
                                <c:when test="${contract.contractStatus != null and (contract.contractStatus.name() eq 'TERMINATED' or contract.contractStatus.name() eq 'terminated')}">
                                    <span class="contract-card-badge badge-terminated">종료</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="contract-card-badge badge-waiting">${contract.contractStatus != null ? contract.contractStatus.name() : '-'}</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="contract-card-info">
                            <div class="contract-card-info-item">
                                <span class="contract-card-info-label">클라이언트</span>
                                <span class="contract-card-info-value">
                                    <c:out value="${contract.clientName != null ? contract.clientName : (contract.counterpartName != null ? contract.counterpartName : '-')}"/>
                                </span>
                            </div>
                            <div class="contract-card-info-item">
                                <span class="contract-card-info-label">계약 금액</span>
                                <span class="contract-card-info-value">
                                    <fmt:formatNumber value="${contract.totalBudget != null ? contract.totalBudget : 0}" pattern="#,###"/>원
                                </span>
                            </div>
                            <div class="contract-card-info-item">
                                <span class="contract-card-info-label">계약일</span>
                                <span class="contract-card-info-value">
                                    <c:out value="${contract.contractedAt != null ? contract.contractedAt : '-'}"/>
                                </span>
                            </div>
                            <c:if test="${contract.totalMilestones != null and contract.totalMilestones > 0}">
                                <div class="contract-card-info-item">
                                    <span class="contract-card-info-label">마일스톤</span>
                                    <span class="contract-card-info-value">
                                        ${contract.paidMilestones != null ? contract.paidMilestones : 0}/${contract.totalMilestones} 완료
                                    </span>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="empty-state">
                <div class="empty-state-icon">📋</div>
                <div class="empty-state-text">등록된 계약이 없습니다.</div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<script>
function goToContractDetail(contractId) {
    if (contractId) {
        window.location.href = '${pageContext.request.contextPath}/freelancer/contract/list?contractId=' + contractId;
    } else {
        window.location.href = '${pageContext.request.contextPath}/freelancer/contract/list';
    }
}
</script>
</body>
</html>
