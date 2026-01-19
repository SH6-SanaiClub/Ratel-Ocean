// ═══════════════════════════════════════════════════════════════════════
// 프로젝트 등록 - 새로운 UI/UX
// ═══════════════════════════════════════════════════════════════════════
// 
// [파일 목적]
// 클라이언트가 프로젝트를 등록하는 5단계 폼의 동작을 제어합니다.
// 
// [주요 기능]
// 1. 단계별 네비게이션 (이전/다음 버튼)
// 2. 각 단계별 유효성 검사
// 3. 진행률 표시 업데이트
// 4. 기술 스택 선택 및 관리
// 5. 최종 미리보기 생성
// 
// [단계 구성]
// Step 1: 프로젝트 기본 정보 (제목, 설명, 파일)
// Step 2: 기술 스택 선택
// Step 3: 예산 및 일정
// Step 4: 진행 방식 (소통/지급 방식, 무상 수정 횟수)
// Step 5: 미리보기 및 등록
// 
// ═══════════════════════════════════════════════════════════════════════

// ────────────────────────────────────────────────────────────────────
// 전역 변수
// ────────────────────────────────────────────────────────────────────

let currentStep = 1;              // 현재 단계 (1~5)
const totalSteps = 5;             // 전체 단계 수
let selectedAreas = [];           // 선택된 개발 영역 (POSITION)
let selectedSkills = [];          // 선택된 기술 스택 (SKILL)

// ═══════════════════════════════════════════════════════════════════════
// 페이지 초기화
// ═══════════════════════════════════════════════════════════════════════
// DOM 로드 완료 시 실행되는 초기화 함수
// - 진행률 표시 초기화
// - 각종 이벤트 리스너 등록
// - 입력 필드 유효성 검사 설정
// ═══════════════════════════════════════════════════════════════════════

document.addEventListener('DOMContentLoaded', () => {
    // ──────── 1. 진행률 표시 초기화 ────────
    updateProgressBar();
    
    // ──────── 2. 설명 글자수 카운터 ────────
    // 실시간으로 입력된 글자 수를 표시
    const descTextarea = document.getElementById('description');
    if (descTextarea) {
        descTextarea.addEventListener('input', (e) => {
            document.getElementById('descLength').textContent = e.target.value.length;
        });
    }
    
    // ──────── 3. 예산 입력 자동 콤마 처리 ────────
    // 숫자만 입력 가능하며, 천 단위 콤마 자동 추가
    // 예) 1000000 → 1,000,000
    const budgetInput = document.getElementById('budgetInput');
    if (budgetInput) {
        budgetInput.addEventListener('input', (e) => {
            let val = e.target.value.replace(/[^0-9]/g, '');
            e.target.value = val ? Number(val).toLocaleString() : '';
        });
    }
    
    // ──────── 4. 시작일 타입에 따른 날짜 입력 표시 ────────
    // "구체적 날짜" 선택 시에만 날짜 입력창 표시
    const startTypeRadios = document.querySelectorAll('input[name="startType"]');
    startTypeRadios.forEach(radio => {
        radio.addEventListener('change', (e) => {
            const specificDateInput = document.getElementById('specificDateInput');
            if (e.target.value === 'SPECIFIC') {
                specificDateInput.style.display = 'block';
            } else {
                specificDateInput.style.display = 'none';
            }
        });
    });
    
    // ──────── 5. 무상 수정 횟수 최대값 제한 ────────
    // 3회를 초과하면 자동으로 3으로 조정
    const revInput = document.getElementById('maxRevisionCount');
    if (revInput) {
        revInput.addEventListener('input', function() {
            if (this.value > 3) {
                alert('⚠️ 무상 수정 횟수는 최대 3회까지만 설정 가능합니다.');
                this.value = 3;
            }
            if (this.value < 0) {
                this.value = 0;
            }
        });
    }
    
    // ──────── 6. 폼 제출 전 데이터 정리 ────────
    // 예산에서 콤마 제거 후 hidden 필드에 저장
    const form = document.getElementById('projectForm');
    if (form) {
        form.addEventListener('submit', () => {
            const budget = budgetInput.value.replace(/,/g, '');
            document.getElementById('budget').value = budget;
        });
    }
});

// ═══════════════════════════════════════════════════════════════════════
// 진행률 표시 업데이트
// ═══════════════════════════════════════════════════════════════════════

function updateProgressBar() {
    // 진행률 텍스트
    document.getElementById('progressText').innerHTML = 
        `<strong>${currentStep}</strong> / ${totalSteps} 단계`;
    
    // 단계 표시 업데이트
    const steps = document.querySelectorAll('.progress-step');
    const dividers = document.querySelectorAll('.progress-divider');
    
    steps.forEach((step, index) => {
        const stepNum = index + 1;
        step.classList.remove('active', 'completed');
        
        if (stepNum === currentStep) {
            step.classList.add('active');
        } else if (stepNum < currentStep) {
            step.classList.add('completed');
        }
    });
    
    dividers.forEach((divider, index) => {
        divider.classList.remove('completed');
        if (index + 1 < currentStep) {
            divider.classList.add('completed');
        }
    });
}

// ═══════════════════════════════════════════════════════════════════════
// 단계 이동
// ═══════════════════════════════════════════════════════════════════════

function nextStep() {
    if (!validateStep(currentStep)) {
        return;
    }
    
    if (currentStep < totalSteps) {
        currentStep++;
        showStep(currentStep);
        window.scrollTo(0, 0);
    }
}

function prevStep() {
    if (currentStep > 1) {
        currentStep--;
        showStep(currentStep);
        window.scrollTo(0, 0);
    }
}

function goToStep(step) {
    currentStep = step;
    showStep(currentStep);
    window.scrollTo(0, 0);
}

function showStep(step) {
    // 모든 단계 숨기기
    document.querySelectorAll('.step-page').forEach(page => {
        page.classList.remove('active');
    });
    
    // 현재 단계 표시
    const currentPage = document.getElementById(`step${step}`);
    if (currentPage) {
        currentPage.classList.add('active');
    }
    
    // 버튼 표시 제어
    const btnPrev = document.getElementById('btnPrev');
    const btnNext = document.getElementById('btnNext');
    const btnSubmit = document.getElementById('btnSubmit');
    
    if (step === 1) {
        btnPrev.style.display = 'none';
    } else {
        btnPrev.style.display = 'inline-flex';
    }
    
    if (step === totalSteps) {
        btnNext.style.display = 'none';
        btnSubmit.style.display = 'inline-flex';
        updatePreview();
    } else {
        btnNext.style.display = 'inline-flex';
        btnSubmit.style.display = 'none';
    }
    
    updateProgressBar();
}

// ═══════════════════════════════════════════════════════════════════════
// 유효성 검사
// ═══════════════════════════════════════════════════════════════════════
// 단계별 유효성 검사
// ═══════════════════════════════════════════════════════════════════════
// 각 단계에서 "다음" 버튼 클릭 시 필수 항목이 입력되었는지 검사합니다.
// 
// [검사 항목]
// Step 1: 제목, 설명 (최소 10자)
// Step 2: 기술 스택 최소 1개 선택 (레벨/경력은 자동 기본값 설정)
// Step 3: 예산 (최소 10만원), 기간
// Step 4: 모두 선택사항 (검사 없음)
// 
// [리턴값]
// true: 유효성 검사 통과, 다음 단계로 이동 가능
// false: 유효성 검사 실패, 경고창 표시
// ═══════════════════════════════════════════════════════════════════════

function validateStep(step) {
    switch(step) {
        case 1:
            return validateStep1();  // 기본 정보 검사
        case 2:
            return validateStep2();  // 기술 스택 검사
        case 3:
            return validateStep3();  // 예산/일정 검사
        case 4:
            return validateStep4();  // 진행 방식 검사 (모두 선택사항)
        default:
            return true;
    }
}

// ──────── Step 1: 프로젝트 기본 정보 검사 ────────
function validateStep1() {
    const title = document.getElementById('title').value.trim();
    const description = document.getElementById('description').value.trim();
    
    // 제목 필수 입력
    if (!title) {
        alert('⚠️ 프로젝트 제목을 입력해주세요.');
        document.getElementById('title').focus();
        return false;
    }
    
    // 설명 필수 입력
    if (!description) {
        alert('⚠️ 프로젝트 상세 내용을 입력해주세요.');
        document.getElementById('description').focus();
        return false;
    }
    
    // 설명 최소 10자 (너무 짧으면 구체적이지 않음)
    if (description.length < 10) {
        alert('⚠️ 프로젝트 상세 내용은 최소 10자 이상 입력해주세요.');
        document.getElementById('description').focus();
        return false;
    }
    
    return true;
}

// ──────── Step 2: 기술 스택 검사 ────────
function validateStep2() {
    // 개발 영역 또는 기술 스택 최소 1개 선택 필수
    if (selectedAreas.length === 0 && selectedSkills.length === 0) {
        alert('⚠️ 개발 영역 또는 기술 스택을 최소 1개 이상 선택해주세요.');
        return false;
    }
    
    // ──────── 레벨/경력을 입력하지 않은 경우 기본값 자동 설정 ────────
    // 클라이언트가 정확한 요구사항을 모를 수 있으므로
    // 미입력 시 자동으로 Lv.1(입문), 0년으로 설정
    
    for (let area of selectedAreas) {
        if (!area.stackLevel) area.stackLevel = 1;           // 기본 레벨: 1 (입문)
        if (area.stackYear === null || area.stackYear === undefined) area.stackYear = 0;  // 기본 경력: 0년
    }
    
    for (let skill of selectedSkills) {
        if (!skill.stackLevel) skill.stackLevel = 1;          // 기본 레벨: 1 (입문)
        if (skill.stackYear === null || skill.stackYear === undefined) skill.stackYear = 0; // 기본 경력: 0년
    }
    
    // hidden input 업데이트 (서버로 전송될 데이터)
    updateHiddenInputs();
    
    return true;
}

// ──────── Step 3: 예산 및 일정 검사 ────────
function validateStep3() {
    const budget = document.getElementById('budgetInput').value.replace(/,/g, '');
    const duration = document.querySelector('input[name="estDuration"]:checked');
    
    // 예산 필수 입력
    if (!budget || parseInt(budget) <= 0) {
        alert('⚠️ 프로젝트 예산을 입력해주세요.');
        document.getElementById('budgetInput').focus();
        return false;
    }
    
    // 예산 최소값: 10만원 (너무 적은 금액 방지)
    if (parseInt(budget) < 100000) {
        alert('⚠️ 프로젝트 예산은 최소 10만원 이상이어야 합니다.\n품질 있는 작업을 위해 적정 예산을 설정해주세요.');
        document.getElementById('budgetInput').focus();
        return false;
    }
    
    // 예상 진행 기간 필수 선택
    if (!duration) {
        alert('⚠️ 예상 진행 기간을 선택해주세요.');
        return false;
    }
    
    // ──────── 선택 항목들 (필수 아님) ────────
    // - 프로젝트 시작일: 클라이언트가 유동적으로 결정 가능
    
    return true;
}

// ──────── Step 4: 진행 방식 검사 ────────
function validateStep4() {
    // ──────── 모두 선택 항목 (필수 아님) ────────
    // - 소통 방식 (ONLINE/OFFLINE): 프리랜서와 협의 가능
    // - 지급 방식 (LUMP_SUM/INSTALLMENT): 계약 시 협의 가능
    // - 무상 수정 횟수: 기본값 1회 설정됨
    
    return true;  // 모든 항목이 선택사항이므로 항상 통과
}

// ═══════════════════════════════════════════════════════════════════════
// 선택 카드 클릭
// ═══════════════════════════════════════════════════════════════════════

function selectChoice(element) {
    const input = element.querySelector('input');
    if (input) {
        input.checked = true;
        
        // 같은 그룹의 다른 카드 선택 해제
        const name = input.name;
        const cards = document.querySelectorAll(`input[name="${name}"]`);
        cards.forEach(card => {
            card.closest('.choice-card').classList.remove('selected');
        });
        
        // 현재 카드 선택
        element.classList.add('selected');
    }
}

// ═══════════════════════════════════════════════════════════════════════
// 파일 선택
// ═══════════════════════════════════════════════════════════════════════

function handleFileSelect(input) {
    if (input.files && input.files[0]) {
        const file = input.files[0];
        document.getElementById('fileNameDisplay').textContent = file.name;
        document.getElementById('fileDisplayDefault').style.display = 'none';
        document.getElementById('fileDisplaySelected').style.display = 'block';
    }
}

// ═══════════════════════════════════════════════════════════════════════
// 기술 스택 모달
// ═══════════════════════════════════════════════════════════════════════

function openProjectTechStackModal() {
    const preselectedAreas = selectedAreas.map(a => ({ id: a.stackId, name: a.stackName }));
    const preselectedStacks = selectedSkills.map(s => ({ id: s.stackId, name: s.stackName }));
    
    if (typeof openTechStackModal === 'function') {
        openTechStackModal(handleTechStackSelection, preselectedAreas, preselectedStacks);
    } else {
        alert('❌ 모달 함수를 찾을 수 없습니다. 페이지를 새로고침해주세요.');
    }
}

function handleTechStackSelection(selectedPositions, selectedStacks) {
    selectedAreas = selectedPositions.map(area => ({
        stackId: area.id,
        stackName: area.name,
        stackLevel: null,
        stackYear: null
    }));
    
    selectedSkills = selectedStacks.map(stack => ({
        stackId: stack.id,
        stackName: stack.name,
        stackLevel: null,
        stackYear: null
    }));
    
    renderSelectedStacks();
    updateHiddenInputs();
}

function renderSelectedStacks() {
    const container = document.getElementById('selectedStacks');
    const areasSection = document.getElementById('selectedAreasSection');
    const skillsSection = document.getElementById('selectedSkillsSection');
    const areasContainer = document.getElementById('selectedAreasContainer');
    const skillsContainer = document.getElementById('selectedSkillsContainer');
    
    if (selectedAreas.length === 0 && selectedSkills.length === 0) {
        container.style.display = 'none';
        return;
    }
    
    container.style.display = 'block';
    
    // 개발 영역 렌더링
    if (selectedAreas.length > 0) {
        areasSection.style.display = 'block';
        areasContainer.innerHTML = '';
        selectedAreas.forEach((area, index) => {
            const card = createStackCard(area, index, true);
            areasContainer.appendChild(card);
        });
    } else {
        areasSection.style.display = 'none';
    }
    
    // 기술 스택 렌더링
    if (selectedSkills.length > 0) {
        skillsSection.style.display = 'block';
        skillsContainer.innerHTML = '';
        selectedSkills.forEach((skill, index) => {
            const card = createStackCard(skill, index, false);
            skillsContainer.appendChild(card);
        });
    } else {
        skillsSection.style.display = 'none';
    }
}

function createStackCard(stack, index, isArea) {
    const card = document.createElement('div');
    card.className = 'stack-card';
    
    card.innerHTML = `
        <div class="stack-card-header">
            <span class="stack-card-title">
                <i class="fa-solid fa-${isArea ? 'folder' : 'code'}" style="color: #1F7A8C; margin-right: 0.5rem;"></i>
                ${stack.stackName}
            </span>
            <button type="button" class="stack-remove-btn" onclick="${isArea ? 'removeArea' : 'removeSkill'}(${index})">
                <i class="fa-solid fa-times"></i>
            </button>
        </div>
        <div style="margin-bottom: 1rem;">
            <label style="display: block; font-size: 0.875rem; color: #6F7272; margin-bottom: 0.5rem; font-weight: 500;">
                <i class="fa-solid fa-star" style="color: #FFA726; margin-right: 4px;"></i>요구 숙련도 (선택사항)
            </label>
            <select onchange="${isArea ? 'updateAreaLevel' : 'updateSkillLevel'}(${index}, this.value)" 
                    style="width: 100%; padding: 0.75rem; border: 1px solid #E5E5E5; border-radius: 8px; font-size: 0.9375rem;">
                <option value="1" ${stack.stackLevel == 1 ? 'selected' : ''}>레벨 모름 / Lv.1 입문</option>
                <option value="2" ${stack.stackLevel == 2 ? 'selected' : ''}>Lv.2 초급</option>
                <option value="3" ${stack.stackLevel == 3 ? 'selected' : ''}>Lv.3 중급</option>
                <option value="4" ${stack.stackLevel == 4 ? 'selected' : ''}>Lv.4 중급+</option>
                <option value="5" ${stack.stackLevel == 5 ? 'selected' : ''}>Lv.5 고급</option>
            </select>
        </div>
        <div>
            <label style="display: block; font-size: 0.875rem; color: #6F7272; margin-bottom: 0.5rem; font-weight: 500;">
                <i class="fa-solid fa-clock" style="color: #66BB6A; margin-right: 4px;"></i>필요 경력 (년) - 선택사항
            </label>
            <input type="number" onchange="${isArea ? 'updateAreaYear' : 'updateSkillYear'}(${index}, this.value)" 
                   value="${stack.stackYear !== null && stack.stackYear !== undefined ? stack.stackYear : 0}" min="0" placeholder="모르겠음 / 0년" 
                   style="width: 100%; padding: 0.75rem; border: 1px solid #E5E5E5; border-radius: 8px; font-size: 0.9375rem;">
        </div>
    `;
    
    return card;
}

function updateAreaLevel(index, level) {
    selectedAreas[index].stackLevel = level ? parseInt(level) : null;
    updateHiddenInputs();
}

function updateAreaYear(index, year) {
    selectedAreas[index].stackYear = year ? parseInt(year) : null;
    updateHiddenInputs();
}

function updateSkillLevel(index, level) {
    selectedSkills[index].stackLevel = level ? parseInt(level) : null;
    updateHiddenInputs();
}

function updateSkillYear(index, year) {
    selectedSkills[index].stackYear = year ? parseInt(year) : null;
    updateHiddenInputs();
}

function removeArea(index) {
    selectedAreas.splice(index, 1);
    renderSelectedStacks();
    updateHiddenInputs();
}

function removeSkill(index) {
    selectedSkills.splice(index, 1);
    renderSelectedStacks();
    updateHiddenInputs();
}

function updateHiddenInputs() {
    const container = document.getElementById('hiddenStackInputs');
    container.innerHTML = '';
    
    const allStacks = [...selectedAreas, ...selectedSkills];
    allStacks.forEach(stack => {
        container.innerHTML += `
            <input type="hidden" name="stackIds" value="${stack.stackId}">
            <input type="hidden" name="stackLevels" value="${stack.stackLevel || ''}">
            <input type="hidden" name="stackYears" value="${stack.stackYear || ''}">
        `;
    });
}

// ═══════════════════════════════════════════════════════════════════════
// 미리보기 업데이트
// ═══════════════════════════════════════════════════════════════════════

function updatePreview() {
    // 제목
    document.getElementById('previewTitle').textContent = 
        document.getElementById('title').value;
    
    // 설명
    document.getElementById('previewDescription').textContent = 
        document.getElementById('description').value;
    
    // 예산
    const budget = document.getElementById('budgetInput').value;
    const budgetNego = document.querySelector('input[name="budgetNegotiable"]').checked;
    document.getElementById('previewBudget').textContent = 
        budget + '원' + (budgetNego ? ' (협의 가능)' : '');
    
    // 진행 기간
    const duration = document.querySelector('input[name="estDuration"]:checked');
    const durationNego = document.querySelector('input[name="durationNegotiable"]').checked;
    document.getElementById('previewDuration').textContent = 
        (duration ? duration.value : '미선택') + (durationNego ? ' (조율 가능)' : '');
    
    // 시작일
    const startType = document.querySelector('input[name="startType"]:checked');
    const startDate = document.getElementById('startDate').value;
    document.getElementById('previewStartDate').textContent = 
        startType && startType.value === 'ASAP' ? '계약 후 즉시' : (startDate || '미선택');
    
    // 기술 스택
    const stacksContainer = document.getElementById('previewStacks');
    const allStacks = [...selectedAreas, ...selectedSkills];
    if (allStacks.length > 0) {
        stacksContainer.innerHTML = allStacks.map(stack => 
            `<span style="display: inline-block; padding: 0.5rem 1rem; margin: 0.25rem; background: rgba(31, 122, 140, 0.1); color: #1F7A8C; border-radius: 8px; font-weight: 500;">
                ${stack.stackName} (Lv.${stack.stackLevel}, ${stack.stackYear}년)
            </span>`
        ).join('');
    } else {
        stacksContainer.innerHTML = '<p style="color: #6F7272;">선택된 기술 스택이 없습니다.</p>';
    }
    
    // 소통 방식
    const comm = document.querySelector('input[name="communicateMethod"]:checked');
    document.getElementById('previewComm').textContent = 
        comm ? (comm.value === 'ONLINE' ? '온라인' : '오프라인') : '미선택';
    
    // 지급 방식
    const pay = document.querySelector('input[name="paymentMethod"]:checked');
    document.getElementById('previewPay').textContent = 
        pay ? (pay.value === 'LUMP_SUM' ? '일괄 지급' : '분할 지급') : '미선택';
    
    // 수정 횟수
    const revision = document.getElementById('maxRevisionCount').value || '1';
    document.getElementById('previewRevision').textContent = `무상 수정 ${revision}회`;
}
