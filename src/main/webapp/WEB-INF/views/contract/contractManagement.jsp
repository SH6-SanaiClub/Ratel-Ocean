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
        /* 스타일은 기존과 동일하므로 생략하지 않고 그대로 유지 */
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
        .contract-list { list-style: none; }
        .contract-item { padding: 12px; margin-bottom: 8px; background: #f8f9fa; border-radius: 8px; cursor: pointer; transition: all 0.2s; border: 2px solid transparent; }
        .contract-item:hover { background: #e9ecef; transform: translateX(4px); }
        .contract-item.active { background: #e3f2fd; border-color: #2196f3; }
        .contract-item-title { font-weight: 600; font-size: 14px; color: #2c384d; margin-bottom: 4px; }
        .contract-item-meta { font-size: 12px; color: #6c757d; }
        .content-area { background: white; border-radius: 12px; padding: 32px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); min-height: 600px; }
        .action-buttons { display: flex; gap: 12px; margin-top: 24px; padding-top: 24px; border-top: 2px solid #e9ecef; }
        .cancel-form { display: flex; gap: 12px; align-items: flex-end; }
        .cancel-form input { flex: 1; padding: 12px; border: 1px solid #ced4da; border-radius: 8px; font-size: 14px; }
    </style>
</head>
<body>
<div class="container">
    <div class="page-header">
        <h1>📋 계약 관리</h1>
        <p>제안한 계약서를 확인하고 관리하세요</p>
    </div>

    <div class="main-layout">
        <div class="sidebar">
            <c:forEach var="statusEntry" items="${contractsByStatus}">
                <div class="status-section">
                    <div class="status-title">
                            <%-- [수정 1] statusEntry.key가 Enum이므로 .name() 추가 --%>
                        <c:choose>
                            <c:when test="${statusEntry.key.name() eq 'WAITING'}">⏳ 대기 중</c:when>
                            <c:when test="${statusEntry.key.name() eq 'SIGNED'}">✅ 수락됨</c:when>
                            <c:when test="${statusEntry.key.name() eq 'COMPLETED'}">🎉 완료됨</c:when>
                            <c:when test="${statusEntry.key.name() eq 'TERMINATED'}">❌ 거절됨</c:when>
                            <c:otherwise>📄 기타</c:otherwise>
                        </c:choose>

                            <%-- [수정 2] 이미 적용하셨던 부분 (.name().toLowerCase()) 유지 --%>
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
                                    <%-- [수정 3] fn:toLowerCase 안에 .name() 추가 --%>
                                <span class="status-indicator ${selectedContract.contractStatus.name().toLowerCase()}">
                                        <%-- [수정 4] .name() 추가 및 불필요한 소문자 비교 제거 --%>
                                        <c:choose>
                                            <c:when test="${selectedContract.contractStatus.name() eq 'WAITING'}">⏳ 대기 중</c:when>
                                            <c:when test="${selectedContract.contractStatus.name() eq 'SIGNED'}">✅ 수락됨</c:when>
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
                                    <%-- [참고] PaymentMethod도 Enum이라면 여기도 .name()이 필요할 수 있음 --%>
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

                    <%-- [수정 5] 액션 버튼 조건문에도 .name() 추가 --%>
                    <c:if test="${selectedContract.contractStatus.name() eq 'SIGNED'}">
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