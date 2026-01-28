
$(document).ready(function () {
    if (typeof msg !== 'undefined' && msg && msg.trim() !== '') {
        alert(msg);
    }

    // 초기 탭: active가 없으면 'edit'로 기본 진입
    if ($('.view-section.active').length === 0) {
        switchTab('edit', $('#menu-edit').get(0));
    }
});

// 탭 전환 기능
function switchTab(viewId, el) {
    $('.view-section').removeClass('active');
    $('#view-' + viewId).addClass('active');

    $('.sidebar-menu li').removeClass('active');
    if (el) $(el).addClass('active');
}

// 헤더 [내 프로필 수정] 버튼
function showEdit() {
    $('#menu-edit').click();
}

// 프로필 이미지 미리보기 (헤더 + 수정폼)
function readURL(input) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function (e) {
            if ($('#previewImg').length) {
                $('#previewImg').attr('src', e.target.result).show();
            }
            if ($('#headerProfileImg').length) {
                $('#headerProfileImg').attr('src', e.target.result).show();
            }
        };
        reader.readAsDataURL(input.files[0]);
    }
}

// 비밀번호 변경 요청
function changePw() {
    const current = $('#currentPw').val();
    const newP = $('#newPw').val();
    const newChk = $('#newPwChk').val();

    if (!current || !newP || !newChk) {
        alert("모든 항목을 입력해주세요.");
        return;
    }
    if (newP !== newChk) {
        alert("새 비밀번호가 일치하지 않습니다.");
        return;
    }

    $.ajax({
        url: contextPath + '/freelancer/mypage/pw-change',
        type: 'POST',
        data: { currentPw: current, newPw: newP },
        success: function (res) {
            if (res === 'success') {
                alert("비밀번호가 변경되었습니다. 보안을 위해 다시 로그인해주세요.");
                location.href = contextPath + "/logout";
            } else {
                alert("현재 비밀번호가 일치하지 않습니다.");
            }
        },
        error: function () {
            alert("서버 통신 중 오류가 발생했습니다.");
        }
    });
}