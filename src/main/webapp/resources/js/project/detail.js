$(document).ready(function() {
    console.log("프로젝트 상세 페이지 로드 완료");

    // 탭 메뉴 클릭 이벤트
    $('.tab').on('click', function() {
        $('.tab').removeClass('active');
        $(this).addClass('active');
    });
});

/**
 * 1. 지원하기 <-> 지원취소 토글 로직
 */
function toggleApply() {
    const btn = document.getElementById('btnApplyToggle');
    const proposeBtn = document.getElementById('btnPropose');
    const chatBtn = document.getElementById('btnChat');
    const countSpan = document.getElementById('applyCount');

    if (!btn) return;

    // 현재 버튼 상태 확인
    const isCancel = btn.classList.contains('cancel');

    let confirmMsg = isCancel
        ? "지원을 취소하시겠습니까?"
        : "이 프로젝트에 지원하시겠습니까?";

    if (!confirm(confirmMsg)) return;

    const urlParams = new URLSearchParams(window.location.search);
    const projectId = urlParams.get('projectId');

    if (!projectId) {
        alert("프로젝트 정보를 찾을 수 없습니다.");
        return;
    }

    $.ajax({
        url: 'apply/toggle',
        type: 'POST',
        data: { projectId: projectId },
        success: function(response) {

            if (response.result === 'FAIL') {
                alert(response.message);
                if (response.message.includes("로그인")) location.href = '/login';
                return;
            }

            // 현재 화면에 표시된 숫자 가져오기
            let currentCount = parseInt(countSpan.innerText) || 0;

            if (response.status === 'APPLIED') {
                // 지원 완료
                btn.classList.add('cancel');
                btn.innerHTML = '<i class="fa-solid fa-xmark"></i> 지원 취소';

                if (proposeBtn) proposeBtn.style.display = 'flex';
                if (chatBtn) chatBtn.disabled = false;

                if (countSpan) countSpan.innerText = currentCount + 1;

                alert("지원이 완료되었습니다!");

            } else if (response.status === 'CANCELED') {
                // 지원 취소
                btn.classList.remove('cancel');
                btn.innerHTML = '<i class="fa-solid fa-paper-plane"></i> 지원하기';

                if (proposeBtn) proposeBtn.style.display = 'none';
                if (chatBtn) chatBtn.disabled = true;

                // 0보다 작아지지 않게 방어
                if (countSpan && currentCount > 0) {
                    countSpan.innerText = currentCount - 1;
                }

                alert("지원이 취소되었습니다.");
            }
        },
        error: function(xhr, status, error) {
            console.error("에러 발생:", error);
            if(xhr.status === 404) {
                alert("경로 에러(404)");
            } else {
                alert("서버 통신 중 오류가 발생했습니다.");
            }
        }
    });
}

/**
 * 2. 관심 프로젝트 저장 (북마크) 토글
 */
function toggleWish(btn) {
    if (!btn) return;

    const urlParams = new URLSearchParams(window.location.search);
    const projectId = urlParams.get('projectId');

    if (!projectId) return;

    $.ajax({
        url: 'bookmark/toggle',
        type: 'POST',
        data: { projectId: projectId },
        success: function(response) {
            if (!response.ok) {
                if (response.message === 'LOGIN_REQUIRED') {
                    alert("로그인이 필요한 서비스입니다.");
                    location.href = '/login';
                } else {
                    alert("처리 중 오류가 발생했습니다.");
                }
                return;
            }

            const icon = btn.querySelector('i');
            const label = btn.querySelector('span');

            if (response.bookmarked) {
                btn.classList.add('active');
                icon.classList.replace('fa-regular', 'fa-solid');
                if (label) label.innerText = "북마크 저장됨";
            } else {
                btn.classList.remove('active');
                icon.classList.replace('fa-solid', 'fa-regular');
                if (label) label.innerText = "북마크 (찜하기)";
            }
        },
        error: function(err) {
            console.error(err);
            alert("북마크 처리 중 통신 오류가 발생했습니다.");
        }
    });
}

/**
 * 3. 채팅방 연결
 */
function moveToChat() {

    const urlParams = new URLSearchParams(window.location.search);
    const projectId = urlParams.get('projectId');

    if (!projectId) {
        alert("프로젝트 정보를 찾을 수 없습니다.");
        return;
    }
    $.ajax({
        url: '/ratelocean/chat/createRoom',
        type: 'POST',
        data: { projectId: projectId },
        success: function (roomId) {

            if (!roomId) {
                alert("채팅방 생성에 실패했습니다.");
                return;
            }
            location.href = '/ratelocean/chat?roomId=' + roomId;
        },
        error: function () {
            alert("채팅방 생성 중 오류가 발생했습니다.");
        }
    });
}