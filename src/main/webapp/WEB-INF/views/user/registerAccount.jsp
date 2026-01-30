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
        :root {
            --brand-main: #2C1A52;
            --brand-accent: #00F0FF;
            --brand-purple: #8A2BE2;
            --bg-light: #F8F9FD;
            --text-dark: #2D2D2D;
            --border-color: #E2E8F0;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Noto Sans KR', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .container {
            width: 100%;
            max-width: 580px;
            background: #FFFFFF;
            border-radius: 20px;
            padding: 50px 45px;
            box-shadow: 0 10px 30px rgba(44, 26, 82, 0.15);
            border: 1px solid var(--border-color);
        }

        .header {
            text-align: center;
            margin-bottom: 35px;
        }

        .header h1 {
            font-size: 1.8rem;
            font-weight: 700;
            color: var(--brand-main);
            margin-bottom: 10px;
        }

        .header p {
            font-size: 0.95rem;
            color: #6c757d;
            line-height: 1.5;
        }

        .form-body {
            display: flex;
            flex-direction: column;
            gap: 24px;
        }

        .input-group {
            display: flex;
            flex-direction: column;
        }

        .wallet-section .input-group {
            margin-bottom: 16px;
        }

        .wallet-section .input-group:last-child {
            margin-bottom: 0;
        }

        .label-text {
            font-size: 0.95rem;
            font-weight: 600;
            color: var(--text-dark);
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .label-text i {
            color: var(--brand-purple);
        }

        .required {
            color: #dc3545;
            margin-left: 4px;
        }

        input[type="text"],
        input[type="password"],
        select {
            padding: 14px 16px;
            border: 1.5px solid var(--border-color);
            border-radius: 10px;
            font-size: 0.95rem;
            color: var(--text-dark);
            transition: all 0.2s ease;
            background: #FFFFFF;
            font-family: inherit;
        }

        input:focus,
        select:focus {
            outline: none;
            border-color: var(--brand-purple);
            box-shadow: 0 0 0 3px rgba(138, 43, 226, 0.1);
        }

        select {
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 24 24' fill='none' stroke='%232C1A52' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 12px center;
            background-size: 16px;
            cursor: pointer;
        }

        .help-text {
            font-size: 0.85rem;
            color: #6c757d;
            margin-top: 5px;
        }

        .message {
            font-size: 0.85rem;
            margin-top: 5px;
            font-weight: 500;
        }

        /* 프리랜서 전용 지갑 섹션 */
        .wallet-section {
            margin-top: 10px;
            padding: 25px;
            background: linear-gradient(135deg, #f8f9ff 0%, #f0f4ff 100%);
            border-radius: 12px;
            border: 1.5px solid #d0d9ff;
        }

        .wallet-section h3 {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--brand-purple);
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .wallet-section h3 i {
            font-size: 1.2rem;
        }

        .info-text {
            font-size: 0.9rem;
            color: #6c757d;
            line-height: 1.6;
            margin-bottom: 20px;
        }

        .security-note {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            padding: 16px;
            background-color: #f8f9fa;
            border-radius: 10px;
            margin: 20px 0;
        }

        .security-note i {
            color: var(--brand-purple);
            font-size: 1.2rem;
            flex-shrink: 0;
            margin-top: 2px;
        }

        .security-note .text {
            font-size: 0.85rem;
            color: #495057;
            line-height: 1.5;
        }

        /* 버튼 그룹 */
        .btn-group {
            display: flex;
            gap: 12px;
            margin-top: 10px;
        }

        .btn {
            flex: 1;
            padding: 18px;
            border-radius: 12px;
            font-size: 1.05rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 8px;
            border: none;
        }

        .btn-secondary {
            background: #6c757d;
            color: #FFFFFF;
        }

        .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(108, 117, 125, 0.3);
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--brand-main) 0%, var(--brand-purple) 100%);
            color: #FFFFFF;
        }

        .btn-primary:hover {
            background: var(--brand-purple);
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(138, 43, 226, 0.3);
        }

        .btn-primary:disabled,
        .btn-secondary:disabled {
            background: #ccc;
            cursor: not-allowed;
            transform: none;
        }

        /* 반응형 */
        @media (max-width: 768px) {
            .container {
                padding: 35px 25px;
            }

            .header h1 {
                font-size: 1.5rem;
            }

            .wallet-section {
                padding: 20px;
            }

            .btn-group {
                flex-direction: column;
            }
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
        <!-- 은행명 -->
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

        <!-- 계좌번호 -->
        <div class="input-group">
            <label class="label-text">
                <i class="fas fa-credit-card"></i>
                계좌번호 <span class="required">*</span>
            </label>
            <input type="text" name="accountNumber" placeholder="'-' 없이 숫자만 입력"
                   pattern="[0-9]*" inputmode="numeric" required>
            <span class="help-text">하이픈(-) 없이 숫자만 입력해주세요</span>
        </div>

        <!-- 예금주 -->
        <div class="input-group">
            <label class="label-text">
                <i class="fas fa-user"></i>
                예금주 <span class="required">*</span>
            </label>
            <input type="text" name="accountHolder" placeholder="실명을 입력하세요" required>
        </div>

        <!-- 프리랜서인 경우에만 지갑 비밀번호 섹션 표시 -->
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

        <!-- 보안 안내 -->
        <div class="security-note">
            <i class="fas fa-shield-alt"></i>
            <div class="text">
                입력하신 계좌 정보는 <strong>SSL 암호화 기술</strong>로 안전하게 보호되며,<br>
                정산 이외의 목적으로 사용되지 않습니다.
            </div>
        </div>

        <!-- 이전/다음 버튼 -->
        <div class="btn-group">
            <button type="button" id="prevBtn" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> 이전
            </button>
            <button type="button" id="submitBtn" class="btn btn-primary">
                완료 <i class="fas fa-check"></i>
            </button>
        </div>
    </form>
</div>

<script>
    const contextPath = '${pageContext.request.contextPath}';
    const isFreelancer = '${userDto.userType}' === 'FREELANCER';

    $(document).ready(function() {
        // 이전 버튼
        $('#prevBtn').click(function() {
            window.history.back();
        });

        // 프리랜서인 경우 지갑 비밀번호 확인 검증
        if (isFreelancer) {
            $('#walletPasswordConfirm').on('input', function() {
                const walletPw = $('#walletPassword').val();
                const walletPwConfirm = $(this).val();
                const message = $('#walletPwMatchMessage');

                if (walletPwConfirm.length > 0) {
                    if (walletPw === walletPwConfirm) {
                        message.text('✓ 비밀번호가 일치합니다').css('color', '#28a745');
                    } else {
                        message.text('✗ 비밀번호가 일치하지 않습니다').css('color', '#dc3545');
                    }
                } else {
                    message.text('');
                }
            });
        }

        // 완료 버튼
        $('#submitBtn').click(function() {
            // 기본 계좌 정보 검증
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

            // 프리랜서인 경우 지갑 비밀번호 검증
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

            // 버튼 비활성화 및 처리중 표시
            $(this).prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> 처리 중...');

            // AJAX 요청
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