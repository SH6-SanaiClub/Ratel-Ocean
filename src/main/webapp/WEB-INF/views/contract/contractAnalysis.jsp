<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>AI 계약 분석 리포트</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f5f5f5;
        }
        .header {
            background: white;
            padding: 24px 32px;
            border-bottom: 1px solid #e0e0e0;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        .header h1 {
            font-size: 24px;
            color: #333;
            margin-bottom: 8px;
        }
        .header .meta {
            font-size: 14px;
            color: #666;
        }
        .container {
            display: flex;
            height: calc(100vh - 100px);
        }
        .pdf-panel {
            width: 50%;
            background: white;
            border-right: 1px solid #e0e0e0;
            overflow-y: auto;
        }
        .analysis-panel {
            width: 50%;
            background: #fafafa;
            overflow-y: auto;
            padding: 32px;
        }
        .pdf-viewer {
            width: 100%;
            height: 100%;
            border: none;
        }
        .section {
            background: white;
            border-radius: 8px;
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        .section-title {
            font-size: 18px;
            font-weight: 600;
            color: #333;
            margin-bottom: 16px;
        }
        .risk-score {
            text-align: center;
            padding: 24px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 8px;
            margin-bottom: 16px;
        }
        .risk-score .score {
            font-size: 48px;
            font-weight: bold;
            margin-bottom: 8px;
        }
        .risk-score .level {
            font-size: 20px;
            margin-bottom: 8px;
        }
        .risk-score .desc {
            font-size: 14px;
            opacity: 0.9;
        }
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }
        .info-item {
            padding: 12px;
            background: #f8f9fa;
            border-radius: 6px;
        }
        .info-label {
            font-size: 12px;
            color: #666;
            margin-bottom: 4px;
        }
        .info-value {
            font-size: 14px;
            color: #333;
            font-weight: 500;
        }
        .risk-clause {
            padding: 16px;
            border-radius: 8px;
            margin-bottom: 16px;
            border-left: 4px solid;
        }
        .risk-clause.high {
            background: #fee;
            border-color: #dc2626;
        }
        .risk-clause.medium {
            background: #fff4e6;
            border-color: #f59e0b;
        }
        .risk-clause .badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 600;
            margin-bottom: 8px;
        }
        .risk-clause.high .badge {
            background: #dc2626;
            color: white;
        }
        .risk-clause.medium .badge {
            background: #f59e0b;
            color: white;
        }
        .risk-clause .clause-title {
            font-size: 16px;
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
        }
        .risk-clause .problem {
            font-size: 14px;
            color: #666;
            margin-bottom: 8px;
        }
        .risk-clause .recommendation {
            font-size: 14px;
            color: #333;
            padding: 8px;
            background: #f0f0f0;
            border-radius: 4px;
        }
        .error-message {
            text-align: center;
            padding: 40px;
            color: #666;
        }
        .error-message h2 {
            font-size: 20px;
            margin-bottom: 12px;
            color: #dc2626;
        }
        .error-message p {
            font-size: 14px;
            margin-bottom: 20px;
        }
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
            display: inline-block;
        }
        .btn-primary {
            background: #667eea;
            color: white;
        }
        .btn-primary:hover {
            background: #5568d3;
        }
        .info-note {
            background: #f0f7ff;
            border: 1px solid #b3d9ff;
            border-radius: 8px;
            padding: 16px;
            text-align: center;
            color: #0066cc;
            font-size: 14px;
            margin-top: 24px;
        }
        .loading-container {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            background: #f5f5f5;
        }
        .spinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #667eea;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            animation: spin 1s linear infinite;
            margin: 0 auto 20px;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        .loading-text {
            font-size: 18px;
            color: #333;
            margin-bottom: 8px;
            text-align: center;
        }
        .loading-subtext {
            font-size: 14px;
            color: #666;
            text-align: center;
        }
    </style>
</head>
<body>
    <c:choose>
        <c:when test="${empty analysis and empty errorMessage}">
            <!-- 로딩 화면 (서버에서 분석 중일 때) -->
            <div class="loading-container">
                <div>
                    <div class="spinner"></div>
                    <div class="loading-text">AI가 계약을 분석하고 있어요</div>
                    <div class="loading-subtext">잠시만 기다려주세요...</div>
                </div>
            </div>
            <script>
                // 페이지 로드 후 자동 새로고침 (서버에서 분석 완료될 때까지)
                setTimeout(function() {
                    location.reload();
                }, 2000);
            </script>
        </c:when>
        <c:otherwise>
            <div class="header">
                <h1>🧭 AI 계약 분석 리포트: <c:out value="${project != null ? project.title : (contract != null ? contract.projectTitle : '계약서')}"/></h1>
                <div class="meta">생성일: <fmt:formatDate value="<%=new java.util.Date()%>" pattern="yyyy-MM-dd HH:mm"/></div>
            </div>
            
            <div class="container">
                <!-- 좌측: PDF -->
                <div class="pdf-panel">
                    <c:if test="${not empty pdfUrl}">
                        <script>
                            (function() {
                                var pdfPath = '<c:out value="${pdfUrl}" />';
                                if (pdfPath) {
                                    pdfPath = pdfPath.replace(/\\/g, '/');
                                    var lastSlashIndex = pdfPath.lastIndexOf('/');
                                    var pdfUrl;
                                    if (lastSlashIndex >= 0) {
                                        var dirPath = pdfPath.substring(0, lastSlashIndex + 1);
                                        var fileName = pdfPath.substring(lastSlashIndex + 1);
                                        pdfUrl = '${pageContext.request.contextPath}/freelancer/contract/file/' + dirPath + encodeURIComponent(fileName);
                                    } else {
                                        pdfUrl = '${pageContext.request.contextPath}/freelancer/contract/file/' + encodeURIComponent(pdfPath);
                                    }
                                    document.write('<iframe class="pdf-viewer" src="' + pdfUrl + '"></iframe>');
                                }
                            })();
                        </script>
                    </c:if>
                </div>
                
                <!-- 우측: 분석 결과 -->
                <div class="analysis-panel">
                    <c:choose>
                        <c:when test="${not empty analysis}">
                            <!-- 종합 판단 -->
                            <div class="section">
                                <div class="section-title">종합 판단</div>
                                <div class="risk-score">
                                    <div class="score"><c:out value="${analysis.riskScore != null ? analysis.riskScore : 0}"/>점</div>
                                    <div class="level">
                                        <c:choose>
                                            <c:when test="${analysis.riskLevel eq 'HIGH'}">🔴 높은 위험</c:when>
                                            <c:when test="${analysis.riskLevel eq 'MEDIUM'}">🟡 주의 필요</c:when>
                                            <c:otherwise>🟢 안전</c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="desc"><c:out value="${analysis.riskDescription != null ? analysis.riskDescription : '분석 정보 없음'}"/></div>
                                </div>
                            </div>
                            
                            <!-- 주요 계약 조건 요약 -->
                            <div class="section">
                                <div class="section-title">주요 계약 조건 요약</div>
                                <div class="info-grid">
                                    <div class="info-item">
                                        <div class="info-label">총 금액</div>
                                        <div class="info-value"><c:out value="${analysis.totalAmount != null ? analysis.totalAmount : '정보 없음'}"/></div>
                                    </div>
                                    <div class="info-item">
                                        <div class="info-label">기간</div>
                                        <div class="info-value"><c:out value="${analysis.contractPeriod != null ? analysis.contractPeriod : '정보 없음'}"/></div>
                                    </div>
                                    <div class="info-item">
                                        <div class="info-label">지급 방식</div>
                                        <div class="info-value"><c:out value="${analysis.paymentMethod != null ? analysis.paymentMethod : '정보 없음'}"/></div>
                                    </div>
                                    <div class="info-item">
                                        <div class="info-label">지연 손해</div>
                                        <div class="info-value"><c:out value="${analysis.delayPenalty != null ? analysis.delayPenalty : '정보 없음'}"/></div>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- 위험 조항 -->
                            <c:if test="${not empty analysis.riskClauses}">
                                <div class="section">
                                    <div class="section-title">위험 조항</div>
                                    <c:forEach var="clause" items="${analysis.riskClauses}">
                                        <div class="risk-clause ${fn:toLowerCase(clause.level)}">
                                            <span class="badge"><c:out value="${clause.level != null ? clause.level : 'MEDIUM'}"/> RISK</span>
                                            <div class="clause-title"><c:out value="${clause.clauseNumber != null ? clause.clauseNumber : ''}"/>: <c:out value="${clause.clauseTitle != null ? clause.clauseTitle : ''}"/></div>
                                            <div class="problem">
                                                <strong>왜 문제인가</strong><br>
                                                → <c:out value="${clause.problemDescription != null ? clause.problemDescription : ''}"/>
                                            </div>
                                            <div class="recommendation">
                                                <strong>AI 권장 대응</strong><br>
                                                → <c:out value="${clause.aiRecommendation != null ? clause.aiRecommendation : ''}"/>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:if>
                            
                            <!-- 리포트 안내 (결정 버튼 제거) -->
                            <div class="info-note">
                                💡 이 리포트는 참고용입니다. 계약 수락/거절은 계약 관리 페이지에서 진행해주세요.
                            </div>
                        </c:when>
                        <c:otherwise>
                            <!-- 분석 실패 또는 에러 -->
                            <div class="error-message">
                                <h2>AI 분석을 생성하지 못했습니다</h2>
                                <p>계약 정보 요약만 제공됩니다.</p>
                                <c:if test="${not empty errorMessage}">
                                    <p style="color: #dc2626; font-size: 12px; margin-top: 8px;">${errorMessage}</p>
                                </c:if>
                                <a href="javascript:location.reload()" class="btn btn-primary">다시 시도</a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</body>
</html>
