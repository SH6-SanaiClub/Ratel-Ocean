<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>RatelOcean | 계좌 등록</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        :root { --brand-deep: #4C1D95; --brand-vivid: #7C3AED; --bg-light: #F9FAFB; --text-main: #111827; --text-sub: #6B7280; --border-color: #E5E7EB; }
        .progress-container { width: 100%; background: linear-gradient(135deg, var(--brand-deep) 0%, var(--brand-vivid) 100%); padding: 20px 0; position: fixed; top: 0; left: 0; z-index: 1000; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .progress-wrapper { max-width: 800px; margin: 0 auto; padding: 0 20px; }
        .progress-info { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
        .progress-step { color: white; font-size: 14px; font-weight: 600; }
        .progress-label { color: rgba(255,255,255,0.9); font-size: 13px; }
        .progress-bar-bg { height: 8px; background: rgba(255,255,255,0.3); border-radius: 10px; overflow: hidden; }
        .progress-bar-fill { height: 100%; background: white; border-radius: 10px; transition: width 0.4s ease; box-shadow: 0 0 10px rgba(255,255,255,0.5); }
        body { background-color: var(--bg-light); font-family: 'Pretendard', -apple-system, sans-serif; margin: 0; display: flex; align-items: center; justify-content: center; min-height: 100vh; padding-top: 100px; }
        .signup-container { width: 100%; max-width: 540px; padding: 20px; }
        .form-card { background: #FFFFFF; border: 1px solid var(--border-color); border-radius: 16px; padding: 48px; box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.05); }
        .eyebrow { color: var(--brand-vivid); font-weight: 700; font-size: 0.85rem; letter-spacing: 1px; margin-bottom: 8px; text-transform: uppercase; }
        .form-card h2 { margin: 0 0 12px 0; font-size: 1.75rem; font-weight: 800; color: var(--text-main); }
        .subtitle { color: var(--text-sub); font-size: 0.95rem; line-height: 1.5; margin-bottom: 40px; }
        .input-group { margin-bottom: 24px; }
        .label { display: block; margin-bottom: 8px; font-size: 0.9rem; font-weight: 600; color: var(--text-main); }
        .input { width: 100%; padding: 14px 16px; border: 1px solid #D1D5DB; border-radius: 10px; font-size: 1rem; box-sizing: border-box; transition: all 0.2s; background-color: #fff; }
        .input:focus { outline: none; border-color: var(--brand-vivid); box-shadow: 0 0 0 4px rgba(124, 58, 237, 0.1); }
        .security-note { display: flex; align-items: center; gap: 10px; padding: 16px; background-color: #F3F4F6; border-radius: 8px; margin: 32px 0; }
        .security-note svg { color: var(--brand-deep); flex-shrink: 0; }
        .security-note .text { font-size: 0.85rem; color: var(--text-sub); line-height: 1.4; }
        .btn.primary { background-color: var(--brand-deep); color: #FFFFFF; width: 100%; padding: 18px; border-radius: 10px; border: none; font-size: 1.1rem; font-weight: 700; cursor: pointer; transition: background-color 0.2s; }
        .btn.primary:hover { background-color: var(--brand-vivid); }
        .btn.primary:disabled { background-color: #ccc; cursor: not-allowed; }
        .back-link { display: block; text-align: center; margin-top: 24px; font-size: 0.9rem; color: var(--text-sub); text-decoration: none; }
        .back-link:hover { text-decoration: underline; }
    </style>
</head>
<body>

<!-- 프로그레스 바 (프리랜서/클라이언트 개인: 4/4, 클라이언트 법인: 5/5) -->
<div class="progress-container">
    <div class="progress-wrapper">
        <div class="progress-info">
            <span class="progress-step">Step 4/4</span>
            <span class="progress-label">계좌 정보 입력</span>
        </div>
        <div class="progress-bar-bg">
            <div class="progress-bar-fill" style="width: 100%"></div>
        </div>
    </div>
</div>

<main class="signup-container">
    <div class="form-card">
        <p class="eyebrow">Step 2. Payment Information</p>
        <h2>정산 계좌 등록</h2>
        <p class="subtitle">수익금 정산을 위해 본인 명의의 계좌 정보를 입력해 주세요. 입력된 정보는 암호화되어 보호됩니다.</p>

        <form id="accountForm">
            <div class="input-group">
                <label class="label">은행명</label>
                <select name="bankName" class="input" required>
                    <option value="">은행을 선택하세요</option>
                    <option value="신한">신한은행</option>
                    <option value="국민">KB국민은행</option>
                    <option value="우리">우리은행</option>
                    <option value="하나">하나은행</option>
                    <option value="기업">IBK기업은행</option>
                    <option value="농협">NH농협은행</option>
                    <option value="카카오">카카오뱅크</option>
                    <option value="토스">토스뱅크</option>
                </select>
            </div>

            <div class="input-group">
                <label class="label">계좌번호</label>
                <input type="text" name="accountNumber" class="input" placeholder="'-' 없이 숫자만 입력" pattern="[0-9]*" inputmode="numeric" required>
            </div>

            <div class="input-group">
                <label class="label">예금주</label>
                <input type="text" name="accountHolder" class="input" placeholder="실명을 입력하세요" required>
            </div>

            <div class="security-note">
                <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                    <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                </svg>
                <div class="text">입력하신 계좌 정보는 안전한 정산 서비스를 위해 SSL 암호화 기술로 보호됩니다.</div>
            </div>

            <button type="button" id="submitBtn" class="btn primary">회원가입 완료하기</button>

            <a href="javascript:history.back()" class="back-link">이전 단계로 돌아가기</a>
        </form>
    </div>
</main>

<script>
    const contextPath = '${pageContext.request.contextPath}';

    $(document).ready(function() {
        $('#accountForm').on('submit', function(e) {
            e.preventDefault();
        });

        $('#submitBtn').click(function() {
            const bankName = $('select[name="bankName"]').val();
            const accountNumber = $('input[name="accountNumber"]').val();
            const accountHolder = $('input[name="accountHolder"]').val();

            if (!bankName || !accountNumber || !accountHolder) {
                alert('모든 항목을 입력해주세요.');
                return;
            }

            if (!/^[0-9]+$/.test(accountNumber)) {
                alert('계좌번호는 숫자만 입력해주세요.');
                return;
            }

            $(this).prop('disabled', true).text('처리 중...');

            $.ajax({
                url: contextPath + '/join/complete',
                method: 'POST',
                data: $('#accountForm').serialize(),
                success: function(response) {
                    if (response.success) {
                        alert(response.message || '회원가입이 완료되었습니다!');
                        window.location.href = contextPath + response.redirectUrl;
                    } else {
                        alert(response.message || '오류가 발생했습니다.');
                        $('#submitBtn').prop('disabled', false).text('회원가입 완료하기');
                    }
                },
                error: function() {
                    alert('서버 연결에 실패했습니다.');
                    $('#submitBtn').prop('disabled', false).text('회원가입 완료하기');
                }
            });
        });
    });
</script>
</body>
</html>
