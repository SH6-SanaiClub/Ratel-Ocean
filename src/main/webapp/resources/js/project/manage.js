let currentProjectId = null;

$(document).ready(function() {
    console.log("Ratel-Ocean System Ready");
});

/* [1] 프로젝트 선택 */
function loadApplicants(projectId, element) {
    currentProjectId = projectId;
    $('.custom-list-item').removeClass('active');
    $(element).addClass('active');

    // 프로젝트 제목 가져오기
    const projectTitle = $(element).find('.item-main-text').text().trim();
    $('#selectedProjectTitle').text(projectTitle);
    $('#projectControlBar').css('display', 'flex');

    $.ajax({
        url: contextPath + '/client/api/applicants',
        type: 'GET',
        data: { projectId: projectId },
        success: function(list) {
            renderList(list);
            $('#applicantDetailArea').html(`
                <div class="empty-state">
                    <i class="fa-regular fa-user"></i>
                    <p>지원자를 선택해주세요.</p>
                </div>
            `);
        },
        error: function(xhr) { alert("목록 로드 실패"); }
    });
}

/* [2] 프로젝트 수정 이동 */
function goEditProject() {
    if (!currentProjectId) {
        alert("수정할 프로젝트를 먼저 선택해주세요.");
        return;
    }
    location.href = contextPath + '/project/edit/' + currentProjectId;
}

/* [3] 프로젝트 삭제 */
function deleteProject() {
    if (!currentProjectId) {
        alert("삭제할 프로젝트를 먼저 선택해주세요.");
        return;
    }
    if (confirm("정말 이 프로젝트를 삭제하시겠습니까?\n삭제 후에는 복구할 수 없습니다.")) {
        $.ajax({
            url: contextPath + '/project/delete',
            type: 'POST',
            data: { projectId: currentProjectId },
            success: function(res) {
                if(res === 'success') {
                    alert("프로젝트가 삭제되었습니다.");
                    location.reload();
                } else {
                    alert("삭제 실패");
                }
            },
            error: function(xhr) { alert("서버 통신 오류"); }
        });
    }
}

/* [4] 상세 페이지 바로가기 */
function goToProjectDetail() {
    if (!currentProjectId) {
        alert("프로젝트를 선택해주세요.");
        return;
    }
    window.open(contextPath + '/project/detail?projectId=' + currentProjectId, '_blank');
}

/* --- 리스트 렌더링 관련 (기존 코드) --- */
function renderList(list) {
    const target = $('#applicantListArea');
    target.empty();
    $('#applicantCountBadge').text(list.length).show();

    if (!list || list.length === 0) {
        target.html(`
            <div class="empty-state">
                <i class="fa-regular fa-folder-open"></i>
                <p>지원자가 없습니다.</p>
            </div>
        `);
        return;
    }

    let html = '';
    list.forEach(app => {
        let badgeClass = "badge-gray";
        let statusText = "미열람";

        if(app.applicationStatus === 'VIEWED') { statusText = "열람함"; badgeClass = "badge-secondary"; }
        else if(app.applicationStatus === 'CHATTING') { statusText = "대화중"; badgeClass = "badge-secondary"; }
        else if(app.applicationStatus === 'OFFERED') { statusText = "제안중"; badgeClass = "badge-primary"; }
        else if(app.applicationStatus === 'CONTRACTED') { statusText = "계약완료"; badgeClass = "badge-primary"; }
        else if(app.applicationStatus === 'REJECTED') { statusText = "불합격"; badgeClass = "badge-gray"; }
        else if(app.applicationStatus === 'CANCELED') { statusText = "취소됨"; }

        const isCanceled = app.applicationStatus === 'CANCELED';
        const clickAction = isCanceled ? '' : `onclick="loadDetail(${app.applicationId}, this)"`;
        const opacity = isCanceled ? 'opacity:0.5;' : '';
        let ratingDisplay = app.rating ? app.rating : '-';

        html += `
            <div class="custom-list-item" id="item-${app.applicationId}" style="${opacity}" ${clickAction}>
                <div class="item-header">
                    <span class="item-main-text">${app.freelancerName}</span>
                    <span class="badge ${badgeClass} badge-area">${statusText}</span>
                </div>
                <div class="applicant-info-row">
                    <span><span class="skill-tag">${app.mainSkill}</span> 경력 ${app.careerYear}년</span>
                    <span class="rating-star"><i class="fa-solid fa-star"></i> ${ratingDisplay}</span>
                </div>
            </div>
        `;
    });
    target.html(html);
}

function loadDetail(appId, element) {
    $('.custom-list-item').removeClass('active');
    $(element).addClass('active');

    $.ajax({
        url: contextPath + '/client/api/applicant/' + appId,
        type: 'GET',
        success: function(data) {
            renderDetail(data);
            if (data.applicationStatus === 'VIEWED') {
                updateBadgeUI(appId, 'VIEWED');
            }
        },
        error: function() { alert("상세 정보 로드 실패"); }
    });
}

function changeStatus(appId, newStatus) {
    if(!confirm("정말 상태를 변경하시겠습니까?")) return;

    $.ajax({
        url: contextPath + '/client/api/applicant/status',
        type: 'POST',
        data: { applicationId: appId, status: newStatus },
        success: function() {
            alert("상태가 변경되었습니다.");
            loadDetail(appId, $(`#item-${appId}`));
            updateBadgeUI(appId, newStatus);
        },
        error: function() { alert("상태 변경 실패"); }
    });
}

function updateBadgeUI(appId, status) {
    const badge = $(`#item-${appId} .badge-area`);
    let text = "미열람";
    let css = "badge-gray";

    if(status === 'VIEWED') { text = "열람함"; css = "badge-secondary"; }
    else if(status === 'CHATTING') { text = "대화중"; css = "badge-secondary"; }
    else if(status === 'OFFERED') { text = "제안중"; css = "badge-primary"; }
    else if(status === 'CONTRACTED') { text = "계약완료"; css = "badge-primary"; }
    else if(status === 'REJECTED') { text = "불합격"; css = "badge-gray"; }

    badge.removeClass('badge-gray badge-secondary badge-primary').addClass(css).text(text);
}

/* 상세 화면 그리기 */
function renderDetail(data) {
    const defaultImg = contextPath + '/resources/img/default_profile.png';
    let skillsText = (data.skills && data.skills.length > 0) ? data.skills.join(', ') : '-';
    let ratingHtml = `★ ${data.rating ? data.rating : '-'} / 5.0`;

    let portfolioHtml = '<span style="color:#999;">등록된 포트폴리오가 없습니다.</span>';
    if (data.portfolioUrl) {
        portfolioHtml = `<a href="${data.portfolioUrl}" target="_blank" style="color:#1F7A8C; text-decoration:underline;">
                            <i class="fa-solid fa-link"></i> 포트폴리오 보기
                         </a>`;
    }

    const status = data.applicationStatus;

    // 1. 기본 버튼 설정 (style 속성 추가)
    let chatBtn = {
        text: '1:1 채팅하기',
        disabled: '',
        onclick: `changeStatus(${data.applicationId}, 'CHATTING')`,
        class: 'btn-outline',
        style: ''
    };
    let offerBtn = {
        text: '계약 제안',
        disabled: '',
        onclick: `changeStatus(${data.applicationId}, 'OFFERED')`,
        class: 'btn-primary',
        style: ''
    };
    let rejectBtn = {
        text: '불합격 처리',
        disabled: '',
        onclick: `changeStatus(${data.applicationId}, 'REJECTED')`,
        class: 'btn-outline',
        style: 'border-color:#ddd; color:#666;'
    };

    // 2. 상태별 버튼 스타일 변경 로직
    if (status === 'CHATTING') {
        chatBtn = { text: '대화 진행 중', disabled: 'disabled', onclick: '', class: 'btn-secondary', style: 'opacity:1;' };
    }
    else if (status === 'OFFERED') {
        chatBtn = { text: '대화 진행 중', disabled: 'disabled', onclick: '', class: 'btn-secondary', style: 'opacity:1;' };
        offerBtn = { text: '제안 완료됨', disabled: 'disabled', onclick: '', class: 'btn-secondary', style: 'opacity:1;' };
    }
    else if (status === 'CONTRACTED') {
        chatBtn = { text: '계약 완료', disabled: 'disabled', onclick: '', class: 'btn-secondary', style: '' };
        offerBtn = { text: '계약 완료', disabled: 'disabled', onclick: '', class: 'btn-secondary', style: '' };
        rejectBtn = { text: '-', disabled: 'disabled', onclick: '', class: 'btn-outline', style: 'opacity:0;' }; // 안 보이게
    }
    // [핵심 수정] 불합격 시 버튼을 아주 흐리게(0.3) 처리
    else if (status === 'REJECTED' || status === 'CANCELED') {
        const dimStyle = "opacity: 0.3; cursor: not-allowed;";

        chatBtn.disabled = 'disabled';
        chatBtn.style = dimStyle; // 채팅 버튼 흐리게

        offerBtn.disabled = 'disabled';
        offerBtn.style = dimStyle; // 제안 버튼 흐리게

        rejectBtn = {
            text: '불합격됨',
            disabled: 'disabled',
            onclick: '',
            class: 'btn-outline',
            style: "background:#f5f5f5; color:#999; border:1px solid #ddd; cursor:not-allowed;"
        };
    }

    const html = `
        <div class="detail-profile-header">
            <img src="${data.profileImageUrl || defaultImg}" class="detail-img">
            <div class="detail-name">${data.freelancerName}</div>
            <div class="detail-rating">${ratingHtml}</div>
        </div>

        <div class="detail-section">
            <span class="detail-label">자기소개</span>
            <div class="detail-content">${data.introduction || "소개 없음"}</div>
        </div>
        <div class="detail-section">
            <span class="detail-label">기술/경력</span>
            <div class="detail-content">${data.careerYear}년차 · ${skillsText}</div>
        </div>
        <div class="detail-section">
            <span class="detail-label">포트폴리오</span>
            <div class="detail-content">${portfolioHtml}</div>
        </div>

        <div style="margin-top:auto; display:grid; gap:10px;">
            <button class="${chatBtn.class}" ${chatBtn.disabled} onclick="${chatBtn.onclick}" style="${chatBtn.style}">
                <i class="fa-regular fa-comments"></i> ${chatBtn.text}
            </button>
            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:10px;">
                <button class="${offerBtn.class}" ${offerBtn.disabled} onclick="${offerBtn.onclick}" style="${offerBtn.style}">
                    ${offerBtn.text}
                </button>
                <button class="${rejectBtn.class}" ${rejectBtn.disabled} onclick="${rejectBtn.onclick}" style="${rejectBtn.style}">
                    ${rejectBtn.text}
                </button>
            </div>
        </div>
    `;
    $('#applicantDetailArea').html(html);
}