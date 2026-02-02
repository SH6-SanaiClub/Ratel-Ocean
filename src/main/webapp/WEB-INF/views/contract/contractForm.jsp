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
        /* 인라인 스타일로 강제 적용 - 프리랜서 프로젝트 관리 페이지 톤 적용 */
        :root {
            --bg: #f6f7fb;
            --card: #fff;
            --text: #111827;
            --muted: #6b7280;
            --line: #e5e7eb;
            --primary: #173160;
            --primary-weak: rgba(59,111,220,.10);
            --shadow: 0 20px 60px rgba(17, 24, 39, 0.08);
            --radius: 18px;
        }
        
        body {
            background: var(--bg) !important;
        }
        
        #projectInfo.summary-box,
        #freelancerInfo.summary-box,
        .page-wrapper .summary-box:not(.contract-preview-box) {
            background-color: var(--card) !important;
            background: var(--card) !important;
            border: 1px solid rgba(229, 231, 235, 0.75) !important;
            border-radius: 22px !important;
            padding: 20px !important;
            margin-top: 16px !important;
            box-shadow: var(--shadow) !important;
        }
        
        .choice-card.selected {
            border-color: var(--primary) !important;
            background-color: var(--primary-weak) !important;
            background: var(--primary-weak) !important;
        }
        
        .choice-card.selected::after {
            background: var(--primary) !important;
            border-color: var(--primary) !important;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 16 16'%3E%3Cpath fill='white' d='M13.854 3.646a.5.5 0 0 1 0 .708l-7 7a.5.5 0 0 1-.708 0l-3.5-3.5a.5.5 0 1 1 .708-.708L6.5 10.293l6.646-6.647a.5.5 0 0 1 .708 0z'/%3E%3C/svg%3E") !important;
            background-size: 12px 12px !important;
            background-position: center !important;
            background-repeat: no-repeat !important;
        }
        
        .pdf-upload-area {
            border: 2px dashed rgba(229, 231, 235, 0.85) !important;
            border-radius: 22px !important;
            padding: 60px 40px !important;
            text-align: center !important;
            background: var(--card) !important;
            margin-top: 16px !important;
            min-height: 200px !important;
            display: flex !important;
            flex-direction: column !important;
            align-items: center !important;
            justify-content: center !important;
            box-shadow: var(--shadow) !important;
        }
        
        /* 카드 스타일 개선 */
        .page-wrapper .card,
        .contract-form-layout .card {
            border: 1px solid rgba(229, 231, 235, 0.75) !important;
            border-radius: 22px !important;
            box-shadow: var(--shadow) !important;
        }
        
        /* 버튼 스타일 개선 */
        .btn-primary {
            background: var(--primary) !important;
            color: #fff !important;
            box-shadow: 0 14px 30px rgba(26, 154, 166, 0.22) !important;
            border-radius: 14px !important;
        }
        
        .btn-primary:hover {
            filter: brightness(0.985) !important;
        }
        
        /* 계약 요청하기 버튼 중앙 정렬 강제 - 최우선 적용 */
        #directFormActionArea,
        #directFormActionArea.action-area,
        #stepDirectForm #directFormActionArea,
        #stepFinalAction,
        #stepFinalAction .action-area,
        .page-wrapper #directFormActionArea,
        .page-wrapper #stepFinalAction .action-area {
            justify-content: center !important;
            align-items: center !important;
            display: flex !important;
            text-align: center !important;
            width: 100% !important;
        }
        
        /* 인라인 스타일이 있어도 중앙 정렬 유지 */
        #directFormActionArea[style],
        #stepFinalAction .action-area[style] {
            justify-content: center !important;
            align-items: center !important;
            text-align: center !important;
        }
        
        /* 버튼 자체를 중앙에 배치 */
        #directFormActionArea .btn-primary,
        #directFormActionArea #finalSubmitBtn,
        #stepFinalAction .action-area .btn-primary,
        #stepFinalAction .action-area #pdfFinalSubmitBtn,
        .page-wrapper #directFormActionArea .btn-primary,
        .page-wrapper #stepFinalAction .action-area .btn-primary {
            margin: 0 auto !important;
            display: block !important;
        }
        
        /* 카드 내부도 중앙 정렬 */
        #stepFinalAction.card,
        #stepDirectForm .card {
            text-align: center !important;
        }
    </style>
</head>

<body>
<c:set var="activeMenu" value="contracts" scope="request"/>
<c:set var="userType" value="CLIENT" scope="request"/>
<jsp:include page="/WEB-INF/views/common/headerBase.jsp" />

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
            <input type="file" name="contractPdf" accept="application/pdf" id="pdfFileInput" style="display: none !important; position: absolute !important; width: 0 !important; height: 0 !important; opacity: 0 !important; pointer-events: none !important;" />
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
        <div class="action-area" id="directFormActionArea" style="justify-content: center !important; align-items: center !important; display: flex !important; text-align: center !important;">
            <button type="button" class="btn-primary hidden" id="finalSubmitBtn" onclick="handleFinalSubmit(event); return false;" title="필수 조항을 모두 입력해야 완성할 수 있습니다" style="margin: 0 auto !important;">계약 요청하기</button>
        </div>
    </section>

    <!-- 최종 완성 버튼 영역 (PDF용) -->
    <section class="card step-card" id="stepFinalAction" style="text-align: center;">
        <div class="action-area" style="justify-content: center !important; align-items: center !important; display: flex !important;">
            <button type="button" class="btn-primary hidden" id="pdfFinalSubmitBtn" onclick="handlePdfFinalSubmit(event); return false;" title="PDF를 업로드해야 완성할 수 있습니다" style="margin: 0 auto !important;">계약 요청하기</button>
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
    
    // body의 마지막 자식으로 이동하여 다른 요소의 영향을 받지 않도록
    document.body.appendChild(modalEl);
    
    // 모달 화면 중앙에 표시 - 모든 스타일 명시적으로 설정
    modalEl.removeAttribute('style');
    modalEl.className = 'modal-overlay';
    // 배경을 더 진하게 (0.7 -> 0.9), backdrop-filter 추가
    modalEl.style.cssText = 'display: flex !important; position: fixed !important; top: 0 !important; left: 0 !important; right: 0 !important; bottom: 0 !important; width: 100vw !important; height: 100vh !important; z-index: 999999 !important; align-items: center !important; justify-content: center !important; flex-direction: column !important; background: rgba(0,0,0,0.9) !important; backdrop-filter: blur(4px) !important; -webkit-backdrop-filter: blur(4px) !important; margin: 0 !important; padding: 0 !important;';
    modalEl.classList.add('show');
    
    // 모달 콘텐츠 스타일 강제 적용 (글자 깨짐 방지)
    const modalContent = modalEl.querySelector('.modal-content');
    if (modalContent) {
        modalContent.style.cssText = 'background: #ffffff !important; border-radius: 20px !important; padding: 40px !important; max-width: 500px !important; width: 90% !important; box-shadow: 0 10px 40px rgba(0,0,0,0.5) !important; text-align: center !important; position: relative !important; margin: auto !important; -webkit-font-smoothing: antialiased !important; -moz-osx-font-smoothing: grayscale !important; text-rendering: optimizeLegibility !important; font-smooth: always !important;';
    }
    
    // 모달 내부 확인 버튼 이벤트 설정
    const confirmBtn = document.getElementById('confirmAiAnalysisBtn');
    if (!confirmBtn) {
        alert('확인 버튼을 찾을 수 없습니다!');
        console.error('[ERROR] Confirm button not found!');
        return;
    }
    
    // 버튼 스타일을 "계약 요청하기" 버튼과 유사하게 강제 적용
    confirmBtn.style.cssText = 'width: auto !important; min-width: 160px !important; height: 48px !important; border-radius: 14px !important; border: none !important; background: #1a9aa6 !important; color: #fff !important; font-size: 13px !important; font-weight: 950 !important; cursor: pointer !important; transition: all 0.25s ease !important; padding: 12px 14px !important; box-shadow: 0 14px 30px rgba(26, 154, 166, 0.22) !important; display: inline-flex !important; align-items: center !important; justify-content: center !important; gap: 8px !important; white-space: nowrap !important;';
    
    // 기존 이벤트 리스너 제거 후 새로 등록
    const newBtn = confirmBtn.cloneNode(true);
    confirmBtn.parentNode.replaceChild(newBtn, confirmBtn);
    
    // 새 버튼에도 스타일 다시 적용
    newBtn.style.cssText = 'width: auto !important; min-width: 160px !important; height: 48px !important; border-radius: 14px !important; border: none !important; background: #1a9aa6 !important; color: #fff !important; font-size: 13px !important; font-weight: 950 !important; cursor: pointer !important; transition: all 0.25s ease !important; padding: 12px 14px !important; box-shadow: 0 14px 30px rgba(26, 154, 166, 0.22) !important; display: inline-flex !important; align-items: center !important; justify-content: center !important; gap: 8px !important; white-space: nowrap !important;';
    
    newBtn.onclick = function(e) {
        e.preventDefault();
        e.stopPropagation();
        console.log('[DEBUG] confirmAiAnalysisBtn clicked');
        submitToContractCheck(inputType, projectId, freelancerId, fileName);
        return false;
    };
    
    // 호버 효과도 추가
    newBtn.addEventListener('mouseenter', function() {
        this.style.filter = 'brightness(0.985)';
        this.style.transform = 'translateY(-1px)';
    });
    newBtn.addEventListener('mouseleave', function() {
        this.style.filter = '';
        this.style.transform = '';
    });
    
    console.log('[DEBUG] Modal displayed');
}

function submitToContractCheck(inputType, projectId, freelancerId, fileName) {
    console.log('[DEBUG] submitToContractCheck called', { inputType, projectId, freelancerId, fileName });
    
    // 모달 완전히 숨기기 - 모든 방법으로 강제 숨김
    const modalEl = document.getElementById('aiAnalysisModal');
    if (modalEl) {
        // 모든 클래스 제거
        modalEl.className = 'modal-overlay';
        // 모든 스타일 속성 제거 후 숨김
        modalEl.removeAttribute('style');
        modalEl.style.cssText = 'display: none !important; visibility: hidden !important; opacity: 0 !important; z-index: -1 !important; pointer-events: none !important; position: fixed !important; top: -9999px !important; left: -9999px !important; width: 0 !important; height: 0 !important;';
        modalEl.classList.remove('show');
        
        // 모달 내부 요소도 숨김
        const modalContent = modalEl.querySelector('.modal-content');
        if (modalContent) {
            modalContent.style.cssText = 'display: none !important;';
        }
    }
    
    // 로딩 오버레이 표시 - 모든 스타일을 강제로 적용
    const loadingEl = document.getElementById('loadingOverlay');
    if (loadingEl) {
        // body의 마지막 자식으로 이동하여 다른 요소의 영향을 받지 않도록
        document.body.appendChild(loadingEl);
        
        // 기존 스타일 모두 제거 후 새로 설정
        loadingEl.removeAttribute('style');
        loadingEl.className = 'loading-overlay';
        
        // 화면 전체를 덮고 중앙에 표시되도록 강제 설정 - cssText로 한 번에 설정
        loadingEl.style.cssText = 'display: flex !important; position: fixed !important; top: 0 !important; left: 0 !important; right: 0 !important; bottom: 0 !important; width: 100vw !important; height: 100vh !important; z-index: 2147483647 !important; align-items: center !important; justify-content: center !important; flex-direction: column !important; background: rgba(255,255,255,0.98) !important; margin: 0 !important; padding: 0 !important; overflow: hidden !important; transform: none !important;';
        loadingEl.classList.add('show');
        
        // loading-content도 중앙 정렬 강제
        const loadingContent = loadingEl.querySelector('.loading-content');
        if (loadingContent) {
            loadingContent.style.cssText = 'text-align: center !important; margin: 0 auto !important; display: flex !important; flex-direction: column !important; align-items: center !important; justify-content: center !important;';
        }
        
        // 강제로 리플로우 발생시켜 스타일 적용 확인
        loadingEl.offsetHeight;
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
<div id="aiAnalysisModal" class="modal-overlay" style="display: none !important; position: fixed !important; top: 0 !important; left: 0 !important; right: 0 !important; bottom: 0 !important; width: 100vw !important; height: 100vh !important; z-index: 999999 !important; align-items: center !important; justify-content: center !important; flex-direction: column !important; background: rgba(0,0,0,0.9) !important; backdrop-filter: blur(4px) !important; -webkit-backdrop-filter: blur(4px) !important; margin: 0 !important; padding: 0 !important;">
    <div class="modal-content" style="background: #ffffff !important; border-radius: 20px !important; padding: 40px !important; max-width: 500px !important; width: 90% !important; box-shadow: 0 10px 40px rgba(0,0,0,0.5) !important; text-align: center !important; position: relative !important; margin: auto !important; -webkit-font-smoothing: antialiased !important; -moz-osx-font-smoothing: grayscale !important; text-rendering: optimizeLegibility !important;">
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
<div id="loadingOverlay" class="loading-overlay" style="display: none !important; position: fixed !important; top: 0 !important; left: 0 !important; width: 100vw !important; height: 100vh !important; z-index: 9999999 !important; align-items: center !important; justify-content: center !important; flex-direction: column !important; background: rgba(255,255,255,0.98) !important; margin: 0 !important; padding: 0 !important;">
    <div class="loading-content" style="text-align: center !important; margin: 0 auto !important;">
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
        // 업로드 버튼 다시 표시 (초기화 시)
        $('#pdfUploadBtn').show().text('PDF 파일 선택 및 업로드');
        
        if (this.value === 'yes') {
            $('#stepPdfUpload').addClass('visible');
            // PDF 업로드 성공 전까지는 완성 버튼 숨김
            scrollToCard($('#stepPdfUpload'));
        } else {
            $('#stepDirectForm').addClass('visible');
            $('#directFormActionArea').css({
                'display': 'flex',
                'justify-content': 'center',
                'align-items': 'center',
                'text-align': 'center'
            }).show();
            $('#finalSubmitBtn').css('margin', '0 auto');
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
                    // 업로드 완료 후 버튼 완전히 숨김
                    $btn.hide().css('display', 'none').prop('disabled', false).text('PDF 파일 선택 및 업로드');
                    
                    // 완성 버튼 표시 및 활성화
                    $('#stepFinalAction').addClass('visible').css({
                        'display': 'block',
                        'text-align': 'center'
                    });
                    const pdfBtn = document.getElementById('pdfFinalSubmitBtn');
                    if (pdfBtn) {
                        $(pdfBtn).removeClass('hidden').show().css('margin', '0 auto');
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
                    // action-area도 중앙 정렬 유지
                    $('#stepFinalAction .action-area').css({
                        'justify-content': 'center',
                        'align-items': 'center',
                        'display': 'flex'
                    });
                    
                    // 알림 표시
                    setTimeout(function() {
                        alert('PDF 업로드가 완료되었습니다.\n이제 "계약 요청하기" 버튼을 클릭하세요.');
                        scrollToCard($('#stepFinalAction'));
                    }, 300);
                } else {
                    $status.html('<span class="status-error">✗ 업로드 실패: ' + ((res && res.error) ? res.error : '알 수 없는 오류') + '</span>');
                    $btn.prop('disabled', false).show().text('PDF 파일 선택 및 업로드');
                    alert('PDF 업로드 실패: ' + ((res && res.error) ? res.error : '알 수 없는 오류'));
                }
            },
            error: function (xhr) {
                const errorMsg = xhr.responseJSON && xhr.responseJSON.error 
                    ? xhr.responseJSON.error 
                    : (xhr.statusText || '알 수 없는 오류');
                $status.html('<span class="status-error">✗ 업로드 오류: ' + errorMsg + '</span>');
                $btn.prop('disabled', false).show().text('PDF 파일 선택 및 업로드');
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
                $(finalBtn).removeClass('hidden').show().css('margin', '0 auto');
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
            // action-area도 중앙 정렬 유지
            $('#directFormActionArea').css({
                'justify-content': 'center',
                'align-items': 'center',
                'display': 'flex',
                'text-align': 'center'
            });
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
    
    // URL 쿼리 파라미터에서 projectId와 freelancerId 가져오기
    function getUrlParameter(name) {
        const urlParams = new URLSearchParams(window.location.search);
        return urlParams.get(name);
    }
    
    // 쿼리 파라미터로 전달된 프로젝트와 프리랜서 자동 선택
    const urlProjectId = getUrlParameter('projectId');
    const urlFreelancerId = getUrlParameter('freelancerId');
    
    if (urlProjectId) {
        // 프로젝트 선택
        $('#projectSelect').val(urlProjectId).trigger('change');
        
        // 프로젝트 정보 업데이트 후 프리랜서 목록 로드
        setTimeout(function() {
            if (urlFreelancerId) {
                // 프리랜서 목록이 로드될 때까지 대기 후 선택
                const checkFreelancerSelect = setInterval(function() {
                    const $freelancerSelect = $('#freelancerSelect');
                    if (!$freelancerSelect.prop('disabled') && $freelancerSelect.find('option[value="' + urlFreelancerId + '"]').length > 0) {
                        $freelancerSelect.val(urlFreelancerId).trigger('change');
                        clearInterval(checkFreelancerSelect);
                    }
                }, 200);
                
                // 최대 5초 대기 후 타임아웃
                setTimeout(function() {
                    clearInterval(checkFreelancerSelect);
                }, 5000);
            }
        }, 500);
    } else {
        // 쿼리 파라미터가 없으면 기존 로직 실행
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
