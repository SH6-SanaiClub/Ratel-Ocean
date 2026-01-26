let currentProjectId = null;

$(document).ready(function() {
    console.log("Ratel-Ocean Manager Ready");
});

/* [탭 전환 기능] */
function switchProjectTab(status, btn) {
    // 1. 탭 버튼 스타일
    $('.tab-btn').removeClass('active');
    $(btn).addClass('active');

    // 2. 좌측 리스트 교체
    $('.project-list-group').hide();
    $('#list-' + status).fadeIn(200);

    // 3. 리스트 선택 초기화
    $('.custom-list-item').removeClass('active');

    // 4. 모든 패널 일단 숨김 (초기화)
    $('#defaultCenterPanel, #defaultRightPanel').hide();
    $('#ongoingCenterPanel, #ongoingRightPanel').hide();
    $('#completedCenterPanel, #completedRightPanel').hide();

    // 5. 선택된 탭에 맞는 패널 보이기
    if (status === 'ONGOING') {
        // [진행 중] 화면 보이기
        $('#ongoingCenterPanel, #ongoingRightPanel').show();

        // 초기화
        $('#ongoingProjectTitle').text('');
        $('#chatFreelancerName').text('프리랜서');
        $('#milestoneListArea').html(`
            <div style="text-align:center; padding-top:100px; color:#ccc;">
                <i class="fa-regular fa-folder-open" style="font-size:48px; margin-bottom:15px;"></i>
                <p>좌측 목록에서<br>프로젝트를 선택해주세요.</p>
            </div>
        `);

    } else if (status === 'COMPLETED') {
        // [완료] 화면 보이기
        $('#completedCenterPanel, #completedRightPanel').show();

        // 1) 텍스트/값 초기화
        $('#reviewProjectTitle').text('');
        $('#reviewComment').val('');
        $('#ratingValue').text('0점');
        $('input[name="rating"]').prop('checked', false);
        $('input[name="recontract"]').prop('checked', false);

        // 2) 화면 상태 초기화 (빈 화면 보이기, 폼 숨기기)
        $('#reviewEmptyState').show();      // "선택해주세요" 안내 보이기
        $('#reviewFormSection').hide();     // 리뷰 폼 숨기기 (삭제X)

        $('#recontractEmptyState').show();  // 우측 빈 화면 보이기
        $('#recontractFormSection').hide(); // 우측 폼 숨기기 (삭제X)

    } else {
        // [모집 중] 화면 보이기 (기본)
        $('#defaultCenterPanel, #defaultRightPanel').show();

        // 초기화
        $('#selectedProjectTitle').text('');
        $('#projectControlBar').hide();
        $('#applicantListArea').html(`
            <div style="text-align:center; padding-top:100px; color:#ccc;">
                <i class="fa-regular fa-folder-open" style="font-size:48px; margin-bottom:15px;"></i>
                <p>좌측 목록에서<br>프로젝트를 선택해주세요.</p>
            </div>
        `);
        $('#applicantDetailArea').html(`
            <div style="text-align:center; padding-top:100px; color:#ccc;">
                <i class="fa-regular fa-user" style="font-size:48px; margin-bottom:15px;"></i>
                <p>지원자를 선택하면<br>상세 정보가 표시됩니다.</p>
            </div>
        `);
    }
}

/* [1] 지원자 목록 조회 */
function loadApplicants(projectId, element) {
    currentProjectId = projectId;
    $('.custom-list-item').removeClass('active');
    $(element).addClass('active');

    const title = $(element).find('.item-main-text').text();
    $('#selectedProjectTitle').text(title);
    $('#projectControlBar').css('display', 'flex');

    $.ajax({
        url: contextPath + '/client/api/applicants',
        type: 'GET',
        data: { projectId: projectId },
        success: function(list) {
            renderList(list);
            $('#applicantDetailArea').html(`
                <div style="text-align:center; padding-top:100px; color:#ccc;">
                    <i class="fa-regular fa-user" style="font-size:48px; margin-bottom:15px;"></i>
                    <p>지원자를 선택하면<br>상세 정보가 표시됩니다.</p>
                </div>
            `);
        },
        error: function() { alert("목록을 불러오지 못했습니다."); }
    });
}

function renderList(list) {
    const target = $('#applicantListArea');
    target.empty();
    $('#applicantCountBadge').text(list.length + "명");

    if(!list || list.length === 0) {
        target.html('<div class="empty-list-msg">지원자가 없습니다.</div>');
        return;
    }

    let html = '';
    list.forEach(app => {
        let badgeStyle = "background:#eee; color:#666;";
        let statusText = "미열람";

        if(app.applicationStatus === 'VIEWED') { statusText = "열람함"; badgeStyle = "background:#E3F2FD; color:#1F7A8C;"; }
        else if(app.applicationStatus === 'OFFERED') { statusText = "제안중"; badgeStyle = "background:#E8F5E9; color:#2E7D32;"; }
        else if(app.applicationStatus === 'REJECTED') { statusText = "불합격"; badgeStyle = "background:#FFEBEE; color:#C62828;"; }
        else if(app.applicationStatus === 'CONTRACTED') { statusText = "계약완료"; badgeStyle = "background:#FFF3E0; color:#EF6C00;"; }

        html += `
            <div class="custom-list-item" id="item-${app.applicationId}" onclick="loadDetail(${app.applicationId}, this)">
                <div style="display:flex; justify-content:space-between; margin-bottom:5px;">
                    <span style="font-weight:700; color:#333;">${app.freelancerName}</span>
                    <span class="status-badge" style="font-size:11px; padding:2px 6px; border-radius:4px; font-weight:700; ${badgeStyle}">
                        ${statusText}
                    </span>
                </div>
                <div style="font-size:13px; color:#888;">
                    ${app.mainSkill}
                </div>
            </div>
        `;
    });
    target.html(html);
}

/* [2] 상세 정보 조회 */
function loadDetail(applicationId, element) {
    $('#applicantListArea .custom-list-item').removeClass('active');
    $(element).addClass('active');

    $.ajax({
        url: contextPath + '/client/api/applicant/' + applicationId,
        type: 'GET',
        success: function(data) {
            renderDetail(data);
            if(data.applicationStatus === 'VIEWED') {
                updateListItemBadge(applicationId, 'VIEWED');
            }
        },
        error: function() { alert("상세 정보를 불러오지 못했습니다."); }
    });
}

function renderDetail(data) {
    const skills = (data.skills && data.skills.length > 0) ? data.skills.join(', ') : '미등록';
    const status = data.applicationStatus;

    let imageHtml = '';
    if (data.profileImageUrl) {
        imageHtml = `<img src="${data.profileImageUrl}" class="detail-img" 
                      onerror="this.outerHTML='<div class=\'detail-img-icon\'><i class=\'fa-solid fa-user\'></i></div>'">`;
    } else {
        imageHtml = `<div class="detail-img-icon"><i class="fa-solid fa-user"></i></div>`;
    }

    let chatDisabled = "", offerDisabled = "", rejectDisabled = "";
    let chatStyle = "btn-outline", offerStyle = "btn-primary", rejectStyle = "btn-outline";

    if (status === 'REJECTED' || status === 'CONTRACTED' || status === 'CANCELED') {
        chatDisabled = "disabled"; offerDisabled = "disabled"; rejectDisabled = "disabled";
        chatStyle = "btn-disabled"; offerStyle = "btn-disabled"; rejectStyle = "btn-disabled";
    }

    const html = `
        <div class="detail-profile-header">
            ${imageHtml} <div class="detail-name">${data.freelancerName}</div>
            <div style="color:#1F7A8C; font-weight:700; margin-top:5px;">${status}</div>
        </div>
        
        <div class="detail-section">
            <span class="detail-label">자기소개</span>
            <div class="detail-content">${data.introduction || "내용 없음"}</div>
        </div>

        <div class="detail-section">
            <span class="detail-label">기술 스택</span>
            <div class="detail-content">${skills}</div>
        </div>

        <div class="action-btn-group" style="margin-top:auto;">
            <button class="btn-action ${chatStyle}" ${chatDisabled} onclick="updateStatus(${data.applicationId}, 'CHATTING')">1:1 채팅하기</button>
            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:10px; margin-top:10px;">
                <button class="btn-action ${offerStyle}" ${offerDisabled} onclick="updateStatus(${data.applicationId}, 'OFFERED')">계약 제안</button>
                <button class="btn-action ${rejectStyle}" style="border-color:#ddd; color:#888;" ${rejectDisabled} onclick="updateStatus(${data.applicationId}, 'REJECTED')">불합격</button>
            </div>
        </div>
    `;
    $('#applicantDetailArea').html(html);
}

/* [3] 상태 변경 */
function updateStatus(appId, status) {
    if(!confirm("상태를 변경하시겠습니까?")) return;

    $.ajax({
        url: contextPath + '/client/api/applicant/status',
        type: 'POST',
        data: { applicationId: appId, status: status },
        success: function() {
            alert("처리되었습니다.");
            loadDetail(appId, $(`#item-${appId}`));
            updateListItemBadge(appId, status);
        },
        error: function() { alert("오류가 발생했습니다."); }
    });
}

function updateListItemBadge(appId, status) {
    const badge = $(`#item-${appId} .status-badge`);
    if(status === 'VIEWED') badge.text("열람함").css({background:"#E3F2FD", color:"#1F7A8C"});
    else if(status === 'OFFERED') badge.text("제안중").css({background:"#E8F5E9", color:"#2E7D32"});
    else if(status === 'REJECTED') badge.text("불합격").css({background:"#FFEBEE", color:"#C62828"});
    else if(status === 'CONTRACTED') badge.text("계약완료").css({background:"#FFF3E0", color:"#EF6C00"});
}

/* [4] 유틸리티 */
function goToProjectDetail() { if(currentProjectId) window.open(contextPath + '/project/detail?projectId='+currentProjectId, '_blank'); }
function goEditProject() { if(currentProjectId) location.href = contextPath + '/project/edit/' + currentProjectId; }
function deleteProject() {
    if (!currentProjectId) return;
    if (confirm("정말 이 프로젝트를 삭제하시겠습니까?")) {
        $.ajax({
            url: contextPath + '/project/delete',
            type: 'POST',
            data: { projectId: currentProjectId },
            success: function(res) {
                if(res === 'success') { alert("삭제되었습니다."); location.reload(); }
                else alert("삭제 실패");
            },
            error: function() { alert("오류가 발생했습니다."); }
        });
    }
}