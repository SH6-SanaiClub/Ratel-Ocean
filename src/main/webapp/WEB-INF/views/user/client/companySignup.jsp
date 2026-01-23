<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>RatelOcean | 회사 정보 입력</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        body { background-color: #F9FAFB; font-family: 'Inter', sans-serif; padding-top: 100px; }
        .brand-gradient { background: linear-gradient(135deg, #7C3AED 0%, #A855F7 100%); }
        .input-field { width: 100%; padding: 14px; border: 2px solid #E5E7EB; border-radius: 12px; transition: all 0.2s; }
        .input-field:focus { outline: none; border-color: #7C3AED; box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.1); }
        .input-field:disabled { background: #F3F4F6; border-color: #10B981; color: #6B7280; cursor: not-allowed; }
        .msg-text { font-size: 13px; margin-top: 6px; min-height: 18px; }
        .text-success { color: #10B981; }
        .text-error { color: #EF4444; }
    </style>
</head>
<body class="min-h-screen flex items-center justify-center py-12 px-4">

<div class="w-full max-w-2xl">
    <div class="text-center mb-10">
        <div class="inline-block p-3 rounded-2xl brand-gradient mb-4 shadow-lg shadow-purple-200">
            <span class="text-white font-bold text-2xl tracking-tighter">RatelOcean</span>
        </div>
        <h1 class="text-3xl font-bold text-gray-900">회사 정보 입력</h1>
        <p class="text-gray-500 mt-2">사업자 정보를 입력해주세요</p>
    </div>

    <div class="bg-white rounded-3xl shadow-xl border border-gray-100 p-8 md:p-12">
        <form id="companyForm">
            <div class="mb-8">
                <h3 class="text-lg font-bold text-gray-900 mb-4 pb-2 border-b">사업자 정보 (진위확인 필수)</h3>

                <div class="mb-5">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">사업자등록번호 *</label>
                    <div class="flex gap-2">
                        <input type="text" id="businessNumber" name="businessNumber" required placeholder="000-00-00000" class="flex-1 input-field text-sm">
                        <button type="button" id="checkBusinessBtn" class="px-6 py-3 bg-blue-600 text-white rounded-xl font-bold hover:bg-blue-700 transition text-sm">중복확인</button>
                    </div>
                    <p id="businessMsg" class="msg-text"></p>
                </div>

                <div class="grid grid-cols-2 gap-4 mb-5">
                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-2">대표자명 *</label>
                        <input type="text" id="ceoName" name="ceoName" required placeholder="홍길동" class="input-field text-sm">
                    </div>
                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-2">개업일자 *</label>
                        <input type="date" id="openingDate" name="openingDate" required class="input-field text-sm">
                    </div>
                </div>

                <button type="button" id="verifyBusinessBtn" class="w-full px-6 py-3 bg-purple-600 text-white rounded-xl font-bold hover:bg-purple-700 transition mb-3 text-sm">🔍 사업자 진위확인</button>
                <p id="verifyMsg" class="msg-text"></p>
            </div>

            <div class="mb-8">
                <h3 class="text-lg font-bold text-gray-900 mb-4 pb-2 border-b">추가 정보</h3>

                <div class="mb-5">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">회사명</label>
                    <input type="text" name="companyName" required placeholder="(주)레이틀오션" class="input-field text-sm">
                </div>

                <div class="mb-5">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">대표 이메일</label>
                    <input type="email" name="ceoEmail" placeholder="ceo@company.com" class="input-field text-sm">
                </div>

                <div class="mb-5">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">업종</label>
                    <input type="text" name="industry" placeholder="IT 서비스업" class="input-field text-sm">
                </div>

                <div class="mb-5">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">회사 주소</label>
                    <input type="text" name="address" placeholder="서울특별시 강남구 ..." class="input-field text-sm">
                </div>

                <div class="mb-5">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">회사 규모</label>
                    <select name="companySize" class="input-field text-sm">
                        <option value="">선택하세요</option>
                        <option value="STARTUP">스타트업 (10인 미만)</option>
                        <option value="SMALL">소기업 (10-49인)</option>
                        <option value="MEDIUM">중기업 (50-299인)</option>
                        <option value="LARGE">대기업 (300-999인)</option>
                        <option value="ENTERPRISE">대기업 이상 (1000인 이상)</option>
                    </select>
                </div>

                <div class="mb-5">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">웹사이트 URL (선택)</label>
                    <input type="url" name="websiteUrl" placeholder="https://www.company.com" class="input-field text-sm">
                </div>
            </div>

            <div class="flex gap-4">
                <a href="${pageContext.request.contextPath}/join/client/select-type" class="flex-1 text-center py-4 px-6 rounded-xl border-2 border-gray-300 text-gray-700 font-bold hover:bg-gray-50 transition">이전</a>
                <button type="button" id="submitBtn" disabled class="flex-1 py-4 px-6 rounded-xl bg-gray-300 text-white font-bold cursor-not-allowed transition">다음</button>
            </div>
        </form>
    </div>
</div>

<script>
    const contextPath = '${pageContext.request.contextPath}';
    let isBusinessChecked = false;
    let isBusinessVerified = false;

    $(document).ready(function() {
        $('#companyForm').on('submit', function(e) {
            e.preventDefault();
        });

        $('#businessNumber').on('input', function() {
            let val = $(this).val().replace(/[^0-9]/g, '');
            if (val.length > 3 && val.length <= 5) {
                val = val.slice(0, 3) + '-' + val.slice(3);
            } else if (val.length > 5) {
                val = val.slice(0, 3) + '-' + val.slice(3, 5) + '-' + val.slice(5, 10);
            }
            $(this).val(val);

            isBusinessChecked = false;
            isBusinessVerified = false;
            $('#businessMsg').text('');
            $('#verifyMsg').text('');
            checkFormValid();
        });

        $('#checkBusinessBtn').click(function() {
            const businessNumber = $('#businessNumber').val().replace(/-/g, '');

            if (businessNumber.length !== 10) {
                $('#businessMsg').text('✕ 올바른 사업자번호를 입력해주세요.').removeClass('text-success').addClass('text-error');
                return;
            }

            $.get(contextPath + '/join/client/check-business-number', { businessNumber }, function(res) {
                if (res.isDuplicate) {
                    $('#businessMsg').text('✕ 이미 등록된 사업자번호입니다.').removeClass('text-success').addClass('text-error');
                    isBusinessChecked = false;
                } else {
                    $('#businessMsg').text('✓ 사용 가능한 사업자번호입니다.').removeClass('text-error').addClass('text-success');
                    isBusinessChecked = true;
                }
                checkFormValid();
            });
        });

        $('#verifyBusinessBtn').click(function() {
            if (!isBusinessChecked) {
                alert('사업자번호 중복 확인을 먼저 진행해주세요.');
                return;
            }

            const businessNumber = $('#businessNumber').val().replace(/-/g, '');
            const ceoName = $('#ceoName').val();
            const openingDate = $('#openingDate').val();

            if (!businessNumber || !ceoName || !openingDate) {
                alert('사업자번호, 대표자명, 개업일자를 모두 입력해주세요.');
                return;
            }

            $(this).prop('disabled', true).text('인증 중...');

            $.post(contextPath + '/join/client/verify-business', {
                businessNumber: businessNumber,
                ceoName: ceoName,
                openingDate: openingDate
            }, function(res) {
                if (res.verified) {
                    $('#verifyMsg').text('✅ ' + res.message).removeClass('text-error').addClass('text-success');
                    isBusinessVerified = true;
                    checkFormValid();
                } else {
                    $('#verifyMsg').text('❌ ' + res.message).removeClass('text-success').addClass('text-error');
                    isBusinessVerified = false;
                }
            }).always(function() {
                $('#verifyBusinessBtn').prop('disabled', false).text('🔍 사업자 진위확인');
            });
        });

        $('#submitBtn').click(function() {
            if (!isBusinessChecked || !isBusinessVerified) {
                alert('사업자번호 중복 확인과 진위확인을 먼저 진행해주세요.');
                return;
            }

            $(this).prop('disabled', true).text('처리 중...');

            $.ajax({
                url: contextPath + '/join/client/company-signup',
                method: 'POST',
                data: $('#companyForm').serialize(),
                success: function(response) {
                    if (response.success && response.redirect) {
                        window.location.href = contextPath + response.redirect;
                    } else {
                        alert(response.message || '오류가 발생했습니다.');
                        $('#submitBtn').prop('disabled', false).text('다음');
                    }
                },
                error: function() {
                    alert('서버 연결에 실패했습니다.');
                    $('#submitBtn').prop('disabled', false).text('다음');
                }
            });
        });

        function checkFormValid() {
            if (isBusinessChecked && isBusinessVerified) {
                $('#submitBtn').prop('disabled', false).removeClass('bg-gray-300 cursor-not-allowed').addClass('brand-gradient hover:opacity-90 cursor-pointer');
            } else {
                $('#submitBtn').prop('disabled', true).removeClass('brand-gradient hover:opacity-90 cursor-pointer').addClass('bg-gray-300 cursor-not-allowed');
            }
        }
    });
</script>

</body>
</html>
