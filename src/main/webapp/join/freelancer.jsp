<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>프리랜서 회원가입 - 기본정보</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif; margin: 0; padding: 0; background-color: #F1F6EE; }
        .container { max-width: 800px; margin: 0 auto; padding: 2rem; }
        .card { background-color: white; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); padding: 2rem; margin-bottom: 2rem; }
        .title { font-size: 2rem; font-weight: 700; color: #2B2B2B; margin-bottom: 0.5rem; }
        .subtitle { font-size: 1rem; color: #6F7272; margin-bottom: 2rem; }
        .section-title { font-size: 1.25rem; font-weight: 600; color: #2B2B2B; margin: 2rem 0 1rem; padding-bottom: 0.5rem; border-bottom: 2px solid #A9D9DB; }
        .field { margin-bottom: 1.5rem; }
        .label { display: block; font-weight: 500; color: #2B2B2B; margin-bottom: 0.5rem; }
        .input { width: 100%; padding: 0.75rem; border: 1px solid #d0d0d0; border-radius: 6px; font-size: 1rem; box-sizing: border-box; }
        .input:focus { outline: none; border-color: #1F7A8C; }
        .input[type="date"] { cursor: pointer; position: relative; }
        .input[type="date"]::-webkit-calendar-picker-indicator { cursor: pointer; position: absolute; top: 0; left: 0; right: 0; bottom: 0; width: auto; height: auto; color: transparent; background: transparent; opacity: 0; }
        .input.error { border-color: #ef4444; }
        .error-message { color: #ef4444; font-size: 0.875rem; margin-top: 0.25rem; display: none; }
        .error-message.show { display: block; }
        .success-message { color: #10b981; font-size: 0.875rem; margin-top: 0.25rem; display: none; }
        .success-message.show { display: block; }
        .btn { padding: 0.75rem 2rem; border: none; border-radius: 6px; font-size: 1rem; font-weight: 500; cursor: pointer; transition: all 0.2s; }
        .btn-primary { background-color: #1F7A8C; color: white; width: 100%; }
        .btn-primary:hover { background-color: #165f6d; }
        .btn-primary:disabled { background-color: #ccc; cursor: not-allowed; }
        .required { color: #ef4444; }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <h1 class="title">프리랜서 회원가입</h1>
            <p class="subtitle">기본 정보를 입력해주세요.</p>

            <form id="signupForm" method="post" action="${pageContext.request.contextPath}/join/signup-basic.do">
                <h3 class="section-title">계정 정보</h3>

                <div class="field">
                    <label class="label">로그인 ID <span class="required">*</span></label>
                    <input type="text" id="loginId" name="loginId" class="input" placeholder="example_id" required />
                    <div class="error-message" id="loginIdError">로그인 ID는 4자 이상이어야 합니다.</div>
                </div>

                <div class="field">
                    <label class="label">이메일 <span class="required">*</span></label>
                    <input type="email" id="email" name="email" class="input" placeholder="you@example.com" required />
                    <div class="error-message" id="emailError">올바른 이메일 형식이 아닙니다.</div>
                </div>

                <div class="field">
                    <label class="label">비밀번호 <span class="required">*</span></label>
                    <input type="password" id="password" name="password" class="input" placeholder="비밀번호 (8자 이상)" required />
                    <div class="error-message" id="passwordError">비밀번호는 8자 이상이어야 합니다.</div>
                </div>

                <div class="field">
                    <label class="label">비밀번호 확인 <span class="required">*</span></label>
                    <input type="password" id="passwordConfirm" class="input" placeholder="비밀번호 확인" required />
                    <div class="error-message" id="passwordConfirmError">비밀번호가 일치하지 않습니다.</div>
                    <div class="success-message" id="passwordConfirmSuccess">✓ 비밀번호가 일치합니다.</div>
                </div>

                <h3 class="section-title">개인 정보</h3>

                <div class="field">
                    <label class="label">이름 <span class="required">*</span></label>
                    <input type="text" id="fullName" name="fullName" class="input" placeholder="홍길동" required />
                </div>

                <div class="field">
                    <label class="label">전화번호 <span class="required">*</span></label>
                    <input type="tel" id="phone" name="phone" class="input" placeholder="010-1234-5678" maxlength="13" pattern="01[0-9]-\d{3,4}-\d{4}" required />
                    <div class="error-message" id="phoneError">전화번호 형식이 올바르지 않습니다. (예: 010-1234-5678)</div>
                </div>

                <div class="field">
                    <label class="label">생년월일 (달력에서 선택)</label>
                    <input type="date" id="birth" name="birth" class="input" max="2010-01-01" />
                </div>

                <button type="submit" class="btn btn-primary" id="submitBtn">다음 단계로</button>
            </form>
        </div>
    </div>

    <script>
        const loginId = document.getElementById('loginId');
        const email = document.getElementById('email');
        const password = document.getElementById('password');
        const passwordConfirm = document.getElementById('passwordConfirm');
        const phone = document.getElementById('phone');
        const form = document.getElementById('signupForm');

        loginId.addEventListener('blur', function() {
            if (this.value.length > 0 && this.value.length < 4) {
                this.classList.add('error');
                document.getElementById('loginIdError').classList.add('show');
            } else {
                this.classList.remove('error');
                document.getElementById('loginIdError').classList.remove('show');
            }
        });

        password.addEventListener('blur', function() {
            if (this.value.length > 0 && this.value.length < 8) {
                this.classList.add('error');
                document.getElementById('passwordError').classList.add('show');
            } else {
                this.classList.remove('error');
                document.getElementById('passwordError').classList.remove('show');
            }
        });

        passwordConfirm.addEventListener('input', function() {
            const pwd = password.value;
            const pwdConfirm = this.value;
            if (pwdConfirm.length > 0) {
                if (pwd === pwdConfirm) {
                    this.classList.remove('error');
                    document.getElementById('passwordConfirmError').classList.remove('show');
                    document.getElementById('passwordConfirmSuccess').classList.add('show');
                } else {
                    this.classList.add('error');
                    document.getElementById('passwordConfirmError').classList.add('show');
                    document.getElementById('passwordConfirmSuccess').classList.remove('show');
                }
            } else {
                this.classList.remove('error');
                document.getElementById('passwordConfirmError').classList.remove('show');
                document.getElementById('passwordConfirmSuccess').classList.remove('show');
            }
        });

        phone.addEventListener('input', function() {
            let value = this.value.replace(/\D/g, '');
            if (value.length > 11) value = value.slice(0, 11);
            let formatted = '';
            if (value.length <= 3) formatted = value;
            else if (value.length <= 7) formatted = value.slice(0, 3) + '-' + value.slice(3);
            else formatted = value.slice(0, 3) + '-' + value.slice(3, 7) + '-' + value.slice(7, 11);
            this.value = formatted;
        });

        phone.addEventListener('blur', function() {
            const phonePattern = /^01[0-9]-?[0-9]{3,4}-?[0-9]{4}$/;
            if (this.value && !phonePattern.test(this.value)) {
                this.classList.add('error');
                document.getElementById('phoneError').classList.add('show');
            } else {
                this.classList.remove('error');
                document.getElementById('phoneError').classList.remove('show');
            }
        });

        form.addEventListener('submit', function(e) {
            let isValid = true;
            if (loginId.value.length < 4) { e.preventDefault(); loginId.classList.add('error'); document.getElementById('loginIdError').classList.add('show'); isValid = false; alert('로그인 ID는 4자 이상이어야 합니다.'); return false; }
            if (password.value.length < 8) { e.preventDefault(); password.classList.add('error'); document.getElementById('passwordError').classList.add('show'); isValid = false; alert('비밀번호는 8자 이상이어야 합니다.'); return false; }
            if (password.value !== passwordConfirm.value) { e.preventDefault(); passwordConfirm.classList.add('error'); document.getElementById('passwordConfirmError').classList.add('show'); isValid = false; alert('비밀번호가 일치하지 않습니다.'); return false; }
            const phonePattern = /^01[0-9]-?[0-9]{3,4}-?[0-9]{4}$/;
            if (phone.value && !phonePattern.test(phone.value)) { e.preventDefault(); phone.classList.add('error'); document.getElementById('phoneError').classList.add('show'); isValid = false; alert('전화번호 형식이 올바르지 않습니다. (예: 010-1234-5678)'); return false; }
            if (isValid) { document.getElementById('submitBtn').disabled = true; document.getElementById('submitBtn').textContent = '처리 중...'; }
            return isValid;
        });
    </script>
</body>
</html>
