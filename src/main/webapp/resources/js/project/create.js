let currentStep = 1;

document.addEventListener('DOMContentLoaded', () => {
    updateUI();

    const revInput = document.getElementById('maxRevisionCount');
    if (revInput) {
        revInput.addEventListener('input', function () {
            if (this.value > 3) {
                alert('무상 수정 횟수는 최대 3회까지만 설정 가능합니다.');
                this.value = 3;
            }
        });
    }

    const budget = document.getElementById('budgetInput');
    if (budget) {
        budget.addEventListener('input', e => {
            let val = e.target.value.replace(/[^0-9]/g, '');
            e.target.value = val ? Number(val).toLocaleString() : '';
        });
    }

    const form = document.getElementById('projectForm');
    if (form) {
        form.addEventListener('submit', () => {
            if (budget) budget.value = budget.value.replace(/,/g, '');
        });
    }

    // 검색 방식 로직
    const searchInput = document.getElementById('stackSearchInput');
    const stackList = document.querySelector('.stack-list');
    if (searchInput && stackList) {
        searchInput.addEventListener('focus', () => {
            stackList.style.display = 'block';
        });
        searchInput.addEventListener('input', function () {
            const filter = this.value.toLowerCase();
            stackList.style.display = 'block';
            document.querySelectorAll('.stack-item').forEach(item => {
                const text = item.innerText.toLowerCase();
                if (item.classList.contains('selected')) {
                    item.style.display = 'none';
                } else {
                    item.style.display = text.includes(filter) ? 'block' : 'none';
                }
            });
        });
        document.addEventListener('click', (e) => {
            if (!searchInput.contains(e.target) && !stackList.contains(e.target)) {
                stackList.style.display = 'none';
            }
        });
    }
});

function updateUI() {
    document.querySelectorAll('.step-section').forEach(el => el.classList.remove('active'));
    document.getElementById('step' + currentStep).classList.add('active');
    window.scrollTo(0, 0);
}

function toggleStackUnknown(chk) {
    const searchInput = document.getElementById('stackSearchInput');
    const displayBox = document.getElementById('stackDisplayBox');

    if (chk.checked) {
        document.getElementById('selectedStackHidden').innerHTML = '';
        displayBox.innerHTML = '<span class="placeholder-text" style="color:#aaa;">전문가와 협의하여 결정합니다.</span>';
        searchInput.disabled = true;
        searchInput.value = '';
    } else {
        displayBox.innerHTML = '<span class="placeholder-text">아래 목록에서 선택하거나 검색해주세요.</span>';
        searchInput.disabled = false;
        searchInput.focus();
    }
}

function nextStep(targetStep) {
    const section = document.getElementById('step' + currentStep);
    let isValid = true;
    const isStackUnknown = document.getElementById('stackIdsUnknown') ? document.getElementById('stackIdsUnknown').checked : false;

    const inputs = section.querySelectorAll('input[required], textarea[required], select[required]');
    for (let input of inputs) {
        if (input.disabled) continue;
        if (input.type === 'radio') {
            const checked = section.querySelector(`input[name="${input.name}"]:checked`);
            if (!checked) {
                isValid = false;
                alert('필수 항목을 선택해주세요.');
                input.focus();
                break;
            }
        } else {
            if (!input.value.trim()) {
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

    if (isValid && currentStep === 2 && !isStackUnknown) {
        const posInputs = document.querySelectorAll('input[name="positionId"]');
        const stackInputs = document.querySelectorAll('input[name="stackIds"]');
        if (posInputs.length === 0 && stackInputs.length === 0) {
            alert("개발 영역 또는 기술 스택을 선택해주세요.");
            isValid = false;
        }
    }

    if (!isValid) return;

    if (targetStep === 5) {
        try {
            updatePreview();
        } catch (e) {
            console.error("미리보기 오류:", e);
        }
    }

    currentStep = targetStep;
    updateUI();
}

function prevStep(target) {
    currentStep = target;
    updateUI();
}

function selectCard(element) {
    const group = element.parentElement;
    group.querySelectorAll('.selection-card').forEach(el => el.classList.remove('selected'));
    element.classList.add('selected');
    element.querySelector('input[type="radio"]').checked = true;
}

function addStack(id, name, element) {
    if (document.getElementById('stackIdsUnknown').checked) {
        alert("'잘 모르겠어요'를 해제한 후 선택해주세요.");
        return;
    }
    const chk = document.getElementById('chk_stack_' + id);
    if (chk.checked) return;

    chk.checked = true;
    element.classList.add('selected');
    element.style.display = 'none';

    const displayBox = document.getElementById('stackDisplayBox');
    const placeholder = displayBox.querySelector('.placeholder-text');
    if (placeholder) placeholder.style.display = 'none';

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

    const searchInput = document.getElementById('stackSearchInput');
    searchInput.value = '';
    searchInput.focus();
}

function removeStack(id, name, btn) {
    btn.parentElement.remove();
    document.getElementById('chk_stack_' + id).checked = false;
    document.getElementById('hidden_stack_' + id).remove();

    document.querySelectorAll('.stack-item').forEach(item => {
        if (item.innerText === name) {
            item.classList.remove('selected');
            item.style.display = 'block';
        }
    });

    const displayBox = document.getElementById('stackDisplayBox');
    if (displayBox.querySelectorAll('.stack-tag').length === 0) {
        displayBox.querySelector('.placeholder-text').style.display = 'inline';
    }
}

function toggleStartType(radio) {
    const dateInput = document.getElementById('startDate');
    if (radio.value === 'ASAP') {
        dateInput.disabled = true;
        dateInput.value = '';
    } else {
        dateInput.disabled = false;
        dateInput.focus();
    }
}

function toggleYear(chk) {
    const input = document.getElementById('minYearInput');
    if (chk.checked) {
        input.disabled = true;
        input.value = '';
        input.style.backgroundColor = '#f5f5f5';
    } else {
        input.disabled = false;
        input.style.backgroundColor = '#fff';
        input.focus();
    }
}

function handleFileSelect(input) {
    const file = input.files[0];
    if (file) {
        document.getElementById('fileDisplayDefault').style.display = 'none';
        document.getElementById('fileDisplaySelected').style.display = 'flex';
        document.getElementById('fileNameDisplay').innerText = file.name;
        window.uploadedFileName = file.name;
    }
}

function formatDate(date) {
    const d = new Date(date);
    return `${d.getFullYear()}.${String(d.getMonth() + 1).padStart(2, '0')}.${String(d.getDate()).padStart(2, '0')}`;
}

// -----------------------------------------------------------
// [Step 5] 미리보기 업데이트 (새 디자인 대응)
// -----------------------------------------------------------
function updatePreview() {
    // 1. 제목 및 메타
    document.getElementById('previewTitle').innerText = document.querySelector('input[name="title"]').value;
    document.getElementById('previewRegDate').innerText = "등록일 " + formatDate(new Date());

    // 2. 설명
    document.getElementById('previewDescription').innerText = document.querySelector('textarea[name="description"]').value;

    // 3. 예산 (만원 단위)
    let rawBudget = document.getElementById('budgetInput').value.replace(/,/g, '');
    let budgetText = "0 만원";
    if (rawBudget) {
        let budgetMan = Math.floor(parseInt(rawBudget) / 10000);
        budgetText = budgetMan.toLocaleString() + "만원";
    }
    if (document.querySelector('input[name="budgetNegotiable"]').checked) {
        budgetText += ' (협의)';
    }
    document.getElementById('previewBudget').innerText = budgetText;

    // 4. 기간
    let durationText = document.getElementById('durationSelect').value;
    if (document.querySelector('input[name="durationNegotiable"]').checked) durationText += ' (조율 가능)';
    document.getElementById('previewDuration').innerText = durationText;

    // 5. 시작일
    const startType = document.querySelector('input[name="startType"]:checked').value;
    document.getElementById('previewStart').innerText = (startType === 'ASAP') ? "계약 후 즉시 시작" : document.getElementById('startDate').value;

    // 6. 마감일 (오늘 + 30일)
    let startDateVal = (startType === 'ASAP') ? new Date() : new Date(document.getElementById('startDate').value);
    if (isNaN(startDateVal.getTime())) startDateVal = new Date();
    startDateVal.setDate(startDateVal.getDate() + 30);
    document.getElementById('previewDeadline').innerText = formatDate(startDateVal);

    // 7. 커뮤니케이션 / 결제
    const commType = document.querySelector('input[name="communicateMethod"]:checked');
    document.getElementById('previewComm').innerText = commType ? commType.parentElement.innerText.trim() : '';

    const payType = document.querySelector('input[name="paymentMethod"]:checked');
    document.getElementById('previewPay').innerText = payType ? payType.parentElement.innerText.trim() : '';

    // 8. 기술 스택 & 분야
    const stackBox = document.getElementById('previewStacks');
    if (document.getElementById('stackIdsUnknown').checked) {
        stackBox.innerText = "전문가와 협의";
    } else {
        const posRadio = document.querySelector('input[name="positionId"]:checked');
        let posText = posRadio ? posRadio.parentElement.querySelector('strong').innerText : '';

        const tags = [];
        document.querySelectorAll('.stack-tag').forEach(tag => {
            tags.push(tag.innerText.replace('×', '').trim());
        });

        let combined = posText;
        if (tags.length > 0) combined += " / " + tags.join(', ');
        stackBox.innerText = combined;
    }

    // 9. 레벨 / 경력
    const levelSelect = document.querySelector('select[name="minLevel"]');
    const levelText = levelSelect.options[levelSelect.selectedIndex].text;
    const isYearUnknown = document.getElementById('minYearUnknown').checked;
    const yearText = isYearUnknown ? "경력 무관" : (document.getElementById('minYearInput').value + "년 이상");
    document.getElementById('previewLevelExp').innerText = `${levelText} / ${yearText}`;

    // 10. 수정 횟수
    document.getElementById('previewRevision').innerText = document.getElementById('maxRevisionCount').value + "회";

    // 11. 정책 및 파일 (표시 여부)
    const policyVal = document.querySelector('textarea[name="changePolicy"]').value.trim();
    const policyContainer = document.getElementById('previewPolicyContainer');
    if (policyVal) {
        policyContainer.style.display = 'block';
        document.getElementById('previewChangePolicy').innerText = policyVal;
    } else {
        policyContainer.style.display = 'none';
    }

    const fileContainer = document.getElementById('previewFileContainer');
    if (window.uploadedFileName) {
        fileContainer.style.display = 'block';
        document.getElementById('previewFileName').innerText = window.uploadedFileName;
    } else {
        fileContainer.style.display = 'none';
    }
}