/**
 * 계약서 검토 페이지 (client_con_second.jsp) 전용 JavaScript
 */

// ═══════════════════════════════════════════════════════════════════════
// 전역 변수
// ═══════════════════════════════════════════════════════════════════════
let contractSelectedAreas = [];
let contractSelectedStacks = [];

// ═══════════════════════════════════════════════════════════════════════
// 예산 조정 함수 (전역)
// ═══════════════════════════════════════════════════════════════════════
function adjustBudget(delta) {
    const input = document.getElementById('budget');
    if (!input) {
        console.error('Budget input not found');
        return false;
    }
    const currentValue = parseInt(input.value) || 0;
    const newValue = Math.max(0, currentValue + delta);
    input.value = newValue;
    validateTotalAmount();
    return false;
}

// ═══════════════════════════════════════════════════════════════════════
// 마일스톤 제거 함수 (전역)
// ═══════════════════════════════════════════════════════════════════════
function removeMilestone(button) {
    const milestoneDiv = button.closest('.milestone-item');
    if (milestoneDiv) {
        milestoneDiv.remove();
        updateMilestoneNumbers();
        validateTotalAmount();
    }
    return false;
}

// ═══════════════════════════════════════════════════════════════════════
// 마일스톤 추가 함수 (전역)
// ═══════════════════════════════════════════════════════════════════════
function addMilestone() {
    const container = document.getElementById('milestonesContainer');
    
    const newMilestone = document.createElement('div');
    newMilestone.className = 'milestone-item';
    newMilestone.innerHTML = `
        <div class="milestone-number">
            단계
        </div>

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
    `;
    
    container.appendChild(newMilestone);
    updateMilestoneNumbers();
}

// ═══════════════════════════════════════════════════════════════════════
// 마일스톤 금액 조정 함수 (전역)
// ═══════════════════════════════════════════════════════════════════════
function adjustMilestoneAmount(button, delta) {
    const container = button.closest('div');
    const input = container.querySelector('input[name="milestoneAmount"]');
    if (input) {
        const currentValue = parseInt(input.value) || 0;
        const newValue = Math.max(0, currentValue + delta);
        input.value = newValue;
        validateTotalAmount();
    }
    return false;
}

// ═══════════════════════════════════════════════════════════════════════
// 마일스톤 번호 업데이트
// ═══════════════════════════════════════════════════════════════════════
function updateMilestoneNumbers() {
    const container = document.getElementById('milestonesContainer');
    const milestones = container.querySelectorAll('.milestone-item');

    milestones.forEach((milestone, index) => {
        const numberDiv = milestone.querySelector('.milestone-number');
        if (!numberDiv) return;
        const stageNumber = index + 1;

        // 모든 단계에 삭제 버튼 포함 (1단계도 가능)
        numberDiv.innerHTML = stageNumber + '단계' +
            ' <button type="button" class="btn-small btn-remove" style="float: right;" onclick="removeMilestone(this)">삭제</button>';
    });

    // 번호 업데이트 후 금액 검증도 실행
    validateTotalAmount();
}

// ═══════════════════════════════════════════════════════════════════════
// 금액 조정 함수 (마일스톤용)
// ═══════════════════════════════════════════════════════════════════════
function adjustAmount(button, delta) {
    const container = button.closest('.amount-input-group');
    const input = container.querySelector('input[name="milestoneAmount"]');
    if (input) {
        const currentValue = parseInt(input.value) || 0;
        const newValue = Math.max(0, currentValue + delta);
        input.value = newValue;
        validateTotalAmount();
    }
    return false;
}

// ═══════════════════════════════════════════════════════════════════════
// 금액 검증
// ═══════════════════════════════════════════════════════════════════════
function validateTotalAmount() {
    const budgetInput = document.getElementById('budget');
    if (!budgetInput) return;
    
    const budget = parseInt(budgetInput.value) || 0;
    
    const amountInputs = document.querySelectorAll('input[name="milestoneAmount"]');
    let totalAmount = 0;
    amountInputs.forEach(input => {
        totalAmount += parseInt(input.value) || 0;
    });
    
    // 합계 표시 업데이트
    const totalMilestoneAmount = document.getElementById('totalMilestoneAmount');
    if (totalMilestoneAmount) {
        totalMilestoneAmount.textContent = '₩ ' + totalAmount.toLocaleString();
    }
    
    // 남은 예산 표시 업데이트
    const remainingBudget = document.getElementById('remainingBudget');
    if (remainingBudget) {
        remainingBudget.textContent = '₩ ' + Math.max(0, budget - totalAmount).toLocaleString();
    }
    
    // 전체 예산 표시 업데이트
    const totalBudget = document.getElementById('totalBudget');
    if (totalBudget) {
        totalBudget.textContent = '₩ ' + budget.toLocaleString();
    }
    
    const warningDiv = document.getElementById('budgetWarning');
    if (!warningDiv) return;
    
    if (totalAmount > budget) {
        warningDiv.style.display = 'block';
        warningDiv.innerHTML = '⚠️ 단계별 금액 합계가 예산을 초과했습니다!';
        warningDiv.style.color = '#e74c3c';
    } else if (totalAmount === budget && totalAmount > 0) {
        warningDiv.style.display = 'block';
        warningDiv.innerHTML = '✓ 예산이 정확히 배분되었습니다!';
        warningDiv.style.color = '#27ae60';
    } else if (totalAmount > 0 && totalAmount < budget) {
        warningDiv.style.display = 'block';
        warningDiv.innerHTML = '💰 남은 예산: ₩' + (budget - totalAmount).toLocaleString() + ' (단계별로 배분해주세요)';
        warningDiv.style.color = '#f39c12';
    } else {
        warningDiv.style.display = 'none';
    }

    // 제출 버튼 활성화/비활성화 처리
    const submitBtn = document.getElementById('submitBtn');
    if (submitBtn) {
        if (totalAmount === budget && budget > 0) {
            submitBtn.disabled = false;
            submitBtn.style.opacity = '1';
            submitBtn.style.cursor = 'pointer';
        } else {
            submitBtn.disabled = true;
            submitBtn.style.opacity = '0.5';
            submitBtn.style.cursor = 'not-allowed';
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════
// 기술 스택 모달 함수 (전역)
// ═══════════════════════════════════════════════════════════════════════
function openContractTechStackModal() {
    console.log('openContractTechStackModal 호출됨');
    if (typeof openTechStackModal === 'undefined') {
        console.error('openTechStackModal 함수가 로드되지 않았습니다');
        alert('기술 스택 모달이 로드되지 않았습니다. 페이지를 새로고침해주세요.');
        return false;
    }
    
    openTechStackModal(function(areas, stacks) {
        contractSelectedAreas = areas;
        contractSelectedStacks = stacks;
        updateContractSelectionDisplay();
    }, contractSelectedAreas, contractSelectedStacks);
    return false;
}

// ═══════════════════════════════════════════════════════════════════════
// 선택 항목 표시 업데이트
// ═══════════════════════════════════════════════════════════════════════
function updateContractSelectionDisplay() {
    const areasDisplay = document.getElementById('contractSelectedAreasDisplay');
    const areasTags = document.getElementById('contractSelectedAreasTags');
    const areasSelect = document.getElementById('selectedPositions');
    
    if (contractSelectedAreas.length > 0 && areasDisplay) {
        areasDisplay.style.display = 'block';
        areasTags.innerHTML = '';
        areasSelect.innerHTML = '';
        contractSelectedAreas.forEach(area => {
            const tag = document.createElement('span');
            tag.className = 'tech-badge';
            tag.textContent = area.name || area;
            areasTags.appendChild(tag);
            
            // select에 option 추가
            const option = document.createElement('option');
            option.value = area.name || area;
            option.textContent = area.name || area;
            option.selected = true;
            areasSelect.appendChild(option);
        });
    } else {
        areasDisplay.style.display = 'none';
        areasSelect.innerHTML = '';
    }
    
    const stacksDisplay = document.getElementById('contractSelectedStacksDisplay');
    const stacksTags = document.getElementById('contractSelectedStacksTags');
    const stacksSelect = document.getElementById('selectedSkills');
    
    if (contractSelectedStacks.length > 0 && stacksDisplay) {
        stacksDisplay.style.display = 'block';
        stacksTags.innerHTML = '';
        stacksSelect.innerHTML = '';
        contractSelectedStacks.forEach(stack => {
            const tag = document.createElement('span');
            tag.className = 'tech-badge';
            tag.textContent = stack.name || stack;
            stacksTags.appendChild(tag);
            
            // select에 option 추가
            const option = document.createElement('option');
            option.value = stack.name || stack;
            option.textContent = stack.name || stack;
            option.selected = true;
            stacksSelect.appendChild(option);
        });
    } else {
        stacksDisplay.style.display = 'none';
        stacksSelect.innerHTML = '';
    }
}

// ═══════════════════════════════════════════════════════════════════════
// 다른 입력 필드 제거
// ═══════════════════════════════════════════════════════════════════════
function removeField(button) {
    const fieldDiv = button.closest('.field-item');
    if (fieldDiv) {
        fieldDiv.remove();
    }
}

// ═══════════════════════════════════════════════════════════════════════
// 다른 방식 추가
// ═══════════════════════════════════════════════════════════════════════
function addOtherMethod() {
    const checkbox = document.getElementById('otherMethodCheckbox');
    const otherGroup = document.getElementById('otherMethodGroup');
    
    if (checkbox.checked) {
        otherGroup.classList.add('show');
    } else {
        otherGroup.classList.remove('show');
        document.getElementById('otherMethod').value = '';
    }
}

// ═══════════════════════════════════════════════════════════════════════
// DOM 로드 완료 후 초기화
// ═══════════════════════════════════════════════════════════════════════
document.addEventListener('DOMContentLoaded', function() {
    console.log('Document ready - client_con_second.js loaded');
    
    // 마일스톤 번호 초기화
    updateMilestoneNumbers();
    
    // 초기 금액 검증 실행 (페이지 로드 시)
    validateTotalAmount();
    
    // 마일스톤 입력 변경 시 검증
    document.addEventListener('change', function(e) {
        if (e.target.name === 'milestoneAmount' || e.target.id === 'budget') {
            validateTotalAmount();
        }
    });
    
    // 마일스톤 입력 키업 시 검증
    document.addEventListener('keyup', function(e) {
        if (e.target.name === 'milestoneAmount' || e.target.id === 'budget') {
            validateTotalAmount();
        }
    });
});
