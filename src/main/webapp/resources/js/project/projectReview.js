let currentReviewContractId = null;

function loadCompletedProject(projectId, element) {
    $('.custom-list-item').removeClass('active');
    $(element).addClass('active');

    $('#defaultCenterPanel, #defaultRightPanel').hide();
    $('#ongoingCenterPanel, #ongoingRightPanel').hide();
    $('#completedCenterPanel, #completedRightPanel').show();

    $.ajax({
        url: contextPath + '/client/api/review/info',
        type: 'GET',
        data: { projectId: projectId },
        success: function(data) {
            renderReviewPage(data);
        },
        error: function() { alert("정보를 불러오지 못했습니다."); }
    });
}

function renderReviewPage(data) {
    if(!data) return;
    currentReviewContractId = data.contractId;

    $('#reviewEmptyState').hide();
    $('#reviewFormSection').show();
    $('#recontractEmptyState').hide();
    $('#recontractFormSection').show();

    $('#reviewProjectTitle').text(data.projectTitle);
    const start = data.startDate ? new Date(data.startDate).toISOString().split('T')[0] : '?';
    const end = data.endDate ? new Date(data.endDate).toISOString().split('T')[0] : '?';
    $('#reviewPeriod').text(`${start} ~ ${end}`);
    $('#centerFreelancerName, #rightFreelancerName').text(data.freelancerName);

    // [별점]
    if(data.rating) {
        const radio = document.querySelector(`input[name="rating"][value="${data.rating}"]`);
        if(radio) radio.checked = true;
        $('#ratingValue').text(parseInt(data.rating) + "점");
    } else {
        const radios = document.getElementsByName('rating');
        for(let r of radios) r.checked = false;
        $('#ratingValue').text("0점");
    }

    // [내용]
    $('#reviewComment').val(data.reviewContent || '');

    // [재계약 의사] (수정됨: renewalIntended 사용)
    // 데이터가 null이 아닐 때만 체크
    if(data.renewalIntended !== null && data.renewalIntended !== undefined) {
        // true/false 값을 문자열로 변환하여 라디오 버튼 찾기
        const valStr = data.renewalIntended.toString();
        const radio = document.querySelector(`input[name="recontract"][value="${valStr}"]`);
        if(radio) radio.checked = true;
    } else {
        const radios = document.getElementsByName('recontract');
        for(let r of radios) r.checked = false;
    }
}

document.addEventListener('change', function(e) {
    if(e.target && e.target.name === 'rating') {
        const val = parseInt(e.target.value);
        const display = document.getElementById('ratingValue');
        if(display) display.innerText = val + "점";
    }
});

function submitReview() {
    const ratingVal = $('input[name="rating"]:checked').val();
    const comment = $('#reviewComment').val();
    const recontract = $('input[name="recontract"]:checked').val();

    if(!ratingVal) { alert("별점을 선택해주세요."); return; }
    if(!recontract) { alert("재계약 의사를 선택해주세요."); return; }

    if(!confirm("리뷰를 작성하시겠습니까?\n작성한 리뷰는 수정이 불가능합니다.")) {
        return;
    }

    const data = {
        contractId: currentReviewContractId,
        rating: parseInt(ratingVal),
        reviewContent: comment,
        renewalIntended: recontract === 'true'
    };

    $.ajax({
        url: contextPath + '/client/api/review/submit',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(data),
        success: function() {
            alert("리뷰가 저장되었습니다.");
            location.reload();
        },
        error: function() { alert("저장에 실패했습니다."); }
    });
}