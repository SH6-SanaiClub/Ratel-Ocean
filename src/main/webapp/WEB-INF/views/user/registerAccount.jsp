<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RatelOcean | 계좌 정보 입력</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        :root{
            --primary:#173160;
            --text:#0f172a;
            --bg:#f6f6f8;

            --line: rgba(59,111,220,.22);
            --tint: rgba(59,111,220,.10);
            --accent-weak:rgba(59,111,220,.10);
            --neutral-bg:#e5e7eb;
            --neutral-text:#111827;
            --neutral-line:#cbd5e1;

            --danger:#dc3545;
            --ok:#16a34a;
        }

        *{ margin:0; padding:0; box-sizing:border-box; }

        body{
            font-family:'Noto Sans KR', sans-serif;
            background:
                    radial-gradient(1200px 600px at 20% 10%, rgba(59,111,220,.08), transparent 55%),
                    radial-gradient(900px 500px at 80% 0%, rgba(23,49,96,.10), transparent 60%),
                    var(--primary);
            min-height:100vh;
            display:flex;
            justify-content:center;
            align-items:center;
            padding:120px 20px 20px;
            color:var(--text);
            letter-spacing:-0.02em;
        }

        .container{
            width:100%;
            max-width:580px;
            background:#ffffff;
            border-radius:24px;
            padding:48px 42px;
            border:1px solid rgba(15,23,42,.08);
            box-shadow:0 20px 40px rgba(15,23,42,.06);
        }

        .header{
            text-align:center;
            margin-bottom:32px;
        }

        .header h1{
            font-size:1.7rem;
            font-weight:800;
            color:var(--text);
            margin-bottom:10px;
            display:flex;
            justify-content:center;
            align-items:center;
            gap:10px;
        }

        .header h1 i{
            color:var(--primary);
        }

        .header p{
            font-size:.95rem;
            color:rgba(15,23,42,.60);
            line-height:1.55;
        }

        .form-body{
            display:flex;
            flex-direction:column;
            gap:22px;
        }

        .input-group{
            display:flex;
            flex-direction:column;
        }

        .label-text{
            font-size:.92rem;
            font-weight:800;
            color:rgba(15,23,42,.78);
            margin-bottom:8px;
            display:flex;
            align-items:center;
            gap:8px;
        }

        .label-text i{
            color:rgba(59,111,220,1);
        }

        .required{
            color:var(--danger);
            margin-left:4px;
        }

        input[type="text"],
        input[type="password"],
        select{
            padding:14px 16px;
            border:1.5px solid var(--neutral-line);
            border-radius:12px;
            font-size:.95rem;
            color:var(--text);
            transition: border-color .2s ease, box-shadow .2s ease, background-color .2s ease;
            background: rgba(255,255,255,.72);
            font-family:inherit;
        }

        input::placeholder{
            color: rgba(15,23,42,.45);
        }

        input:focus,
        select:focus{
            outline:none;
            border-color: var(--line);
            box-shadow: 0 0 0 3px var(--tint);
            background:#fff;
        }

        select{
            appearance:none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 24 24' fill='none' stroke='%23173160' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
            background-repeat:no-repeat;
            background-position:right 12px center;
            background-size:16px;
            cursor:pointer;
        }

        .help-text{
            font-size:.85rem;
            color: rgba(15,23,42,.60);
            margin:4px 0 6px 0;
        }

        .message{
            font-size:.85rem;
            margin-top:6px;
            font-weight:700;
            min-height:18px;
        }

        .wallet-section{
            margin-top:8px;
            padding:22px;
            background: linear-gradient(180deg, rgba(59,111,220,.06) 0%, rgba(23,49,96,.05) 100%);
            border-radius:16px;
            border:1.5px solid var(--line);
        }

        .wallet-section h3{
            font-size:1.05rem;
            font-weight:900;
            color:var(--text);
            margin-bottom:8px;
            display:flex;
            align-items:center;
            gap:10px;
        }

        .wallet-section h3 i{
            color:rgba(59,111,220,1);
            font-size:1.1rem;
        }

        .info-text{
            font-size:.9rem;
            color: rgba(15,23,42,.60);
            line-height:1.6;
            margin-bottom:18px;
        }

        .security-note{
            display:flex;
            align-items:flex-start;
            gap:12px;
            padding:16px;
            background: var(--accent-weak);
            border: 1px solid var(--line);
            border-radius:14px;
            margin-top:2px;
        }

        .security-note i{
            color:rgba(59,111,220,1);
            font-size:1.15rem;
            flex-shrink:0;
            margin-top:2px;
        }

        .security-note .text{
            font-size:.85rem;
            color: rgba(15,23,42,.72);
            line-height:1.55;
        }

        .btn-group{
            display:flex;
            gap:12px;
            margin-top:6px;
        }

        .btn{
            flex:1;
            padding:16px 18px;
            border-radius:16px;
            font-size:1.02rem;
            font-weight:900;
            cursor:pointer;
            transition: transform .15s ease, filter .15s ease, background-color .15s ease, border-color .15s ease;
            display:flex;
            justify-content:center;
            align-items:center;
            gap:10px;
            border:none;
        }

        .btn-secondary{
            background:#fff;
            color:var(--text);
            border:2px solid var(--neutral-line);
        }

        .btn-secondary:hover{
            background: rgba(15,23,42,.03);
            border-color: rgba(15,23,42,.18);
        }

        .btn-secondary:active{
            transform: scale(.99);
        }

        .btn-primary{
            background: var(--primary);
            color:#fff;
            box-shadow:0 16px 30px rgba(15,23,42,.10);
        }

        .btn-primary:hover{
            transform: translateY(-1px);
            filter: brightness(1.02);
        }

        .btn-primary:active{
            transform: scale(.99);
        }

        .btn-primary:disabled,
        .btn-secondary:disabled{
            background: var(--neutral-bg);
            color: var(--neutral-text);
            cursor:not-allowed;
            border:1px solid var(--neutral-line);
            box-shadow:none;
            filter:none;
            transform:none;
        }

        @media (max-width: 768px){
            .container{ padding:34px 22px; border-radius:22px; }
            .header h1{ font-size:1.45rem; }
            .wallet-section{ padding:18px; }
            .btn-group{ flex-direction:column; }
        }
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <h1><i class="fas fa-university"></i> 계좌 정보 입력</h1>
        <p>수익금 정산을 위해 본인 명의의 계좌 정보를 입력해 주세요.<br>입력된 정보는 암호화되어 안전하게 보호됩니다.</p>
    </div>

    <form id="accountForm" class="form-body">
        <div class="input-group">
            <label class="label-text">
                <i class="fas fa-landmark"></i>
                은행명 <span class="required">*</span>
            </label>
            <select name="bankName" required>
                <option value="">은행을 선택하세요</option>
                <option value="KB국민은행">KB국민은행</option>
                <option value="신한은행">신한은행</option>
                <option value="우리은행">우리은행</option>
                <option value="하나은행">하나은행</option>
                <option value="IBK기업은행">IBK기업은행</option>
                <option value="NH농협은행">NH농협은행</option>
                <option value="SC제일은행">SC제일은행</option>
                <option value="한국씨티은행">한국씨티은행</option>
                <option value="카카오뱅크">카카오뱅크</option>
                <option value="케이뱅크">케이뱅크</option>
                <option value="토스뱅크">토스뱅크</option>
            </select>
        </div>

        <div class="input-group">
            <label class="label-text">
                <i class="fas fa-credit-card"></i>
                계좌번호 <span class="required">*</span>
            </label>
            <input type="text" name="accountNumber" placeholder="'-' 없이 숫자만 입력"
                   pattern="[0-9]*" inputmode="numeric" required>
            <span class="help-text">하이픈(-) 없이 숫자만 입력해주세요</span>
        </div>

        <div class="input-group">
            <label class="label-text">
                <i class="fas fa-user"></i>
                예금주 <span class="required">*</span>
            </label>
            <input type="text" name="accountHolder" placeholder="실명을 입력하세요" required>
        </div>

        <c:if test="${userDto.userType == 'FREELANCER'}">
            <div class="wallet-section">
                <h3>
                    <i class="fas fa-wallet"></i>
                    지갑 비밀번호 설정
                </h3>
                <p class="info-text">
                    프로젝트 대금을 받기 위한 지갑이 생성됩니다.<br>
                    출금 시 사용할 <strong>4자리 숫자 비밀번호</strong>를 설정해주세요.
                </p>

                <div class="input-group">
                    <label class="label-text">
                        <i class="fas fa-lock"></i>
                        지갑 비밀번호 <span class="required">*</span>
                    </label>
                    <input type="password" id="walletPassword" name="walletPassword"
                           pattern="[0-9]{4}" maxlength="4" required
                           placeholder="4자리 숫자">
                    <p class="help-text">숫자 4자리만 입력 가능합니다</p>
                </div>

                <div class="input-group">
                    <label class="label-text">
                        <i class="fas fa-lock"></i>
                        지갑 비밀번호 확인 <span class="required">*</span>
                    </label>
                    <input type="password" id="walletPasswordConfirm" name="walletPasswordConfirm"
                           pattern="[0-9]{4}" maxlength="4" required
                           placeholder="비밀번호 재입력">
                    <span id="walletPwMatchMessage" class="message"></span>
                </div>
            </div>
        </c:if>

        <div class="security-note">
            <i class="fas fa-shield-alt"></i>
            <div class="text">
                입력하신 계좌 정보는 <strong>SSL 암호화 기술</strong>로 안전하게 보호되며,<br>
                정산 이외의 목적으로 사용되지 않습니다.
            </div>
        </div>

        <div class="btn-group">
            <button type="button" id="prevBtn" class="btn btn-secondary">
                이전
            </button>
            <button type="button" id="submitBtn" class="btn btn-primary">
                완료
            </button>
        </div>
    </form>
</div>

<script>
    const contextPath = '${pageContext.request.contextPath}';
    const isFreelancer = '${userDto.userType}' === 'FREELANCER';

    $(document).ready(function() {
        $('#prevBtn').click(function() {
            window.history.back();
        });

        if (isFreelancer) {
            $('#walletPasswordConfirm').on('input', function() {
                const walletPw = $('#walletPassword').val();
                const walletPwConfirm = $(this).val();
                const message = $('#walletPwMatchMessage');

                if (walletPwConfirm.length > 0) {
                    if (walletPw === walletPwConfirm) {
                        message.text('✓ 비밀번호가 일치합니다').css('color', '#16a34a');
                    } else {
                        message.text('✗ 비밀번호가 일치하지 않습니다').css('color', '#dc3545');
                    }
                } else {
                    message.text('');
                }
            });
        }

        $('#submitBtn').click(function() {
            const bankName = $('select[name="bankName"]').val();
            const accountNumber = $('input[name="accountNumber"]').val();
            const accountHolder = $('input[name="accountHolder"]').val();

            if (!bankName || !accountNumber || !accountHolder) {
                alert('모든 계좌 정보를 입력해주세요.');
                return;
            }

            if (!/^[0-9]+$/.test(accountNumber)) {
                alert('계좌번호는 숫자만 입력해주세요.');
                return;
            }

            if (isFreelancer) {
                const walletPw = $('#walletPassword').val();
                const walletPwConfirm = $('#walletPasswordConfirm').val();

                if (!walletPw || walletPw.length !== 4) {
                    alert('지갑 비밀번호는 4자리 숫자여야 합니다.');
                    $('#walletPassword').focus();
                    return;
                }

                if (!/^[0-9]{4}$/.test(walletPw)) {
                    alert('지갑 비밀번호는 숫자 4자리만 입력 가능합니다.');
                    $('#walletPassword').focus();
                    return;
                }

                if (walletPw !== walletPwConfirm) {
                    alert('지갑 비밀번호가 일치하지 않습니다.');
                    $('#walletPasswordConfirm').focus();
                    return;
                }
            }

            $(this).prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> 처리 중...');

            $.ajax({
                url: contextPath + '/join/complete',
                method: 'POST',
                data: $('#accountForm').serialize(),
                success: function(response) {
                    if (response.success) {
                        alert(response.message || '회원가입이 완료되었습니다!');
                        window.location.href = contextPath + (response.redirectUrl || '/login');
                    } else {
                        alert(response.message || '회원가입 중 오류가 발생했습니다.');
                        $('#submitBtn').prop('disabled', false)
                            .html('완료 <i class="fas fa-check"></i>');
                    }
                },
                error: function(xhr) {
                    console.error('회원가입 실패:', xhr);
                    alert('서버 연결에 실패했습니다. 다시 시도해주세요.');
                    $('#submitBtn').prop('disabled', false)
                        .html('완료 <i class="fas fa-check"></i>');
                }
            });
        });
    });
</script>

</body>
</html>
