<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>계약 관리</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/contract/contract-common.css"/>
</head>
<body>
    <div class="container">
        <div class="page-header">
            <h1>📋 계약 관리</h1>
            <p>제안한 계약서를 확인하고 관리하세요</p>
        </div>
        
        <c:if test="${not empty successMessage}">
            <div class="message-success">
                ✅ ${successMessage}
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="message-error">
                ❌ ${errorMessage}
            </div>
        </c:if>

        <div class="main-layout">
            <div class="sidebar">
                <c:forEach var="statusEntry" items="${contractsByStatus}">
                    <c:choose>
                        <c:when test="${statusEntry.key eq 'TERMINATED'}">
                            <c:set var="hasRejected" value="false"/>
                            <c:forEach var="contract" items="${statusEntry.value}">
                                <c:if test="${fn:startsWith(contract.cancelReason, '[거절]')}">
                                    <c:set var="hasRejected" value="true"/>
                                </c:if>
                            </c:forEach>
                            <c:if test="${hasRejected}">
                                <div class="status-section">
                                    <div class="status-title" onclick="toggleSection(this)">
                                        <span class="toggle-icon">▼</span>
                                        🚫 프리랜서가 거절함
                                        <span class="status-badge rejected">
                                            <c:set var="rejectedCount" value="0"/>
                                            <c:forEach var="contract" items="${statusEntry.value}">
                                                <c:if test="${fn:startsWith(contract.cancelReason, '[거절]')}">
                                                    <c:set var="rejectedCount" value="${rejectedCount + 1}"/>
                                                </c:if>
                                            </c:forEach>
                                            ${rejectedCount}
                                        </span>
                                    </div>
                                    <ul class="contract-list">
                                        <c:forEach var="contract" items="${statusEntry.value}">
                                            <c:if test="${fn:startsWith(contract.cancelReason, '[거절]')}">
                                            <li class="contract-item ${selectedContract.contractId eq contract.contractId ? 'active' : ''}"
                                                onclick="location.href='?contractId=${contract.contractId}'">
                                                <div class="contract-item-title">
                                                    <c:choose>
                                                        <c:when test="${not empty contract.projectTitle}">
                                                            <c:out value="${contract.projectTitle}"/>
                                                        </c:when>
                                                        <c:otherwise>프로젝트 정보 없음</c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="contract-item-subtitle">
                                                    <c:choose>
                                                        <c:when test="${not empty contract.counterpartName}">
                                                            <c:out value="${contract.counterpartName}"/>
                                                        </c:when>
                                                        <c:otherwise>프리랜서 정보 없음</c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="contract-item-meta">
                                                    <fmt:formatNumber value="${contract.totalBudget}" pattern="#,###"/>원
                                                    <c:if test="${not empty contract.contractedAt}">
                                                        · ${contract.contractedAt}
                                                    </c:if>
                                                </div>
                                            </li>
                                            </c:if>
                                        </c:forEach>
                                    </ul>
                                </div>
                            </c:if>
                            
                            <!-- 취소됨 섹션 -->
                            <c:set var="hasCancelled" value="false"/>
                            <c:forEach var="contract" items="${statusEntry.value}">
                                <c:if test="${fn:startsWith(contract.cancelReason, '[취소]')}">
                                    <c:set var="hasCancelled" value="true"/>
                                </c:if>
                            </c:forEach>
                            <c:if test="${hasCancelled}">
                                <div class="status-section">
                                    <div class="status-title" onclick="toggleSection(this)">
                                        <span class="toggle-icon">▼</span>
                                        ❌ 내가 취소함
                                        <span class="status-badge cancelled">
                                            <c:set var="cancelledCount" value="0"/>
                                            <c:forEach var="contract" items="${statusEntry.value}">
                                                <c:if test="${fn:startsWith(contract.cancelReason, '[취소]')}">
                                                    <c:set var="cancelledCount" value="${cancelledCount + 1}"/>
                                                </c:if>
                                            </c:forEach>
                                            ${cancelledCount}
                                        </span>
                                    </div>
                                    <ul class="contract-list">
                                        <c:forEach var="contract" items="${statusEntry.value}">
                                            <c:if test="${fn:startsWith(contract.cancelReason, '[취소]')}">
                                            <li class="contract-item ${selectedContract.contractId eq contract.contractId ? 'active' : ''}"
                                                onclick="location.href='?contractId=${contract.contractId}'">
                                                <div class="contract-item-title">
                                                    <c:choose>
                                                        <c:when test="${not empty contract.projectTitle}">
                                                            <c:out value="${contract.projectTitle}"/>
                                                        </c:when>
                                                        <c:otherwise>프로젝트 정보 없음</c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="contract-item-subtitle">
                                                    <c:choose>
                                                        <c:when test="${not empty contract.counterpartName}">
                                                            <c:out value="${contract.counterpartName}"/>
                                                        </c:when>
                                                        <c:otherwise>프리랜서 정보 없음</c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="contract-item-meta">
                                                    <fmt:formatNumber value="${contract.totalBudget}" pattern="#,###"/>원
                                                    <c:if test="${not empty contract.contractedAt}">
                                                        · ${contract.contractedAt}
                                                    </c:if>
                                                </div>
                                            </li>
                                            </c:if>
                                        </c:forEach>
                                    </ul>
                                </div>
                            </c:if>
                            
                            <!-- 기타 종료된 계약 (prefix가 없는 경우) -->
                            <c:set var="hasOtherTerminated" value="false"/>
                            <c:forEach var="contract" items="${statusEntry.value}">
                                <c:if test="${!fn:startsWith(contract.cancelReason, '[거절]') && !fn:startsWith(contract.cancelReason, '[취소]')}">
                                    <c:set var="hasOtherTerminated" value="true"/>
                                </c:if>
                            </c:forEach>
                            <c:if test="${hasOtherTerminated}">
                                <div class="status-section">
                                    <div class="status-title" onclick="toggleSection(this)">
                                        <span class="toggle-icon">▼</span>
                                        ⚠️ 중도 종료
                                        <span class="status-badge terminated">
                                            <c:set var="otherTerminatedCount" value="0"/>
                                            <c:forEach var="contract" items="${statusEntry.value}">
                                                <c:if test="${!fn:startsWith(contract.cancelReason, '[거절]') && !fn:startsWith(contract.cancelReason, '[취소]')}">
                                                    <c:set var="otherTerminatedCount" value="${otherTerminatedCount + 1}"/>
                                                </c:if>
                                            </c:forEach>
                                            ${otherTerminatedCount}
                                        </span>
                                    </div>
                                    <ul class="contract-list">
                                        <c:forEach var="contract" items="${statusEntry.value}">
                                            <c:if test="${!fn:startsWith(contract.cancelReason, '[거절]') && !fn:startsWith(contract.cancelReason, '[취소]')}">
                                            <li class="contract-item ${selectedContract.contractId eq contract.contractId ? 'active' : ''}"
                                                onclick="location.href='?contractId=${contract.contractId}'">
                                                <div class="contract-item-title">
                                                    <c:choose>
                                                        <c:when test="${not empty contract.projectTitle}">
                                                            <c:out value="${contract.projectTitle}"/>
                                                        </c:when>
                                                        <c:otherwise>프로젝트 정보 없음</c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="contract-item-subtitle">
                                                    <c:choose>
                                                        <c:when test="${not empty contract.counterpartName}">
                                                            <c:out value="${contract.counterpartName}"/>
                                                        </c:when>
                                                        <c:otherwise>프리랜서 정보 없음</c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="contract-item-meta">
                                                    <fmt:formatNumber value="${contract.totalBudget}" pattern="#,###"/>원
                                                    <c:if test="${not empty contract.contractedAt}">
                                                        · ${contract.contractedAt}
                                                    </c:if>
                                                </div>
                                            </li>
                                            </c:if>
                                        </c:forEach>
                                    </ul>
                                </div>
                            </c:if>
                        </c:when>
                        <c:otherwise>
                            <!-- 일반 상태 (WAITING, SIGNED, PAID, COMPLETED) -->
                            <div class="status-section">
                                <div class="status-title" onclick="toggleSection(this)">
                                    <span class="toggle-icon">▼</span>
                                    <c:choose>
                                        <c:when test="${statusEntry.key eq 'WAITING'}">⏳ 전송됨</c:when>
                                        <c:when test="${statusEntry.key eq 'SIGNED'}">✅ 프리랜서 승인 완료 (지급 대기 중)</c:when>
                                        <c:when test="${statusEntry.key eq 'PAID'}">
                                            <jsp:include page="includes/statusTitlePaid.jsp"/>
                                        </c:when>
                                        <c:when test="${statusEntry.key eq 'SETTLEMENT_PENDING'}">
                                            <jsp:include page="includes/statusTitleSettlementPending.jsp"/>
                                        </c:when>
                                        <c:when test="${statusEntry.key eq 'COMPLETED_HISTORY'}">
                                            ✅ 완료 내역
                                        </c:when>
                                        <c:when test="${statusEntry.key eq 'COMPLETED'}">
                                            <%-- 기존 COMPLETED도 처리 (하위 호환성) --%>
                                            <c:set var="firstContract" value="${statusEntry.value[0]}"/>
                                            <c:choose>
                                                <c:when test="${firstContract.totalMilestones == null || firstContract.totalMilestones == 0}">
                                                    ✅ 완료 내역
                                                </c:when>
                                                <c:when test="${firstContract.paidMilestones == firstContract.totalMilestones}">
                                                    ✅ 완료 내역
                                                </c:when>
                                                <c:otherwise>
                                                    🎉 정산 대기
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:otherwise>📄 기타 (${statusEntry.key})</c:otherwise>
                                    </c:choose>
                                    <span class="status-badge ${statusEntry.key.toLowerCase()}">${fn:length(statusEntry.value)}</span>
                                </div>
                                <ul class="contract-list">
                                    <c:forEach var="contract" items="${statusEntry.value}">
                                        <li class="contract-item ${selectedContract.contractId eq contract.contractId ? 'active' : ''}"
                                            onclick="location.href='?contractId=${contract.contractId}'">
                                            <div class="contract-item-title">
                                                <c:choose>
                                                    <c:when test="${not empty contract.projectTitle}">
                                                        <c:out value="${contract.projectTitle}"/>
                                                    </c:when>
                                                    <c:otherwise>프로젝트 정보 없음</c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="contract-item-subtitle">
                                                <c:choose>
                                                    <c:when test="${not empty contract.counterpartName}">
                                                        <c:out value="${contract.counterpartName}"/>
                                                    </c:when>
                                                    <c:otherwise>프리랜서 정보 없음</c:otherwise>
                                                </c:choose>
                                            </div>
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
                        </c:otherwise>
                    </c:choose>
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
                                            <c:when test="${selectedContract.contractStatus eq 'WAITING' or selectedContract.contractStatus eq 'waiting'}">⏳ 전송됨</c:when>
                                            <c:when test="${selectedContract.contractStatus eq 'SIGNED' or selectedContract.contractStatus eq 'signed'}">✅ 프리랜서 승인 완료 (지급 대기 중)</c:when>
                                            <c:when test="${selectedContract.contractStatus eq 'PAID' or selectedContract.contractStatus eq 'paid'}">
                                                <c:choose>
                                                    <c:when test="${selectedContract.requestedMilestones > 0}">
                                                        ✅ 최종 승인 대기 (지급 요청 대기: ${selectedContract.requestedMilestones}건)
                                                    </c:when>
                                                    <c:when test="${selectedContract.depositedMilestones > 0}">
                                                        ✅ 최종 승인 대기 (입금 완료: ${selectedContract.depositedMilestones}건)
                                                    </c:when>
                                                    <c:when test="${selectedContract.paidMilestones > 0}">
                                                        ✅ 최종 승인 대기 (지급 진행 중: ${selectedContract.paidMilestones}/${selectedContract.totalMilestones})
                                                    </c:when>
                                                    <c:otherwise>
                                                        ✅ 최종 승인 대기
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:when test="${selectedContract.contractStatus eq 'COMPLETED' or selectedContract.contractStatus eq 'completed'}">
                                                <c:choose>
                                                    <%-- 마일스톤이 없는 경우 (일시지급) --%>
                                                    <c:when test="${selectedContract.totalMilestones == null || selectedContract.totalMilestones == 0}">
                                                        ✅ 완료 내역
                                                    </c:when>
                                                    <%-- 마일스톤이 있는 경우 (MILESTONE) --%>
                                                    <c:otherwise>
                                                        <c:choose>
                                                            <c:when test="${selectedContract.paidMilestones == selectedContract.totalMilestones}">
                                                                ✅ 완료 내역
                                                            </c:when>
                                                            <c:otherwise>
                                                                🎉 정산 대기
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:when test="${selectedContract.contractStatus eq 'TERMINATED' or selectedContract.contractStatus eq 'terminated'}">
                                                <c:choose>
                                                    <c:when test="${fn:startsWith(selectedContract.cancelReason, '[거절]')}">
                                                        <span class="status-rejected">🚫 프리랜서가 거절함</span>
                                                    </c:when>
                                                    <c:when test="${fn:startsWith(selectedContract.cancelReason, '[취소]')}">
                                                        <span class="status-cancelled">❌ 내가 취소함</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="status-terminated">⚠️ 중도 종료</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:otherwise>${selectedContract.contractStatus}</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">프로젝트명</div>
                                <div class="info-value">
                                    <c:choose>
                                        <c:when test="${not empty project and not empty project.projectId and not empty project.title}">
                                            <a href="${pageContext.request.contextPath}/project/detail?projectId=${project.projectId}" 
                                               class="status-link"
                                               onmouseover="this.style.textDecoration='underline'"
                                               onmouseout="this.style.textDecoration='none'">
                                                <c:out value="${project.title}"/>
                                            </a>
                                        </c:when>
                                        <c:when test="${not empty selectedContract.projectTitle}">
                                            <c:choose>
                                                <c:when test="${not empty selectedContract.projectId}">
                                                    <a href="${pageContext.request.contextPath}/project/detail?projectId=${selectedContract.projectId}" 
                                                       class="status-link"
                                                       onmouseover="this.style.textDecoration='underline'"
                                                       onmouseout="this.style.textDecoration='none'">
                                                        <c:out value="${selectedContract.projectTitle}"/>
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:out value="${selectedContract.projectTitle}"/>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:otherwise>
                                            <c:out value="${project.title}" default="-"/>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
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
                            <!-- 종료 사유 표시 (TERMINATED 상태일 때만) -->
                            <c:if test="${(selectedContract.contractStatus eq 'TERMINATED' or selectedContract.contractStatus eq 'terminated') and not empty selectedContract.cancelReason}">
                                <div class="info-item info-item-full-width">
                                    <div class="info-label">종료 유형</div>
                                    <div class="info-value">
                                        <c:choose>
                                            <c:when test="${fn:startsWith(selectedContract.cancelReason, '[거절]')}">
                                                <span style="color: #dc2626; font-weight: 600;">🚫 프리랜서가 거절함</span>
                                            </c:when>
                                            <c:when test="${fn:startsWith(selectedContract.cancelReason, '[취소]')}">
                                                <span style="color: #d97706; font-weight: 600;">❌ 내가 취소함</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: #6b7280; font-weight: 600;">⚠️ 중도 종료</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                                <div class="info-item info-item-full-width">
                                    <div class="info-label">사유</div>
                                    <div class="info-value info-value-error">
                                        <c:out value="${fn:replace(fn:replace(selectedContract.cancelReason, '[거절] ', ''), '[취소] ', '')}"/>
                                    </div>
                                </div>
                            </c:if>
                        </div>

                        <!-- PDF 표시 (클라이언트는 항상 볼 수 있음) -->
                        <c:choose>
                            <c:when test="${not empty selectedContract.originContractUrl}">
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
                            </c:when>
                            <c:otherwise>
                                <div class="section-title">📄 계약서 PDF</div>
                                <div class="payment-warning-section" style="text-align: center; padding: 24px;">
                                    <p class="payment-warning-text-large">⚠️ 계약서 PDF가 등록되지 않았습니다.</p>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <!-- 일시지급 수락/거부 버튼 (일시지급이고 cancel_reason이 "[지급요청]"인 경우, COMPLETED가 아닌 경우) -->
                        <c:if test="${(empty milestones or milestones.size() eq 0) 
                            and (selectedContract.paymentMethod eq 'FIXED' or selectedContract.paymentMethod eq 'FULL') 
                            and (selectedContract.contractStatus eq 'PAID' or selectedContract.contractStatus eq 'paid')
                            and selectedContract.cancelReason eq '[지급요청]'}">
                            <div class="section-title">💰 일시지급 요청</div>
                            <div class="payment-request-section">
                                <p class="payment-request-text">프리랜서가 일시지급을 요청했습니다. 수락하거나 거부할 수 있습니다.</p>
                                <form method="post" action="${pageContext.request.contextPath}/client/contract/management/approve-payment" class="form-inline-margin">
                                    <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                    <button type="submit" class="btn btn-success" onclick="return confirm('일시지급을 수락하시겠습니까?')">
                                        ✅ 지급 수락
                                    </button>
                                </form>
                                <form method="post" action="${pageContext.request.contextPath}/client/contract/management/reject-payment" class="form-inline">
                                    <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                    <button type="submit" class="btn btn-danger" onclick="return confirm('일시지급을 거부하시겠습니까?')">
                                        ❌ 지급 거부
                                    </button>
                                </form>
                            </div>
                        </c:if>
                        
                        <!-- 일시지급 요청 대기 중 (아직 요청하지 않은 경우, COMPLETED가 아닌 경우) -->
                        <c:if test="${(empty milestones or milestones.size() eq 0) 
                            and (selectedContract.paymentMethod eq 'FIXED' or selectedContract.paymentMethod eq 'FULL') 
                            and (selectedContract.contractStatus eq 'PAID' or selectedContract.contractStatus eq 'paid')
                            and selectedContract.cancelReason ne '[지급요청]'}">
                            <div class="section-title">💰 일시지급 요청</div>
                            <div class="payment-request-section">
                                <p class="payment-waiting-text">⏳ 프리랜서의 지급 요청을 기다리는 중입니다.</p>
                            </div>
                        </c:if>
                        
                        <!-- 일시지급 완료 (COMPLETED 상태인 경우) -->
                        <c:if test="${(empty milestones or milestones.size() eq 0) 
                            and (selectedContract.paymentMethod eq 'FIXED' or selectedContract.paymentMethod eq 'FULL') 
                            and (selectedContract.contractStatus eq 'COMPLETED' or selectedContract.contractStatus eq 'completed')}">
                            <div class="section-title">💰 일시지급 완료</div>
                            <div class="payment-completed-section">
                                <p class="payment-completed-text">✅ 일시지급이 완료되었습니다.</p>
                            </div>
                        </c:if>

                        <!-- 마일스톤 (일시지급이 아닌 경우만 표시) -->
                        <c:if test="${not empty milestones and selectedContract.paymentMethod ne 'FIXED' and selectedContract.paymentMethod ne 'FULL'}">
                            <div class="section-title">🎯 마일스톤 내역</div>
                            <table class="milestone-table">
                                <thead>
                                    <tr>
                                        <th>단계</th>
                                        <th>마일스톤명</th>
                                        <th style="text-align: right;">지급금액</th>
                                        <th>작업 내용</th>
                                        <th>상태</th>
                                        <th>액션</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="m" items="${milestones}" varStatus="status">
                                        <tr>
                                            <td style="text-align: center; font-weight: bold;">${status.index + 1}단계</td>
                                            <td><c:out value="${m.title}"/></td>
                                            <td style="text-align: right;"><fmt:formatNumber value="${m.amount}" pattern="#,###"/>원</td>
                                            <td><c:out value="${m.description}" default="-"/></td>
                                            <td style="text-align: center;">
                                                <c:choose>
                                                    <c:when test="${m.status eq 'WAITING' or m.status eq 'waiting'}">⏳ 대기 중</c:when>
                                                    <c:when test="${m.status eq 'REQUESTED' or m.status eq 'requested'}">📤 지급 요청</c:when>
                                                    <c:when test="${m.status eq 'DEPOSITED' or m.status eq 'deposited'}">💳 입금 완료</c:when>
                                                    <c:when test="${m.status eq 'PAID' or m.status eq 'paid'}">✅ 지급 완료</c:when>
                                                    <c:otherwise>${m.status}</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="text-align: center;">
                                                <c:if test="${(selectedContract.contractStatus eq 'PAID' or selectedContract.contractStatus eq 'paid' or selectedContract.contractStatus eq 'COMPLETED' or selectedContract.contractStatus eq 'completed') and (m.status eq 'REQUESTED' or m.status eq 'requested')}">
                                                    <form method="post" action="${pageContext.request.contextPath}/client/contract/management/approve-payment" style="display: inline;">
                                                        <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                                        <input type="hidden" name="step" value="${m.step}" />
                                                        <button type="submit" class="btn btn-success btn-sm" onclick="return confirm('${m.step}단계 마일스톤 지급을 수락하시겠습니까?')">
                                                            ✅ 지급 수락
                                                        </button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/client/contract/management/reject-payment" style="display: inline; margin-left: 8px;">
                                                        <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                                        <input type="hidden" name="step" value="${m.step}" />
                                                        <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('${m.step}단계 마일스톤 지급을 거부하시겠습니까?')">
                                                            ❌ 지급 거부
                                                        </button>
                                                    </form>
                                                </c:if>
                                            </td>
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
                                    <button type="submit" class="btn btn-primary" onclick="return confirm('계약 결제를 완료하시겠습니까?')">
                                        💰 계약 결제 완료
                                    </button>
                                </form>
                                <form method="post" action="${pageContext.request.contextPath}/client/contract/management/cancel" class="cancel-form" style="display: inline;">
                                    <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                    <input type="text" name="reason" placeholder="취소 사유를 입력하세요" required 
                                           class="form-input" />
                                    <button type="submit" class="btn btn-danger" onclick="return confirm('계약을 취소하시겠습니까?')">
                                        ❌ 계약 취소
                                    </button>
                                </form>
                            </div>
                        </c:if>
                        
                        <!-- 일시지급 수락 버튼 (PAID 상태일 때, REQUESTED 마일스톤이 있는 경우) -->
                        <c:if test="${selectedContract.contractStatus eq 'PAID' or selectedContract.contractStatus eq 'paid'}">
                            <c:set var="hasRequestedMilestone" value="false"/>
                            <c:forEach var="m" items="${milestones}">
                                <c:if test="${m.status eq 'REQUESTED' or m.status eq 'requested'}">
                                    <c:set var="hasRequestedMilestone" value="true"/>
                                </c:if>
                            </c:forEach>
                            <c:if test="${hasRequestedMilestone}">
                                <div class="action-buttons">
                                    <form method="post" action="${pageContext.request.contextPath}/client/contract/management/approve-payment" style="display: inline;">
                                        <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                        <button type="submit" class="btn btn-success" onclick="return confirm('일시지급을 수락하시겠습니까?')">
                                            ✅ 일시지급 수락
                                        </button>
                                    </form>
                                </div>
                            </c:if>
                        </c:if>
                        
                        <!-- 액션 버튼 (PAID 상태일 때만, 일시지급이 아닌 경우만) -->
                        <c:if test="${(selectedContract.contractStatus eq 'PAID' or selectedContract.contractStatus eq 'paid')
                            and not ((selectedContract.paymentMethod eq 'FIXED' or selectedContract.paymentMethod eq 'FULL') 
                            and (selectedContract.totalMilestones == null or selectedContract.totalMilestones == 0))}">
                            <div class="action-buttons">
                                <form method="post" action="${pageContext.request.contextPath}/client/contract/management/complete" style="display: inline;">
                                    <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                    <button type="submit" class="btn btn-primary" onclick="return confirm('모든 마일스톤이 완료되었나요? 계약 정산을 완료하시겠습니까?')">
                                        🎉 계약 정산 완료
                                    </button>
                                </form>
                                <form method="post" action="${pageContext.request.contextPath}/client/contract/management/cancel" class="cancel-form" style="display: inline;">
                                    <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                    <input type="text" name="reason" placeholder="중도 종료 사유를 입력하세요" required 
                                           class="form-input" />
                                    <button type="submit" class="btn btn-danger" onclick="return confirm('계약을 중도 종료하시겠습니까?')">
                                        ❌ 계약 중도 종료
                                    </button>
                                </form>
                            </div>
                        </c:if>
                        
                        <!-- 중도 종료 버튼만 (일시지급이고 PAID 상태일 때) -->
                        <c:if test="${(selectedContract.contractStatus eq 'PAID' or selectedContract.contractStatus eq 'paid')
                            and (selectedContract.paymentMethod eq 'FIXED' or selectedContract.paymentMethod eq 'FULL') 
                            and (selectedContract.totalMilestones == null or selectedContract.totalMilestones == 0)}">
                            <div class="action-buttons">
                                <form method="post" action="${pageContext.request.contextPath}/client/contract/management/cancel" class="cancel-form" style="display: inline;">
                                    <input type="hidden" name="contractId" value="${selectedContract.contractId}" />
                                    <input type="text" name="reason" placeholder="중도 종료 사유를 입력하세요" required 
                                           class="form-input" />
                                    <button type="submit" class="btn btn-danger" onclick="return confirm('계약을 중도 종료하시겠습니까?')">
                                        ❌ 계약 중도 종료
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
    
    <script>
        // 사이드바 토글 기능
        function toggleSection(element) {
            const section = element.closest('.status-section');
            const list = section.querySelector('.contract-list');
            const icon = element.querySelector('.toggle-icon');
            
            if (list) {
                if (list.style.display === 'none') {
                    list.style.display = 'block';
                    icon.textContent = '▼';
                    section.classList.remove('collapsed');
                } else {
                    list.style.display = 'none';
                    icon.textContent = '▶';
                    section.classList.add('collapsed');
                }
            }
        }
        
        // 페이지 로드 시 선택된 계약이 있는 섹션은 자동으로 펼치기
        document.addEventListener('DOMContentLoaded', function() {
            const activeItem = document.querySelector('.contract-item.active');
            if (activeItem) {
                const section = activeItem.closest('.status-section');
                if (section) {
                    const list = section.querySelector('.contract-list');
                    const title = section.querySelector('.status-title');
                    const icon = title.querySelector('.toggle-icon');
                    if (list) {
                        list.style.display = 'block';
                        if (icon) icon.textContent = '▼';
                        section.classList.remove('collapsed');
                    }
                }
            }
        });
    </script>
</body>
</html>
