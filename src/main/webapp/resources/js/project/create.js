$(document).ready(function() {
    $('#description').summernote({
        height: 350,
        lang: 'ko-KR',
        toolbar: [ ['style', ['style']], ['font', ['bold', 'underline', 'clear']], ['para', ['ul', 'ol', 'paragraph']], ['insert', ['link']] ]
    });

    $('#stackSearch').on('input', function() {
        const val = $(this).val().toLowerCase();
        $('.stack-chip').each(function() {
            const text = $(this).text().toLowerCase();
            $(this).toggle(text.includes(val));
        });
    });

    toggleStartType($('input[name="startType"]:checked')[0]);

    // 폼 제출 시 데이터 전처리
    $('#projectForm').on('submit', function(e) {
        // 1. 공고 마감일 자동 계산 (오늘 + 30일)
        const today = new Date();
        today.setDate(today.getDate() + 30);
        const deadline = today.toISOString().split('T')[0];
        $('#deadlineDate').val(deadline);

        // 2. ASAP 선택 시 오늘 날짜를 startDate에 강제 주입
        if ($('input[name="startType"]:checked').val() === 'ASAP') {
            const now = new Date().toISOString().split('T')[0];
            $('#startDate').prop('disabled', false).val(now);
        }

        // 3. 예산 콤마 제거
        const budget = $('#budgetInput').val().replace(/,/g, '');
        $('#budgetInput').val(budget);
    });
});

function handleFileSelect(input) {
    if (input.files && input.files[0]) {
        $('#file-placeholder').hide();
        $('#file-selected').show();
        $('#file-name-display').text(input.files[0].name);
        window.uploadedFileName = input.files[0].name;
    }
}

function togglePosition(card) {
    $(card).toggleClass('selected');
    const checkbox = $(card).find('input[type="checkbox"]');
    checkbox.prop('checked', !checkbox.prop('checked'));
}

function toggleStack(item, stackName) {
    if ($('#stackIdsUnknown').is(':checked')) {
        alert("먼저 '잘 모르겠어요'를 해제해주세요.");
        return;
    }
    const checkbox = $(item).find('input[type="checkbox"]');
    const isSelected = !checkbox.prop('checked');
    checkbox.prop('checked', isSelected);
    const chipsDiv = $('#selectedChips');
    const placeholder = $('#stackPlaceholder');
    if (isSelected) {
        $(item).addClass('selected');
        placeholder.hide();
        chipsDiv.append(`<span class="sel-chip" id="chip-${checkbox.val()}">${stackName}</span>`);
    } else {
        $(item).removeClass('selected');
        $(`#chip-${checkbox.val()}`).remove();
        if (chipsDiv.children().length === 0) placeholder.show();
    }
}

function toggleStackUnknown(chk) {
    const container = $('#stackContainer');
    const chipsDiv = $('#selectedChips');
    const items = container.find('.stack-chip');
    if (chk.checked) {
        items.removeClass('selected').find('input').prop('checked', false);
        chipsDiv.empty();
        $('#stackPlaceholder').show();
        container.addClass('disabled');
    } else {
        container.removeClass('disabled');
    }
}

function inputNumberFormat(obj) {
    obj.value = String(obj.value.replace(/[^0-9]/g, '')).replace(/(\d)(?=(?:\d{3})+(?!\d))/g, '$1,');
}

function toggleStartType(radio) {
    const input = $('#startDate');
    if (radio.value === 'ASAP') {
        input.prop('disabled', true).val('');
        input.css('background', '#f5f5f5');
    } else {
        input.prop('disabled', false).focus();
        input.css('background', '#fff');
    }
}

function toggleYear(chk) {
    const input = $('#minYear');
    if (chk.checked) input.prop('disabled', true).val('');
    else input.prop('disabled', false).focus();
}

// 단계 이동 시 필수값 검증
function nextStep(step) {
    if (step === 2) {
        if (!$('#title').val().trim()) { alert('프로젝트 제목을 입력해주세요.'); $('#title').focus(); return; }
        if ($('#description').summernote('isEmpty')) { alert('상세 내용을 입력해주세요.'); return; }
    }
    if (step === 3) {
        if ($('input[name="positionIds"]:checked').length === 0) { alert('개발 분야를 하나 이상 선택해주세요.'); return; }
        if ($('input[name="stackIds"]:checked').length === 0 && !$('#stackIdsUnknown').is(':checked')) { alert('기술 스택을 선택하거나 "잘 모르겠어요"를 체크해주세요.'); return; }
    }
    if (step === 4) {
        if (!$('#budgetInput').val()) { alert('예산을 입력해주세요.'); $('#budgetInput').focus(); return; }
        if (!$('#estDuration').val()) { alert('예상 기간을 선택해주세요.'); $('#estDuration').focus(); return; }
        if ($('input[name="startType"]:checked').val() === 'DATE' && !$('#startDate').val()) { alert('시작 예정일을 선택해주세요.'); $('#startDate').focus(); return; }
        if (!$('#maxRevisionCount').val()) { alert('수정 횟수를 입력해주세요.'); $('#maxRevisionCount').focus(); return; }
    }

    $('.step-section').removeClass('active');
    $('#step' + step).addClass('active');
    $('.step').removeClass('active');
    $(`.step[data-step="${step}"]`).addClass('active');
    window.scrollTo(0, 0);
    if (step === 4) updatePreview();
}

function prevStep(step) {
    nextStep(step);
}

function updatePreview() {
    $('#prev-title').text($('#title').val());
    const positions = [];
    $('.position-card.selected').each(function () {
        positions.push($(this).find('span').text());
    });
    $('#prev-positions').text(positions.join(', ') || '미지정');

    let raw = $('#budgetInput').val().replace(/,/g, '');
    let text = '0만원';
    if (raw && !isNaN(raw)) {
        let man = Math.floor(parseInt(raw) / 10000);
        text = man.toLocaleString() + '만원';
    }
    if ($('input[name="budgetNegotiable"]').is(':checked')) text += ' (협의 가능)';
    $('#prev-budget').text(text);

    let duration = $('#estDuration').val();
    if ($('input[name="durationNegotiable"]').is(':checked')) duration += ' (협의 가능)';
    $('#prev-duration').text(duration || '-');

    const startType = $('input[name="startType"]:checked').val();
    $('#prev-start').text(startType === 'ASAP' ? '즉시 착수 가능' : $('#startDate').val());

    $('#prev-desc').html($('#description').summernote('code'));

    $('#prev-stacks').empty();
    if ($('#stackIdsUnknown').is(':checked')) {
        $('#prev-stacks').html('<span>전문가와 협의</span>');
    } else {
        $('.stack-chip.selected').each(function () {
            $('#prev-stacks').append(`<span>${$(this).text().trim()}</span>`);
        });
    }

    const levelText = $('select[name="minLevel"] option:selected').text();
    const yearText = $('#minYearUnknown').is(':checked') ? '경력 무관' : $('#minYear').val() + '년 이상';
    $('#prev-level-text').text(levelText);
    $('#prev-year-text').text(yearText);

    const meetingVal = $('input[name="communicateMethod"]:checked').val();
    $('#prev-meeting').text(meetingVal === 'ONLINE' ? '온라인 (화상/메신저)' : '오프라인 (대면)');

    // FULL / MILESTONE 값을 기준으로 텍스트 표시
    const payVal = $('input[name="paymentMethod"]:checked').val();
    $('#prev-payment').text(payVal === 'FULL' ? '일괄 지급 (종료 후)' : '분할 지급 (단계별)');

    $('#prev-revision').text($('input[name="maxRevisionCount"]').val() + '회');

    const policy = $('#changePolicy').val();
    if (policy.trim()) {
        $('#prev-policy-area').show();
        $('#prev-policy-text').text(policy);
    } else {
        $('#prev-policy-area').hide();
    }

    const fileName = $('#file-name-display').text();
    if (fileName) {
        $('#prev-file-area').show();
        $('#prev-filename').text(fileName);
    } else {
        $('#prev-file-area').hide();
    }
}

function initEditMode(stackList) {
    if (!stackList || stackList.length === 0) return;

    stackList.forEach(stack => {
        if (stack.category === 'POSITION') {
            const posInput = $(`.position-card input[value='${stack.stackId}']`);
            if (posInput.length > 0) {
                if (!posInput.prop('checked')) {
                    togglePosition(posInput.closest('.position-card')[0]);
                }
            }
        }
        else if (stack.category === 'SKILL') {
            const stackInput = $(`.stack-chip input[value='${stack.stackId}']`);
            if (stackInput.length > 0) {
                const chip = stackInput.closest('.stack-chip');
                const name = chip.text().trim();
                if (!stackInput.prop('checked')) {
                    toggleStack(chip[0], name);
                }
            }
        }
    });
}