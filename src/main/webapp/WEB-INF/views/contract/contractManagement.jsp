<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <title>계약 관리</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common/contract-common.css"/>
    <!-- 결제 모달 CSS 추가 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/payment/payment-modal.css"/>

    <!-- jQuery 및 포트원 SDK -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.iamport.kr/v1/iamport.js"></script>

    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f7fa; color: #333; }
        .container { max-width: 1400px; margin: 0 auto; padding: 24px; }
        .page-header { background: linear-gradient(135deg, #2c384d 0%, #1a2332 100%); color: white; padding: 32px; border-radius: 12px; margin-bottom: 24px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
        .page-header h1 { font-size: 28px; font-weight: 700; margin-bottom: 8px; }
        .page-header p { font-size: 14px; opacity: 0.9; }
        .main-layout { display: grid; grid-template-columns: 320px 1fr; gap: 24px; }
        .sidebar { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); height: fit-content; position: sticky; top: 24px; }
        .status-section { margin-bottom: 24px; }
        .status-section:last-child { margin-bottom: 0; }
        .status-title { font-size: 16px; font-weight: 700; color: #2c384d; margin-bottom: 12px; padding-bottom: 8px; border-bottom: 2px solid #e9ecef; display: flex; align-items: center; gap: 8px; }
        .status-badge { background: #e9ecef; color: #6c757d; padding: 2px 8px; border-radius: 12px; font-size: 12px; font-weight: 600; }
        .status-badge.waiting { background: #fff3cd; color: #856404; }
        .status-badge.signed { background: #d4edda; color: #155724; }
        .status-badge.paid { background: #cce5ff; color: #004085; }
        .status-badge.completed { background: #d1ecf1; color: #0c5460; }
        .status-badge.terminated { background: #f8d7da; color: #721c24; }
        .contract-list { list-style: none; }
        .contract-item { padding: 12px; margin-bottom: 8px; background: #f8f9fa; border-radius: 8px; cursor: pointer; transition: all 0.2s; border: 2px solid transparent; }
        .contract-item:hover { background: #e9ecef; transform: translateX(4px); }
        .contract-item.active { background: #e3f2fd; border-color: #2196f3; }
        .contract-item-title { font-weight: 600; font-size: 14px; color: #2c384d; margin-bottom: 4px; }
        .contract-item-meta { font-size: 12px; color: #6c757d; }
        .content-area { background: white; border-radius: 12px; padding: 32px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); min-height: 600px; }
        .empty-state { text-align: center; padding: 80px 20px; }
        .empty-state-icon { font-size: 64px; margin-bottom: 16px; opacity: 0.3; }
        .empty-state-text { font-size: 16px; color: #6c757d; }
        .section-title { font-size: 20px; font-weight: 700; color: #2c384d; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 2px solid #e9ecef; }
        .info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 16px; margin-bottom: 24px; }
        .info-item { padding: 16px; background: #f8f9fa; border-radius: 8px; }
        .info-label { font-size: 13px; color: #6c757d; margin-bottom: 6px; font-weight: 500; }
        .info-value { font-size: 15px; color: #2c384d; font-weight: 600; }
        .status-indicator { display: inline-block; padding: 6px 12px; border-radius: 20px; font-size: 13px; font-weight: 600; }
        .status-indicator.waiting { background: #fff3cd; color: #856404; }
        .status-indicator.signed { background: #d4edda; color: #155724; }
        .status-indicator.paid { background: #cce5ff; color: #004085; }
        .status-indicator.completed { background: #d1ecf1; color: #0c5460; }
        .status-indicator.terminated { background: #f8d7da; color: #721c24; }
        .action-buttons { display: flex; gap: 12px; margin-top: 24px; padding-top: 24px; border-top: 2px solid #e9ecef; }
        .cancel-form { display: flex; gap: 12px; align-items: flex-end; flex: 1; }
        .cancel-form input { flex: 1; padding: 12px; border: 1px solid #ced4da; border-radius: 8px; font-size: 14px; }
        .milestone-table { width: 100%; border-collapse: collapse; margin-top: 16px; }
        .milestone-table th, .milestone-table td { border: 1px solid #e9ecef; padding: 12px; text-align: left; }
        .milestone-table th { background: #f8f9fa; font-weight: 700; color: #2c384d; }
        .milestone-table tr:nth-child(even) { background: #f8f9fa; }
    </style>
</head>
<body>
<div class="container">
    <div class="page-header">
        <h1>📋 계약 관리</h1>
        <p>제안한 계약서를 확인하고 관리하세요</p>
    </div>

    <div class="main-layout">
        <!-- 사이드바 -->
        <div class="sidebar">
            <c:forEach var="statusEntry" items="${contractsByStatus}">
                <div class="status-section">
                    <div class="status-title">
                        <c:choose>
                            <c:when test="${statusEntry.key.name() eq 'WAITING'}">⏳ 대기 중</c:when>
                            <c:when test="${statusEntry.key.name() eq 'SIGNED'}">✅ 수락됨</c:when>
                            <c:when test="${statusEntry.key.name() eq 'PAID'}">💳 결제 완료</c:when>
                            <c:when test="${statusEntry.key.name() eq 'COMPLETED'}">🎉 완료됨</c:when>
                            <c:when test="${statusEntry.key.name() eq 'TERMINATED'}">❌ 거절됨</c:when>
                            <c:otherwise>📄 기타</c:otherwise>
                        </c:choose>
                        <span class="status-badge ${statusEntry.key.name().toLowerCase()}">${fn:length(statusEntry.value)}</span>
                    </div>
                    <ul class="contract-list">
                        <c:forEach var="contract" items="${statusEntry.value}">
                            <li class="contract-item ${selectedContract.contractId eq contract.contractId ? 'active' : ''}"
                                onclick="location.href='?contractId=${contract.contractId}'">
                                <div class="contract-item-title">계약 #${contract.contractId}</div>
                                <div class="contract-item-meta">
                                    <fmt:formatNumber value="${contract.totalBudget}" pattern="#,###"/>원
                                    <c:if test="${not empty contract.contractedAt}">
                                        · ${contract.contractedAt}
                                    </c:if>
                                </div>
                            </li>
                        </c:forEach>
                    </ul>
                </div>
            </c:forEach>
        </div>

        <!-- 메인 콘텐츠 영역 -->
        <div class="content-area">
            <c:choose>
                <c:when test="${not empty selectedContract}">
                    <div class="section-title">📄 계약 정보</div>
                    <div class="info-grid">
                        <div class="info-item">
                            <div class="info-label">계약 ID</div>
                            <div class="info-value">#${selectedContract.contractId}</div>
                        </div>
                        <div class="info-item">
                            <div class="info-label">계약 상태</div>
                            <div class="info-value">
                                <span class="status-indicator ${selectedContract.contractStatus.name().toLowerCase()}">
                                    <c:choose>
                                        <c:when test="${selectedContract.contractStatus.name() eq 'WAITING'}">⏳ 대기 중</c:when>
                                        <c:when test="${selectedContract.contractStatus.name() eq 'SIGNED'}">✅ 수락됨</c:when>
                                        <c:when test="${selectedContract.contractStatus.name() eq 'PAID'}">💳 결제 완료</c:when>
                                        <c:when test="${selectedContract.contractStatus.name() eq 'COMPLETED'}">🎉 완료됨</c:when>
                                        <c:when test="${selectedContract.contractStatus.name() eq 'TERMINATED'}">❌ 거절됨</c:when>
                                        <c:otherwise>${selectedContract.contractStatus}</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                        </div>
                        <div class="info-item">
                            <div class="info-label">프로젝트명</div>
                            <div class="info-value"><c:out value="${project.title}" default="-"/></div>
                        </div>
                        <div class="info-item">
                            <div class="info-label">프리랜서</div>
                            <div class="info-value">
                                <c:choose>
                                    <c:when test="${not empty contractDetail && not empty contractDetail.freelancerUser}">
                                        <c:out value="${contractDetail.freelancerUser.name}" default="-"/>
                                    </c:when>
                                    <c:otherwise>-</c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="info-item">
                            <div class="info-label">계약 시작일</div>
                            <div class="info-value"><c:out value="${selectedContract.contractStartDate}" default="-"/></div>
                        </div>
                        <div class="info-item">
                            <div class="info-label">계약 종료일</div>
                            <div class="info-value"><c:out value="${selectedContract.contractEndDate}" default="-"/></div>
                        </div>
                        <div class="info-item">
                            <div class="info-label">총 계약 금액</div>
                            <div class="info-value">
                                <fmt:formatNumber value="${selectedContract.totalBudget}" pattern="#,###"/>원
                            </div>
                        </div>
                    </div>

                    <!-- PDF 뷰어 (originContractUrl이 있는 경우) -->
                    <c:if test="${not empty selectedContract.originContractUrl}">
                        <div class="section-title">📑 계약서 PDF</div>
                        <div class="pdf-viewer-container">
                            <script>
                                (function() {
                                    const contractUrl = '${selectedContract.originContractUrl}';
                                    const viewerDiv = document.currentScript.parentElement;
                                    if (contractUrl) {
                                        const fullPath = '${pageContext.request.contextPath}/uploads/' + contractUrl;
                                        viewerDiv.innerHTML = '<iframe src="' + fullPath + '" style="width:100%; height:700px; border:none;"></iframe>';
                                    } else {
                                        viewerDiv.innerHTML = '<p style="text-align:center; padding:40px; color:#999;">계약서 PDF를 불러올 수 없습니다.</p>';
                                    }
                                    const downloadBtn = document.createElement('a');
                                    downloadBtn.href = fullPath;
                                    downloadBtn.download = 'contract_' + ${selectedContract.contractId} + '.pdf';
                                    downloadBtn.className = 'btn btn-secondary';
                                    downloadBtn.style.marginTop = '16px';
                                    downloadBtn.innerHTML = '📥 PDF 다운로드';
                                    if (contractUrl) {
                                        viewerDiv.appendChild(downloadBtn);
                                    }
                                })();
                            </script>
                        </div>
                    </c:if>

                    <!-- 마일스톤 정보 (있는 경우) -->
                    <c:if test="${not empty milestones}">
                        <div class="section-title">🎯 마일스톤 내역</div>
                        <table class="milestone-table">
                            <thead>
                            <tr>
                                <th>단계</th>
                                <th>마일스톤명</th>
                                <th style="text-align: right;">지급금액</th>
                                <th>작업 내용</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="m" items="${milestones}" varStatus="status">
                                <tr>
                                    <td style="text-align: center; font-weight: bold;">${status.index + 1}단계</td>
                                    <td><c:out value="${m.title}"/></td>
                                    <td style="text-align: right;"><fmt:formatNumber value="${m.amount}" pattern="#,###"/>원</td>
                                    <td><c:out value="${m.description}" default="-"/></td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </c:if>

                    <!-- 액션 버튼 (SIGNED 상태일 때만 표시) -->
                    <c:if test="${selectedContract.contractStatus.name() eq 'SIGNED'}">
                        <div class="action-buttons">
                            <!-- 결제하기 버튼 (모달 열기) -->
                            <c:set var="freelancerName" value="프리랜서"/>
                            <c:if test="${not empty contractDetail and not empty contractDetail.freelancerUser}">
                                <c:set var="freelancerName" value="${contractDetail.freelancerUser.name}"/>
                            </c:if>

                            <button type="button" class="btn btn-primary"
                                    onclick="openPaymentModal(
                                        ${selectedContract.contractId},
                                        ${selectedContract.totalBudget},
                                            '<c:out value="${not empty project ? project.title : '프로젝트'}"/>',
                                            '<c:out value="${freelancerName}"/>'
                                            )">
                                💳 결제하기
                            </button>

                            <!-- 계약 취소 -->
                            <form method="post" action="${pageContext.request.contextPath}/client/contract/management/cancel"
                                  class="cancel-form" style="display: flex; gap: 12px; align-items: flex-end; flex: 1;">
                                <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                <input type="text" name="reason" placeholder="취소 사유를 입력하세요" required
                                       style="flex: 1; padding: 12px; border: 1px solid #ced4da; border-radius: 8px; font-size: 14px;" />
                                <button type="submit" class="btn btn-danger" onclick="return confirm('계약을 취소하시겠습니까?')">
                                    ❌ 계약 취소
                                </button>
                            </form>
                        </div>
                    </c:if>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <div class="empty-state-icon">📋</div>
                        <div class="empty-state-text">왼쪽에서 계약을 선택하세요</div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<!-- ============================================================================
     결제 모달 HTML
     ============================================================================ -->
<div class="payment-modal-overlay">
    <div class="payment-modal-container">
        <!-- 모달 헤더 -->
        <div class="payment-modal-header">
            <button type="button" class="payment-modal-close" onclick="closePaymentModal()">×</button>
            <h2 class="payment-modal-title">💳 계약 결제</h2>
            <p class="payment-modal-subtitle">안전한 에스크로 결제 시스템으로 보호됩니다</p>
        </div>

        <!-- 모달 본문 -->
        <div class="payment-modal-body">
            <!-- 계약 정보 -->
            <div class="payment-info-section">
                <h3 class="payment-info-title">📋 계약 정보</h3>
                <div class="payment-info-grid">
                    <div class="payment-info-item">
                        <span class="payment-info-label">프로젝트명</span>
                        <span class="payment-info-value" id="payment-project-title">-</span>
                    </div>
                    <div class="payment-info-item">
                        <span class="payment-info-label">프리랜서</span>
                        <span class="payment-info-value" id="payment-freelancer-name">-</span>
                    </div>
                    <div class="payment-info-item">
                        <span class="payment-info-label">계약 ID</span>
                        <span class="payment-info-value" id="payment-contract-id">-</span>
                    </div>
                </div>

                <!-- 결제 금액 강조 -->
                <div class="payment-amount-highlight">
                    <div class="payment-amount-label">총 결제 금액</div>
                    <div class="payment-amount-value">
                        <span id="payment-total-amount">0원</span>
                    </div>
                </div>
            </div>

            <!-- 안내 메시지 -->
            <div class="payment-notice">
                <p class="payment-notice-title">⚠️ 결제 전 확인사항</p>
                <ul class="payment-notice-list">
                    <li>결제 금액은 에스크로 시스템에서 안전하게 보관됩니다</li>
                    <li>프로젝트 완료 후 프리랜서에게 지급됩니다</li>
                    <li>결제 후 계약 취소 시 환불이 가능합니다</li>
                </ul>
            </div>

            <!-- 버튼 그룹 -->
            <div class="payment-modal-buttons">
                <button type="button" class="payment-modal-btn payment-modal-btn-secondary" onclick="closePaymentModal()">
                    취소
                </button>
                <button type="button" class="payment-modal-btn payment-modal-btn-primary" id="payment-submit-btn" onclick="startPayment()">
                    💳 결제하기
                </button>
            </div>
        </div>
    </div>
</div>

<!-- 결제 모달 JavaScript -->
<script src="${pageContext.request.contextPath}/resources/js/payment/payment-modal.js"></script>

</body>
</html>
