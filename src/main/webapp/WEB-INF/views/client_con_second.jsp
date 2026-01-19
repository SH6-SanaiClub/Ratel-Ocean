<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>계약서 검토 - Ratel Ocean</title>
    
    <!-- Select2 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background-color: #f9f9f9;
            padding: 2rem;
        }

        .container {
            max-width: 900px;
            margin: 0 auto;
        }

        .page-header {
            margin-bottom: 2rem;
        }

        .page-title {
            font-size: 1.8rem;
            font-weight: 700;
            color: #2B2B2B;
            margin-bottom: 0.5rem;
        }

        .page-subtitle {
            font-size: 0.95rem;
            color: #666;
            line-height: 1.5;
        }

        .form-section {
            background: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            padding: 2rem;
            margin-bottom: 1.5rem;
        }

        .section-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: #2B2B2B;
            margin-bottom: 1.5rem;
            padding-bottom: 0.75rem;
            border-bottom: 2px solid #94D9DB;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
            margin-bottom: 1.5rem;
        }

        .form-row.full {
            grid-template-columns: 1fr;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group label {
            font-weight: 600;
            color: #2B2B2B;
            margin-bottom: 0.5rem;
            font-size: 0.9rem;
        }

        .form-group input[type="text"],
        .form-group input[type="date"],
        .form-group input[type="number"],
        .form-group textarea {
            padding: 0.75rem;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 0.9rem;
            font-family: inherit;
            transition: border-color 0.2s ease;
        }

        .form-group input[type="text"]:focus,
        .form-group input[type="date"]:focus,
        .form-group input[type="number"]:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #94D9DB;
            box-shadow: 0 0 0 3px rgba(148, 217, 219, 0.1);
        }

        .form-group textarea {
            resize: vertical;
            min-height: 100px;
            line-height: 1.5;
        }

        .checkbox-group {
            display: flex;
            gap: 1.5rem;
            flex-wrap: wrap;
        }

        .checkbox-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .checkbox-item input[type="checkbox"] {
            width: 18px;
            height: 18px;
            cursor: pointer;
            accent-color: #94D9DB;
        }

        .checkbox-item label {
            cursor: pointer;
            color: #555;
            font-weight: normal;
            margin: 0;
        }

        .hidden-input {
            display: none;
        }

        .hidden-input.show {
            display: block;
        }

        .tech-stack {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
        }

        .tech-badge {
            background-color: #e8f4f5;
            color: #1F7A8C;
            padding: 0.4rem 0.8rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 500;
            border: 1px solid #94D9DB;
        }

        .milestone-item {
            background-color: #fafafa;
            border: 1px solid #e5e7eb;
            border-radius: 6px;
            padding: 1.5rem;
            margin-bottom: 1rem;
        }

        .milestone-item .form-row {
            margin-bottom: 1rem;
        }

        .milestone-item .form-row:last-child {
            margin-bottom: 0;
        }

        .milestone-number {
            font-size: 1rem;
            color: #2B2B2B;
            font-weight: 700;
            margin-bottom: 1rem;
            padding-bottom: 0.75rem;
            border-bottom: 2px solid #94D9DB;
        }
        
        .amount-input-group {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .amount-btn {
            width: 40px;
            height: 40px;
            border: 1px solid #ddd;
            background: white;
            border-radius: 6px;
            font-size: 1.2rem;
            font-weight: 600;
            color: #495057;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .amount-btn:hover {
            background: #f8f9fa;
            border-color: #94D9DB;
            color: #94D9DB;
        }
        
        .amount-btn:active {
            transform: scale(0.95);
        }
        
        .milestone-amount-input {
            flex: 1;
            text-align: center;
            font-weight: 600;
        }
        
        /* input type="number" spinner 제거 */
        .milestone-amount-input::-webkit-outer-spin-button,
        .milestone-amount-input::-webkit-inner-spin-button {
            -webkit-appearance: none;
            margin: 0;
        }
        
        .milestone-amount-input[type=number] {
            -moz-appearance: textfield;
        }

        .budget-helper {
            font-size: 0.8rem;
            color: #999;
            margin-top: 0.25rem;
        }

        .button-group {
            display: flex;
            gap: 1rem;
            justify-content: center;
            margin-top: 2rem;
        }

        .btn {
            padding: 0.75rem 2rem;
            border-radius: 6px;
            border: none;
            font-size: 0.95rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .btn-primary {
            background-color: #2B2B2B;
            color: white;
        }

        .btn-primary:hover {
            background-color: #1a1a1a;
        }

        .btn-secondary {
            background-color: #e5e7eb;
            color: #2B2B2B;
        }

        .btn-secondary:hover {
            background-color: #d1d5db;
        }

        .info-box {
            background-color: #f0f8f9;
            border-left: 4px solid #94D9DB;
            padding: 1rem;
            border-radius: 4px;
            margin-bottom: 1.5rem;
            font-size: 0.9rem;
            color: #555;
            line-height: 1.5;
        }

        .no-data {
            color: #999;
            font-style: italic;
        }

        .input-with-btn {
            display: flex;
            gap: 0.5rem;
            align-items: center;
            margin-bottom: 0.75rem;
        }

        .input-with-btn input {
            flex: 1;
        }

        .btn-small {
            padding: 0.5rem 0.75rem;
            border-radius: 4px;
            border: none;
            font-size: 0.85rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            white-space: nowrap;
        }

        .btn-add {
            background-color: #94D9DB;
            color: white;
        }

        .btn-add:hover {
            background-color: #7cc5c7;
        }

        .btn-remove {
            background-color: #ff6b6b;
            color: white;
            min-width: 60px;
        }

        .btn-remove:hover {
            background-color: #ee5a52;
        }

        .add-button-container {
            margin-top: 1rem;
        }
        
        /* 개발 영역 버튼 그리드 */
        .position-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            gap: 0.75rem;
            margin-top: 1rem;
        }
        
        .position-btn {
            padding: 0.75rem 1rem;
            border: 2px solid #ddd;
            background-color: white;
            color: #666;
            border-radius: 8px;
            font-size: 0.9rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
            text-align: center;
        }
        
        .position-btn:hover {
            border-color: #94D9DB;
            background-color: #f8fdfd;
            transform: translateY(-2px);
            box-shadow: 0 2px 8px rgba(148, 217, 219, 0.2);
        }
        
        .position-btn.selected {
            background: linear-gradient(135deg, #94D9DB 0%, #7cc5c7 100%);
            border-color: #94D9DB;
            color: white;
            font-weight: 600;
            box-shadow: 0 2px 8px rgba(148, 217, 219, 0.3);
        }
        
        .position-btn.selected:hover {
            background: linear-gradient(135deg, #7cc5c7 0%, #6ab5b7 100%);
        }
        
        /* 기술 스택 섹션 */
        .tech-stack-section {
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }
        
        .selected-tags-area {
            min-height: 50px;
            padding: 0.75rem;
            border: 2px dashed #ddd;
            border-radius: 8px;
            background-color: #f9fafb;
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            align-items: center;
        }
        
        .selected-tags-area.empty {
            justify-content: center;
            align-items: center;
            color: #999;
            font-style: italic;
        }
        
        .tech-tag {
            background: linear-gradient(135deg, #e8f4f5 0%, #d4eef0 100%);
            border: 1.5px solid #94D9DB;
            color: #1F7A8C;
            padding: 6px 12px;
            border-radius: 20px;
            font-weight: 500;
            font-size: 0.875rem;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 1px 3px rgba(31, 122, 140, 0.1);
            transition: all 0.2s ease;
        }
        
        .tech-tag:hover {
            background: linear-gradient(135deg, #d4eef0 0%, #c0e8eb 100%);
            box-shadow: 0 2px 5px rgba(31, 122, 140, 0.15);
        }
        
        .tech-tag-remove {
            color: #1F7A8C;
            font-weight: 700;
            font-size: 1rem;
            cursor: pointer;
            width: 18px;
            height: 18px;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s ease;
        }
        
        .tech-tag-remove:hover {
            background-color: #ff6b6b;
            color: white;
            transform: scale(1.15);
        }
        
        .search-filter-area {
            display: flex;
            gap: 0.75rem;
            align-items: center;
        }
        
        .search-input-box {
            flex: 1;
            padding: 0.75rem;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 0.9rem;
            font-family: inherit;
            transition: border-color 0.2s ease;
        }
        
        .search-input-box:focus {
            outline: none;
            border-color: #94D9DB;
            box-shadow: 0 0 0 3px rgba(148, 217, 219, 0.1);
        }
        
        .alphabet-filters {
            display: flex;
            gap: 0.25rem;
            flex-wrap: wrap;
        }
        
        .alphabet-btn {
            width: 32px;
            height: 32px;
            border: 1px solid #ddd;
            background-color: white;
            color: #666;
            border-radius: 6px;
            font-size: 0.85rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .alphabet-btn:hover {
            border-color: #94D9DB;
            background-color: #e8f4f5;
            color: #1F7A8C;
        }
        
        .alphabet-btn.active {
            background-color: #94D9DB;
            border-color: #94D9DB;
            color: white;
        }
        
        .alphabet-btn.all {
            width: auto;
            padding: 0 0.75rem;
        }
        
        .tech-items-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
            gap: 0.5rem;
            max-height: 300px;
            overflow-y: auto;
            padding: 0.75rem;
            border: 1px solid #ddd;
            border-radius: 6px;
            background-color: white;
        }
        
        .tech-item {
            padding: 0.5rem 0.75rem;
            border: 1px solid #ddd;
            background-color: white;
            color: #666;
            border-radius: 6px;
            font-size: 0.85rem;
            cursor: pointer;
            transition: all 0.2s ease;
            text-align: center;
        }
        
        .tech-item:hover {
            border-color: #94D9DB;
            background-color: #f8fdfd;
            color: #1F7A8C;
        }
        
        /* 선택된 기술 아이템 */
        .tech-item.selected {
            background-color: #94D9DB;
            border-color: #1F7A8C;
            color: white;
            font-weight: 600;
        }
        
        .tech-item.selected:hover {
            background-color: #7ac5c8;
            border-color: #1F7A8C;
        }
        
        .tech-item.hidden {
            display: none;
        }
        
        /* Select2 스타일 커스터마이징 - 제거됨, 이제 사용 안 함 */
        
        .form-group .select2-hint {
            font-size: 0.8rem;
            color: #666;
            margin-top: 0.25rem;
        }
        
        .form-group .select2-hint strong {
            color: #1F7A8C;
            font-weight: 600;
        }

        @media (max-width: 768px) {
            .form-row {
                grid-template-columns: 1fr;
            }

            .page-title {
                font-size: 1.5rem;
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

<%@ include file="/WEB-INF/views/common/client_header.jsp" %>
    <div class="container">
        <div class="page-header">
            <h1 class="page-title">계약서 검토 및 수정</h1>
            <p class="page-subtitle">제출하신 계약서와 프로젝트 공지를 바탕으로 계약 정보를 정리했습니다. 
                내용을 검토하고 필요시 수정 후 진행해주세요.</p>
        </div>

        <div class="info-box">
            💡 AI가 자동으로 생성한 계약 정보입니다. 잘못된 내용이 있다면 수정해주세요.
        </div>

        <form method="post" action="/ratelocean/contract/second">

            <!-- 프로젝트 기본 정보 -->
            <div class="form-section">
                <h2 class="section-title">프로젝트 기본 정보</h2>

                <div class="form-row">
                    <div class="form-group">
                        <label for="startDate">예상 시작일 *</label>
                        <input type="date" id="startDate" name="startDate" 
                               value="${contract.startDate}" required style="cursor: pointer;">
                    </div>
                    <div class="form-group">
                        <label for="deadlineDate">마감일 *</label>
                        <input type="date" id="deadlineDate" name="deadlineDate" 
                               value="${contract.deadlineDate}" required style="cursor: pointer;">
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="estDuration">예상 진행 기간</label>
                        <input type="text" id="estDuration" name="estDuration" 
                               value="${contract.estDuration}" placeholder="예: 3개월">
                    </div>
                </div>

                <div class="form-row full">
                    <div class="form-group">
                        <label for="budget">예산 *</label>
                        <div class="amount-input-group">
                            <button type="button" class="amount-btn amount-decrease" onclick="adjustBudget(-10000)">−</button>
                            <input type="number" id="budget" name="budget" class="milestone-amount-input"
                                   value="${contract.budget}" placeholder="0" step="10000" min="0" required>
                            <button type="button" class="amount-btn amount-increase" onclick="adjustBudget(10000)">+</button>
                        </div>
                    </div>
                </div>

                <div class="checkbox-group">
                    <div class="checkbox-item">
                        <input type="checkbox" id="budgetNegotiable" name="budgetNegotiable" 
                               value="true" <c:if test="${contract.budgetNegotiable == true}">checked</c:if>>
                        <label for="budgetNegotiable">예산 협의 가능</label>
                    </div>
                </div>
            </div>

            <!-- 개발 영역 및 기술 스택 -->
            <div class="form-section">
                <h2 class="section-title">개발 영역 및 기술 스택</h2>

                <div class="form-row full">
                    <div class="form-group">
                        <button type="button" onclick="openContractTechStackModal()" 
                            style="width: 100%; padding: 1rem; background: linear-gradient(135deg, #94D9DB 0%, #7cc5c7 100%); color: white; border: none; border-radius: 8px; font-size: 1rem; font-weight: 600; cursor: pointer; transition: all 0.2s ease;">
                            📝 개발 영역 및 기술 스택 선택하기
                        </button>
                    </div>
                </div>

                <!-- 선택된 개발 영역 표시 -->
                <div id="contractSelectedAreasDisplay" style="display: none; margin-top: 1rem; padding: 1rem; background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 8px;">
                    <div style="font-weight: 600; color: #2B2B2B; margin-bottom: 0.75rem;">✅ 선택된 개발 영역:</div>
                    <div id="contractSelectedAreasTags" style="display: flex; flex-wrap: wrap; gap: 0.5rem;"></div>
                </div>
                
                <!-- 선택된 기술 스택 표시 -->
                <div id="contractSelectedStacksDisplay" style="display: none; margin-top: 1rem; padding: 1rem; background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 8px;">
                    <div style="font-weight: 600; color: #2B2B2B; margin-bottom: 0.75rem;">🛠️ 선택된 기술 스택:</div>
                    <div id="contractSelectedStacksTags" style="display: flex; flex-wrap: wrap; gap: 0.5rem;"></div>
                </div>
                
                <!-- hidden inputs for form submission -->
                <select id="selectedPositions" name="developmentAreas" multiple required style="display: none;"></select>
                <select id="selectedSkills" name="technicalStacks" multiple style="display: none;"></select>
            </div>

            <!-- 협업 방식 -->
            <div class="form-section">
                <h2 class="section-title">협업 방식</h2>

                <div class="form-row full">
                    <div class="form-group">
                        <label>협업 방식 선택 (복수 선택 가능)</label>
                        <div class="checkbox-group">
                            <div class="checkbox-item">
                                <input type="checkbox" id="comm_offline" name="communicationMethods" 
                                       value="OFFLINE" <c:if test="${contract.communicationMethods.contains('OFFLINE')}">checked</c:if>>
                                <label for="comm_offline">오프라인</label>
                            </div>
                            <div class="checkbox-item">
                                <input type="checkbox" id="comm_messenger" name="communicationMethods" 
                                       value="MESSENGER" <c:if test="${contract.communicationMethods.contains('MESSENGER')}">checked</c:if>>
                                <label for="comm_messenger">메신저</label>
                            </div>
                            <div class="checkbox-item">
                                <input type="checkbox" id="comm_email" name="communicationMethods" 
                                       value="EMAIL" <c:if test="${contract.communicationMethods.contains('EMAIL')}">checked</c:if>>
                                <label for="comm_email">이메일</label>
                            </div>
                            <div class="checkbox-item">
                                <input type="checkbox" id="comm_videocall" name="communicationMethods" 
                                       value="VIDEOCALL" <c:if test="${contract.communicationMethods.contains('VIDEOCALL')}">checked</c:if>>
                                <label for="comm_videocall">화상회의</label>
                            </div>
                            <div class="checkbox-item">
                                <input type="checkbox" id="comm_other" name="communicationMethods" 
                                       value="OTHER" <c:if test="${contract.communicationMethods.contains('OTHER')}">checked</c:if>
                                       onchange="toggleOtherMethod()">
                                <label for="comm_other">기타</label>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="form-row full hidden-input <c:if test="${contract.communicationMethods.contains('OTHER')}">show</c:if>" id="otherMethodGroup">
                    <div class="form-group">
                        <label for="otherMethod">기타 협업 방식</label>
                        <input type="text" id="otherMethod" name="otherMethod" 
                               value="${contract.otherMethod}" placeholder="협업 방식을 입력해주세요">
                    </div>
                </div>
            </div>

            <!-- 프로젝트 내용 -->
            <div class="form-section">
                <h2 class="section-title">프로젝트 내용</h2>

                <div class="form-row full">
                    <div class="form-group">
                        <label for="expectedDeliverables">예상 산출물 *</label>
                        <textarea id="expectedDeliverables" name="expectedDeliverables" 
                                  required>${contract.expectedDeliverables}</textarea>
                    </div>
                </div>

                <div class="form-row full">
                    <div class="form-group">
                        <label for="mainFeatures">주요 기능 및 요구사항 *</label>
                        <textarea id="mainFeatures" name="mainFeatures" 
                                  required>${contract.mainFeatures}</textarea>
                    </div>
                </div>
            </div>

            <!-- 마일스톤 -->
            <div class="form-section">
                <h2 class="section-title">진행 단계 및 금액 배분</h2>

                <div id="milestonesContainer">
                    <c:choose>
                        <c:when test="${not empty contract.milestones}">
                            <c:forEach var="milestone" items="${contract.milestones}" varStatus="status">
                                <div class="milestone-item">
                                    <div class="milestone-number">
                                        ${status.count}단계
                                        <c:if test="${status.count > 1}">
                                            <button type="button" class="btn-small btn-remove" style="float: right;" onclick="removeMilestone(this)">삭제</button>
                                        </c:if>
                                    </div>

                                    <div class="form-row">
                                        <div class="form-group">
                                            <label>단계명 *</label>
                                            <input type="text" name="milestoneName" 
                                                   value="${milestone.name}" 
                                                   placeholder="예: API 설계 및 DB 구축" required>
                                        </div>
                                        <div class="form-group">
                                            <label>금액 *</label>
                                            <div class="amount-input-group">
                                                <button type="button" class="amount-btn amount-decrease" onclick="adjustAmount(this, -10000)">-</button>
                                                <input type="number" name="milestoneAmount" class="milestone-amount-input"
                                                       value="${milestone.amount}" 
                                                       placeholder="0" step="10000" min="0" required onchange="validateTotalAmount()">
                                                <button type="button" class="amount-btn amount-increase" onclick="adjustAmount(this, 10000)">+</button>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="form-row full">
                                        <div class="form-group">
                                            <label>설명</label>
                                            <textarea name="milestoneDescription" 
                                                      placeholder="단계별 작업 내용을 입력해주세요">${milestone.description}</textarea>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="milestone-item">
                                <div class="milestone-number">1단계</div>

                                <div class="form-row">
                                    <div class="form-group">
                                        <label>단계명 *</label>
                                        <input type="text" name="milestoneName" 
                                               placeholder="예: API 설계 및 DB 구축" required>
                                    </div>
                                    <div class="form-group">
                                        <label>금액 *</label>
                                        <div class="amount-input-group">
                                            <button type="button" class="amount-btn amount-decrease" onclick="adjustAmount(this, -10000)">-</button>
                                            <input type="number" name="milestoneAmount" class="milestone-amount-input"
                                                   value="0" step="10000" min="0" required onchange="validateTotalAmount()">
                                            <button type="button" class="amount-btn amount-increase" onclick="adjustAmount(this, 10000)">+</button>
                                        </div>
                                    </div>
                                </div>

                                <div class="form-row full">
                                    <div class="form-group">
                                        <label>설명</label>
                                        <textarea name="milestoneDescription" 
                                                  placeholder="단계별 작업 내용을 입력해주세요"></textarea>
                                    </div>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="add-button-container">
                    <button type="button" class="btn-small btn-add" onclick="addMilestone()">+ 다음 단계 추가</button>
                </div>
                
                <!-- 예산 대비 금액 합계 표시 -->
                <div class="budget-summary" style="margin-top: 1.5rem; padding: 1rem; background: #f8f9fa; border-radius: 8px; border-left: 4px solid #007bff;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem;">
                        <span style="font-weight: 600; color: #495057;">전체 예산:</span>
                        <span id="totalBudget" style="font-size: 1.1rem; font-weight: 700; color: #007bff;">₩ <c:out value="${contract.budget}"/></span>
                    </div>
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem;">
                        <span style="font-weight: 600; color: #495057;">단계별 금액 합계:</span>
                        <span id="totalMilestoneAmount" style="font-size: 1.1rem; font-weight: 700; color: #28a745;">₩ 0</span>
                    </div>
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <span style="font-weight: 600; color: #495057;">남은 예산:</span>
                        <span id="remainingBudget" style="font-size: 1.1rem; font-weight: 700; color: #6c757d;">₩ <c:out value="${contract.budget}"/></span>
                    </div>
                    <div id="budgetWarning" style="display: none; margin-top: 0.75rem; padding: 0.5rem; background: #fff3cd; border-left: 4px solid #ffc107; color: #856404;">
                        ⚠️ 단계별 금액 합계가 예산을 초과했습니다!
                    </div>
                    <div id="budgetError" style="display: none; margin-top: 0.75rem; padding: 0.5rem; background: #f8d7da; border-left: 4px solid #dc3545; color: #721c24;">
                        ❌ 단계별 금액 합계가 예산을 초과할 수 없습니다!
                    </div>
                </div>
            </div>

            <!-- 버튼 -->
            <div class="button-group">
                <button type="button" class="btn btn-secondary" onclick="history.back()">
                    이전으로
                </button>
                <button type="submit" class="btn btn-primary" id="submitBtn">
                    계약서 전달
                </button>
            </div>

        </form>
    </div>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <!-- 기술 스택 모달 JavaScript 로드 -->
    <script src="/ratelocean/resources/js/tech-stack-modal.js"></script>
    
    <!-- 계약서 검토 페이지 JavaScript -->
    <script src="/ratelocean/resources/js/client-con-second.js"></script>

    <script>
        // 페이지 로드 시 JSP 데이터로 선택값 초기화
        document.addEventListener('DOMContentLoaded', function() {
            // 기존 선택된 개발 영역 복원
            <c:if test="${not empty contract.developmentAreas}">
                contractSelectedAreas = [
                    <c:forEach var="area" items="${contract.developmentAreas}" varStatus="status">
                        {id: 0, name: '${area}'}<c:if test="${!status.last}">,</c:if>
                    </c:forEach>
                ];
            </c:if>
            
            // 기존 선택된 기술 스택 복원
            <c:if test="${not empty contract.technicalStacks}">
                contractSelectedStacks = [
                    <c:forEach var="stack" items="${contract.technicalStacks}" varStatus="status">
                        {id: 0, name: '${stack}'}<c:if test="${!status.last}">,</c:if>
                    </c:forEach>
                ];
            </c:if>
            
            // UI 업데이트
            updateContractSelectionDisplay();
        });
    </script>

    <style>
        /* 날짜 입력 전체와 캘린더 아이콘에 포인터 커서 적용 */
        input[type="date"] { cursor: pointer; }
        input[type="date"]::-webkit-calendar-picker-indicator { cursor: pointer; }
    </style>

    
    <!-- 기술 스택 선택 모달 (공통 컴포넌트) -->
    <%@ include file="/WEB-INF/views/common/tech-stack-modal.jsp" %>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

</body>
</html>
