<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
    <head>
    <title>계약서 작성</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/contract/contract-form.css"/>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
    <style>
        /* 인라인 스타일로 강제 적용 */
        body {
            background: #F1F6EE !important;
        }
        
        #projectInfo.summary-box,
        #freelancerInfo.summary-box,
        .page-wrapper .summary-box:not(.contract-preview-box) {
            background-color: #f8f9fa !important;
            background: #f8f9fa !important;
            border: 1px solid #e9ecef !important;
            border-radius: 12px !important;
            padding: 20px !important;
            margin-top: 16px !important;
        }
        
        .choice-card.selected {
            border-color: #1F7A8C !important;
            background-color: rgba(31, 122, 140, 0.05) !important;
            background: rgba(31, 122, 140, 0.05) !important;
        }
        
        .choice-card.selected::after {
            background: #1F7A8C !important;
            border-color: #1F7A8C !important;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 16 16'%3E%3Cpath fill='white' d='M13.854 3.646a.5.5 0 0 1 0 .708l-7 7a.5.5 0 0 1-.708 0l-3.5-3.5a.5.5 0 1 1 .708-.708L6.5 10.293l6.646-6.647a.5.5 0 0 1 .708 0z'/%3E%3C/svg%3E") !important;
            background-size: 12px 12px !important;
            background-position: center !important;
            background-repeat: no-repeat !important;
        }
        
        .pdf-upload-area {
            border: 2px dashed #d0d0d0 !important;
            border-radius: 12px !important;
            padding: 60px 40px !important;
            text-align: center !important;
            background: white !important;
            margin-top: 16px !important;
            min-height: 200px !important;
            display: flex !important;
            flex-direction: column !important;
            align-items: center !important;
            justify-content: center !important;
        }
    </style>
</head>

<body>
<c:set var="activeMenu" value="contracts" scope="request"/>
<style>
    /* 헤더 네비게이션 */
    .header {
        background: white;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        position: sticky;
        top: 0;
        z-index: 100;
    }

    .header-inner {
        max-width: 1400px;
        margin: 0 auto;
        padding: 0 2rem;
        display: flex;
        align-items: center;
        gap: 2rem;
    }

    .logo {
        font-size: 1.25rem;
        font-weight: bold;
        color: #1F7A8C;
        text-decoration: none;
        padding: 1rem 0;
        display: flex;
        align-items: center;
        gap: 0.5rem;
    }

    .logo-icon {
        width: 28px;
        height: 28px;
        background: #1F7A8C;
        border-radius: 6px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-size: 0.9rem;
        font-weight: bold;
    }

    .nav-menu {
        display: flex;
        gap: 0.5rem;
        flex: 1;
    }

    .nav-link {
        color: #2B2B2B;
        text-decoration: none;
        padding: 1rem 1.25rem;
        border-bottom: 3px solid transparent;
        transition: all 0.2s;
        font-weight: 500;
        font-size: 0.95rem;
    }

    .nav-link:hover {
        color: #1F7A8C;
    }

    .nav-link.active {
        color: #1F7A8C;
        border-bottom-color: #1F7A8C;
    }

    .nav-icons {
        display: flex;
        align-items: center;
        gap: 1rem;
    }

    .icon-btn {
        width: 40px;
        height: 40px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: #F1F6EE;
        border: none;
        border-radius: 50%;
        cursor: pointer;
        transition: all 0.2s;
        position: relative;
    }

    .icon-btn:hover {
        background: #A9D9DB;
    }

    .icon-btn .badge {
        position: absolute;
        top: 5px;
        right: 5px;
        width: 8px;
        height: 8px;
        background: #ef4444;
        border-radius: 50%;
    }

    .profile-dropdown {
        position: relative;
    }

    .profile-btn {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        padding: 0.5rem 1rem;
        background: #F1F6EE;
        border: none;
        border-radius: 20px;
        cursor: pointer;
        font-weight: 500;
        transition: all 0.2s;
    }

    .profile-btn:hover {
        background: #A9D9DB;
    }

    .dropdown-menu {
        display: none;
        position: absolute;
        top: 100%;
        right: 0;
        margin-top: 0.5rem;
        background: white;
        border-radius: 10px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        min-width: 180px;
        overflow: hidden;
    }

    .dropdown-menu.show {
        display: block;
    }

    .dropdown-item {
        display: block;
        padding: 0.875rem 1.25rem;
        color: #2B2B2B;
        text-decoration: none;
        transition: background 0.2s;
    }

    .dropdown-item:hover {
        background: #F1F6EE;
    }

    .dropdown-divider {
        height: 1px;
        background: #e2e8f0;
        margin: 0.5rem 0;
    }
</style>

<!-- 헤더 네비게이션 -->
<header class="header">
    <div class="header-inner">
        <a href="${pageContext.request.contextPath}/" class="logo">
            <div class="logo-icon">R</div>
            <span>Ratel-Ocean</span>
        </a>

        <nav class="nav-menu">
            <a href="${pageContext.request.contextPath}/client/dashboard" class="nav-link ${requestScope.activeMenu eq 'dashboard' ? 'active' : ''}">대시보드</a>
            <a href="${pageContext.request.contextPath}/project/create" class="nav-link ${requestScope.activeMenu eq 'project-create' ? 'active' : ''}">프로젝트 등록</a>
            <a href="${pageContext.request.contextPath}/client/manage" class="nav-link ${requestScope.activeMenu eq 'manage' ? 'active' : ''}">내 프로젝트</a>
            <a href="${pageContext.request.contextPath}/client/applicants" class="nav-link ${requestScope.activeMenu eq 'applicants' ? 'active' : ''}">지원자 관리</a>
            <a href="${pageContext.request.contextPath}/client/contracts" class="nav-link ${requestScope.activeMenu eq 'contracts' ? 'active' : ''}">계약 관리</a>
        </nav>

        <div class="nav-icons">
            <!-- 알림 -->
            <button class="icon-btn" title="알림">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
                    <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
                </svg>
                <span class="badge"></span>
            </button>

            <!-- 채팅 -->
            <button class="icon-btn" title="채팅">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
                </svg>
            </button>

            <!-- 프로필 드롭다운 -->
            <div class="profile-dropdown">
                <button class="profile-btn" onclick="toggleDropdown()">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                        <circle cx="12" cy="7" r="4"></circle>
                    </svg>
                    <span>${sessionScope.loginId}</span>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                        <polyline points="6 9 12 15 18 9"></polyline>
                    </svg>
                </button>

                <div id="dropdownMenu" class="dropdown-menu">
                    <a href="${pageContext.request.contextPath}/client/mypage" class="dropdown-item">마이페이지</a>
                    <a href="${pageContext.request.contextPath}/client/company" class="dropdown-item">회사 정보</a>
                    <div class="dropdown-divider"></div>
                    <a href="#" onclick="logout(event)" class="dropdown-item">로그아웃</a>
                </div>
            </div>
        </div>
    </div>
</header>

<script>
// 드롭다운 토글
function toggleDropdown() {
    const dropdown = document.getElementById('dropdownMenu');
    if (dropdown) {
        dropdown.classList.toggle('show');
    }
}

// 외부 클릭 시 드롭다운 닫기
document.addEventListener('click', function(e) {
    const profileDropdown = document.querySelector('.profile-dropdown');
    if (profileDropdown && !profileDropdown.contains(e.target)) {
        const dropdown = document.getElementById('dropdownMenu');
        if (dropdown) {
            dropdown.classList.remove('show');
        }
    }
});

// 로그아웃
async function logout(e) {
    e.preventDefault();

    try {
        const response = await fetch('${pageContext.request.contextPath}/logout', {
            method: 'POST'
        });

        if (response.ok) {
            window.location.href = '${pageContext.request.contextPath}/login';
        }
    } catch (error) {
        console.error('로그아웃 오류:', error);
        alert('로그아웃에 실패했습니다.');
    }
}
</script>

<div class="page-wrapper">
    <!-- STEP 1: 프로젝트 선택 -->
    <section class="card step-card visible" id="stepProject">
        <h2 class="section-title">1. 프로젝트 선택</h2>
        <form id="projectForm" method="get">
            <label for="projectSelect">프로젝트 선택</label>
            <select id="projectSelect" name="projectId" class="select-box">
                <option value="">-- 선택 --</option>
                <c:forEach var="p" items="${projectList}">
                    <c:set var="budgetStr" value="" />
                    <c:if test="${p.budget != null}">
                        <c:choose>
                            <c:when test="${p.budget.getClass().simpleName == 'String'}">
                                <c:set var="budgetStr" value="${p.budget}" />
                            </c:when>
                            <c:otherwise>
                                <fmt:formatNumber value="${p.budget}" pattern="#,###" var="budgetStr" />
                            </c:otherwise>
                        </c:choose>
                    </c:if>
                    <option value="${p.projectId}" 
                            data-title="${fn:escapeXml(p.title)}" 
                            data-budget="${budgetStr}" 
                            data-start="${p.startDate != null ? fn:escapeXml(String.valueOf(p.startDate)) : ''}" 
                            data-deadline="${p.deadlineDate != null ? fn:escapeXml(String.valueOf(p.deadlineDate)) : ''}">${p.title}</option>
                </c:forEach>
            </select>
        </form>
        <div id="projectInfo" class="summary-box hidden"></div>
    </section>

    <!-- STEP 2: 프리랜서 선택 (동적으로 표시) -->
    <section class="card step-card" id="stepFreelancer">
        <h2 class="section-title">2. 프리랜서 선택</h2>
        <form id="freelancerForm" method="get">
            <label for="freelancerSelect">프리랜서 선택</label>
            <select id="freelancerSelect" name="freelancerId" class="select-box">
                <option value="">-- 선택 --</option>
                <c:forEach var="f" items="${freelancerList}">
                    <option value="${f.id}" data-name="${fn:escapeXml(f.name)}" data-email="${fn:escapeXml(f.email)}">${f.name}</option>
                </c:forEach>
            </select>
        </form>
        <div id="freelancerInfo" class="summary-box hidden"></div>
    </section>

    <!-- STEP 3: PDF 여부 (동적으로 표시) -->
    <section class="card step-card" id="stepPdfQuestion">
        <h2 class="section-title">3. 계약서가 있습니까?</h2>
        <div class="choice-group">
            <label class="choice-card">
                <input type="radio" name="hasPdf" value="yes">
                <div class="choice-card-title">PDF 있음</div>
                <div class="choice-card-desc">기존 계약서를 업로드합니다</div>
            </label>
            <label class="choice-card">
                <input type="radio" name="hasPdf" value="no">
                <div class="choice-card-title">직접 작성</div>
                <div class="choice-card-desc">계약서를 새로 작성합니다</div>
            </label>
        </div>
        <div class="hint">※ 선택에 따라 아래 입력 단계가 자동으로 열립니다.</div>
    </section>

    <!-- STEP 4-A: PDF 업로드 (동적으로 표시) -->
    <section class="card step-card" id="stepPdfUpload">
        <h2 class="section-title">4. 계약서 PDF 업로드</h2>
        <form id="pdfUploadForm" enctype="multipart/form-data" onsubmit="return false;">
            <input type="file" name="contractPdf" accept="application/pdf" id="pdfFileInput" class="hidden" />
            <input type="hidden" name="projectId" />
            <input type="hidden" name="freelancerId" />
            <input type="hidden" id="uploadedPdfFileName" />
            <div class="pdf-upload-area">
                <button type="button" class="btn-primary pdf-upload-btn" id="pdfUploadBtn">PDF 파일 선택 및 업로드</button>
                <div class="pdf-upload-hint">최대 파일 용량: 20MB (.pdf 만 가능)</div>
                <div id="pdfUploadStatus" class="pdf-upload-status"></div>
            </div>
        </form>
    </section>

    <!-- STEP 4-B: 직접 작성 (동적으로 표시) -->
    <section class="card step-card" id="stepDirectForm">
        <h2 class="section-title">4. 계약서 직접 작성</h2>
        <div class="contract-form-layout">
            <!-- 입력 영역 -->
            <div>
                <div id="clauseEditor"></div>
                <div class="contract-hint-box">
                    <strong>💡 안내</strong><br/>
                    <span>미리보기의 조항을 클릭하면 해당 조항을 다시 수정할 수 있습니다.</span>
                </div>
            </div>
            <!-- 미리보기 영역 -->
            <div>
                <div class="summary-box contract-preview-box">
                    <div class="contract-preview-header">
                        <b>📄 계약서 미리보기</b>
                        <span id="progressIndicator" class="progress-badge">0/6</span>
                    </div>
                    <div id="contractDocument"></div>
                </div>
            </div>
        </div>
        <!-- 최종 완성 버튼 영역 (직접작성용) -->
        <div class="action-area" id="directFormActionArea">
            <button type="button" class="btn-primary hidden" id="finalSubmitBtn" onclick="handleFinalSubmit(event); return false;" title="필수 조항을 모두 입력해야 완성할 수 있습니다">계약 요청하기</button>
        </div>
    </section>

    <!-- 최종 완성 버튼 영역 (PDF용) -->
    <section class="card step-card" id="stepFinalAction">
        <div class="action-area">
            <button type="button" class="btn-primary hidden" id="pdfFinalSubmitBtn" onclick="handlePdfFinalSubmit(event); return false;" title="PDF를 업로드해야 완성할 수 있습니다">계약 요청하기</button>
        </div>
    </section>

</div>

<script>
// 전역 변수 및 함수들 (jQuery ready 전에 선언)
// 직접작성: Clause Wizard 데이터
const clauses = [
    { 
        key:'contractPurpose',   
        title:'제1조 (계약 목적)',     
        required:true,  
        placeholder:'예: 웹 서비스 개발 및 운영',
        description:'이 계약의 핵심 목적을 간단명료하게 작성해주세요. 예: "웹 서비스 개발 및 운영", "모바일 앱 개발" 등'
    },
    { 
        key:'workScope',         
        title:'제2조 (업무 범위)',     
        required:true,  
        placeholder:'예: 프론트엔드 개발, 백엔드 API 구축, 데이터베이스 설계',
        description:'수주자가 실제로 수행할 구체적인 업무를 나열해주세요. 여러 항목은 줄바꿈으로 구분할 수 있습니다.'
    },
    { 
        key:'deliverables',      
        title:'제3조 (결과물 정의)',   
        required:true,  
        placeholder:'예: 완성된 웹 애플리케이션, 소스코드, API 문서, 배포 가이드',
        description:'프로젝트 완료 시 최종적으로 제공될 산출물을 명시해주세요. 검수 기준도 함께 작성하면 좋습니다.'
    },
    { 
        key:'paymentCondition',  
        title:'제4조 (대금 지급)',     
        required:true,  
        placeholder:'예: 계약금 30% (계약 체결 시), 중도금 40% (중간 완료 시), 잔금 30% (최종 납품 시)',
        description:'대금 지급 방식과 시점을 명확히 작성해주세요. 계약금, 중도금, 잔금 비율과 지급 조건을 구체적으로 기재하세요.'
    },
    { 
        key:'scheduleCondition', 
        title:'제5조 (일정)',          
        required:true,  
        placeholder:'예: 착수일 2026-01-20, 중간점검 2026-02-15, 최종 납품 2026-03-21',
        description:'프로젝트 일정과 주요 마일스톤을 작성해주세요. 착수일, 중간점검일, 최종 납품일 등을 포함하세요.'
    },
    { 
        key:'specialTerms',      
        title:'제6조 (기타 특약)',     
        required:false, 
        placeholder:'예: 지적재산권은 발주자에게 귀속, 유지보수 기간 3개월',
        description:'추가로 합의한 특별 조건이 있다면 작성해주세요. 없으면 비워두셔도 됩니다.'
    }
];

// 상태
let state = { idx: 0, data: {} };

function handlePdfFinalSubmit(e) {
    console.log('[DEBUG] handlePdfFinalSubmit START');
    
    if (e) {
        e.preventDefault();
        e.stopPropagation();
    }

    const projectId = document.getElementById('projectSelect') ? document.getElementById('projectSelect').value : '';
    const freelancerId = document.getElementById('freelancerSelect') ? document.getElementById('freelancerSelect').value : '';
    const fileNameEl = document.getElementById('uploadedPdfFileName');
    const filePath = fileNameEl ? fileNameEl.value : ''; // filePath는 전체 경로 (contracts/{clientId}/{projectId}/{fileName})
    
    console.log('[DEBUG] PDF 업로드 정보:', { projectId, freelancerId, filePath });
    
    if (!projectId || !freelancerId || !filePath) {
        alert('필수 정보가 누락되었습니다.');
        return false;
    }

    // 검증 통과 시 바로 모달 표시
    console.log('[DEBUG] Calling showAiAnalysisModal with filePath:', filePath);
    showAiAnalysisModal('PDF', projectId, freelancerId, filePath);
    return false;
}

function handleFinalSubmit(e) {
    console.log('[DEBUG] handleFinalSubmit START');
    
    if (e) {
        e.preventDefault();
        e.stopPropagation();
    }

    const projectId = document.getElementById('projectSelect') ? document.getElementById('projectSelect').value : '';
    const freelancerId = document.getElementById('freelancerSelect') ? document.getElementById('freelancerSelect').value : '';
    
    if (!projectId || !freelancerId) {
        alert('프로젝트와 프리랜서를 선택해주세요.');
        return false;
    }

    // 필수 조항 검증
    let ok = true;
    const missingClauses = [];
    clauses.forEach(c => {
        if (c.required && !(state.data[c.key] || '').trim()) {
            ok = false;
            missingClauses.push(c.title);
        }
    });
    if (!ok) {
        alert('다음 필수 조항을 모두 입력해주세요:\n- ' + missingClauses.join('\n- '));
        return false;
    }

    // 검증 통과 시 바로 모달 표시
    console.log('[DEBUG] Calling showAiAnalysisModal');
    showAiAnalysisModal('FORM', projectId, freelancerId, null);
    return false;
}

function showAiAnalysisModal(inputType, projectId, freelancerId, fileName) {
    console.log('[DEBUG] showAiAnalysisModal called', { inputType, projectId, freelancerId, fileName });
    
    const modalEl = document.getElementById('aiAnalysisModal');
    if (!modalEl) {
        alert('모달 요소를 찾을 수 없습니다!');
        console.error('[ERROR] Modal element not found!');
        return;
    }
    
    // 모달 즉시 표시
    modalEl.classList.add('show');
    
    // 모달 내부 확인 버튼 이벤트 설정
    const confirmBtn = document.getElementById('confirmAiAnalysisBtn');
    if (!confirmBtn) {
        alert('확인 버튼을 찾을 수 없습니다!');
        console.error('[ERROR] Confirm button not found!');
        return;
    }
    
    // 기존 이벤트 리스너 제거 후 새로 등록
    const newBtn = confirmBtn.cloneNode(true);
    confirmBtn.parentNode.replaceChild(newBtn, confirmBtn);
    
    newBtn.onclick = function(e) {
        e.preventDefault();
        e.stopPropagation();
        console.log('[DEBUG] confirmAiAnalysisBtn clicked');
        submitToContractCheck(inputType, projectId, freelancerId, fileName);
        return false;
    };
    
    console.log('[DEBUG] Modal displayed');
}

function submitToContractCheck(inputType, projectId, freelancerId, fileName) {
    console.log('[DEBUG] submitToContractCheck called', { inputType, projectId, freelancerId, fileName });
    
    const modalEl = document.getElementById('aiAnalysisModal');
    if (modalEl) {
        modalEl.classList.remove('show');
    }
    
    const loadingEl = document.getElementById('loadingOverlay');
    if (loadingEl) {
        loadingEl.classList.add('show');
    }
    
    const loadingMessages = [
        '프롬프트 생성 중...',
        '프로젝트 정보 분석 중...',
        'DeepSeek AI 호출 중...',
        '계약서 초안 생성 중...',
        '최종 검토 중...'
    ];
    let msgIndex = 0;
    const statusInterval = setInterval(function() {
        const statusEl = document.getElementById('loadingStatus');
        if (statusEl && msgIndex < loadingMessages.length) {
            statusEl.textContent = loadingMessages[msgIndex];
            msgIndex++;
        } else {
            clearInterval(statusInterval);
        }
    }, 1500);
    
    // form 생성 및 제출
    const contextPath = window.pageContextPath || '';
    const form = document.createElement('form');
    form.method = 'post';
    form.action = contextPath + '/client/contract/contractCheck';
    
    const inputs = [
        { name: 'contractInputType', value: inputType },
        { name: 'projectId', value: projectId },
        { name: 'freelancerId', value: freelancerId }
    ];
    
    if (inputType === 'PDF') {
        // fileName은 실제로는 전체 경로 (contracts/{clientId}/{projectId}/{fileName})
        inputs.push({ name: 'uploadedPdfFileName', value: fileName });
        console.log('[DEBUG] PDF 파일 경로 전달:', fileName);
    } else {
        // 직접 작성: 원본 입력값 전송
        clauses.forEach(c => {
            const v = state.data[c.key] || '';
            inputs.push({ name: c.key, value: v });
        });
    }
    
    inputs.forEach(input => {
        const hidden = document.createElement('input');
        hidden.type = 'hidden';
        hidden.name = input.name;
        hidden.value = input.value;
        form.appendChild(hidden);
    });
    
    document.body.appendChild(form);
    
    setTimeout(function() {
        console.log('[DEBUG] Submitting form to contractCheck');
        form.submit();
    }, 500);
}
</script>

<!-- AI 분석 안내 모달 -->
<div id="aiAnalysisModal" class="modal-overlay">
    <div class="modal-content">
        <div class="modal-icon">🤖</div>
        <h2 class="modal-title">AI 계약서 분석</h2>
        <p class="modal-description">
            입력하신 정보를 바탕으로<br/>
            <strong class="modal-ai-name">DeepSeek AI</strong>가 계약서를 분석하고<br/>
            <span class="modal-highlight">법률 문서 형식의 계약서 초안</span>을 생성합니다.
        </p>
        <div class="modal-status-box">
            <div class="modal-status-content">
                <div class="pulse-dots">
                    <span class="pulse-dot"></span>
                    <span class="pulse-dot"></span>
                    <span class="pulse-dot"></span>
                </div>
                <span class="modal-status-text">AI 분석 준비 완료</span>
            </div>
        </div>
        <button type="button" class="modal-btn" id="confirmAiAnalysisBtn">계약서 완성하기</button>
    </div>
</div>

<!-- 로딩 오버레이 -->
<div id="loadingOverlay" class="loading-overlay">
    <div class="loading-content">
        <div class="loading-spinner"></div>
        <h3 class="loading-title">AI 계약서 생성 중</h3>
        <p class="loading-description">
            DeepSeek AI가 입력하신 정보를 분석하고 있습니다.<br/>
            <span class="loading-highlight">법률 문서 형식의 계약서 초안</span>을 생성 중입니다.
        </p>
        <div class="loading-status">
            <span id="loadingStatus">프롬프트 생성 중...</span>
        </div>
    </div>
</div>

<script>
// 전역 변수 및 함수들 (jQuery ready 전에 선언)
let ctx = '${pageContext.request.contextPath}';
window.pageContextPath = ctx;

$(function () {
    // ctx 재확인
    if (!ctx) {
        ctx = window.pageContextPath || '';
    }
    console.log('[DEBUG] 페이지 로드 완료, contextPath:', ctx);

    // 양쪽 영역 높이 동기화 함수
    function syncColumnHeights() {
        const $leftCol = $('.contract-form-layout > div:first-child');
        const $previewBox = $('.contract-preview-box');
        if ($leftCol.length && $previewBox.length) {
            const leftHeight = $leftCol[0].offsetHeight;
            if (leftHeight > 0) {
                $previewBox.css('min-height', Math.max(leftHeight, 400) + 'px');
            }
        }
    }

    function normalizeDisplayValue(v) {
        if (v == null) return '';
        const s = String(v).trim();
        if (!s) return '';
        // JSP/EL에서 null이 "false"로 찍히는 케이스 방어
        if (s === 'false' || s === 'null' || s === 'undefined') return '';
        return s;
    }

    // 자동 스크롤 함수: 새로 표시된 카드로 부드럽게 스크롤
    function scrollToCard($card) {
        if (!$card || !$card.length) return;
        setTimeout(function() {
            const offset = $card.offset();
            if (offset) {
                $('html, body').animate({
                    scrollTop: offset.top - 40
                }, 400);
            }
        }, 100);
    }

    function updatePreviewIfNeeded() {
        if ($('#stepDirectForm').hasClass('visible')) {
            renderPreview();
        }
    }

    function updateProjectInfoBox() {
        console.log('[DEBUG] updateProjectInfoBox 호출됨');
        const $sel = $('#projectSelect');
        const $opt = $sel.find('option:selected');
        const hasValue = !!$sel.val();
        
        console.log('[DEBUG] 프로젝트 선택 상태:', {
            hasValue: hasValue,
            selectedText: $opt.text(),
            selectedValue: $sel.val()
        });

        if (!hasValue) {
            console.log('[DEBUG] 프로젝트가 선택되지 않음 - 정보 숨김');
            $('#projectInfo').addClass('hidden').empty();
            updatePreviewIfNeeded();
            return;
        }

        const title = normalizeDisplayValue($opt.text());
        const budget = normalizeDisplayValue($opt.attr('data-budget')) || '';
        const start = normalizeDisplayValue($opt.attr('data-start')) || '';
        const deadline = normalizeDisplayValue($opt.attr('data-deadline')) || '';
        
        console.log('[DEBUG] 프로젝트 정보 추출:', {
            title: title,
            budget: budget,
            start: start,
            deadline: deadline
        });
        
        if (!title) {
            console.log('[DEBUG] 제목이 없음 - 정보 숨김');
            $('#projectInfo').addClass('hidden').empty();
            return;
        }
        
        let infoHtml = '<b>프로젝트:</b> ' + title;
        if (budget && budget.trim() !== '') {
            infoHtml += '<br/><b>예산:</b> ' + budget;
        }
        if (start && start.trim() !== '' && deadline && deadline.trim() !== '') {
            infoHtml += '<br/><b>기간:</b> ' + start + ' ~ ' + deadline;
        } else if (start && start.trim() !== '') {
            infoHtml += '<br/><b>시작일:</b> ' + start;
        } else if (deadline && deadline.trim() !== '') {
            infoHtml += '<br/><b>마감일:</b> ' + deadline;
        }
        
        console.log('[DEBUG] 프로젝트 정보 HTML:', infoHtml);
        
        const $projectInfo = $('#projectInfo');
        console.log('[DEBUG] projectInfo 요소:', $projectInfo.length, $projectInfo);
        
        if ($projectInfo.length === 0) {
            console.error('[ERROR] #projectInfo 요소를 찾을 수 없습니다!');
            return;
        }
        
        $projectInfo
            .html(infoHtml)
            .removeClass('hidden')
            .css('display', ''); // display 속성도 명시적으로 제거
        
        console.log('[DEBUG] 프로젝트 정보 표시 완료, hidden 클래스 제거됨');
        console.log('[DEBUG] projectInfo 현재 상태:', {
            hasHidden: $projectInfo.hasClass('hidden'),
            display: $projectInfo.css('display'),
            html: $projectInfo.html()
        });
        
        updatePreviewIfNeeded();
    }

    function resetFreelancerSelect(disabled, placeholderText) {
        const text = placeholderText || '-- 선택 --';
        $('#freelancerSelect')
            .empty()
            .append($('<option>', { value: '', text }))
            .prop('disabled', !!disabled)
            .val('');
        $('#freelancerInfo').addClass('hidden').empty();
        $('input[name="hasPdf"]').prop('checked', false);
        $('#stepPdfQuestion, #stepPdfUpload, #stepDirectForm, #stepFinalAction').removeClass('visible');
    }

    function loadFreelancersByProject(projectId) {
        if (!projectId) {
            resetFreelancerSelect(true, '-- 선택 --');
            return;
        }
        
        resetFreelancerSelect(true, '불러오는 중...');
        $.ajax({
            url: ctx + '/client/contract/freelancers',
            type: 'GET',
            dataType: 'json',
            data: { projectId: projectId },
            success: function(list) {
                console.log('[DEBUG] 프리랜서 목록 로드 성공:', list);
                resetFreelancerSelect(false, '-- 선택 --');
                if (!Array.isArray(list) || list.length === 0) {
                    resetFreelancerSelect(true, '지원자 없음');
                    console.warn('[WARN] 프리랜서 목록이 비어있습니다.');
                    return;
                }
                list.forEach(function(f) {
                    const name = normalizeDisplayValue(f.name) || ('ID ' + f.id);
                    const email = normalizeDisplayValue(f.email) || '';
                    $('#freelancerSelect').append(
                        $('<option>', {
                            value: f.id,
                            text: name
                        })
                            .attr('data-name', name)
                            .attr('data-email', email)
                    );
                });
                $('#freelancerSelect').prop('disabled', false);
                console.log('[DEBUG] 프리랜서 목록 추가 완료:', list.length + '명');
            },
            error: function(xhr, status, error) {
                resetFreelancerSelect(true, '불러오기 실패');
                console.error('[ERROR] 프리랜서 목록 로드 실패:', {
                    status: status,
                    error: error,
                    responseText: xhr.responseText,
                    statusCode: xhr.status
                });
                alert('프리랜서 목록을 불러오는 중 오류가 발생했습니다.\n상세 정보는 콘솔을 확인하세요.');
            }
        });
    }

    // STEP 1: 프로젝트 선택
    function hideStepCardsFrom(idx) {
        $('.step-card').each(function(i) {
            if (i > idx) $(this).removeClass('visible');
        });
    }
    
    // 프로젝트 선택 이벤트 바인딩 (명시적으로)
    console.log('[DEBUG] 프로젝트 선택 이벤트 바인딩 시작');
    const $projectSelect = $('#projectSelect');
    console.log('[DEBUG] projectSelect 요소:', $projectSelect.length);
    
    if ($projectSelect.length === 0) {
        console.error('[ERROR] #projectSelect 요소를 찾을 수 없습니다!');
    } else {
        $projectSelect.on('change', function() {
        console.log('[DEBUG] 프로젝트 선택 이벤트 발생:', $(this).val());
        const projectId = $(this).val();
        const $opt = $(this).find('option:selected');
        console.log('[DEBUG] 선택된 옵션:', {
            text: $opt.text(),
            budget: $opt.attr('data-budget'),
            start: $opt.attr('data-start'),
            deadline: $opt.attr('data-deadline')
        });
        
        updateProjectInfoBox();
        
        if (projectId) {
            console.log('[DEBUG] 프로젝트 ID:', projectId, '- 프리랜서 목록 로드 시작');
            $('#stepFreelancer').addClass('visible');
            scrollToCard($('#stepFreelancer'));
            resetFreelancerSelect(true, '불러오는 중...');
            loadFreelancersByProject(projectId);
            $('#stepPdfQuestion, #stepPdfUpload, #stepDirectForm, #stepFinalAction').removeClass('visible');
        } else {
            resetFreelancerSelect(true, '-- 선택 --');
            $('#stepFreelancer').removeClass('visible');
            $('#stepPdfQuestion, #stepPdfUpload, #stepDirectForm, #stepFinalAction').removeClass('visible');
        }
        $('input[name="hasPdf"]').prop('checked', false);
        });
        console.log('[DEBUG] 프로젝트 선택 이벤트 바인딩 완료');
    }

    // STEP 2: 프리랜서 선택
    $('#freelancerSelect').on('change', function() {
        const freelancerId = $(this).val();
        if (freelancerId) {
            const $opt = $(this).find('option:selected');
            const name = normalizeDisplayValue($opt.attr('data-name'));
            const email = normalizeDisplayValue($opt.attr('data-email'));
            
            if (!name && !email) {
                $('#freelancerInfo').addClass('hidden').empty();
            } else {
                $('#freelancerInfo')
                    .html('<b>프리랜서:</b> ' + name + '<br/><b>이메일:</b> ' + email)
                    .removeClass('hidden');
            }
            
            $('#stepPdfQuestion').addClass('visible');
            scrollToCard($('#stepPdfQuestion'));
            $('#stepPdfUpload, #stepDirectForm, #stepFinalAction').removeClass('visible');
        } else {
            $('#freelancerInfo').addClass('hidden').empty();
            $('#stepPdfQuestion, #stepPdfUpload, #stepDirectForm, #stepFinalAction').removeClass('visible');
        }
        updatePreviewIfNeeded();
        $('input[name="hasPdf"]').prop('checked', false);
    });

    // STEP 3: PDF 여부
    $('input[name="hasPdf"]').on('change', function() {
        // 선택된 카드에 클래스 추가/제거
        $('.choice-card').removeClass('selected');
        $(this).closest('.choice-card').addClass('selected');
        
        $('#stepPdfUpload, #stepDirectForm, #stepFinalAction').removeClass('visible');
        $('#pdfFinalSubmitBtn, #finalSubmitBtn').addClass('hidden').hide();
        $('#directFormActionArea').hide();
        $('#pdfUploadStatus').empty();
        $('#pdfFileInput').val(''); // 파일 선택 초기화
        
        if (this.value === 'yes') {
            $('#stepPdfUpload').addClass('visible');
            // PDF 업로드 성공 전까지는 완성 버튼 숨김
            scrollToCard($('#stepPdfUpload'));
        } else {
            $('#stepDirectForm').addClass('visible');
            $('#directFormActionArea').css('display', 'flex').show();
            const finalBtn = document.getElementById('finalSubmitBtn');
            if (finalBtn) {
                $(finalBtn).removeClass('hidden').show();
                // onclick 속성 확실하게 설정
                finalBtn.setAttribute('onclick', 'handleFinalSubmit(event); return false;');
                finalBtn.onclick = function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    handleFinalSubmit(e);
                    return false;
                };
                console.log('[DEBUG] finalSubmitBtn shown with onclick handler');
            }
            scrollToCard($('#stepDirectForm'));
            if ($('#clauseEditor').is(':empty')) {
                renderClauseEditor(state.idx);
                renderPreview();
                validateDirectReady();
                updateProgressIndicator();
            } else {
                validateDirectReady();
            }
        }
    });

    // PDF 업로드 플로우: 버튼 클릭 시 파일 선택 다이얼로그 열기
    $('#pdfUploadBtn').on('click', function () {
        // 프로젝트/프리랜서 선택 검증
        const projectId = $('#projectSelect').val();
        const freelancerId = $('#freelancerSelect').val();
        if (!projectId) {
            alert('프로젝트를 선택해주세요.');
            return;
        }
        if (!freelancerId) {
            alert('프리랜서를 선택해주세요.');
            return;
        }
        
        // 파일 선택 다이얼로그 열기
        $('#pdfFileInput').click();
    });
    
    // 파일 선택 후 자동 업로드
    $('#pdfFileInput').on('change', function() {
        const fileInput = this;
        if (!fileInput.files || fileInput.files.length === 0) {
            return;
        }
        
        const projectId = $('#projectSelect').val();
        const freelancerId = $('#freelancerSelect').val();
        
        // 프로젝트 ID 검증
        if (!projectId) {
            alert('프로젝트를 선택해주세요.');
            $('#pdfFileInput').val(''); // 파일 선택 초기화
            return;
        }
        
        // 업로드 버튼 비활성화 및 상태 표시
        const $btn = $('#pdfUploadBtn');
        const $status = $('#pdfUploadStatus');
        $btn.prop('disabled', true).text('업로드 중...');
        $status.html('<span class="status-info">📤 파일 업로드 중입니다...</span>');
        
        // FormData 생성 및 필수 파라미터 추가
        const fd = new FormData();
        fd.append('contractPdf', fileInput.files[0]);
        fd.append('projectId', projectId); // 필수 파라미터
        
        console.log('[DEBUG] PDF 업로드 시작:', {
            projectId: projectId,
            freelancerId: freelancerId,
            fileName: fileInput.files[0].name
        });
        
        $.ajax({
            url: ctx + '/client/contract/uploadPdf',
            type: 'POST',
            data: fd,
            processData: false,
            contentType: false,
            success: function (res) {
                if (res && res.success) {
                    // filePath가 있으면 filePath 사용, 없으면 fileName 사용
                    const filePath = res.filePath || res.fileName || '';
                    const fileName = res.fileName || '';
                    const fileNameDisplay = fileInput.files[0].name;
                    $('#uploadedPdfFileName').val(filePath); // 전체 경로 저장
                    
                    // 성공 알림
                    $status.html('<span class="status-success">✓ 업로드 완료: ' + fileNameDisplay + '</span>');
                    $btn.prop('disabled', false).text('다시 업로드');
                    
                    // 완성 버튼 표시 및 활성화
                    $('#stepFinalAction').addClass('visible').css('display', 'block');
                    const pdfBtn = document.getElementById('pdfFinalSubmitBtn');
                    if (pdfBtn) {
                        $(pdfBtn).removeClass('hidden').show();
                        // onclick 속성 확실하게 설정
                        pdfBtn.setAttribute('onclick', 'handlePdfFinalSubmit(event); return false;');
                        pdfBtn.onclick = function(e) {
                            e.preventDefault();
                            e.stopPropagation();
                            handlePdfFinalSubmit(e);
                            return false;
                        };
                        pdfBtn.title = '';
                        console.log('[DEBUG] PDF button displayed with onclick handler');
                    }
                    
                    // 알림 표시
                    setTimeout(function() {
                        alert('PDF 업로드가 완료되었습니다.\n이제 "계약 요청하기" 버튼을 클릭하세요.');
                        scrollToCard($('#stepFinalAction'));
                    }, 300);
                } else {
                    $status.html('<span class="status-error">✗ 업로드 실패: ' + ((res && res.error) ? res.error : '알 수 없는 오류') + '</span>');
                    $btn.prop('disabled', false).text('PDF 파일 선택 및 업로드');
                    alert('PDF 업로드 실패: ' + ((res && res.error) ? res.error : '알 수 없는 오류'));
                }
            },
            error: function (xhr) {
                const errorMsg = xhr.responseJSON && xhr.responseJSON.error 
                    ? xhr.responseJSON.error 
                    : (xhr.statusText || '알 수 없는 오류');
                $status.html('<span class="status-error">✗ 업로드 오류: ' + errorMsg + '</span>');
                $btn.prop('disabled', false).text('PDF 파일 선택 및 업로드');
                alert('PDF 업로드 중 오류 발생: ' + errorMsg);
                console.error('PDF upload error:', xhr);
            }
        });
    });

    // jQuery 이벤트 위임으로 버튼 클릭 처리 (항상 작동)
    $(document).on('click', '#pdfFinalSubmitBtn', function(e) {
        console.log('[DEBUG] pdfFinalSubmitBtn clicked via jQuery delegation');
        e.preventDefault();
        e.stopPropagation();
        handlePdfFinalSubmit(e);
        return false;
    });

    /* ========= 직접작성: Clause Wizard + 미리보기 + 클릭 수정 ========= */
    // clauses와 state는 전역 변수로 이미 선언됨

    // 계약서 조항 템플릿 (보험 약관 스타일)
    const clauseTemplates = {
        contractPurpose: function(ctx) {
            const projectTitle = ctx.projectTitle || '';
            const value = ctx.value || '';
            if (!value) return '';
            return '본 계약은 발주자가 추진하는 ' + projectTitle + '과 관련하여, ' +
                   '수주자가 ' + value + '을(를) 수행함에 있어 ' +
                   '양 당사자 간의 권리·의무 및 책임 사항을 규정함을 목적으로 한다.';
        },
        workScope: function(ctx) {
            const value = ctx.value || '';
            if (!value) return '';
            return '수주자는 본 계약에 따라 다음 각 호의 업무를 수행한다.\n' +
                   '1. ' + value + '\n' +
                   '2. 발주자와 협의하여 추가로 합의된 업무';
        },
        deliverables: function(ctx) {
            const value = ctx.value || '';
            if (!value) return '';
            return '본 계약에 따른 업무 결과물은 다음 각 호와 같다.\n' +
                   '1. ' + value + '\n' +
                   '2. 기타 발주자와 합의된 산출물';
        },
        paymentCondition: function(ctx) {
            const budget = ctx.budget || '';
            const value = ctx.value || '';
            if (!value) return '';
            let result = '① 본 계약에 따른 총 계약금액은 ' + budget + '원으로 한다.\n';
            result += '② 발주자는 수주자에게 다음 각 호의 조건에 따라 대금을 지급한다.\n';
            result += '   ' + value;
            return result;
        },
        scheduleCondition: function(ctx) {
            const startDate = ctx.startDate || '';
            const endDate = ctx.endDate || '';
            const value = ctx.value || '';
            if (!value) return '';
            let result = '① 본 계약의 계약기간은 ' + startDate + '부터 ' + endDate + '까지로 한다.\n';
            result += '② 세부 일정은 다음과 같이 정한다.\n';
            result += '   ' + value;
            return result;
        },
        specialTerms: function(ctx) {
            const value = ctx.value || '';
            if (!value) {
                return '본 조는 적용하지 아니한다.';
            }
            return '본 계약에 정하지 아니한 사항 또는 특약 사항은 다음과 같다.\n' + value;
        }
    };

    // 프로젝트/프리랜서 정보를 가져오는 헬퍼 함수
    function getContractContext() {
        const $projectOpt = $('#projectSelect option:selected');
        const $freelancerOpt = $('#freelancerSelect option:selected');
        return {
            projectTitle: normalizeDisplayValue($projectOpt.text()) || '',
            budget: normalizeDisplayValue($projectOpt.attr('data-budget')) || '',
            startDate: normalizeDisplayValue($projectOpt.attr('data-start')) || '',
            endDate: normalizeDisplayValue($projectOpt.attr('data-deadline')) || '',
            freelancerName: normalizeDisplayValue($freelancerOpt.attr('data-name')) || '',
            freelancerEmail: normalizeDisplayValue($freelancerOpt.attr('data-email')) || ''
        };
    }

    function escapeHtml(str) {
        if (!str) return '';
        const div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }

    function renderClauseEditor(index) {
        const c = clauses[index];
        const val = state.data[c.key] || '';
        const currentStep = index + 1;
        const totalSteps = clauses.length;
        const progressPercent = Math.round((currentStep / totalSteps) * 100);

        const btnLabel = (index < clauses.length - 1) ? '다음 조항으로 →' : '✓ 입력 완료';
        const reqBadge = c.required ? '<span class="badge-required">필수</span>' : '<span class="badge-optional">선택</span>';

        // 진행 바 HTML
        const progressBar = '<div class="progress-bar-container">' +
            '<div class="progress-bar-header">' +
            '<span class="progress-bar-label">진행 상황</span>' +
            '<span class="progress-bar-value">' + currentStep + '/' + totalSteps + '</span>' +
            '</div>' +
            '<div class="progress-bar-track">' +
            '<div class="progress-bar-fill" style="width: ' + progressPercent + '%;"></div>' +
            '</div>' +
            '</div>';

        // 에디터 HTML
        const editorHtml = '<div class="clause-editor-card">' +
            progressBar +
            '<div class="clause-header">' +
            '<h3 class="clause-title">' +
            '<span class="step-number">' + currentStep + '</span>' +
            '<span>' + c.title + '</span> ' + reqBadge +
            '</h3>' +
            '<p class="clause-guide">' +
            '<strong>💡 가이드:</strong> ' + (c.description || c.placeholder) +
            '</p>' +
            '</div>' +
            '<div class="clause-input-group">' +
            '<label class="clause-input-label">입력 내용</label>' +
            '<textarea id="clauseInput" class="clause-textarea" rows="12" placeholder="' + (c.placeholder || '') + '" style="min-height: 200px; line-height: 1.6;"></textarea>' +
            '</div>' +
            '<button type="button" class="btn-primary clause-save-btn" id="saveClauseBtn">' + btnLabel + '</button>' +
            '</div>';

        $('#clauseEditor').html(editorHtml);
        
        // textarea에 값 설정
        $('#clauseInput').val(val);
        
        // textarea 자동 높이 조절 함수
        function autoResizeTextarea(textarea) {
            textarea.style.height = 'auto';
            var scrollHeight = textarea.scrollHeight;
            if (scrollHeight > 0) {
                textarea.style.height = Math.max(200, scrollHeight) + 'px';
            }
        }
        
        // 초기 높이 설정
        setTimeout(function() {
            var $textarea = $('#clauseInput');
            if ($textarea.length) {
                autoResizeTextarea($textarea[0]);
            }
        }, 50);
        
        // 입력 시 자동 높이 조절
        $(document).off('input', '#clauseInput').on('input', '#clauseInput', function() {
            autoResizeTextarea(this);
            syncColumnHeights();
        });

        // 포커스
        setTimeout(function() {
            $('#clauseInput').focus();
            // 높이 동기화
            syncColumnHeights();
        }, 100);

        // 저장 버튼에 현재 key를 data로 보관
        $('#saveClauseBtn').data('key', c.key);
        $('#saveClauseBtn').data('idx', index);
        
        // 진행 상황 업데이트
        updateProgressIndicator();
    }
    
    // 진행 상황 표시 업데이트
    function updateProgressIndicator() {
        let completed = 0;
        clauses.forEach(function(c) {
            if (c.required && (state.data[c.key] || '').trim()) {
                completed++;
            }
        });
        const total = clauses.filter(function(c) { return c.required; }).length;
        $('#progressIndicator').text(completed + '/' + total);
    }

    function renderPreview() {
        const $doc = $('#contractDocument');
        $doc.empty();
        
        // 높이 동기화를 위해 렌더링 후 실행
        setTimeout(syncColumnHeights, 50);

        const ctx = getContractContext();

        clauses.forEach((c, i) => {
            const rawValue = (state.data[c.key] || '').trim();
            const isCurrentEditing = (state.idx === i);
            const hasValue = !!rawValue;
            
            if (!rawValue && c.required) return; // 필수 항목은 값이 있을 때만 표시

            // 템플릿 적용: 사용자 입력값을 템플릿 문장에 삽입
            const templateFn = clauseTemplates[c.key];
            let finalText = '';
            
            if (templateFn && rawValue) {
                // 템플릿에 context 전달하여 최종 문장 생성
                finalText = templateFn({
                    value: rawValue,
                    projectTitle: ctx.projectTitle,
                    budget: ctx.budget,
                    startDate: ctx.startDate,
                    endDate: ctx.endDate,
                    freelancerName: ctx.freelancerName,
                    freelancerEmail: ctx.freelancerEmail
                });
            } else if (rawValue) {
                // 템플릿이 없으면 원본 값 사용 (fallback)
                finalText = rawValue;
            } else if (!c.required) {
                // 선택 항목이고 값이 없으면 템플릿의 기본값 사용
                finalText = templateFn ? templateFn({
                    value: '',
                    projectTitle: ctx.projectTitle,
                    budget: ctx.budget,
                    startDate: ctx.startDate,
                    endDate: ctx.endDate,
                    freelancerName: ctx.freelancerName,
                    freelancerEmail: ctx.freelancerEmail
                }) : '';
            }

            if (!finalText) return;

            // HTML 이스케이프 처리 및 줄바꿈 변환
            const safe = escapeHtml(finalText).replaceAll('\n', '<br>');
            
            // 현재 편집 중인 조항 강조
            const clauseClass = isCurrentEditing ? 'contract-clause editing' : 'contract-clause';
            
            const statusIcon = hasValue ? 
                '<span class="status-icon complete">✓</span>' :
                '<span class="status-icon incomplete">○</span>';
            
            $doc.append(
                '<div class="' + clauseClass + '" data-idx="' + i + '" title="클릭하여 수정">' +
                '<h4>' + statusIcon + c.title + '</h4>' +
                '<p>' + safe + '</p>' +
                '</div>'
            );
        });

        if ($doc.children().length === 0) {
            $doc.append('<div class="hint">아직 입력된 조항이 없습니다.</div>');
        }
    }

    function validateDirectReady() {
        // 필수 5개 모두 입력되면 활성화
        let ok = true;
        clauses.forEach(c => {
            if (c.required) {
                const v = (state.data[c.key] || '').trim();
                if (!v) ok = false;
            }
        });

        const $btn = $('#finalSubmitBtn');
        // disabled 속성 제거 - 항상 클릭 가능하게 유지
        // 대신 시각적 피드백만 제공
        if (ok) {
            $btn.attr('title', '');
            $btn.css('opacity', '1');
            $btn.css('cursor', 'pointer');
            $btn.removeClass('btn-disabled');
        } else {
            $btn.attr('title', '필수 조항을 모두 입력해야 완성할 수 있습니다');
            $btn.css('opacity', '0.6');
            $btn.css('cursor', 'not-allowed');
            $btn.addClass('btn-disabled');
        }
    }

    // 조항 저장(다음)
    $(document).on('click', '#saveClauseBtn', function () {
        const idx = Number($(this).data('idx'));
        const c = clauses[idx];
        const v = ($('#clauseInput').val() || '').trim();

        if (c.required && !v) {
            alert(c.title + ' 항목은 필수입니다.');
            $('#clauseInput').focus();
            return;
        }

        state.data[c.key] = v;

        renderPreview();
        validateDirectReady();
        updateProgressIndicator();
        // 높이 동기화
        setTimeout(syncColumnHeights, 100);

        // 다음 조항으로 이동
        if (idx < clauses.length - 1) {
            state.idx = idx + 1;
            renderClauseEditor(state.idx);
            // 다음 조항으로 스크롤
            setTimeout(function() {
                scrollToCard($('#clauseEditor'));
            }, 100);
        } else {
            // 마지막까지 저장한 경우: 완성 버튼 표시
            const finalBtn = document.getElementById('finalSubmitBtn');
            if (finalBtn) {
                $(finalBtn).removeClass('hidden').show();
                // onclick 속성 확실하게 설정
                finalBtn.setAttribute('onclick', 'handleFinalSubmit(event); return false;');
                finalBtn.onclick = function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    handleFinalSubmit(e);
                    return false;
                };
                console.log('[DEBUG] All clauses saved, finalSubmitBtn displayed with onclick handler');
            }
            validateDirectReady();
            
            // 완료 안내 메시지 (한 번만 표시)
            if (!$('#clauseEditor').find('.completion-message').length) {
                $('#clauseEditor').prepend(
                    '<div class="completion-message">' +
                    '<strong>✓ 모든 조항 입력이 완료되었습니다!</strong><br/>' +
                    '<span>아래 "계약 요청하기" 버튼을 클릭하세요.</span>' +
                    '</div>'
                );
            }
            
            // 완성 버튼으로 스크롤
            setTimeout(function() {
                const actionArea = document.getElementById('directFormActionArea');
                if (actionArea) {
                    $('html, body').animate({
                        scrollTop: $(actionArea).offset().top - 40
                    }, 400);
                }
            }, 300);
        }
    });

    // 미리보기 클릭 -> 해당 조항 편집
    $(document).on('click', '.contract-clause', function () {
        const idx = Number($(this).data('idx'));
        state.idx = idx;
        renderClauseEditor(state.idx);

        // 편집 위치로 스크롤(UX)
        $('html, body').animate({
            scrollTop: $('#stepDirectForm').offset().top - 20
        }, 250);
    });

    // jQuery 이벤트 위임으로 버튼 클릭 처리 (항상 작동)
    $(document).on('click', '#finalSubmitBtn', function(e) {
        console.log('[DEBUG] finalSubmitBtn clicked via jQuery delegation');
        e.preventDefault();
        e.stopPropagation();
        handleFinalSubmit(e);
        return false;
    });
    
    // showAiAnalysisModal과 submitToContractCheck는 전역 함수로 이미 선언됨

    // 초기 상태 세팅
    updateProjectInfoBox();
    
    // 초기 로드 시 선택된 choice-card에 클래스 추가
    $('input[name="hasPdf"]:checked').each(function() {
        $(this).closest('.choice-card').addClass('selected');
    });
    
    // 초기 로드 시 프리랜서 정보도 표시
    function updateFreelancerInfoBox() {
        const $sel = $('#freelancerSelect');
        const $opt = $sel.find('option:selected');
        const hasValue = !!$sel.val() && !$sel.prop('disabled');
        
        if (!hasValue) {
            $('#freelancerInfo').addClass('hidden').empty();
            return;
        }
        
        const name = normalizeDisplayValue($opt.attr('data-name'));
        const email = normalizeDisplayValue($opt.attr('data-email'));
        
        if (!name && !email) {
            $('#freelancerInfo').addClass('hidden').empty();
            return;
        }
        
        const info = '<b>프리랜서:</b> ' + name + '<br/><b>이메일:</b> ' + email;
        // hidden 클래스 제거 후 표시
        $('#freelancerInfo').html(info).removeClass('hidden');
    }
    
    if (!$('#projectSelect').val()) {
        resetFreelancerSelect(true, '-- 선택 --');
    } else {
        // 서버 렌더링 목록이 없어도, 선택된 프로젝트가 있다면 AJAX로 다시 로드
        loadFreelancersByProject($('#projectSelect').val());
        // 프리랜서 정보도 초기 표시
        setTimeout(function() {
            updateFreelancerInfoBox();
        }, 500);
    }
    
    // 리사이즈 및 콘텐츠 변경 시 높이 동기화
    $(window).on('resize', syncColumnHeights);
    // 직접 작성 폼이 표시될 때 높이 동기화 (MutationObserver 사용)
    if (typeof MutationObserver !== 'undefined') {
        const observer = new MutationObserver(function() {
            setTimeout(syncColumnHeights, 100);
        });
        const clauseEditor = document.getElementById('clauseEditor');
        if (clauseEditor) {
            observer.observe(clauseEditor, { childList: true, subtree: true });
        }
    }
});
</script>

</body>
</html>
