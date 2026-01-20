<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI 계약서 분석 & 검토 - Ratel Ocean</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background-color: #f5f5f5;
            color: #333;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 2rem;
        }
        
        /* ═══════════════════════════════════════════════════════════════════════
           페이지 헤더
           ═══════════════════════════════════════════════════════════════════════ */
        
        .page-header {
            margin-bottom: 2rem;
        }
        
        .page-header h1 {
            font-size: 1.8rem;
            color: #2B2B2B;
            margin-bottom: 0.3rem;
            font-weight: 600;
        }
        
        .page-header p {
            font-size: 0.9rem;
            color: #888;
        }
        
        .ai-badge {
            display: inline-block;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            margin-left: 0.5rem;
        }
        
        /* AI 경고 배너 */
        .ai-warning {
            background: linear-gradient(135deg, #fff3cd 0%, #ffe8a1 100%);
            border-left: 4px solid #ffc107;
            border-radius: 8px;
            padding: 1rem 1.5rem;
            margin-bottom: 2rem;
            box-shadow: 0 2px 8px rgba(255, 193, 7, 0.2);
        }
        
        .ai-warning-title {
            font-weight: 600;
            color: #856404;
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .ai-warning-content {
            font-size: 0.85rem;
            color: #856404;
            line-height: 1.6;
        }
        
        /* ═══════════════════════════════════════════════════════════════════════
           메인 레이아웃 (좌측: 계약서 폼 / 우측: AI 분석 리포트)
           ═══════════════════════════════════════════════════════════════════════ */
        
        .main-layout {
            display: grid;
            grid-template-columns: 1fr 400px;
            gap: 2rem;
        }
        
        @media (max-width: 1200px) {
            .main-layout {
                grid-template-columns: 1fr;
            }
        }
        
        /* ═══════════════════════════════════════════════════════════════════════
           좌측: 계약서 폼
           ═══════════════════════════════════════════════════════════════════════ */
        
        .contract-form-section {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            padding: 2rem;
        }
        
        .section-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: #2B2B2B;
            margin-bottom: 1.5rem;
            padding-bottom: 0.75rem;
            border-bottom: 2px solid #94D9DB;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .form-group {
            margin-bottom: 1.5rem;
        }
        
        .form-group label {
            display: block;
            font-size: 0.85rem;
            font-weight: 600;
            color: #666;
            margin-bottom: 0.5rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .form-group input,
        .form-group select {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 0.9rem;
            font-family: inherit;
            transition: all 0.2s ease;
        }
        
        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #94D9DB;
            box-shadow: 0 0 0 3px rgba(148, 217, 219, 0.1);
        }
        
        .form-group input[readonly] {
            background: #f8f9fa;
            color: #666;
            cursor: not-allowed;
        }
        
        /* 마일스톤 테이블 */
        .milestone-section {
            margin-top: 2rem;
        }
        
        .milestone-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
            font-size: 0.85rem;
        }
        
        .milestone-table th {
            background: #f8f9fa;
            padding: 0.75rem;
            text-align: left;
            font-weight: 600;
            color: #2B2B2B;
            border-bottom: 2px solid #e0e0e0;
        }
        
        .milestone-table td {
            padding: 0.75rem;
            border-bottom: 1px solid #f0f0f0;
        }
        
        .milestone-table input {
            width: 100%;
            padding: 0.5rem;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 0.85rem;
        }
        
        .milestone-table input:focus {
            outline: none;
            border-color: #94D9DB;
        }
        
        /* 버튼 그룹 */
        .button-group {
            margin-top: 2rem;
            display: flex;
            gap: 1rem;
            justify-content: center;
        }
        
        .btn {
            padding: 0.75rem 2rem;
            border: none;
            border-radius: 6px;
            font-size: 0.9rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
        }
        
        .btn-secondary {
            background: #f0f0f0;
            color: #333;
        }
        
        .btn-secondary:hover {
            background: #e0e0e0;
        }
        
        /* ═══════════════════════════════════════════════════════════════════════
           우측: AI 분석 리포트
           ═══════════════════════════════════════════════════════════════════════ */
        
        .ai-report-section {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            padding: 1.5rem;
            position: sticky;
            top: 2rem;
            max-height: calc(100vh - 4rem);
            overflow-y: auto;
        }
        
        .ai-report-header {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 1.5rem;
            padding-bottom: 1rem;
            border-bottom: 2px solid #667eea;
        }
        
        .ai-report-header h2 {
            font-size: 1.1rem;
            font-weight: 600;
            color: #2B2B2B;
        }
        
        .ai-report-badge {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 0.2rem 0.5rem;
            border-radius: 4px;
            font-size: 0.7rem;
            font-weight: 600;
        }
        
        .ai-insight-card {
            background: linear-gradient(135deg, #f8f9fa 0%, #e8f4f5 100%);
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1rem;
            border-left: 4px solid #667eea;
        }
        
        .ai-insight-label {
            font-size: 0.7rem;
            font-weight: 700;
            color: #999;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 0.5rem;
        }
        
        .ai-insight-value {
            font-size: 0.9rem;
            color: #2B2B2B;
            line-height: 1.6;
            font-weight: 500;
        }
        
        .ai-list {
            list-style: none;
            margin-top: 0.75rem;
        }
        
        .ai-list li {
            padding: 0.5rem 0;
            padding-left: 1.5rem;
            position: relative;
            font-size: 0.85rem;
            color: #555;
            line-height: 1.5;
        }
        
        .ai-list li:before {
            content: "•";
            position: absolute;
            left: 0;
            color: #667eea;
            font-weight: bold;
            font-size: 1.2rem;
        }
        
        .ai-risk-item {
            background: #fff3cd;
            border-left-color: #ffc107;
        }
        
        .ai-risk-item .ai-insight-label {
            color: #856404;
        }
        
        .ai-recommendation-item {
            background: #d4edda;
            border-left-color: #28a745;
        }
        
        .ai-recommendation-item .ai-insight-label {
            color: #155724;
        }
        
        .ai-meta-info {
            margin-top: 1.5rem;
            padding-top: 1.5rem;
            border-top: 1px solid #e0e0e0;
            font-size: 0.75rem;
            color: #999;
        }
        
        .ai-meta-info div {
            margin-bottom: 0.5rem;
        }
        
        .confidence-bar {
            width: 100%;
            height: 6px;
            background: #e0e0e0;
            border-radius: 3px;
            overflow: hidden;
            margin-top: 0.5rem;
        }
        
        .confidence-fill {
            height: 100%;
            background: linear-gradient(90deg, #28a745 0%, #94D9DB 100%);
            transition: width 0.3s ease;
        }
        
        /* 에러 메시지 */
        .error-message {
            background: #ffebee;
            color: #c62828;
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            border-left: 4px solid #c62828;
            font-size: 0.85rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- 페이지 헤더 -->
        <div class="page-header">
            <h1>
                🤖 AI 계약서 분석 & 검토
                <span class="ai-badge">${empty insight.analysisModel ? 'AI Insight' : insight.analysisModel}</span>
            </h1>
            <p>AI가 분석한 계약서 초안을 검토하고 수정하세요. 모든 내용은 확정 전까지 수정 가능합니다.</p>
        </div>
        
        <!-- AI 경고 배너 -->
        <div class="ai-warning">
            <div class="ai-warning-title">⚠️ AI 분석 결과는 참고용입니다</div>
            <div class="ai-warning-content">
                AI가 제안한 내용은 초안이며, 최종 결정권은 귀하에게 있습니다. 
                계약 조건, 금액, 마일스톤 등을 반드시 검토하고 필요시 수정하세요.
            </div>
        </div>
        
        <c:if test="${not empty errorMessage}">
            <div class="error-message">
                ❌ ${errorMessage}
            </div>
        </c:if>
        
        <!-- 메인 레이아웃 -->
        <form action="${pageContext.request.contextPath}/contract/confirm" method="post">
            <div class="main-layout">
                <!-- ═══════════════════════════════════════════════════════════════
                     좌측: 계약서 폼
                     ═══════════════════════════════════════════════════════════════ -->
                <div class="contract-form-section">
                    <div class="section-title">
                        📄 계약서 정보
                    </div>
                    
                    <!-- Hidden Fields -->
                    <input type="hidden" name="projectId" value="${projectId}" />
                    <input type="hidden" name="freelancerId" value="${freelancerId}" />
                    
                    <!-- 계약 기간 -->
                    <div class="form-group">
                        <label>계약 시작일</label>
                        <input type="date" name="contractStartDate" 
                               value="${insight.proposedStartDate}" required />
                    </div>
                    
                    <div class="form-group">
                        <label>계약 종료일</label>
                        <input type="date" name="contractEndDate" 
                               value="${insight.proposedEndDate}" required />
                    </div>
                    
                    <!-- 계약 금액 -->
                    <div class="form-group">
                        <label>총 계약 금액 (원)</label>
                           <input type="number" name="totalBudget"
                               value="${not empty insight.proposedBudget ? insight.proposedBudget : projectBudget}"
                               min="0" required />
                    </div>
                    
                    <!-- 결제 방식 -->
                    <div class="form-group">
                        <label>결제 방식</label>
                        <select name="paymentMethod" required>
                            <option value="ESCROW" selected>에스크로 (안전거래)</option>
                            <option value="DIRECT">직접 송금</option>
                        </select>
                    </div>
                    
                    <!-- 소통 방법 -->
                    <div class="form-group">
                        <label>소통 방법</label>
                        <select name="communicationMethod" required>
                            <option value="MESSENGER" selected>메신저</option>
                            <option value="EMAIL">이메일</option>
                            <option value="VIDEOCALL">화상회의</option>
                            <option value="PHONE">전화</option>
                        </select>
                    </div>
                    
                    <!-- 마일스톤 섹션 -->
                    <div class="milestone-section">
                        <div class="section-title">
                            🎯 마일스톤 (${fn:length(insight.proposedMilestones)}단계)
                        </div>
                        
                        <table class="milestone-table">
                            <thead>
                                <tr>
                                    <th style="width: 5%">#</th>
                                    <th style="width: 25%">단계명</th>
                                    <th style="width: 35%">작업 범위</th>
                                    <th style="width: 15%">완료일</th>
                                    <th style="width: 20%">금액 (원)</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${insight.proposedMilestones}" var="milestone" varStatus="status">
                                    <tr>
                                        <td>${status.index + 1}</td>
                                        <td>
                                            <input type="text" 
                                                   name="milestones[${status.index}].milestoneName"
                                                   value="${milestone.milestoneName}" 
                                                   required />
                                        </td>
                                        <td>
                                            <input type="text" 
                                                   name="milestones[${status.index}].workScope"
                                                   value="${milestone.workScope}" 
                                                   required />
                                        </td>
                                        <td>
                                            <input type="date" 
                                                   name="milestones[${status.index}].dueDate"
                                                   value="${milestone.dueDate}" 
                                                   required />
                                        </td>
                                        <td>
                                            <input type="number" 
                                                   name="milestones[${status.index}].amount"
                                                   value="${milestone.amount}" 
                                                   required />
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                    
                    <!-- 버튼 그룹 -->
                    <div class="button-group">
                        <a href="${pageContext.request.contextPath}/contract/start?projectId=${projectId}&freelancerId=${freelancerId}" 
                           class="btn btn-secondary">
                            ← 다시 분석
                        </a>
                        <button type="submit" class="btn btn-primary">
                            계약서 확정 →
                        </button>
                    </div>
                </div>
                
                <!-- ═══════════════════════════════════════════════════════════════
                     우측: AI 분석 리포트
                     ═══════════════════════════════════════════════════════════════ -->
                <div class="ai-report-section">
                    <div class="ai-report-header">
                        <h2>🤖 AI 분석 리포트</h2>
                        <span class="ai-report-badge">
                            ${insight.analysisModel}
                        </span>
                    </div>
                    
                    <!-- 계약 기간 분석 -->
                    <div class="ai-insight-card">
                        <div class="ai-insight-label">📅 제안된 계약 기간</div>
                        <div class="ai-insight-value" id="ai-dates-display">
                            ${insight.proposedStartDate} ~ ${insight.proposedEndDate}
                        </div>
                    </div>
                    
                    <!-- 예산 분석 -->
                    <div class="ai-insight-card">
                        <div class="ai-insight-label">💰 예산 분석</div>
                        <div class="ai-insight-value" id="ai-budget-display">
                            총 <fmt:formatNumber value="${projectBudget}" type="number" groupingUsed="true"/>원<br/>
                            ${fn:length(insight.proposedMilestones)}단계 마일스톤으로 분할 제안
                        </div>
                    </div>
                    
                    <!-- 리스크 요소 -->
                    <c:if test="${not empty insight.riskFactors}">
                        <div class="ai-insight-card ai-risk-item">
                            <div class="ai-insight-label">⚠️ 리스크 요소 (${fn:length(insight.riskFactors)}개)</div>
                            <ul class="ai-list">
                                <c:forEach items="${insight.riskFactors}" var="risk">
                                    <li>${risk}</li>
                                </c:forEach>
                            </ul>
                        </div>
                    </c:if>
                    
                    <!-- 권장사항 -->
                    <c:if test="${not empty insight.recommendedReviewPoints}">
                        <div class="ai-insight-card ai-recommendation-item">
                            <div class="ai-insight-label">✓ 권장사항 (${fn:length(insight.recommendedReviewPoints)}개)</div>
                            <ul class="ai-list">
                                <c:forEach items="${insight.recommendedReviewPoints}" var="recommendation">
                                    <li>${recommendation}</li>
                                </c:forEach>
                            </ul>
                        </div>
                    </c:if>
                    
                    <!-- AI 메타 정보 -->
                    <div class="ai-meta-info">
                        <div>
                            <strong>분석 모델:</strong> ${insight.analysisModel}
                        </div>
                        <div>
                            <strong>분석 일시:</strong> ${insight.analysisTimestamp}
                        </div>
                        <div>
                            <strong>신뢰도:</strong> 
                            <fmt:formatNumber value="${insight.confidenceScore != null ? insight.confidenceScore * 100 : 0}" pattern="#"/>%
                            <div class="confidence-bar">
                                <div class="confidence-fill" 
                                     style="width: ${insight.confidenceScore != null ? insight.confidenceScore * 100 : 0}%"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </div>

    <script>
        (function() {
            // 좌측 입력값 변경 시 우측 AI 패널을 즉시 동기화해 사용자가 보는 수치가 항상 일치하도록 한다.
            const startInput = document.querySelector('input[name="contractStartDate"]');
            const endInput = document.querySelector('input[name="contractEndDate"]');
            const budgetInput = document.querySelector('input[name="totalBudget"]');
            const dateDisplay = document.getElementById('ai-dates-display');
            const budgetDisplay = document.getElementById('ai-budget-display');
            const milestoneRows = document.querySelectorAll('.milestone-table tbody tr').length;

            const syncDates = () => {
                if (!dateDisplay || !startInput || !endInput) return;
                dateDisplay.textContent = (startInput.value || '시작일 미정') + ' ~ ' + (endInput.value || '종료일 미정');
            };

            const syncBudget = () => {
                if (!budgetDisplay || !budgetInput) return;
                const numeric = Number(budgetInput.value);
                const pretty = isNaN(numeric) ? '0' : numeric.toLocaleString('ko-KR');
                budgetDisplay.innerHTML = '총 ' + pretty + '원<br/>' + milestoneRows + '단계 마일스톤으로 분할 제안';
            };

            if (startInput) startInput.addEventListener('input', syncDates);
            if (endInput) endInput.addEventListener('input', syncDates);
            if (budgetInput) budgetInput.addEventListener('input', syncBudget);

            syncDates();
            syncBudget();
        })();
    </script>
</body>
</html>
