<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>기회 큐 통합 관리 - Ratel Ocean</title>
    
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        /* ═══════════════════════════════════════════════════════════════════════
           기본 스타일
           ═══════════════════════════════════════════════════════════════════════ */
        
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
        
        .queue-header {
            margin-bottom: 2rem;
            padding-bottom: 0;
        }
        
        .queue-header h1 {
            font-size: 1.8rem;
            color: #2B2B2B;
            margin-bottom: 0.3rem;
            font-weight: 600;
        }
        
        .queue-header p {
            font-size: 0.9rem;
            color: #888;
        }
        
        /* ═══════════════════════════════════════════════════════════════════════
           메인 레이아웃 (좌/우)
           ═══════════════════════════════════════════════════════════════════════ */
        
        .queue-layout {
            display: grid;
            grid-template-columns: 340px 1fr;
            gap: 2rem;
        }
        
        @media (max-width: 1000px) {
            .queue-layout {
                grid-template-columns: 1fr;
            }
        }
        
        /* ═══════════════════════════════════════════════════════════════════════
           자동 추천 큐 (좌측)
           ═══════════════════════════════════════════════════════════════════════ */
        
        .queue-section {
            background: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
            padding: 1.2rem;
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
        }
        
        .queue-section h2 {
            font-size: 1rem;
            color: #2B2B2B;
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-weight: 600;
        }
        
        .queue-badge {
            background-color: #E8F4F5;
            color: #1F7A8C;
            padding: 0.2rem 0.5rem;
            border-radius: 3px;
            font-size: 0.7rem;
            font-weight: 600;
        }
        
        /* ─────────────────────────────────────────────────────────────────
           프로젝트 카드
           ───────────────────────────────────────────────────────────────── */
        
        .project-card {
            background: white;
            border-radius: 8px;
            padding: 0.8rem;
            transition: all 0.2s ease;
            border: 1px solid #f0f0f0;
        }
        
        .project-card:hover {
            box-shadow: 0 2px 8px rgba(148, 217, 219, 0.2);
            border-color: #94D9DB;
        }
        
        .project-card-title {
            font-size: 0.85rem;
            font-weight: 600;
            color: #2B2B2B;
            margin-bottom: 0.4rem;
            cursor: pointer;
            color: #1F7A8C;
            text-decoration: none;
            display: block;
            line-height: 1.2;
        }
        
        .project-card-title:hover {
            text-decoration: underline;
        }
        
        .project-card-info {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            font-size: 0.8rem;
            color: #666;
            margin-bottom: 0.5rem;
        }
        
        .project-card-info-item {
            display: flex;
            align-items: center;
            gap: 0.25rem;
        }
        
        .project-card-actions {
            display: flex;
            gap: 0.25rem;
            justify-content: flex-end;
        }
        
        .btn-small {
            padding: 0.35rem 0.5rem;
            font-size: 0.75rem;
            border: 1px solid #ddd;
            background: white;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        
        .btn-small:hover {
            background: #f9f9f9;
            border-color: #94D9DB;
            color: #1F7A8C;
        }
        
        .btn-small.btn-delete {
            color: #e74c3c;
            border-color: #e74c3c;
        }
        
        .btn-small.btn-delete:hover {
            background: #fee;
        }
        
        .empty-state {
            text-align: center;
            padding: 2rem 1rem;
            color: #999;
        }
        
        .empty-state-icon {
            font-size: 2.5rem;
            margin-bottom: 0.5rem;
        }
        
        /* ─────────────────────────────────────────────────────────────────
           조건 큐 카드 (우측)
           ───────────────────────────────────────────────────────────────── */
        
        .custom-queues-section {
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }
        
        .custom-queue-card {
            background: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
            padding: 1.2rem;
        }
        
        .queue-card-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 1rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid #f0f0f0;
        }
        
        .queue-card-title {
            font-size: 1rem;
            font-weight: 600;
            color: #2B2B2B;
        }
        
        .queue-status-toggle {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .toggle-switch {
            width: 48px;
            height: 24px;
            background: #e0e0e0;
            border-radius: 12px;
            position: relative;
            cursor: pointer;
            transition: background 0.3s ease;
            border: none;
            padding: 0;
        }
        
        .toggle-switch.active {
            background: #94D9DB;
        }
        
        .toggle-switch::after {
            content: '';
            position: absolute;
            width: 20px;
            height: 20px;
            background: white;
            border-radius: 50%;
            top: 2px;
            left: 2px;
            transition: left 0.3s ease;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
        }
        
        .toggle-switch.active::after {
            left: 24px;
        }
        
        .queue-conditions {
            background: #fafafa;
            padding: 0.9rem;
            border-radius: 6px;
            margin-bottom: 1rem;
            border: 1px solid #f0f0f0;
        }
        
        .queue-condition {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 0.6rem;
            font-size: 0.9rem;
        }
        
        .queue-condition:last-child {
            margin-bottom: 0;
        }
        
        .queue-condition-label {
            font-weight: 600;
            color: #2B2B2B;
            min-width: 50px;
        }
        
        .queue-condition-value {
            color: #1F7A8C;
            text-align: right;
            flex: 1;
        }
        
        .queue-projects {
            margin-top: 0.75rem;
        }
        
        .queue-projects h4 {
            font-size: 0.95rem;
            font-weight: 600;
            color: #2B2B2B;
            margin-bottom: 0.6rem;
        }
        
        .btn-create-queue {
            padding: 0.5rem 1rem;
            background: #94D9DB;
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 0.8rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            white-space: nowrap;
        }
        
        .btn-create-queue:hover {
            background: #7ac5c8;
            transform: translateY(-2px);
            box-shadow: 0 2px 6px rgba(148, 217, 219, 0.3);
        }
        
        .btn-create-queue.disabled {
            opacity: 0.5;
            cursor: not-allowed;
            background: #ccc;
        }
        
        /* ─────────────────────────────────────────────────────────────────
           큐 생성 폼
           ───────────────────────────────────────────────────────────────── */
        
        .create-queue-form {
            background: linear-gradient(135deg, #f8f9fa 0%, #e8f8f9 100%);
            border: 2px solid #94D9DB;
            border-radius: 8px;
            padding: 1.5rem;
            display: none;
            animation: slideIn 0.3s ease;
        }
        
        .create-queue-form.active {
            display: block;
        }
        
        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .form-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
            margin-bottom: 1.5rem;
        }
        
        .form-group {
            display: flex;
            flex-direction: column;
        }
        
        .form-group.full {
            grid-column: 1 / -1;
        }
        
        .form-group label {
            font-weight: 600;
            color: #2B2B2B;
            margin-bottom: 0.4rem;
            font-size: 0.9rem;
        }
        
        .form-group input,
        .form-group select,
        .form-group textarea {
            padding: 0.6rem 0.75rem;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 0.9rem;
            font-family: inherit;
            transition: all 0.2s ease;
        }
        
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #94D9DB;
            box-shadow: 0 0 0 3px rgba(148, 217, 219, 0.1);
        }
        
        .form-group textarea {
            resize: vertical;
            min-height: 60px;
        }
        
        .form-buttons {
            display: flex;
            gap: 0.75rem;
            justify-content: flex-end;
        }
        
        .btn-submit {
            padding: 0.6rem 1.2rem;
            background: #94D9DB;
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 0.9rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        
        .btn-submit:hover {
            background: #7ac5c8;
            transform: translateY(-2px);
            box-shadow: 0 2px 6px rgba(148, 217, 219, 0.3);
        }
        
        .btn-cancel {
            padding: 0.6rem 1.2rem;
            background: white;
            color: #666;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 0.9rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        
        .btn-cancel:hover {
            background: #f9f9f9;
            border-color: #999;
        }
        
        /* ═══════════════════════════════════════════════════════════════════════
           스택 태그
           ═══════════════════════════════════════════════════════════════════════ */
        
        .tech-stack-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            margin-top: 0.5rem;
        }
        
        .tech-tag {
            background: #e8f4f5;
            color: #1F7A8C;
            padding: 0.3rem 0.6rem;
            border-radius: 4px;
            font-size: 0.8rem;
            font-weight: 500;
        }
        
        /* ═══════════════════════════════════════════════════════════════════════
           예산 입력 버튼 스타일
           ═══════════════════════════════════════════════════════════════════════ */
        
        .amount-btn:hover {
            background: #f0f0f0;
            border-color: #94D9DB;
            color: #1F7A8C;
            transform: translateY(-1px);
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

    <div class="container">
        <!-- ═══════════════════════════════════════════════════════════════════════
             페이지 헤더
             ═══════════════════════════════════════════════════════════════════════ -->
        <div class="queue-header">
            <h1>⭐ 기회 큐 통합 관리</h1>
            <p>전문 프리랜서를 위한 맞춤형 프로젝트 추천 플랫폼</p>
        </div>
        
        <!-- ═══════════════════════════════════════════════════════════════════════
             메인 컨텐츠 (좌: 자동 추천, 우: 조건 큐)
             ═══════════════════════════════════════════════════════════════════════ -->
        <div class="queue-layout">
            <!-- ───────────────────────────────────────────────────────────────
                 좌측: 자동 추천 큐 (SYSTEM QUEUE)
                 ─────────────────────────────────────────────────────────────── -->
            <div class="queue-section">
                <h2>
                    🤖 자동 추천 큐
                    <span class="queue-badge">시스템</span>
                </h2>
                
                <div id="systemQueueProjects" style="display: flex; flex-direction: column; gap: 0.75rem;">
                    <c:choose>
                        <c:when test="${not empty queuePageData.systemQueueProjects}">
                            <c:forEach var="project" items="${queuePageData.systemQueueProjects}">
                                <div class="project-card" style="margin-bottom: 0;">
                                    <div class="project-card-title" onclick="viewProject(${project.projectId})" style="cursor: pointer;">
                                        ${project.projectTitle}
                                    </div>
                                    
                                    <div class="project-card-info" style="flex-direction: column; gap: 0.3rem; margin-bottom: 0.6rem;">
                                        <div class="project-card-info-item" style="justify-content: space-between;">
                                            <span>💰 예산</span>
                                            <span style="color: #1F7A8C; font-weight: 500;">
                                                <fmt:formatNumber value="${project.minBudget}" type="number" groupingUsed="true"/>
                                            </span>
                                        </div>
                                        <div class="project-card-info-item" style="justify-content: space-between;">
                                            <span>📅 기간</span>
                                            <span style="color: #1F7A8C; font-weight: 500;">${project.expectedDuration}</span>
                                        </div>
                                        <div class="project-card-info-item" style="justify-content: space-between;">
                                            <span>💯 매칭</span>
                                            <span style="color: #94D9DB; font-weight: 600;">${project.matchScore}%</span>
                                        </div>
                                    </div>
                                    
                                    <div class="project-card-actions" style="gap: 0.3rem;">
                                        <button class="btn-small" style="flex: 1;" onclick="viewProject(${project.projectId})">
                                            보기
                                        </button>
                                        <button class="btn-small btn-delete" style="flex: 0 0 auto;" onclick="removeFromQueue('system', ${project.projectId})">
                                            ✕
                                        </button>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">
                                <div class="empty-state-icon">📭</div>
                                <p>추천 프로젝트가 없습니다.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            
            <!-- ───────────────────────────────────────────────────────────────
                 우측: 조건 기반 큐 (CUSTOM QUEUE)
                 ─────────────────────────────────────────────────────────────── -->
            <div class="custom-queues-section">
                <!-- 섹션 헤더 -->
                <div style="display: flex; justify-content: space-between; align-items: center; padding: 0 0 1rem 0; border-bottom: 1px solid #e0e0e0; margin-bottom: 1.5rem;">
                    <h2 style="margin: 0; font-size: 1.2rem; color: #2B2B2B; display: flex; align-items: center; gap: 0.5rem;">
                        🎯 조건 큐
                        <span style="font-size: 0.85rem; color: #999;">(${empty queuePageData.customQueues ? 0 : queuePageData.customQueues.size()}/2)</span>
                    </h2>
                    <c:if test="${queuePageData.canAddMoreQueues()}">
                        <button class="btn-create-queue" onclick="createNewQueue()">
                            ➕ 새 큐 만들기
                        </button>
                    </c:if>
                </div>
                
                <!-- 조건 큐 목록 -->
                <c:choose>
                    <c:when test="${not empty queuePageData.customQueues}">
                        <c:forEach var="queue" items="${queuePageData.customQueues}">
                            <div class="custom-queue-card">
                                <!-- 큐 헤더 -->
                                <div class="queue-card-header">
                                    <div>
                                        <h3 class="queue-card-title">${queue.queueName}</h3>
                                        <p style="font-size: 0.8rem; color: #999; margin-top: 0.3rem;">
                                            ID: ${queue.queueId}
                                        </p>
                                    </div>
                                    
                                    <div class="queue-status-toggle">
                                        <span style="font-size: 0.85rem; color: #666;">
                                            <c:choose>
                                                <c:when test="${queue.isActive()}">
                                                    🟢 활성
                                                </c:when>
                                                <c:otherwise>
                                                    🔴 중지
                                                </c:otherwise>
                                            </c:choose>
                                        </span>
                                        <div 
                                            class="toggle-switch <c:if test='${queue.isActive()}'>active</c:if>"
                                            onclick="toggleQueueStatus(${queue.queueId})">
                                        </div>
                                    </div>
                                </div>
                                
                                <!-- 큐 조건 -->
                                <div class="queue-conditions">
                                    <div class="queue-condition">
                                        <span class="queue-condition-label">분야</span>
                                        <span class="queue-condition-value">${queue.category}</span>
                                    </div>
                                    <div class="queue-condition">
                                        <span class="queue-condition-label">예산</span>
                                        <span class="queue-condition-value">
                                            <fmt:formatNumber value="${queue.minBudget}" type="number" groupingUsed="true"/> 
                                            ~ 
                                            <fmt:formatNumber value="${queue.maxBudget}" type="number" groupingUsed="true"/>
                                        </span>
                                    </div>
                                    <div class="queue-condition">
                                        <span class="queue-condition-label">기간</span>
                                        <span class="queue-condition-value">${queue.expectedDuration}</span>
                                    </div>
                                    <c:if test="${not empty queue.techStacks}">
                                        <div class="queue-condition">
                                            <span class="queue-condition-label">기술</span>
                                            <div class="tech-stack-tags">
                                                <c:forEach var="stack" items="${queue.techStacks}">
                                                    <span class="tech-tag">${stack}</span>
                                                </c:forEach>
                                            </div>
                                        </div>
                                    </c:if>
                                </div>
                                
                                <!-- 추천 프로젝트 -->
                                <div class="queue-projects">
                                    <h4>추천 프로젝트 <span style="color: #999; font-size: 0.85rem;">(${empty queue.projects ? 0 : queue.projects.size()}개)</span></h4>
                                    
                                    <c:choose>
                                        <c:when test="${not empty queue.projects}">
                                            <c:forEach var="project" items="${queue.projects}">
                                                <div class="project-card" style="margin-bottom: 0.75rem;">
                                                    <a href="/ratelocean/project/${project.projectId}" class="project-card-title">
                                                        ${project.projectTitle}
                                                    </a>
                                                    
                                                    <div class="project-card-info">
                                                        <div class="project-card-info-item">
                                                            💰 
                                                            <fmt:formatNumber value="${project.minBudget}" type="number" groupingUsed="true"/> 
                                                            ~ 
                                                            <fmt:formatNumber value="${project.maxBudget}" type="number" groupingUsed="true"/>
                                                        </div>
                                                        <div class="project-card-info-item">
                                                            💯 ${project.matchScore}%
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="project-card-actions">
                                                        <button class="btn-small" onclick="viewProject(${project.projectId})">
                                                            상세보기
                                                        </button>
                                                        <button class="btn-small btn-delete" onclick="removeFromQueue(${queue.queueId}, ${project.projectId})">
                                                            ✕
                                                        </button>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <div style="text-align: center; padding: 1rem; color: #999; font-size: 0.9rem;">
                                                📭 이 큐와 매칭되는 프로젝트가 없습니다.
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                </c:choose>
                
                <!-- 큐 추가 버튼 -->
                <c:choose>
                    <c:when test="${queuePageData.canAddMoreQueues()}">
                        <div class="add-queue-card" onclick="createNewQueue()" id="addQueueButton">
                            <div class="add-queue-card-icon">➕</div>
                            <div class="add-queue-card-text">새로운 조건 큐 생성</div>
                            <p style="font-size: 0.85rem; color: #999; margin-top: 0.5rem;">
                                최대 2개까지 생성할 수 있습니다. (현재: ${queuePageData.getCustomQueueCount()}개)
                            </p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="add-queue-card disabled" style="cursor: not-allowed;">
                            <div class="add-queue-card-icon">❌</div>
                            <div class="add-queue-card-text">큐 생성 제한 도달</div>
                            <p style="font-size: 0.85rem; color: #999; margin-top: 0.5rem;">
                                최대 2개의 큐만 생성할 수 있습니다.
                            </p>
                        </div>
                    </c:otherwise>
                </c:choose>
                
                <!-- 큐 생성 폼 (처음엔 숨겨짐) -->
                <div id="createQueueForm" class="create-queue-form">
                    <h3 style="margin: 0 0 1.2rem 0; color: #2B2B2B; font-size: 1rem;">
                        📝 새로운 조건 큐 생성
                    </h3>
                    
                    <form onsubmit="submitNewQueue(event)">
                        <!-- 첫째 행: 큐 이름 -->
                        <div class="form-section">
                            <div class="form-group full">
                                <label for="queueName">큐 이름 *</label>
                                <input type="text" id="queueName" name="queueName" placeholder="예: Python 백엔드 프로젝트" required>
                            </div>
                        </div>
                        
                        <!-- 둘째 행: 기간 -->
                        <div class="form-section">
                            <div class="form-group">
                                <label for="duration">희망 기간 *</label>
                                <select id="duration" name="duration" required>
                                    <option value="">선택하세요</option>
                                    <option value="1주일">1주일</option>
                                    <option value="2주">2주</option>
                                    <option value="1개월">1개월</option>
                                    <option value="2개월">2개월</option>
                                    <option value="3개월">3개월</option>
                                    <option value="6개월">6개월</option>
                                    <option value="장기">장기</option>
                                </select>
                            </div>
                        </div>
                        
                        <!-- 셋째 행: 예산 -->
                        <div class="form-section">
                            <div class="form-group">
                                <label for="minBudget">최소 예산 (원) *</label>
                                <div class="amount-input-group" style="display: flex; align-items: center; gap: 0.5rem;">
                                    <button type="button" class="amount-btn" onclick="adjustBudget('minBudget', -10000)" style="width: 40px; height: 40px; border: 1px solid #ddd; background: white; border-radius: 6px; cursor: pointer; font-size: 1.2rem; font-weight: bold; transition: all 0.2s ease;">−</button>
                                    <input type="number" id="minBudget" name="minBudget" value="1000000" step="10000" min="0" required style="flex: 1; text-align: center;">
                                    <button type="button" class="amount-btn" onclick="adjustBudget('minBudget', 10000)" style="width: 40px; height: 40px; border: 1px solid #ddd; background: white; border-radius: 6px; cursor: pointer; font-size: 1.2rem; font-weight: bold; transition: all 0.2s ease;">+</button>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="maxBudget">최대 예산 (원) *</label>
                                <div class="amount-input-group" style="display: flex; align-items: center; gap: 0.5rem;">
                                    <button type="button" class="amount-btn" onclick="adjustBudget('maxBudget', -10000)" style="width: 40px; height: 40px; border: 1px solid #ddd; background: white; border-radius: 6px; cursor: pointer; font-size: 1.2rem; font-weight: bold; transition: all 0.2s ease;">−</button>
                                    <input type="number" id="maxBudget" name="maxBudget" value="5000000" step="10000" min="0" required style="flex: 1; text-align: center;">
                                    <button type="button" class="amount-btn" onclick="adjustBudget('maxBudget', 10000)" style="width: 40px; height: 40px; border: 1px solid #ddd; background: white; border-radius: 6px; cursor: pointer; font-size: 1.2rem; font-weight: bold; transition: all 0.2s ease;">+</button>
                                </div>
                            </div>
                        </div>
                        
                        <!-- 넷째 행: 개발 영역 & 희망 기술 스택 -->
                        <div class="form-section">
                            <div class="form-group full">
                                <label>개발 영역 & 희망 기술 스택</label>
                                <button type="button" onclick="openQueueTechStackModal()" 
                                    style="width: 100%; padding: 0.75rem; background: linear-gradient(135deg, #94D9DB 0%, #7cc5c7 100%); color: white; border: none; border-radius: 6px; font-size: 0.95rem; font-weight: 600; cursor: pointer; transition: all 0.2s ease;">
                                    📝 개발 영역 및 기술 스택 선택하기
                                </button>
                                
                                <!-- 선택된 영역 표시 -->
                                <div id="selectedAreasDisplay" style="margin-top: 0.75rem; padding: 0.75rem; background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 6px; display: none;">
                                    <div style="font-weight: 600; color: #2B2B2B; margin-bottom: 0.5rem;">✅ 선택된 개발 영역:</div>
                                    <div id="selectedAreasTags" style="display: flex; flex-wrap: wrap; gap: 0.5rem;"></div>
                                </div>
                                
                                <!-- 선택된 기술 스택 표시 -->
                                <div id="selectedStacksDisplay" style="margin-top: 0.75rem; padding: 0.75rem; background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 6px; display: none;">
                                    <div style="font-weight: 600; color: #2B2B2B; margin-bottom: 0.5rem;">🛠️ 선택된 희망 기술 스택:</div>
                                    <div id="selectedStacksTags" style="display: flex; flex-wrap: wrap; gap: 0.5rem;"></div>
                                </div>
                                
                                <!-- hidden inputs for form submission -->
                                <input type="hidden" id="selectedCategoryInput" name="category">
                                <input type="hidden" id="selectedAreasInput" name="developmentAreas">
                                <input type="hidden" id="selectedStacksInput" name="techStacks">
                            </div>
                        </div>
                        
                        <!-- 다섯째 행: 설명 -->
                        <div class="form-section">
                            <div class="form-group full">
                                <label for="description">추가 설명</label>
                                <textarea id="description" name="description" placeholder="이 큐에서 찾는 프로젝트의 특징을 입력해주세요"></textarea>
                            </div>
                        </div>
                        
                        <!-- 버튼 -->
                        <div class="form-buttons">
                            <button type="button" class="btn-cancel" onclick="cancelCreateQueue()">취소</button>
                            <button type="submit" class="btn-submit">큐 생성</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    <!-- ═══════════════════════════════════════════════════════════════════════
         JavaScript 함수들
         ═══════════════════════════════════════════════════════════════════════ -->
    <script>
        /**
         * 프로젝트 상세 페이지로 이동
         * @param {number} projectId 프로젝트 ID
         */
        function viewProject(projectId) {
            window.location.href = '/ratelocean/project/' + projectId;
        }
        
        /**
         * 큐에서 프로젝트 삭제
         * @param {number|string} queueId 큐 ID ('system' 또는 숫자)
         * @param {number} projectId 프로젝트 ID
         */
        function removeFromQueue(queueId, projectId) {
            if (!confirm('이 프로젝트를 제거하시겠습니까?')) {
                return;
            }
            
            // TODO: AJAX 호출로 서버에 요청
            // POST /queue/{queueId}/projects/{projectId}/delete
            console.log('제거 요청: queueId=' + queueId + ', projectId=' + projectId);
            
            alert('프로젝트가 제거되었습니다.');
            // 실제 구현 시 해당 카드를 DOM에서 제거
            location.reload();  // 임시 새로고침
        }
        
        /**
         * 큐 상태 토글 (ON/OFF)
         * @param {number} queueId 큐 ID
         */
        function toggleQueueStatus(queueId) {
            // TODO: AJAX 호출로 서버에 요청
            // POST /queue/{queueId}/toggle
            console.log('큐 상태 토글: queueId=' + queueId);
            
            // 실제 구현 시 토글 상태 변경
            location.reload();  // 임시 새로고침
        }
        
        /**
         * 예산 조절 (만원 단위)
         */
        function adjustBudget(inputId, amount) {
            const input = document.getElementById(inputId);
            if (!input) {
                console.error('Input element not found:', inputId);
                return false;
            }
            const currentValue = parseInt(input.value) || 0;
            const newValue = Math.max(0, currentValue + amount);
            input.value = newValue;
            console.log(`Adjusted ${inputId}: ${currentValue} → ${newValue}`);
            return false;
        }
        
        /**
         * 기술 스택 모달 열기 (큐 생성 폼용)
         */
        let queueSelectedAreas = [];
        let queueSelectedStacks = [];
        
        function openQueueTechStackModal() {
            openTechStackModal(function(areas, stacks) {
                queueSelectedAreas = areas;
                queueSelectedStacks = stacks;
                
                // UI 업데이트
                updateQueueSelectionDisplay();
            }, queueSelectedAreas, queueSelectedStacks);
        }
        
        function updateQueueSelectionDisplay() {
            // 개발 영역 표시
            const areasDisplay = document.getElementById('selectedAreasDisplay');
            const areasTags = document.getElementById('selectedAreasTags');
            const areasInput = document.getElementById('selectedAreasInput');
            const categoryInput = document.getElementById('selectedCategoryInput');
            
            if (queueSelectedAreas.length > 0) {
                areasDisplay.style.display = 'block';
                areasTags.innerHTML = '';
                queueSelectedAreas.forEach(area => {
                    const tag = document.createElement('span');
                    tag.className = 'tech-tag';
                    tag.textContent = area.name;
                    areasTags.appendChild(tag);
                });
                
                // hidden input 업데이트
                areasInput.value = queueSelectedAreas.map(a => a.name).join(',');
                // 첫 번째 영역을 category로 저장 (임시)
                categoryInput.value = queueSelectedAreas[0].name;
            } else {
                areasDisplay.style.display = 'none';
                areasInput.value = '';
                categoryInput.value = '';
            }
            
            // 기술 스택 표시
            const stacksDisplay = document.getElementById('selectedStacksDisplay');
            const stacksTags = document.getElementById('selectedStacksTags');
            const stacksInput = document.getElementById('selectedStacksInput');
            
            if (queueSelectedStacks.length > 0) {
                stacksDisplay.style.display = 'block';
                stacksTags.innerHTML = '';
                queueSelectedStacks.forEach(stack => {
                    const tag = document.createElement('span');
                    tag.className = 'tech-tag';
                    tag.textContent = stack.name;
                    stacksTags.appendChild(tag);
                });
                
                // hidden input 업데이트
                stacksInput.value = queueSelectedStacks.map(s => s.name).join(',');
            } else {
                stacksDisplay.style.display = 'none';
                stacksInput.value = '';
            }
        }
        
        /**
         * 새로운 조건 큐 생성 폼 표시
         */
        function createNewQueue() {
            const form = document.getElementById('createQueueForm');
            const button = document.getElementById('addQueueButton');
            
            form.classList.add('active');
            button.style.display = 'none';
            
            // 폼 상단으로 스크롤
            form.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
        
        /**
         * 큐 생성 폼 닫기
         */
        function cancelCreateQueue() {
            const form = document.getElementById('createQueueForm');
            const button = document.getElementById('addQueueButton');
            
            form.classList.remove('active');
            button.style.display = 'block';
            
            // 폼 초기화
            form.querySelector('form').reset();
        }
        
        /**
         * 새로운 큐 생성 폼 제출
         */
        function submitNewQueue(event) {
            event.preventDefault();
            
            const queueName = document.getElementById('queueName').value;
            const category = document.getElementById('category').value;
            const duration = document.getElementById('duration').value;
            const minBudget = document.getElementById('minBudget').value;
            const maxBudget = document.getElementById('maxBudget').value;
            const techStacks = document.getElementById('techStacks').value;
            const description = document.getElementById('description').value;
            
            // 검증
            if (!queueName || !duration || !minBudget || !maxBudget) {
                alert('필수 항목을 모두 입력해주세요.');
                return;
            }
            
            if (queueSelectedAreas.length === 0) {
                alert('개발 영역을 최소 1개 이상 선택해주세요.');
                return;
            }
            
            if (parseInt(minBudget) > parseInt(maxBudget)) {
                alert('최소 예산이 최대 예산보다 클 수 없습니다.');
                return;
            }
            
            // TODO: AJAX 호출로 서버에 요청
            // POST /queue/create
            const queueData = {
                queueName: queueName,
                category: category,
                duration: duration,
                minBudget: minBudget,
                maxBudget: maxBudget,
                techStacks: techStacks,
                description: description
            };
            
            console.log('새 큐 생성:', queueData);
            alert('큐가 생성되었습니다!');
            
            // 페이지 새로고침 (실제 구현 시 AJAX 후 동적 추가)
            location.reload();
        }
    </script>
    
    <!-- 기술 스택 선택 모달 (공통 컴포넌트) -->
    <%@ include file="/WEB-INF/views/common/tech-stack-modal.jsp" %>
    
    <!-- 기술 스택 모달 JavaScript 로드 -->
    <script src="/ratelocean/resources/js/tech-stack-modal.js"></script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

</body>
</html>
