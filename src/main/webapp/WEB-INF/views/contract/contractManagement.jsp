<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <title>계약 관리</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common/contract-common.css"/>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f7fa;
            color: #333;
        }
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 24px;
        }
        .page-header {
            background: linear-gradient(135deg, #2c384d 0%, #1a2332 100%);
            color: white;
            padding: 32px;
            border-radius: 12px;
            margin-bottom: 24px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        .page-header h1 {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 8px;
        }
        .page-header p {
            font-size: 14px;
            opacity: 0.9;
        }
        .main-layout {
            display: grid;
            grid-template-columns: 320px 1fr;
            gap: 24px;
        }
        .sidebar {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            height: fit-content;
            position: sticky;
            top: 24px;
        }
        .status-section {
            margin-bottom: 24px;
        }
        .status-section:last-child {
            margin-bottom: 0;
        }
        .status-title {
            font-size: 16px;
            font-weight: 700;
            color: #2c384d;
            margin-bottom: 12px;
            padding-bottom: 8px;
            border-bottom: 2px solid #e9ecef;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        /* 상태 배지는 공통 CSS에서 가져옴 */
        .contract-list {
            list-style: none;
        }
        .contract-item {
            padding: 12px;
            margin-bottom: 8px;
            background: #f8f9fa;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s;
            border: 2px solid transparent;
        }
        .contract-item:hover {
            background: #e9ecef;
            transform: translateX(4px);
        }
        .contract-item.active {
            background: #e3f2fd;
            border-color: #2196f3;
        }
        .contract-item-title {
            font-weight: 600;
            font-size: 14px;
            color: #2c384d;
            margin-bottom: 4px;
        }
        .contract-item-meta {
            font-size: 12px;
            color: #6c757d;
        }
        .content-area {
            background: white;
            border-radius: 12px;
            padding: 32px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            min-height: 600px;
        }
        /* 빈 상태는 공통 CSS에서 가져옴 */
        /* 섹션 제목, 정보 그리드, PDF 뷰어, 마일스톤 테이블은 공통 CSS에서 가져옴 */
        .action-buttons {
            display: flex;
            gap: 12px;
            margin-top: 24px;
            padding-top: 24px;
            border-top: 2px solid #e9ecef;
        }
        /* 버튼 스타일은 공통 CSS에서 가져옴 */
        .cancel-form {
            display: flex;
            gap: 12px;
            align-items: flex-end;
        }
        .cancel-form input {
            flex: 1;
            padding: 12px;
            border: 1px solid #ced4da;
            border-radius: 8px;
            font-size: 14px;
        }
        /* 상태 인디케이터는 공통 CSS에서 가져옴 */
    </style>
</head>
<body>
    <div class="container">
        <div class="page-header">
            <h1>📋 계약 관리</h1>
            <p>제안한 계약서를 확인하고 관리하세요</p>
        </div>

        <div class="main-layout">
            <!-- 왼쪽 사이드바: 상태별 계약 목록 -->
            <div class="sidebar">
                <c:forEach var="statusEntry" items="${contractsByStatus}">
                    <div class="status-section">
                        <div class="status-title">
                            <c:choose>
                                <c:when test="${statusEntry.key eq 'WAITING'}">⏳ 대기 중</c:when>
                                <c:when test="${statusEntry.key eq 'SIGNED'}">✅ 수락됨</c:when>
                                <c:when test="${statusEntry.key eq 'COMPLETED'}">🎉 완료됨</c:when>
                                <c:when test="${statusEntry.key eq 'TERMINATED'}">❌ 거절됨</c:when>
                                <c:otherwise>📄 기타</c:otherwise>
                            </c:choose>
                            <span class="status-badge ${statusEntry.key.toLowerCase()}">${fn:length(statusEntry.value)}</span>
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

            <!-- 오른쪽: 선택한 계약 상세 정보 -->
            <div class="content-area">
                <c:choose>
                    <c:when test="${not empty selectedContract}">
                        <!-- 계약 정보 -->
                        <div class="section-title">📄 계약 정보</div>
                        <div class="info-grid">
                            <div class="info-item">
                                <div class="info-label">계약 ID</div>
                                <div class="info-value">#${selectedContract.contractId}</div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">계약 상태</div>
                                <div class="info-value">
                                    <span class="status-indicator ${fn:toLowerCase(selectedContract.contractStatus)}">
                                        <c:choose>
                                            <c:when test="${selectedContract.contractStatus eq 'WAITING' or selectedContract.contractStatus eq 'waiting'}">⏳ 대기 중</c:when>
                                            <c:when test="${selectedContract.contractStatus eq 'SIGNED' or selectedContract.contractStatus eq 'signed'}">✅ 수락됨</c:when>
                                            <c:when test="${selectedContract.contractStatus eq 'COMPLETED' or selectedContract.contractStatus eq 'completed'}">🎉 완료됨</c:when>
                                            <c:when test="${selectedContract.contractStatus eq 'TERMINATED' or selectedContract.contractStatus eq 'terminated'}">❌ 거절됨</c:when>
                                            <c:otherwise>${selectedContract.contractStatus}</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">프로젝트명</div>
                                <div class="info-value"><c:out value="${project.title}" default="-"/></div>
                            </div>
                            <c:if test="${not empty client}">
                                <div class="info-item">
                                    <div class="info-label">클라이언트</div>
                                    <div class="info-value"><c:out value="${client.clientName}" default="-"/></div>
                                </div>
                                <div class="info-item">
                                    <div class="info-label">이메일</div>
                                    <div class="info-value"><c:out value="${client.email}" default="-"/></div>
                                </div>
                                <div class="info-item">
                                    <div class="info-label">연락처</div>
                                    <div class="info-value"><c:out value="${client.phone}" default="-"/></div>
                                </div>
                            </c:if>
                            <div class="info-item">
                                <div class="info-label">계약 시작일</div>
                                <div class="info-value"><c:out value="${selectedContract.contractStartDate}" default="-"/></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">계약 종료일</div>
                                <div class="info-value"><c:out value="${selectedContract.contractEndDate}" default="-"/></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">총 예산</div>
                                <div class="info-value"><fmt:formatNumber value="${selectedContract.totalBudget}" pattern="#,###"/>원</div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">지급 방식</div>
                                <div class="info-value">
                                    <c:choose>
                                        <c:when test="${selectedContract.paymentMethod eq 'FULL'}">일시 지급</c:when>
                                        <c:when test="${selectedContract.paymentMethod eq 'MILESTONE'}">분할 지급 (마일스톤별)</c:when>
                                        <c:otherwise>${selectedContract.paymentMethod}</c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">계약 생성일</div>
                                <div class="info-value"><c:out value="${selectedContract.contractedAt}" default="-"/></div>
                            </div>
                        </div>

                        <!-- PDF 표시 -->
                        <c:if test="${not empty selectedContract.originContractUrl}">
                            <div class="section-title">📄 계약서 PDF</div>
                            <div class="pdf-viewer-container">
                                <iframe id="pdfViewer" src=""></iframe>
                                <script>
                                    (function() {
                                        var pdfPath = '<c:out value="${selectedContract.originContractUrl}" />';
                                        if (pdfPath) {
                                            pdfPath = pdfPath.replace(/\\/g, '/');
                                            var lastSlashIndex = pdfPath.lastIndexOf('/');
                                            if (lastSlashIndex >= 0) {
                                                var dirPath = pdfPath.substring(0, lastSlashIndex + 1);
                                                var fileName = pdfPath.substring(lastSlashIndex + 1);
                                                var encodedPath = dirPath + encodeURIComponent(fileName);
                                                document.getElementById('pdfViewer').src = '${pageContext.request.contextPath}/client/contract/file/' + encodedPath;
                                            } else {
                                                document.getElementById('pdfViewer').src = '${pageContext.request.contextPath}/client/contract/file/' + encodeURIComponent(pdfPath);
                                            }
                                        }
                                    })();
                                </script>
                            </div>
                            <div style="margin-bottom: 24px;">
                                <script>
                                    (function() {
                                        var pdfPath = '<c:out value="${selectedContract.originContractUrl}" />';
                                        if (pdfPath) {
                                            pdfPath = pdfPath.replace(/\\/g, '/');
                                            var lastSlashIndex = pdfPath.lastIndexOf('/');
                                            var downloadUrl;
                                            if (lastSlashIndex >= 0) {
                                                var dirPath = pdfPath.substring(0, lastSlashIndex + 1);
                                                var fileName = pdfPath.substring(lastSlashIndex + 1);
                                                downloadUrl = '${pageContext.request.contextPath}/client/contract/file/' + dirPath + encodeURIComponent(fileName);
                                            } else {
                                                downloadUrl = '${pageContext.request.contextPath}/client/contract/file/' + encodeURIComponent(pdfPath);
                                            }
                                            document.write('<a href="' + downloadUrl + '" download class="btn btn-secondary">📥 PDF 다운로드</a>');
                                        }
                                    })();
                                </script>
                            </div>
                        </c:if>

                        <!-- 마일스톤 -->
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

                        <!-- 액션 버튼 (SIGNED 상태일 때만) -->
                        <c:if test="${selectedContract.contractStatus eq 'SIGNED' or selectedContract.contractStatus eq 'signed'}">
                            <div class="action-buttons">
                                <form method="post" action="${pageContext.request.contextPath}/client/contract/management/finalize" style="display: inline;">
                                    <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                    <button type="submit" class="btn btn-primary" onclick="return confirm('계약을 최종 수락(결제)하시겠습니까?')">
                                        ✅ 계약 최종 수락 (결제)
                                    </button>
                                </form>
                                <form method="post" action="${pageContext.request.contextPath}/client/contract/management/cancel" class="cancel-form" style="display: inline;">
                                    <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                    <input type="text" name="reason" placeholder="취소 사유를 입력하세요" required 
                                           style="padding: 12px; border: 1px solid #ced4da; border-radius: 8px; font-size: 14px;" />
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
</body>
</html>
