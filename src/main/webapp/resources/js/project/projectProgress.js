function loadProjectProgress(projectId, element) {
    $('.custom-list-item').removeClass('active');
    $(element).addClass('active');

    const title = $(element).find('.item-main-text').text().trim();
    $('#ongoingProjectTitle').text(title);

    $('.manage-grid-layout > .card:eq(1)').hide(); // 기존 지원자 목록 카드
    $('.manage-grid-layout > .card:eq(2)').hide(); // 기존 상세 프로필 카드

    $('#ongoingCenterPanel').show();
    $('#ongoingRightPanel').show();

    // 3. 마일스톤 데이터 로드
    $.ajax({
        url: contextPath + '/client/api/progress/milestones',
        type: 'GET',
        data: {projectId: projectId},
        success: function (list) {
            renderMilestones(list);
            // 채팅 연결 포인트
        },
        error: function () {
            alert("진행 정보를 불러오지 못했습니다.");
        }
    });
}

function renderMilestones(list) {
    const target = $('#milestoneListArea');
    target.empty();

    if (!list || list.length === 0) {
        target.html('<div style="text-align:center; padding:40px; color:#ccc;">등록된 마일스톤이 없습니다.</div>');
        return;
    }

    if (list[0].freelancerName) $('#chatFreelancerName').text(list[0].freelancerName);

    let html = '';
    list.forEach(m => {
        let statusBadge = '<span class="ms-status st-WAITING">대기중</span>';
        let btnHtml = '';

        if (m.status === 'REQUESTED') {
            statusBadge = '<span class="ms-status st-REQUESTED">지급 요청됨</span>';
            btnHtml = `<button class="btn-pay-approve" onclick="payMilestone(${m.milestoneId})">
                         <i class="fa-solid fa-check"></i> ₩ ${m.amount.toLocaleString()} 지급 승인
                       </button>`;
        } else if (m.status === 'PAID') {
            statusBadge = '<span class="ms-status st-PAID">지급 완료</span>';
        }

        const dateStr = m.dueDate ? new Date(m.dueDate).toISOString().split('T')[0] : '-';

        html += `
            <div class="milestone-card">
                <div class="ms-header">
                    <div>
                        <span class="ms-step">${m.stepOrder}단계</span>
                        <span class="ms-title">${m.milestoneName}</span>
                    </div>
                    ${statusBadge}
                </div>
                <div class="ms-details">
                    <span>지급 예정일: ${dateStr}</span>
                    <span class="ms-amount">₩ ${m.amount.toLocaleString()}</span>
                </div>
                ${btnHtml}
            </div>
        `;
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
            $('.custom-list-item.active').find('.payment-req-badge').remove();

            const activeId = $('.custom-list-item.active').attr('onclick').match(/\d+/)[0];
            loadProjectProgress(activeId, $('.custom-list-item.active'));
        }
    });
}