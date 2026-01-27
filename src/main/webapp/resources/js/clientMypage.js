/* [중요] contextPath와 msg 변수는 mypage.jsp 파일 하단의 <script> 태그에서 선언됩니다.
   외부 JS 파일에서는 EL 표기법(${...})을 사용할 수 없으므로, 전역 변수를 그대로 사용합니다.
*/

// 1. 알림 메시지 처리 (저장 완료, 실패 등)
$(document).ready(function () {
    if (typeof msg !== 'undefined' && msg && msg.trim() !== '') {
        alert(msg);
    }
});

// 2. 탭 전환 기능 (대시보드 <-> 정보수정)
function switchTab(viewId, el) {
    // 모든 뷰 섹션 숨김
    $('.view-section').removeClass('active');
    // 선택한 뷰 섹션 보임
    $('#view-' + viewId).addClass('active');

    // 사이드바 메뉴 활성화 스타일 변경
    $('.sidebar-menu li').removeClass('active');
    if (el) $(el).addClass('active');
}

// 3. 헤더의 [내 프로필 수정] 버튼 클릭 시 동작
function showEdit() {
    // 사이드바의 '내 정보 수정' 메뉴를 클릭한 것과 동일하게 처리
    $('#menu-edit').click();
}

// 4. 프로필 이미지 미리보기
function readURL(input) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();

        reader.onload = function (e) {

            if($('#previewImg').length) {
                $('#previewImg').attr('src', e.target.result).show();
            }

            if($('#headerProfileImg').length) {
                $('#headerProfileImg').attr('src', e.target.result).show();
            }
        }

        reader.readAsDataURL(input.files[0]);
    }
}

// 회사 정보 수정 접근 권한 체크
function checkCompanyAccess(el) {
    if (clientType === 'PERSONAL' || clientType === 'CORPORATION') {
        switchTab('company', el);
    } else {
        alert("해당 메뉴는 사업자만 이용 가능합니다.");
    }
}

// 5. 비밀번호 변경 요청
function changePw() {
    const current = $('#currentPw').val();
    const newP = $('#newPw').val();
    const newChk = $('#newPwChk').val();

    // 유효성 검사
    if (!current || !newP || !newChk) {
        alert("모든 항목을 입력해주세요.");
        return;
    }
    if (newP !== newChk) {
        alert("새 비밀번호가 일치하지 않습니다.");
        return;
    }

    // 서버로 변경 요청 전송
    $.ajax({
        url: contextPath + '/client/mypage/pw-change', // 전역 변수 contextPath 사용
        type: 'POST',
        data: {
            currentPw: current,
            newPw: newP
        },
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