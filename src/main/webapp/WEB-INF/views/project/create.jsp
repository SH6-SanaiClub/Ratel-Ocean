<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>프로젝트 등록 | Ratel Ocean</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/project/create-new.css">
</head>
<body>

<!-- 클라이언트 상단바 -->
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<!-- Progress Indicator (상단 고정) -->
<div class="progress-container">
    <div class="progress-inner">
        <div class="progress-steps" id="progressSteps">
            <div class="progress-step active" data-step="1">1</div>
            <div class="progress-divider"></div>
            <div class="progress-step" data-step="2">2</div>
            <div class="progress-divider"></div>
            <div class="progress-step" data-step="3">3</div>
            <div class="progress-divider"></div>
            <div class="progress-step" data-step="4">4</div>
            <div class="progress-divider"></div>
            <div class="progress-step" data-step="5">5</div>
        </div>
        <div class="progress-label">
            <span id="progressText"><strong>1</strong> / 5 단계</span>
        </div>
    </div>
</div>

<form id="projectForm" action="${pageContext.request.contextPath}/project/create" method="post" enctype="multipart/form-data">

<!-- ═══════════════════════════════════════════════════════════════════════
     Step 1: 프로젝트 기본 정보
     ═══════════════════════════════════════════════════════════════════════ -->
<div class="page-container">
    <div class="form-wrapper">
        <div class="step-page active" id="step1">
            <div class="step-header">
                <span class="step-number-badge">STEP 1</span>
                <h1 class="step-title">프로젝트의 기본을 알려주세요</h1>
                <p class="step-description">
                    아래는 기능 통이는 필요 없어요. 프리랜서가 클라이언트님의 아이디어를 명확히 이해할 수 있도록 간단한 질문에만 답변해주세요.
                </p>
            </div>

            <!-- 프로젝트 제목 -->
            <div class="question-card">
                <label class="question-label">
                    <i class="fa-solid fa-file-signature"></i>
                    프로젝트 제목<span class="required-mark">*</span>
                </label>
                <input type="text" name="title" id="title" class="input-field" 
                       placeholder="예) 패션 브랜드 이커머스 웹사이트 리뉴얼" required>
                <p class="input-hint">
                    <i class="fa-solid fa-lightbulb" style="color: #FFA726; margin-right: 4px;"></i>
                    <strong>팁:</strong> "무엇을" + "어떻게" 형식으로 작성하면 좋아요<br>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;예) 회원 관리 시스템 개발, 모바일 앱 UI/UX 디자인
                </p>
            </div>

            <!-- 프로젝트 상세 내용 -->
            <div class="question-card">
                <label class="question-label">
                    <i class="fa-solid fa-file-lines"></i>
                    프로젝트 상세 내용<span class="required-mark">*</span>
                </label>
                <textarea name="description" id="description" class="input-field" required
                          placeholder="1. 프로젝트 진행 배경 및 목적&#10;- 이 프로젝트를 기획하게 된 계기와 해결하고자 하는 문제를 적어주세요.&#10;&#10;2. 상세 업무 내용&#10;- 구현이 필요한 핵심 기능이나 페이지 구성에 대해 나열해 주세요.&#10;&#10;3. 참고 레퍼런스&#10;- 벤치마킹하고 싶은 웹사이트나 앱 URL이 있다면 기재해 주세요."></textarea>
                <p class="input-hint">
                    <i class="fa-solid fa-circle-info" style="color: #1F7A8C; margin-right: 4px;"></i>
                    최소 10자 이상 작성해주세요 (현재: <span id="descLength">0</span>자)<br>
                    <i class="fa-solid fa-lightbulb" style="color: #FFA726; margin-right: 4px;"></i>
                    <strong>팁:</strong> 구체적일수록 적합한 프리랜서를 찾기 쉬워요!
                </p>
            </div>

            <div class="question-card">
                <label class="question-label">
                    <i class="fa-solid fa-cloud-arrow-up"></i>
                    기획서 등 관련 파일 (선택)
                </label>
                <div class="modal-trigger-card" onclick="document.getElementById('fileInput').click()">
                    <div id="fileDisplayDefault">
                        <i class="fa-solid fa-cloud-arrow-up modal-trigger-icon"></i>
                        <p style="color: #6F7272; margin-bottom: 1rem;">클릭하여 파일 업로드 (최대 5GB)</p>
                        <button type="button" class="modal-trigger-button">
                            <i class="fa-solid fa-plus"></i>
                            파일 선택
                        </button>
                    </div>
                    <div id="fileDisplaySelected" style="display:none;">
                        <i class="fa-solid fa-file-lines modal-trigger-icon"></i>
                        <p style="color: #1F7A8C; font-weight: 600; margin-bottom: 0.5rem;" id="fileNameDisplay"></p>
                        <p style="color: #6F7272; font-size: 0.875rem;">클릭하여 파일 변경</p>
                    </div>
                </div>
                <input type="file" id="fileInput" name="planFile" style="display:none;" onchange="handleFileSelect(this)">
                <input type="hidden" name="planUrl" id="planUrl">
                <input type="hidden" name="fileSize" id="fileSize">
            </div>
        </div>

<!-- ═══════════════════════════════════════════════════════════════════════
     Step 2: 기술 스택
     ═══════════════════════════════════════════════════════════════════════ -->
        <div class="step-page" id="step2">
            <div class="step-header">
                <span class="step-number-badge">STEP 2</span>
                <h1 class="step-title">어떤 전문가가 필요하신가요?</h1>
                <p class="step-description">
                    개발 영역과 기술 스택을 선택해주세요. 정확히 모르시더라도 괜찮아요!<br>
                    <i class="fa-solid fa-circle-info" style="color: #1F7A8C; margin-right: 4px;"></i>
                    <strong>팁:</strong> 요구 숙련도와 필요 경력을 모르면 기본값(레벨 모름/0년)으로 넣어두어도 됩니다.
                </p>
            </div>

            <!-- 기술 스택 선택 버튼 -->
            <div class="question-card">
                <label class="question-label">
                    <i class="fa-solid fa-code"></i>
                    필요한 기술 스택 선택<span class="required-mark">*</span>
                </label>
                <div class="modal-trigger-card" onclick="openProjectTechStackModal()">
                    <i class="fa-solid fa-plus-circle modal-trigger-icon"></i>
                    <p style="color: #6F7272; margin-bottom: 1rem;">기술 스택을 선택하고 요구사항을 입력해주세요</p>
                    <button type="button" class="modal-trigger-button">
                        <i class="fa-solid fa-code"></i>
                        기술 스택 선택하기
                    </button>
                </div>
            </div>

            <!-- 선택된 기술 스택 표시 -->
            <div id="selectedStacks" class="selected-stacks" style="display:none;">
                <div class="question-card">
                    <div class="selected-stack-header">
                        <i class="fa-solid fa-check-circle" style="color: #1F7A8C;"></i>
                        선택된 기술 스택
                    </div>
                    
                    <!-- 개발 영역 -->
                    <div id="selectedAreasSection" style="display:none;">
                        <div style="font-size: 0.875rem; font-weight: 600; color: #1F7A8C; margin-bottom: 0.75rem; margin-top: 1rem;">
                            <i class="fa-solid fa-folder" style="margin-right: 0.5rem;"></i>개발 영역
                        </div>
                        <div id="selectedAreasContainer" class="stack-cards-grid"></div>
                    </div>
                    
                    <!-- 기술 스택 -->
                    <div id="selectedSkillsSection" style="display:none;">
                        <div style="font-size: 0.875rem; font-weight: 600; color: #1F7A8C; margin-bottom: 0.75rem; margin-top: 1.5rem;">
                            <i class="fa-solid fa-code" style="margin-right: 0.5rem;"></i>기술 스택
                        </div>
                        <div id="selectedSkillsContainer" class="stack-cards-grid"></div>
                    </div>
                </div>
            </div>

            <div id="hiddenStackInputs"></div>
        </div>

<!-- ═══════════════════════════════════════════════════════════════════════
     Step 3: 예산 및 일정
     ═══════════════════════════════════════════════════════════════════════ -->
        <div class="step-page" id="step3">
            <div class="step-header">
                <span class="step-number-badge">STEP 3</span>
                <h1 class="step-title">예산과 일정을 알려주세요</h1>
                <p class="step-description">
                    프로젝트 예산과 진행 기간, 시작일을 입력해주세요.
                </p>
            </div>

            <div class="question-card">
                <label class="question-label">
                    <i class="fa-solid fa-won-sign"></i>
                    프로젝트 예산<span class="required-mark">*</span>
                </label>
                <div style="position: relative;">
                    <input type="text" id="budgetInput" class="input-field" 
                           placeholder="예) 10,000,000" required 
                           style="padding-right: 3rem;">
                    <span style="position: absolute; right: 1.25rem; top: 50%; transform: translateY(-50%); color: #6F7272; font-weight: 600;">원</span>
                </div>
                <input type="hidden" name="budget" id="budget">
                <label style="display: flex; align-items: center; gap: 0.5rem; margin-top: 1rem; cursor: pointer;">
                    <input type="checkbox" name="budgetNegotiable" value="true" style="width: 18px; height: 18px; cursor: pointer;">
                    <span style="color: #6F7272; font-size: 0.9375rem;">예산 협의 가능</span>
                </label>
                <p class="input-hint">최소 10만원 이상 입력해주세요</p>
            </div>

            <div class="question-card">
                <label class="question-label">
                    <i class="fa-solid fa-calendar-days"></i>
                    예상 진행 기간<span class="required-mark">*</span>
                </label>
                <div class="choice-grid" style="grid-template-columns: repeat(3, 1fr);">
                    <div class="choice-card" onclick="selectChoice(this)">
                        <input type="radio" name="estDuration" value="1개월 이하" required>
                        <div class="choice-icon">📅</div>
                        <div class="choice-title">1개월 이하</div>
                    </div>
                    <div class="choice-card" onclick="selectChoice(this)">
                        <input type="radio" name="estDuration" value="1~3개월" required>
                        <div class="choice-icon">📆</div>
                        <div class="choice-title">1~3개월</div>
                    </div>
                    <div class="choice-card" onclick="selectChoice(this)">
                        <input type="radio" name="estDuration" value="3~6개월" required>
                        <div class="choice-icon">🗓️</div>
                        <div class="choice-title">3~6개월</div>
                    </div>
                </div>
                <label style="display: flex; align-items: center; gap: 0.5rem; margin-top: 1rem; cursor: pointer;">
                    <input type="checkbox" name="durationNegotiable" value="true" style="width: 18px; height: 18px; cursor: pointer;">
                    <span style="color: #6F7272; font-size: 0.9375rem;">기간 조율 가능</span>
                </label>
            </div>

            <div class="question-card">
                <label class="question-label">
                    <i class="fa-solid fa-calendar-check"></i>
                    프로젝트 시작일 (선택)
                </label>
                <div class="choice-grid" style="grid-template-columns: repeat(2, 1fr);">
                    <div class="choice-card" onclick="selectChoice(this)">
                        <input type="radio" name="startType" value="ASAP">
                        <div class="choice-icon">⚡</div>
                        <div class="choice-title">계약 후 즉시</div>
                        <div class="choice-description">빠른 시작 가능</div>
                    </div>
                    <div class="choice-card" onclick="selectChoice(this)">
                        <input type="radio" name="startType" value="SPECIFIC">
                        <div class="choice-icon">📍</div>
                        <div class="choice-title">구체적 날짜</div>
                        <div class="choice-description">특정 날짜 지정</div>
                    </div>
                </div>
                <div id="specificDateInput" style="margin-top: 1rem; display: none;">
                    <input type="date" name="startDate" id="startDate" class="input-field">
                </div>
            </div>
        </div>

<!-- ═══════════════════════════════════════════════════════════════════════
     Step 4: 진행 방식
     ═══════════════════════════════════════════════════════════════════════ -->
        <div class="step-page" id="step4">
            <div class="step-header">
                <span class="step-number-badge">STEP 4</span>
                <h1 class="step-title">진행 방식을 선택해주세요</h1>
                <p class="step-description">
                    선호하는 소통 방식과 대금 지급 방식을 선택해주세요.
                </p>
            </div>

            <div class="question-card">
                <label class="question-label">
                    <i class="fa-solid fa-comments"></i>
                    선호하는 소통 방식 (선택)
                </label>
                <div class="choice-grid">
                    <div class="choice-card" onclick="selectChoice(this)">
                        <input type="radio" name="communicateMethod" value="ONLINE">
                        <div class="choice-icon">💻</div>
                        <div class="choice-title">온라인</div>
                        <div class="choice-description">화상회의, 메신저 등</div>
                    </div>
                    <div class="choice-card" onclick="selectChoice(this)">
                        <input type="radio" name="communicateMethod" value="OFFLINE">
                        <div class="choice-icon">🏢</div>
                        <div class="choice-title">오프라인</div>
                        <div class="choice-description">대면 미팅 선호</div>
                    </div>
                </div>
            </div>

            <div class="question-card">
                <label class="question-label">
                    <i class="fa-solid fa-credit-card"></i>
                    대금 지급 방식 (선택)
                </label>
                <div class="choice-grid">
                    <div class="choice-card" onclick="selectChoice(this)">
                        <input type="radio" name="paymentMethod" value="LUMP_SUM">
                        <div class="choice-icon">💰</div>
                        <div class="choice-title">일괄 지급</div>
                        <div class="choice-description">프로젝트 완료 후 전액</div>
                    </div>
                    <div class="choice-card" onclick="selectChoice(this)">
                        <input type="radio" name="paymentMethod" value="INSTALLMENT">
                        <div class="choice-icon">📊</div>
                        <div class="choice-title">분할 지급</div>
                        <div class="choice-description">단계별 지급</div>
                    </div>
                </div>
            </div>

            <!-- 무상 수정 횟수 -->
            <div class="question-card">
                <label class="question-label">
                    <i class="fa-solid fa-rotate-left"></i>
                    무상 수정 횟수 (선택)
                </label>
                <input type="number" name="maxRevisionCount" id="maxRevisionCount" 
                       class="input-field" placeholder="예) 2" min="0" max="3" value="1">
                <p class="input-hint" style="line-height: 1.6;">
                    <i class="fa-solid fa-circle-info" style="color: #1F7A8C; margin-right: 4px;"></i>
                    <strong>무상 수정 횟수란?</strong><br>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;프로젝트가 <strong>완료된 후</strong> 추가 비용 없이 수정을 요청할 수 있는 횟수입니다.<br>
                    <br>
                    <i class="fa-solid fa-lightbulb" style="color: #FFA726; margin-right: 4px;"></i>
                    <strong>예시:</strong><br>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• 웹사이트 디자인 색상 변경<br>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• 텍스트 문구 수정<br>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• 이미지 교체<br>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• 간단한 UI 조정<br>
                    <br>
                    <i class="fa-solid fa-triangle-exclamation" style="color: #FF6B6B; margin-right: 4px;"></i>
                    <strong>주의:</strong> 새로운 기능 추가나 대규모 수정은 포함되지 않으며, 별도 협의가 필요합니다.<br>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(최대 3회, 기본값: 1회)
                </p>
            </div>
        </div>

<!-- ═══════════════════════════════════════════════════════════════════════
     Step 5: 미리보기
     ═══════════════════════════════════════════════════════════════════════ -->
        <div class="step-page" id="step5">
            <div class="step-header">
                <span class="step-number-badge">STEP 5</span>
                <h1 class="step-title">프로젝트 공지 미리보기</h1>
                <p class="step-description">
                    입력하신 내용을 확인해주세요. 수정이 필요한 경우 해당 단계로 이동할 수 있습니다.
                </p>
            </div>

            <div class="preview-container">
                <div class="preview-header">
                    <span class="preview-badge">프로젝트 공지</span>
                    <h2 class="preview-title" id="previewTitle"></h2>
                </div>

                <div class="preview-section">
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <h3 class="preview-section-title">
                            <i class="fa-solid fa-file-lines"></i>
                            프로젝트 설명
                        </h3>
                        <button type="button" class="edit-section-btn" onclick="goToStep(1)">
                            <i class="fa-solid fa-pen"></i> 수정
                        </button>
                    </div>
                    <div class="preview-content" id="previewDescription"></div>
                </div>

                <div class="preview-section">
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <h3 class="preview-section-title">
                            <i class="fa-solid fa-won-sign"></i>
                            예산 및 일정
                        </h3>
                        <button type="button" class="edit-section-btn" onclick="goToStep(3)">
                            <i class="fa-solid fa-pen"></i> 수정
                        </button>
                    </div>
                    <div class="preview-meta-grid">
                        <div class="preview-meta-item">
                            <div class="preview-meta-label">예산</div>
                            <div class="preview-meta-value" id="previewBudget"></div>
                        </div>
                        <div class="preview-meta-item">
                            <div class="preview-meta-label">진행 기간</div>
                            <div class="preview-meta-value" id="previewDuration"></div>
                        </div>
                        <div class="preview-meta-item">
                            <div class="preview-meta-label">시작일</div>
                            <div class="preview-meta-value" id="previewStartDate"></div>
                        </div>
                    </div>
                </div>

                <div class="preview-section">
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <h3 class="preview-section-title">
                            <i class="fa-solid fa-code"></i>
                            필요 기술 스택
                        </h3>
                        <button type="button" class="edit-section-btn" onclick="goToStep(2)">
                            <i class="fa-solid fa-pen"></i> 수정
                        </button>
                    </div>
                    <div class="preview-content" id="previewStacks"></div>
                </div>

                <div class="preview-section">
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <h3 class="preview-section-title">
                            <i class="fa-solid fa-handshake"></i>
                            진행 방식
                        </h3>
                        <button type="button" class="edit-section-btn" onclick="goToStep(4)">
                            <i class="fa-solid fa-pen"></i> 수정
                        </button>
                    </div>
                    <div class="preview-content">
                        <p><strong>소통 방식:</strong> <span id="previewComm"></span></p>
                        <p><strong>지급 방식:</strong> <span id="previewPay"></span></p>
                        <p><strong>수정 횟수:</strong> <span id="previewRevision"></span></p>
                    </div>
                </div>
            </div>

            <input type="hidden" name="isPublic" value="true">
            <input type="hidden" name="projectStatus" value="READY">
        </div>
    </div>
</div>

<!-- Navigation Buttons (하단 고정) -->
<div class="nav-buttons">
    <div class="nav-buttons-inner">
        <button type="button" class="btn btn-back" onclick="prevStep()" id="btnPrev" style="display:none;">
            <i class="fa-solid fa-arrow-left"></i>
            이전
        </button>
        <div style="flex: 1;"></div>
        <button type="button" class="btn btn-next" onclick="nextStep()" id="btnNext">
            다음
            <i class="fa-solid fa-arrow-right"></i>
        </button>
        <button type="submit" class="btn btn-submit" id="btnSubmit" style="display:none;">
            <i class="fa-solid fa-check"></i>
            등록 완료
        </button>
    </div>
</div>

</form>

<!-- 기술 스택 모달 -->
<%@ include file="/WEB-INF/views/common/tech-stack-modal.jsp" %>

<script src="${pageContext.request.contextPath}/resources/js/tech-stack-modal.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/project/create.js"></script>
</body>
</html>
