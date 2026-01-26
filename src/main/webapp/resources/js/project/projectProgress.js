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

    $.ajax({
        url: contextPath + '/client/api/progress/milestones',
        type: 'GET',
        data: {projectId: projectId},
        success: function (data) {
            renderMilestones(data);
        },
        error: function () {
            // 에러 시에도 메시지 표시
            $('#milestoneListArea').html('<div style="text-align:center; padding:40px; color:#ccc;">정보를 불러오지 못했습니다.</div>');
        }
    });
}

function renderMilestones(data) {
    const target = $('#milestoneListArea');
    target.empty();

    if (!data) {
        target.html('<div style="text-align:center; padding:40px; color:#ccc;">진행 정보를 찾을 수 없습니다.</div>');
        return;
    }

    // 데이터가 있으면 무조건 표시
    $('#ongoingControlButtons').show();
    $('#projectDetailSummary').show();

    const startStr = data.startDate ? new Date(data.startDate).toISOString().split('T')[0].replace(/-/g, '/') : '-';
    const endStr = data.endDate ? new Date(data.endDate).toISOString().split('T')[0].replace(/-/g, '/') : '-';

    $('#projectPeriodDisplay').text(`${startStr} ~ ${endStr}`);
    $('#sumBudget').text('₩ ' + (data.budget || 0).toLocaleString());
    $('#sumComm').text(data.communicateMethod || '-');
    $('#sumPayment').text(data.paymentMethod || '-');
    $('#sumRevision').text(data.maxRevisionCount || 0);

    $('#btnDownloadContract').off('click').on('click', function() {
        if(data.originContractUrl) location.href = data.originContractUrl;
        else alert('등록된 계약서가 없습니다.');
    });

    if (data.freelancerName) $('#chatFreelancerName').text(data.freelancerName);

    // 마일스톤 리스트
    if (!data.milestones || data.milestones.length === 0) {
        target.html('<div style="text-align:center; padding:40px; color:#ccc;">등록된 마일스톤이 없습니다.</div>');
        return;
    }

    let html = '';
    data.milestones.forEach(m => {
        let statusBadge = '<span class="ms-status st-WAITING">대기중</span>';
        let btnHtml = '';
        const safeAmount = (m.amount || 0).toLocaleString();

        if (m.status === 'REQUESTED') {
            statusBadge = '<span class="ms-status st-REQUESTED">지급 요청됨</span>';
            btnHtml = `<button class="btn-pay-approve" onclick="payMilestone(${m.milestoneId})">
                         <i class="fa-solid fa-check"></i> ₩ ${safeAmount} 지급 승인
                       </button>`;
        } else if (m.status === 'PAID') {
            statusBadge = '<span class="ms-status st-PAID">지급 완료</span>';
        }

        const dateStr = m.dueDate ? new Date(m.dueDate).toISOString().split('T')[0] : '-';

        html += `
            <div class="milestone-card">
                <div class="ms-header">
                    <div><span class="ms-step">${m.stepOrder}단계</span> <span class="ms-title">${m.milestoneName}</span></div>
                    ${statusBadge}
                </div>
                <div class="ms-details">
                    <span>지급 예정일: ${dateStr}</span>
                    <span class="ms-amount">₩ ${safeAmount}</span>
                </div>
                ${btnHtml}
            </div>`;
    });
    target.html(html);
}

function payMilestone(milestoneId) {
    if (!confirm("지급을 승인하시겠습니까?")) return;
    $.ajax({
        url: contextPath + '/client/api/progress/pay',
        type: 'POST',
        data: {milestoneId: milestoneId},
        success: function () {
            alert("지급이 승인되었습니다.");
            const activeId = $('.custom-list-item.active').attr('onclick').match(/\d+/)[0];
            loadProjectProgress(activeId, $('.custom-list-item.active'));
        },
        error: function() { alert("오류가 발생했습니다."); }
    });
}

function terminateProject() {
    if(confirm("정말 계약을 파기하시겠습니까?")) alert("준비중입니다.");
}
function completeProject() {
    if(confirm("프로젝트를 완료하시겠습니까?")) alert("준비중입니다.");
}