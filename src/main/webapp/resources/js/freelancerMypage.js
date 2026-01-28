
$(document).ready(function () {
    if (typeof msg !== 'undefined' && msg && msg.trim() !== '') {
        alert(msg);
    }

    // 초기 탭: active가 없으면 'edit'로 기본 진입
    if ($('.view-section.active').length === 0) {
        switchTab('edit', $('#menu-edit').get(0));
    }
});

let historyOffset = 0;
const historyLimit = 10;

function switchTab(viewId, el) {
    $('.view-section').removeClass('active');
    $('#view-' + viewId).addClass('active');

    $('.sidebar-menu li').removeClass('active');
    if (el) $(el).addClass('active');

    // 거래내역 탭 처음 열 때 1회 로드
    if (viewId === 'received' && historyOffset === 0) {
        loadMoreHistory(true);
    }
}

function ioTypeLabel(type) {
    switch (type) {
        case 'DEPOSIT': return '입금';
        case 'WITHDRAWAL': return '출금';
        case 'PAYMENT': return '결제';
        case 'REFUND': return '환불';
        default: return type;
    }
}

function loadMoreHistory(reset) {
    if (reset) {
        historyOffset = 0;
        $('#historyList').empty();
        $('#btnMoreHistory').show();
    }

    $.ajax({
        url: contextPath + '/freelancer/mypage/wallet/history',
        type: 'GET',
        data: { offset: historyOffset, limit: historyLimit },
        success: function (list) {
            if (!list || list.length === 0) {
                if (historyOffset === 0) {
                    $('#historyList').html('<div style="color:#888;">거래 내역이 없습니다.</div>');
                }
                $('#btnMoreHistory').hide();
                return;
            }

            list.forEach(function (h) {
                const isMinus = (h.ioType === 'WITHDRAWAL' || h.ioType === 'PAYMENT');
                const sign = isMinus ? '-' : '+';

                const row = `
          <div style="display:flex; justify-content:space-between; gap:15px; padding:14px 0; border-bottom:1px solid #eee;">
            <div style="min-width:0;">
              <div style="font-weight:800;">${ioTypeLabel(h.ioType)}</div>
              <div style="color:#888; font-size:12px; margin-top:4px;">${h.summary || ''}</div>
              <div style="color:#999; font-size:12px; margin-top:2px;">${h.createdAt || ''}</div>
            </div>
            <div style="text-align:right; flex-shrink:0;">
              <div style="font-weight:800;">${sign}${Number(h.amount).toLocaleString()}원</div>
              <div style="color:#888; font-size:12px; margin-top:4px;">잔액 ${Number(h.balance).toLocaleString()}원</div>
            </div>
          </div>
        `;
                $('#historyList').append(row);
            });

            historyOffset += list.length;

            if (list.length < historyLimit) {
                $('#btnMoreHistory').hide();
            }
        },
        error: function () {
            alert("거래 내역 조회 실패");
        }
    });
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