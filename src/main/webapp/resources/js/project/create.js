let currentStep = 1;

document.addEventListener('DOMContentLoaded', () => {
    updateUI();

    // 1. 무상 수정 횟수 제한 (최대 3회)
    const revInput = document.getElementById('maxRevisionCount');
    if(revInput) {
        revInput.addEventListener('input', function() {
            if (this.value > 3) {
                alert('무상 수정 횟수는 최대 3회까지만 설정 가능합니다.');
                this.value = 3;
            }
        });
    }

    // 2. 기술 스택 검색 기능
    const searchInput = document.getElementById('stackSearchInput');
    if(searchInput) {
        searchInput.addEventListener('input', function() {
            const filter = this.value.toLowerCase();
            document.querySelectorAll('.stack-item').forEach(item => {
                const text = item.innerText.toLowerCase();
                if (!item.classList.contains('selected')) {
                    item.style.display = text.includes(filter) ? 'block' : 'none';
                }
            });
        });
    }

    // 3. 예산 입력 콤마 자동 처리
    const budget = document.getElementById('budgetInput');
    if(budget) {
        budget.addEventListener('input', e => {
            let val = e.target.value.replace(/[^0-9]/g, '');
            e.target.value = val ? Number(val).toLocaleString() : '';
        });
    }

    // 4. 폼 제출 시 예산 콤마 제거
    const form = document.getElementById('projectForm');
    if(form) {
        form.addEventListener('submit', () => {
            if(budget) budget.value = budget.value.replace(/,/g, '');
        });
    }
});

// UI 업데이트 (단계 전환)
function updateUI() {
    document.querySelectorAll('.step-section').forEach(el => el.classList.remove('active'));
    document.getElementById('step' + currentStep).classList.add('active');
    window.scrollTo(0, 0);
}

// 다음 단계로 이동 (유효성 검사 포함)
function nextStep(targetStep) {
    const section = document.getElementById('step' + currentStep);
    let isValid = true;

    const inputs = section.querySelectorAll('input[required], textarea[required], select[required]');
    for(let input of inputs) {
        if(input.disabled) continue;

        if(input.type === 'radio') {
            const checked = section.querySelector(`input[name="${input.name}"]:checked`);
            if(!checked) {
                isValid = false;
                alert('필수 항목을 선택해주세요.');
                input.focus();
                break;
            }
        } else {
            if(!input.value.trim()) {
                isValid = false;
                alert('필수 항목을 입력해주세요.');
                input.focus();
                input.style.borderColor = '#ff4d4f';
                break;
            } else {
                input.style.borderColor = '#ddd';
            }
        }
    }

    if (!isValid) return;

    if (targetStep === 5) updatePreview();
    currentStep = targetStep;
    updateUI();
}

// 이전 단계로 이동
function prevStep(target) {
    currentStep = target;
    updateUI();
}

// 카드 선택 (라디오 버튼)
function selectCard(element) {
    const group = element.parentElement;
    group.querySelectorAll('.selection-card').forEach(el => el.classList.remove('selected'));
    element.classList.add('selected');
    element.querySelector('input[type="radio"]').checked = true;
}

// 기술 스택 추가
function addStack(id, name, element) {
    const chk = document.getElementById('chk_stack_' + id);
    if (chk.checked) return;

    chk.checked = true;
    element.classList.add('selected');

    const displayBox = document.getElementById('stackDisplayBox');
    const placeholder = displayBox.querySelector('.placeholder-text');
    if(placeholder) placeholder.style.display = 'none';

    const tag = document.createElement('span');
    tag.className = 'stack-tag';
    tag.innerHTML = `${name} <span class="remove-btn" onclick="removeStack('${id}', '${name}', this)">&times;</span>`;
    displayBox.appendChild(tag);

    const hiddenArea = document.getElementById('selectedStackHidden');
    const hidden = document.createElement('input');
    hidden.type = 'hidden';
    hidden.name = 'stackIds';
    hidden.value = id;
    hidden.id = 'hidden_stack_' + id;
    hiddenArea.appendChild(hidden);
}

// 기술 스택 삭제
function removeStack(id, name, btn) {
    btn.parentElement.remove();
    document.getElementById('chk_stack_' + id).checked = false;
    document.getElementById('hidden_stack_' + id).remove();

    document.querySelectorAll('.stack-item').forEach(item => {
        if(item.innerText === name) item.classList.remove('selected');
    });

    const displayBox = document.getElementById('stackDisplayBox');
    if (displayBox.querySelectorAll('.stack-tag').length === 0) {
        displayBox.querySelector('.placeholder-text').style.display = 'inline';
    }
}

// 시작일 라디오 버튼 토글
function toggleStartType(radio) {
    const dateInput = document.getElementById('startDate');
    if(radio.value === 'ASAP') {
        dateInput.disabled = true;
        dateInput.value = '';
    } else {
        dateInput.disabled = false;
        dateInput.focus();
    }
}

// 경력 무관 체크박스 토글
function toggleYear(chk) {
    const input = document.getElementById('minYearInput');
    if(chk.checked) {
        input.disabled = true;
        input.value = '';
        input.style.backgroundColor = '#f5f5f5';
    } else {
        input.disabled = false;
        input.style.backgroundColor = '#fff';
        input.focus();
    }
}

// 파일 선택 처리 (5GB 제한)
function handleFileSelect(input) {
    const file = input.files[0];
    if(file) {
        const maxSize = 5 * 1024 * 1024 * 1024; // 5GB

        if(file.size > maxSize) {
            alert("파일 용량은 최대 5GB까지만 업로드 가능합니다.");
            input.value = "";
            return;
        }

        document.getElementById('fileDisplayDefault').style.display = 'none';
        document.getElementById('fileDisplaySelected').style.display = 'flex';
        document.getElementById('fileNameDisplay').innerText = file.name;
    }
}

// 미리보기
function updatePreview() {
    // 1. 기본 정보
    document.getElementById('previewTitle').innerText = document.querySelector('input[name="title"]').value;
    document.getElementById('previewDescription').innerText = document.querySelector('textarea[name="description"]').value;

    // 2. 카테고리
    const pos = document.querySelector('input[name="positionId"]:checked');
    if(pos) document.getElementById('previewCategory').innerText = pos.parentElement.querySelector('strong').innerText;

    // 3. 예산 및 협의 배지
    document.getElementById('previewBudget').innerText = document.getElementById('budgetInput').value + "원";
    const isBudgetNego = document.querySelector('input[name="budgetNegotiable"]').checked;
    const budgetBadge = document.getElementById('previewBudgetNego');
    if(budgetBadge) budgetBadge.style.display = isBudgetNego ? 'inline-block' : 'none';

    // 4. 기간 및 조율 배지
    const durationVal = document.getElementById('durationSelect').value;
    document.getElementById('previewDuration').innerText = durationVal ? durationVal : "미선택";
    const isDurationNego = document.querySelector('input[name="durationNegotiable"]').checked;
    const durationBadge = document.getElementById('previewDurationNego');
    if(durationBadge) durationBadge.style.display = isDurationNego ? 'inline-block' : 'none';

    // 5. 시작일 및 협의 배지
    const startType = document.querySelector('input[name="startType"]:checked').value;
    document.getElementById('previewStart').innerText = (startType === 'ASAP') ? "계약 후 즉시" : document.getElementById('startDate').value;

    // 시작일 협의 여부
    const isStartNego = document.querySelector('input[name="startNegotiable"]').checked;
    const startBadge = document.getElementById('previewStartNego');
    if(startBadge) startBadge.style.display = isStartNego ? 'inline-block' : 'none';


    // 6. 기술 스택
    const stackBox = document.getElementById('previewStacks');
    stackBox.innerHTML = '';
    const tags = document.querySelectorAll('.stack-tag');
    if(tags.length > 0) {
        tags.forEach(tag => {
            const span = document.createElement('span');
            // CSS에 정의한 .round-badge-style 클래스를 적용하여 모양 통일
            span.className = 'round-badge-style';
            span.innerText = tag.innerText.replace('×', '').trim();
            stackBox.appendChild(span);
        });
    } else {
        stackBox.innerHTML = '<span style="color:#aaa;">선택된 기술이 없습니다.</span>';
    }

    // 7. 메타 정보
    const level = document.querySelector('select[name="minLevel"]');
    document.getElementById('previewLevelBadge').innerText = level.options[level.selectedIndex].text;

    const isYearUnknown = document.getElementById('minYearUnknown').checked;
    document.getElementById('previewYearBadge').innerText = isYearUnknown ? "경력 무관" : (document.getElementById('minYearInput').value + "년 이상");

    const comm = document.querySelector('input[name="communicateMethod"]:checked');
    if(comm) document.getElementById('previewComm').innerText = comm.parentElement.querySelector('strong').innerText;

    const pay = document.querySelector('input[name="paymentMethod"]:checked');
    if(pay) document.getElementById('previewPay').innerText = pay.parentElement.querySelector('strong').innerText;

    const revCount = document.getElementById('maxRevisionCount').value;
    document.getElementById('previewRevision').innerText = "무상 수정 " + revCount + "회";

    // 8. 파일
    const fileName = document.getElementById('fileNameDisplay').innerText;
    const fileArea = document.getElementById('previewFileArea');
    if(fileName) {
        fileArea.style.display = 'block';
        document.getElementById('previewFileName').innerText = fileName;
    } else {
        fileArea.style.display = 'none';
    }
}