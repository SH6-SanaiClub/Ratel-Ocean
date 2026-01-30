/**
 * projectProgress.js
 * 클라이언트 프로젝트 진행 관리 - 마일스톤 지급 기능
 * PayoutController API 연동 + 비밀번호 인증
 */

// 전역 변수
let currentProjectData = null;
let pendingPayoutAction = null; // {type: 'approve'|'release'|'reject', milestoneId, contractId, amount}

/**
 * 프로젝트 진행 정보 로드
 */
function loadProjectProgress(projectId, element) {
    $('.custom-list-item').removeClass('active');
    $(element).addClass('active');

    const title = $(element).find('.item-main-text').text().trim();
    $('#ongoingProjectTitle').text(title);

    $('.manage-grid-layout > .card:eq(1)').hide();
    $('.manage-grid-layout > .card:eq(2)').hide();

    $('#ongoingCenterPanel').show();
    $('#ongoingRightPanel').show();

    // 초기화
    $('#ongoingControlButtons').hide();
    $('#projectDetailSummary').hide();
    $('#milestoneListArea').html('<div style="padding:20px; text-align:center;">불러오는 중...</div>');
    $('#ongoingFreelancerDisplay').text('');

    $.ajax({
        url: contextPath + '/client/api/progress/milestones',
        type: 'GET',
        data: {projectId: projectId},
        success: function (data) {
            currentProjectData = data;
            currentProjectData.projectId = projectId;
            renderMilestones(data);

            $('#ongoingFreelancerDisplay').text("담당자 : " + data.freelancerName);
        },
        error: function () {
            $('#milestoneListArea').html('<div style="text-align:center; padding:40px; color:#ccc;">정보를 불러오지 못했습니다.</div>');
        }
    });
}

/**
 * 마일스톤 목록 렌더링
 */
function renderMilestones(data) {
    const target = $('#milestoneListArea');
    target.empty();

    if (!data) {
        target.html('<div style="text-align:center; padding:40px; color:#ccc;">진행 정보를 찾을 수 없습니다.</div>');
        return;
    }

    $('#ongoingControlButtons').show();
    $('#projectDetailSummary').show();

    if (data.freelancerName) {
        $('#ongoingFreelancerDisplay').html('<i class="fa-solid fa-user" style="color:#1F7A8C; margin-right:5px;"></i> ' + data.freelancerName);
        $('#chatFreelancerName').text(data.freelancerName);
    }

    const startStr = data.startDate ? new Date(data.startDate).toISOString().split('T')[0].replace(/-/g, '/') : '-';
    const endStr = data.endDate ? new Date(data.endDate).toISOString().split('T')[0].replace(/-/g, '/') : '-';

    $('#projectPeriodDisplay').text(startStr + ' ~ ' + endStr);
    $('#sumBudget').text('₩ ' + (data.budget || 0).toLocaleString());
    $('#sumComm').text(data.communicateMethod || '-');
    $('#sumPayment').text(data.paymentMethod || '-');
    $('#sumRevision').text(data.maxRevisionCount || 0);

    $('#btnDownloadContract').off('click').on('click', function() {
        if(data.originContractUrl) location.href = data.originContractUrl;
        else alert('등록된 계약서가 없습니다.');
    });

    // 마일스톤 리스트 렌더링
    if (!data.milestones || data.milestones.length === 0) {
        target.html('<div style="text-align:center; padding:40px; color:#ccc;">등록된 마일스톤이 없습니다.</div>');
        return;
    }

    let html = '';
    data.milestones.forEach(function(m) {
        const safeAmount = (m.amount || 0).toLocaleString();
        const dateStr = m.dueDate ? new Date(m.dueDate).toISOString().split('T')[0] : '-';

        // 상태별 뱃지 및 버튼 설정
        let statusBadge = '';
        let btnHtml = '';

        switch(m.status) {
            case 'WAITING':
                statusBadge = '<span class="ms-status st-WAITING">⏳ 결제 대기</span>';
                break;

            case 'DEPOSITED':
                statusBadge = '<span class="ms-status st-DEPOSITED">💳 에스크로 보관</span>';
                btnHtml = '<button class="btn-pay-direct" onclick="openPayoutModal(\'release\', ' + m.milestoneId + ', ' + m.contractId + ', ' + m.amount + ')">' +
                    '<i class="fa-solid fa-paper-plane"></i> ₩ ' + safeAmount + ' 직접 지급</button>';
                break;

            case 'REQUESTED':
                statusBadge = '<span class="ms-status st-REQUESTED">📤 지급 요청됨</span>';
                btnHtml = '<div class="btn-group-payout">' +
                    '<button class="btn-pay-approve" onclick="openPayoutModal(\'approve\', ' + m.milestoneId + ', ' + m.contractId + ', ' + m.amount + ')">' +
                    '<i class="fa-solid fa-check"></i> 승인</button>' +
                    '<button class="btn-pay-reject" onclick="openPayoutModal(\'reject\', ' + m.milestoneId + ', ' + m.contractId + ', ' + m.amount + ')">' +
                    '<i class="fa-solid fa-times"></i> 거부</button>' +
                    '</div>';
                break;

            case 'PAID':
                statusBadge = '<span class="ms-status st-PAID">✅ 지급 완료</span>';
                break;

            default:
                statusBadge = '<span class="ms-status">' + (m.status || '-') + '</span>';
        }

        html += '<div class="milestone-card' + (m.status === 'REQUESTED' ? ' requested' : '') + '">' +
            '<div class="ms-header">' +
            '<div><span class="ms-step">' + m.stepOrder + '단계</span> <span class="ms-title">' + (m.milestoneName || '') + '</span></div>' +
            statusBadge +
            '</div>' +
            '<div class="ms-details">' +
            '<span>예정일: ' + dateStr + '</span>' +
            '<span class="ms-amount">₩ ' + safeAmount + '</span>' +
            '</div>' +
            (btnHtml ? '<div class="ms-actions">' + btnHtml + '</div>' : '') +
            '</div>';
    });

    target.html(html);
}

/**
 * 비밀번호 인증 모달 열기
 */
function openPayoutModal(actionType, milestoneId, contractId, amount) {
    pendingPayoutAction = {
        type: actionType,
        milestoneId: milestoneId,
        contractId: contractId,
        amount: amount
    };

    // 모달 내용 설정
    let title = '';
    let desc = '';
    const amountStr = (amount || 0).toLocaleString();

    switch(actionType) {
        case 'approve':
            title = '💰 지급 승인';
            desc = '프리랜서에게 ₩' + amountStr + '을 지급합니다.';
            break;
        case 'release':
            title = '💸 직접 지급';
            desc = '프리랜서에게 ₩' + amountStr + '을 직접 지급합니다.';
            break;
        case 'reject':
            title = '❌ 지급 거부';
            desc = '지급 요청을 거부합니다. 프리랜서가 다시 요청할 수 있습니다.';
            break;
    }

    $('#payoutModalTitle').text(title);
    $('#payoutModalDesc').text(desc);
    $('#payoutPassword').val('');
    $('#payoutModal').show();
    $('#payoutPassword').focus();
}

/**
 * 비밀번호 인증 모달 닫기
 */
function closePayoutModal() {
    $('#payoutModal').hide();
    pendingPayoutAction = null;
    $('#payoutPassword').val('');
}

/**
 * 비밀번호 확인 후 지급 처리
 */
function confirmPayout() {
    const password = $('#payoutPassword').val();

    if (!password) {
        alert('비밀번호를 입력해주세요.');
        $('#payoutPassword').focus();
        return;
    }

    if (!pendingPayoutAction) {
        alert('처리할 작업이 없습니다.');
        closePayoutModal();
        return;
    }

    const action = pendingPayoutAction;
    let url = '';
    let data = {};

    switch(action.type) {
        case 'approve':
            url = contextPath + '/payout/milestone/approve';
            data = { milestoneId: action.milestoneId, password: password };
            break;
        case 'release':
            url = contextPath + '/payout/milestone/release';
            data = { contractId: action.contractId, milestoneId: action.milestoneId, password: password };
            break;
        case 'reject':
            url = contextPath + '/payout/milestone/reject';
            data = { milestoneId: action.milestoneId, password: password };
            break;
    }

    // 버튼 비활성화
    $('#payoutConfirmBtn').prop('disabled', true).text('처리 중...');

    $.ajax({
        url: url,
        type: 'POST',
        data: data,
        success: function(response) {
            closePayoutModal();

            if (response.success) {
                let msg = '';
                switch(action.type) {
                    case 'approve':
                    case 'release':
                        msg = '지급이 완료되었습니다.';
                        if (response.walletBalance !== undefined) {
                            msg += '\n프리랜서 지갑 잔액: ₩' + response.walletBalance.toLocaleString();
                        }
                        break;
                    case 'reject':
                        msg = '지급 요청을 거부했습니다.';
                        break;
                }
                alert(msg);

                // 목록 새로고침
                refreshCurrentProject();
            } else {
                alert(response.message || '처리 중 오류가 발생했습니다.');
            }
        },
        error: function(xhr) {
            let errorMsg = '처리 중 오류가 발생했습니다.';
            try {
                const resp = JSON.parse(xhr.responseText);
                if (resp.message) errorMsg = resp.message;
            } catch(e) {}
            alert(errorMsg);
        },
        complete: function() {
            $('#payoutConfirmBtn').prop('disabled', false).text('확인');
        }
    });
}

/**
 * 현재 선택된 프로젝트 새로고침
 */
function refreshCurrentProject() {
    const activeItem = $('.custom-list-item.active');
    if (activeItem.length > 0 && currentProjectData && currentProjectData.projectId) {
        loadProjectProgress(currentProjectData.projectId, activeItem[0]);
    }
}

/**
 * Enter 키로 비밀번호 제출
 */
$(document).on('keypress', '#payoutPassword', function(e) {
    if (e.which === 13) {
        confirmPayout();
    }
});

/**
 * 모달 외부 클릭 시 닫기
 */
$(document).on('click', '#payoutModal', function(e) {
    if (e.target === this) {
        closePayoutModal();
    }
});

// 기존 함수 유지
function terminateProject() {
    if(confirm("정말 계약을 파기하시겠습니까?")) alert("준비중입니다.");
}

function completeProject() {
    if(confirm("프로젝트를 완료하시겠습니까?")) alert("준비중입니다.");
}