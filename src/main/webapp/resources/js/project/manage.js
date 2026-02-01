let currentProjectId = null;
let currentSelectedFreelancerId = null;

$(document).ready(function () {
    console.log("Ratel-Ocean Manager Ready");
});

/* [탭 전환 기능] */
function switchProjectTab(status, btn) {
    $('.tab-btn').removeClass('active');
    $(btn).addClass('active');

    // 1. 리스트 영역 전환
    $('.project-list-group').hide();
    $('#list-' + status).fadeIn(200);

    // 2. 리스트 선택 효과 제거
    $('.custom-list-item').removeClass('active');

    // 3. 모든 패널 일단 숨기기
    $('#defaultCenterPanel, #defaultRightPanel').hide();
    $('#ongoingCenterPanel, #ongoingRightPanel').hide();
    $('#completedCenterPanel, #completedRightPanel').hide();

    // 4. 탭별 상세 초기화 및 표시 로직
    if (status === 'ONGOING') {
        $('#ongoingCenterPanel, #ongoingRightPanel').show();

        $('#ongoingProjectTitle').text('');
        $('#chatFreelancerName').text('프리랜서');

        $('#ongoingFreelancerDisplay').empty(); // 프리랜서 이름/아이콘 비우기
        $('#projectPeriodDisplay').text('');    // 날짜 비우기
        $('#projectDetailSummary').hide();      // 예산/요약 박스 숨기기
        $('#ongoingControlButtons').hide();     // 하단 버튼 숨기기

        // 빈 화면 메시지
        $('#milestoneListArea').html(`
            <div style="text-align:center; padding-top:100px; color:#ccc;">
                <i class="fa-regular fa-folder-open" style="font-size:48px; margin-bottom:15px;"></i>
                <p>좌측 목록에서<br>프로젝트를 선택해주세요.</p>
            </div>
        `);

    } else if (status === 'COMPLETED') {
        $('#completedCenterPanel, #completedRightPanel').show();
        $('#reviewProjectTitle').text('');
        $('#reviewComment').val('');
        $('#ratingValue').text('0점');
        $('input[name="rating"]').prop('checked', false);
        $('input[name="recontract"]').prop('checked', false);

        $('#reviewEmptyState').show();
        $('#reviewFormSection').hide();
        $('#recontractEmptyState').show();
        $('#recontractFormSection').hide();

    } else {
        // [모집 중 탭] (RECRUITING)
        $('#defaultCenterPanel, #defaultRightPanel').show();
        $('#selectedProjectTitle').text('');

        // 상세 보기 버튼 숨김
        $('#btnGoFreelancerProfile').hide();
        $('#applicantCountBadge').text('0명');
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

    // 프로젝트 변경 시 상세 보기 버튼 숨김
    $('#btnGoFreelancerProfile').hide();

    $.ajax({
        url: contextPath + '/client/api/applicants',
        type: 'GET',
        data: {projectId: projectId},
        success: function (list) {
            renderList(list);
            $('#applicantDetailArea').html(`
                <div style="text-align:center; padding-top:100px; color:#ccc;">
                    <i class="fa-regular fa-user" style="font-size:48px; margin-bottom:15px;"></i>
                    <p>지원자를 선택하면<br>상세 정보가 표시됩니다.</p>
                </div>
            `);
        },
        error: function () {
            alert("목록을 불러오지 못했습니다.");
        }
    });
}

function renderList(list) {
    const target = $('#applicantListArea');
    target.empty();
    $('#applicantCountBadge').text(list.length + "명");

    if (!list || list.length === 0) {
        target.html('<div class="empty-list-msg">지원자가 없습니다.</div>');
        return;
    }

    let html = '';
    list.forEach(app => {
        let badgeStyle = "background:#eee; color:#666;";
        let statusText = "미열람";

        if (app.applicationStatus === 'VIEWED') {
            statusText = "열람함";
            badgeStyle = "background:#E3F2FD; color:#1F7A8C;";
        } else if (app.applicationStatus === 'OFFERED') {
            statusText = "제안중";
            badgeStyle = "background:#E8F5E9; color:#2E7D32;";
        } else if (app.applicationStatus === 'REJECTED') {
            statusText = "불합격";
            badgeStyle = "background:#FFEBEE; color:#C62828;";
        } else if (app.applicationStatus === 'CONTRACTED') {
            statusText = "계약완료";
            badgeStyle = "background:#FFF3E0; color:#EF6C00;";
        }

        // 평점 처리 (null이면 0.0)
        const ratingVal = app.rating ? app.rating.toFixed(1) : "0.0";

        html += `
            <div class="custom-list-item" id="item-${app.applicationId}" onclick="loadDetail(${app.applicationId}, this)">
                <div style="display:flex; justify-content:space-between; margin-bottom:5px;">
                    <div style="display:flex; align-items:center; gap:6px;">
                        <span style="font-weight:700; color:#333;">${app.freelancerName}</span>
                        <span style="font-size:12px; color:#f39c12; font-weight:600;">
                            <i class="fa-solid fa-star"></i> ${ratingVal}
                        </span>
                    </div>
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

function loadDetail(applicationId, element) {
    $('#applicantListArea .custom-list-item').removeClass('active');
    $(element).addClass('active');

    $.ajax({
        url: contextPath + '/client/api/applicant/' + applicationId,
        type: 'GET',
        success: function (data) {
            renderDetail(data);
            if (data.applicationStatus === 'VIEWED') {
                updateListItemBadge(applicationId, 'VIEWED');
            }
        },
        error: function () {
            alert("상세 정보를 불러오지 못했습니다.");
        }
    });
}

function renderDetail(data) {
    const skills = (data.skills && data.skills.length > 0) ? data.skills.join(', ') : '미등록';
    const status = data.applicationStatus;

    currentSelectedFreelancerId = data.freelancerId;
    $('#btnGoFreelancerProfile').css('display', 'flex');

    // 1. 프로필 이미지
    let imgSrc = data.profileImageUrl;

    if (imgSrc && imgSrc !== 'null') {
        if (!imgSrc.startsWith('/') && !imgSrc.startsWith('http')) {
            imgSrc = contextPath + "/resources/upload/profile/" + encodeURIComponent(imgSrc);
        }
        else if (imgSrc.startsWith('/')) {
            imgSrc = contextPath + imgSrc;
        }
    }

    let imageHtml = '';

    if (imgSrc && imgSrc !== 'null') {
        imageHtml = `
        <div style="position:relative; width:80px; height:80px; margin: 0 auto;">
            <img src="${imgSrc}" class="detail-img" 
                 style="width:100%; height:100%; border-radius:50%; object-fit:cover; border:1px solid #eee; display:block;"
                 onerror="this.style.display='none'; this.parentElement.querySelector('.alt-icon').style.display='flex';">
            
            <div class="alt-icon" style="display:none; width:100%; height:100%; border-radius:50%; background:#f0f0f0; align-items:center; justify-content:center; font-size:30px; color:#ccc; position:absolute; top:0; left:0;">
                <i class="fa-solid fa-user"></i>
            </div>
        </div>`;
    } else {
        imageHtml = `<div style="width:80px; height:80px; border-radius:50%; background:#f0f0f0; display:flex; align-items:center; justify-content:center; font-size:30px; color:#ccc; margin: 0 auto;"><i class="fa-solid fa-user"></i></div>`;
    }

    // 2. 평점 처리
    const ratingVal = data.rating ? data.rating.toFixed(1) : "0.0";

    // 3. 학력 정보 처리 (-/-/- 형식)
    const school = data.schoolName || "-";
    const major = data.major || "-";
    const gradStatus = data.graduationStatus || "-";
    const eduInfo = `${school} / ${major} / ${gradStatus}`;

    // 4. 링크 버튼 생성
    let linksHtml = '';
    if (data.githubUrl) {
        linksHtml += `<a href="${data.githubUrl}" target="_blank" style="margin-right:10px; color:#333; text-decoration:none; font-size:20px;"><i class="fa-brands fa-github"></i></a>`;
    }
    if (data.websiteUrl) {
        linksHtml += `<a href="${data.websiteUrl}" target="_blank" style="color:#333; text-decoration:none; font-size:18px;"><i class="fa-solid fa-globe"></i></a>`;
    }
    if (linksHtml === '') linksHtml = '<span style="color:#ccc; font-size:13px;">등록된 링크 없음</span>';


    // 버튼 스타일 (기존 유지)
    let chatDisabled = "", offerDisabled = "", rejectDisabled = "";
    let chatStyle = "btn-outline", offerStyle = "btn-primary", rejectStyle = "btn-secondary";

    if (status === 'REJECTED' || status === 'CONTRACTED' || status === 'CANCELED') {
        chatDisabled = "disabled"; offerDisabled = "disabled"; rejectDisabled = "disabled";
        chatStyle = "btn-disabled"; offerStyle = "btn-disabled"; rejectStyle = "btn-disabled";
    }

    const html = `
        <div class="detail-profile-header" style="text-align:center; padding-bottom:20px; border-bottom:1px solid #eee;">
            ${imageHtml}
            
            <div style="margin-top:10px; display:flex; align-items:center; justify-content:center; gap:8px;">
                <span class="detail-name" style="font-size:18px; font-weight:700;">${data.freelancerName}</span>
                <span style="color:#f39c12; font-weight:600; font-size:14px;">
                    <i class="fa-solid fa-star"></i> ${ratingVal}
                </span>
            </div>

            <div style="margin-top:5px; font-size:13px; color:#666;">
                ${eduInfo}
            </div>
        </div>
        
        <div class="detail-section" style="margin-top:20px;">
            <span class="detail-label">자기소개</span>
            <div class="detail-content" style="white-space:pre-wrap;">${data.introduction || "내용 없음"}</div>
        </div>

        <div class="detail-section">
            <span class="detail-label">기술 스택</span>
            <div class="detail-content">${skills}</div>
            <div style="margin-top:8px; display:flex; align-items:center;">
                ${linksHtml}
            </div>
        </div>

        <div class="action-btn-group" style="margin-top:auto; padding-top:20px;">
            <button class="btn-action ${chatStyle}" ${chatDisabled} onclick="updateStatus(${data.applicationId}, 'CHATTING')">
                1:1 채팅하기
            </button>
            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:10px; margin-top:10px;">
                <button class="btn-action ${offerStyle}" ${offerDisabled} onclick="goToContractForm(${currentProjectId}, ${data.freelancerId})">
                    계약 제안
                </button>
                <button class="btn-action ${rejectStyle}" ${rejectDisabled} onclick="updateStatus(${data.applicationId}, 'REJECTED')">
                    불합격
                </button>
            </div>
        </div>
    `;
    $('#applicantDetailArea').html(html);
}

function goFreelancerProfileDetail() {
    if (currentSelectedFreelancerId) {
        window.open(contextPath + '/profile/' + currentSelectedFreelancerId, '_blank');
    }
}

function updateStatus(appId, status) {
    if (!confirm("상태를 변경하시겠습니까?")) return;

    $.ajax({
        url: contextPath + '/client/api/applicant/status',
        type: 'POST',
        data: {applicationId: appId, status: status},
        success: function () {
            alert("처리되었습니다.");
            loadDetail(appId, $(`#item-${appId}`));
            updateListItemBadge(appId, status);
        },
        error: function () {
            alert("오류가 발생했습니다.");
        }
    });
}

function updateListItemBadge(appId, status) {
    const badge = $(`#item-${appId} .status-badge`);
    if (status === 'VIEWED') badge.text("열람함").css({background: "#E3F2FD", color: "#1F7A8C"});
    else if (status === 'OFFERED') badge.text("제안중").css({background: "#E8F5E9", color: "#2E7D32"});
    else if (status === 'REJECTED') badge.text("불합격").css({background: "#FFEBEE", color: "#C62828"});
    else if (status === 'CONTRACTED') badge.text("계약완료").css({background: "#FFF3E0", color: "#EF6C00"});
}

function goToProjectDetail() {
    if (currentProjectId) window.open(contextPath + '/project/detail?projectId=' + currentProjectId, '_blank');
}

function goEditProject() {
    if (currentProjectId) location.href = contextPath + '/project/edit/' + currentProjectId;
}

function deleteProject() {
    if (!currentProjectId) return;
    if (confirm("정말 이 프로젝트를 삭제하시겠습니까?")) {
        $.ajax({
            url: contextPath + '/project/delete',
            type: 'POST',
            data: {projectId: currentProjectId},
            success: function (res) {
                if (res === 'success') {
                    alert("삭제되었습니다.");
                    location.reload();
                } else alert("삭제 실패");
            },
            error: function () {
                alert("오류가 발생했습니다.");
            }
        });
    }
}

function goToContractForm(projectId, freelancerId) {
    if (!projectId || !freelancerId) {
        alert('프로젝트와 프리랜서를 선택해주세요.');
        return;
    }
    const url = contextPath + '/client/contract/form?projectId=' + projectId + '&freelancerId=' + freelancerId;
    window.location.href = url;
}