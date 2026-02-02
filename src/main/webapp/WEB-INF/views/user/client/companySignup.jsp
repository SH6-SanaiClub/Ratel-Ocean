<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>RatelOcean | 회사 정보 입력</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        :root{
            --primary:#173160;
            --text:#0f172a;
            --bg:#f6f6f8;

            --line: rgba(59,111,220,.22);
            --tint: rgba(59,111,220,.10);

            --neutral-bg:#e5e7eb;
            --neutral-text:#111827;
            --neutral-line:#cbd5e1;

            --ok:#16a34a;
            --danger:#e11d48;
        }

        body{
            background:
                    radial-gradient(1200px 600px at 20% 10%, rgba(59,111,220,.08), transparent 55%),
                    radial-gradient(900px 500px at 80% 0%, rgba(23,49,96,.10), transparent 60%),
                    var(--primary);
            min-height:100vh;
            display:flex;
            align-items:center;
            justify-content:center;
            padding:120px 16px 40px;
            color:var(--text);
            font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Apple SD Gothic Neo", "Noto Sans KR", "Malgun Gothic", Arial, "Helvetica Neue", sans-serif;
            letter-spacing:-0.02em;
        }

        .shell{
            background:#fff;
            border:1px solid rgba(15,23,42,.08);
            box-shadow:0 20px 40px rgba(15,23,42,.06);
            border-radius:24px;
        }

        .brand-gradient{
            background: var(--primary);
            box-shadow:0 16px 30px rgba(15,23,42,.10);
        }

        .input-field{
            width:100%;
            padding:14px 16px;
            border:1.5px solid var(--neutral-line);
            border-radius:12px;
            transition:border-color .2s ease, box-shadow .2s ease, background-color .2s ease;
            background: rgba(255,255,255,.72);
            color:var(--text);
        }

        .input-field::placeholder{
            color: rgba(15,23,42,.45);
        }

        .input-field:focus{
            outline:none;
            border-color: var(--line);
            box-shadow: 0 0 0 3px var(--tint);
            background:#fff;
        }

        .input-field:disabled{
            background: var(--neutral-bg);
            border-color: var(--neutral-line);
            color: rgba(15,23,42,.55);
            cursor:not-allowed;
        }
        .text-2xl {
            font-size: 1.5rem;
            line-height: 2rem;
        }
        .msg-text{
            font-size:13px;
            margin-top:6px;
            min-height:18px;
        }

        .text-success{ color: var(--ok); }
        .text-error{ color: var(--danger); }

        .muted{ color: rgba(15,23,42,.60); }
        .label{ color: rgba(15,23,42,.72); }

        .section-title{
            color:var(--text);
            border-bottom:1px solid rgba(15,23,42,.10);
        }

        .btn-primary{
            background: var(--primary);
            color:#fff;
            font-weight:900;
            border-radius:16px;
            transition: transform .15s ease, filter .15s ease, background-color .15s ease, border-color .15s ease;
            box-shadow:0 16px 30px rgba(15,23,42,.10);
            border:none;
        }

        .btn-primary:hover{
            transform: translateY(-1px);
            filter: brightness(1.02);
        }

        .btn-primary:active{
            transform: scale(.99);
        }

        .btn-primary:disabled{
            background: var(--neutral-bg);
            color: var(--neutral-text);
            border:1px solid var(--neutral-line);
            box-shadow:none;
            cursor:not-allowed;
            filter:none;
            transform:none;
        }

        .btn-secondary{
            background:#fff;
            color:var(--text);
            border:2px solid var(--neutral-line);
            border-radius:16px;
            font-weight:900;
            transition: background-color .15s ease, border-color .15s ease, transform .15s ease;
        }

        .btn-secondary:hover{
            background: rgba(15,23,42,.03);
            border-color: rgba(15,23,42,.18);
        }

        .btn-secondary:active{
            transform: scale(.99);
        }

        .btn-ghost{
            background:#fff;
            color:var(--text);
            border:2px solid rgba(15,23,42,.18);
            border-radius:14px;
            font-weight:900;
            transition: background-color .15s ease, border-color .15s ease, transform .15s ease, filter .15s ease;
        }

        .btn-ghost:hover{
            background: rgba(15,23,42,.03);
            border-color: rgba(15,23,42,.28);
        }

        .btn-ghost:active{
            transform: scale(.99);
        }

        .pill{
            display:inline-flex;
            align-items:center;
            gap:8px;
            padding:10px 14px;
            border-radius:16px;
            border:1px solid rgba(15,23,42,.08);
            background: rgba(255,255,255,.65);
        }
    </style>
</head>
<body class="min-h-screen flex items-center justify-center">
<div class="w-full max-w-2xl">


    <div class="shell p-8 md:p-12">
        <form id="companyForm">
            <div class="text-center mb-10">
            <h1 class="text-2xl font-bold" style="color:var(--text);">회사 정보 입력</h1>
            <p class="muted mt-2">사업자 정보를 입력해주세요</p>
            </div>
            <div class="mb-10">
                <div class="flex items-center justify-between gap-3 mb-4 pb-3 section-title">
                    <h3 class="text-lg font-extrabold">사업자 정보</h3>
                    <span class="text-xs font-bold pill" style="border-color:var(--line); background:var(--tint); color:var(--text);">
                        진위확인 필수
                    </span>
                </div>

                <div class="mb-5">
                    <label class="block text-sm font-extrabold label mb-2">사업자등록번호 *</label>
                    <div class="flex gap-2">
                        <input type="text" id="businessNumber" name="businessNumber" required placeholder="000-00-00000" class="flex-1 input-field text-sm">
                        <button type="button" id="checkBusinessBtn" class="px-6 py-3 btn-ghost text-sm">중복확인</button>
                    </div>
                    <p id="businessMsg" class="msg-text"></p>
                </div>

                <div class="grid grid-cols-2 gap-4 mb-5">
                    <div>
                        <label class="block text-sm font-extrabold label mb-2">대표자명 *</label>
                        <input type="text" id="ceoName" name="ceoName" required placeholder="홍길동" class="input-field text-sm">
                    </div>
                    <div>
                        <label class="block text-sm font-extrabold label mb-2">개업일자 *</label>
                        <input type="date" id="openingDate" name="openingDate" required class="input-field text-sm">
                    </div>
                </div>

                <button type="button" id="verifyBusinessBtn" class="w-full px-6 py-3 btn-primary text-sm">🔍 사업자 진위확인</button>
                <p id="verifyMsg" class="msg-text"></p>
            </div>

            <div class="mb-10">
                <h3 class="text-lg font-extrabold mb-4 pb-3 section-title">추가 정보</h3>

                <div class="mb-5">
                    <label class="block text-sm font-extrabold label mb-2">회사명</label>
                    <input type="text" name="companyName" required placeholder="(주)레이틀오션" class="input-field text-sm">
                </div>

                <div class="mb-5">
                    <label class="block text-sm font-extrabold label mb-2">대표 이메일</label>
                    <input type="email" name="ceoEmail" placeholder="ceo@company.com" class="input-field text-sm">
                </div>

                <div class="mb-5">
                    <label class="block text-sm font-extrabold label mb-2">업종</label>
                    <input type="text" name="industry" placeholder="IT 서비스업" class="input-field text-sm">
                </div>

                <div class="mb-5">
                    <label class="block text-sm font-extrabold label mb-2">회사 주소</label>
                    <input type="text" name="address" placeholder="서울특별시 강남구 ..." class="input-field text-sm">
                </div>

                <div class="mb-5">
                    <label class="block text-sm font-extrabold label mb-2">회사 규모</label>
                    <select name="companySize" class="input-field text-sm">
                        <option value="">선택하세요</option>
                        <option value="STARTUP">스타트업 (10인 미만)</option>
                        <option value="SMALL">소기업 (10-49인)</option>
                        <option value="MEDIUM">중기업 (50-299인)</option>
                        <option value="LARGE">대기업 (300-999인)</option>
                        <option value="ENTERPRISE">대기업 이상 (1000인 이상)</option>
                    </select>
                </div>

                <div class="mb-2">
                    <label class="block text-sm font-extrabold label mb-2">웹사이트 URL (선택)</label>
                    <input type="url" name="websiteUrl" placeholder="https://www.company.com" class="input-field text-sm">
                </div>
            </div>

            <div class="flex gap-4">
                <a href="${pageContext.request.contextPath}/join/client/select-type"
                   class="flex-1 text-center py-4 px-6 btn-secondary">
                    이전
                </a>
                <button type="button" id="submitBtn" disabled class="flex-1 py-4 px-6 btn-primary">
                    다음
                </button>
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
            $('#businessMsg').text('').removeClass('text-success text-error');
            $('#verifyMsg').text('').removeClass('text-success text-error');
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

            $(this).prop('disabled', true).css('opacity', .7).text('인증 중...');

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
                    checkFormValid();
                }
            }).always(function() {
                $('#verifyBusinessBtn').prop('disabled', false).css('opacity', 1).text('🔍 사업자 진위확인');
            });
        });

        $('#submitBtn').click(function() {
            if (!isBusinessChecked || !isBusinessVerified) {
                alert('사업자번호 중복 확인과 진위확인을 먼저 진행해주세요.');
                return;
            }

            $(this).prop('disabled', true).css('opacity', .7).text('처리 중...');

            $.ajax({
                url: contextPath + '/join/client/company-signup',
                method: 'POST',
                data: $('#companyForm').serialize(),
                success: function(response) {
                    if (response.success && response.redirect) {
                        window.location.href = contextPath + response.redirect;
                    } else {
                        alert(response.message || '오류가 발생했습니다.');
                        $('#submitBtn').prop('disabled', false).css('opacity', 1).text('다음');
                    }
                },
                error: function() {
                    alert('서버 연결에 실패했습니다.');
                    $('#submitBtn').prop('disabled', false).css('opacity', 1).text('다음');
                }
            });
        });

        function checkFormValid() {
            if (isBusinessChecked && isBusinessVerified) {
                $('#submitBtn').prop('disabled', false).css('opacity', 1);
            } else {
                $('#submitBtn').prop('disabled', true).css('opacity', 1);
            }
        }
    });
</script>

</body>
</html>
