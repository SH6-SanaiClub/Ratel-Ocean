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
        if(input.disabled) continue; // 비활성화된 항목 패스

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

// 시작일 라디오 버튼 토글 (ASAP vs 날짜선택)
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

// 파일 선택 처리
function handleFileSelect(input) {
    const file = input.files[0];
    if(file) {
        // 5GB 용량 체크 로직
        const maxSize = 5 * 1024 * 1024 * 1024; // 5GB (바이트 단위)

        if(file.size > maxSize) {
            alert("파일 용량은 최대 5GB까지만 업로드 가능합니다.");
            input.value = ""; // 선택된 파일 초기화
            return; // 함수 종료
        }

        document.getElementById('fileDisplayDefault').style.display = 'none';
        document.getElementById('fileDisplaySelected').style.display = 'flex';
        document.getElementById('fileNameDisplay').innerText = file.name;
    }
}

// 미리보기 데이터 업데이트
function updatePreview() {
    // 1. 기본 정보
    document.getElementById('previewTitle').innerText = document.querySelector('input[name="title"]').value;
    document.getElementById('previewDescription').innerText = document.querySelector('textarea[name="description"]').value;

    // 2. 카테고리
    const pos = document.querySelector('input[name="positionId"]:checked');
    if(pos) document.getElementById('previewCategory').innerText = pos.parentElement.querySelector('strong').innerText;

    // 3. 예산
    document.getElementById('previewBudget').innerText = document.getElementById('budgetInput').value + "원";

    // 4. 기간 (드롭다운 값 가져오기)
    const durationVal = document.getElementById('durationSelect').value;
    document.getElementById('previewDuration').innerText = durationVal ? durationVal : "미선택";

    // 5. 시작일
    const startType = document.querySelector('input[name="startType"]:checked').value;
    document.getElementById('previewStart').innerText = (startType === 'ASAP') ? "계약 후 즉시" : document.getElementById('startDate').value;

    // 6. 기술 스택 태그
    const stackBox = document.getElementById('previewStacks');
    stackBox.innerHTML = '';
    document.querySelectorAll('.stack-tag').forEach(tag => {
        const span = document.createElement('span');
        // 미리보기용 태그 스타일
        span.style.cssText = "background:#f1f1f1; padding:5px 12px; border-radius:20px; font-size:13px; margin-right:5px; display:inline-block; margin-bottom:5px; border:1px solid #ddd;";
        span.innerText = tag.innerText.replace('×', '');
        stackBox.appendChild(span);
    });

    // 7. 숙련도 및 경력
    const level = document.querySelector('select[name="minLevel"]');
    document.getElementById('previewLevelBadge').innerText = level.options[level.selectedIndex].text;
    const isYearUnknown = document.getElementById('minYearUnknown').checked;
    document.getElementById('previewYearBadge').innerText = isYearUnknown ? "경력 무관" : (document.getElementById('minYearInput').value + "년 이상");

    // 8. 소통 및 대금 방식
    const comm = document.querySelector('input[name="communicateMethod"]:checked');
    if(comm) document.getElementById('previewComm').innerText = comm.parentElement.querySelector('strong').innerText;

    const pay = document.querySelector('input[name="paymentMethod"]:checked');
    if(pay) document.getElementById('previewPay').innerText = pay.parentElement.querySelector('strong').innerText;

    // 9. 수정 횟수
    const revCount = document.getElementById('maxRevisionCount').value;
    document.getElementById('previewRevision').innerText = "무상 수정 " + revCount + "회";

    // 10. 첨부 파일
    const fileName = document.getElementById('fileNameDisplay').innerText;
    if(fileName) {
        document.getElementById('previewFileArea').style.display = 'block';
        document.getElementById('previewFileName').innerText = fileName;
    }
}