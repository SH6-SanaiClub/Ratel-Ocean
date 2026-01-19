<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>회원가입 - Ratel Ocean</title>
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
            <h1 class="title">회원가입</h1>
            <p class="subtitle">기본 정보를 입력해주세요.</p>
            
            <!-- 에러 메시지 표시 -->
            <% String error = (String) request.getAttribute("error"); %>
            <% if (error != null && !error.isEmpty()) { %>
                <div style="background-color: #fee; border: 1px solid #fcc; color: #c00; padding: 1rem; border-radius: 6px; margin-bottom: 1rem;">
                    ⚠️ <%= error %>
                </div>
            <% } %>

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
                    <label class="label">생년월일 <span class="required">*</span> <span class="label-small">(달력에서 선택)</span></label>
                    <input type="date" id="birth" name="birth" class="input" max="2010-01-01" required />
                    <div class="error-message" id="birthError">생년월일을 선택해주세요.</div>
                </div>

                <button type="submit" class="btn btn-primary" id="submitBtn" disabled style="opacity: 0.5; cursor: not-allowed;">다음 단계로</button>
            </form>
        </div>
    </div>

    <script>
        // ═══════════════════════════════════════════════════════════════════
        // 실시간 폼 검증 및 버튼 활성화/비활성화
        // ═══════════════════════════════════════════════════════════════════
        
        // 실시간 검증
        const loginId = document.getElementById('loginId');
        const email = document.getElementById('email');
        const password = document.getElementById('password');
        const passwordConfirm = document.getElementById('passwordConfirm');
        const fullName = document.getElementById('fullName');
        const phone = document.getElementById('phone');
        const form = document.getElementById('signupForm');
        const submitBtn = document.getElementById('submitBtn');

        // ═══════════════════════════════════════════════════════════════════
        // 폼 유효성 검사 함수
        // ═══════════════════════════════════════════════════════════════════
        function checkFormValidity() {
            // 1. 로그인 ID: 4자 이상
            const isLoginIdValid = loginId.value.trim().length >= 4;
            
            // 2. 이메일: 형식 검증
            const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            const isEmailValid = emailPattern.test(email.value.trim());
            
            // 3. 비밀번호: 8자 이상
            const isPasswordValid = password.value.length >= 8;
            
            // 4. 비밀번호 확인: 일치
            const isPasswordConfirmValid = password.value === passwordConfirm.value && passwordConfirm.value.length > 0;
            
            // 5. 이름: 2자 이상
            const isFullNameValid = fullName.value.trim().length >= 2;
            
            // 6. 전화번호: 010-XXXX-XXXX 형식
            const phonePattern = /^01[0-9]-?\d{3,4}-?\d{4}$/;
            const isPhoneValid = phonePattern.test(phone.value.replace(/\s/g, ''));
            
            // 7. 생년월일: 필수 입력
            const birth = document.getElementById('birth');
            const isBirthValid = birth.value.trim().length > 0;
            
            // 모든 필드가 유효한지 확인
            const isFormValid = isLoginIdValid && isEmailValid && isPasswordValid && 
                                isPasswordConfirmValid && isFullNameValid && isPhoneValid && isBirthValid;
            
            // 버튼 활성화/비활성화
            if (isFormValid) {
                submitBtn.disabled = false;
                submitBtn.style.opacity = '1';
                submitBtn.style.cursor = 'pointer';
            } else {
                submitBtn.disabled = true;
                submitBtn.style.opacity = '0.5';
                submitBtn.style.cursor = 'not-allowed';
            }
            
            return isFormValid;
        }

        // ═══════════════════════════════════════════════════════════════════
        // 이벤트 리스너 등록 - 모든 필드 변경 시 실시간 검증
        // ═══════════════════════════════════════════════════════════════════
        
        // 페이지 로드 시 초기 검증
        document.addEventListener('DOMContentLoaded', function() {
            checkFormValidity();
        });
        
        // 모든 필드에 input/change 이벤트 리스너 추가
        loginId.addEventListener('input', checkFormValidity);
        email.addEventListener('input', checkFormValidity);
        password.addEventListener('input', checkFormValidity);
        passwordConfirm.addEventListener('input', checkFormValidity);
        fullName.addEventListener('input', checkFormValidity);
        phone.addEventListener('input', checkFormValidity);
        document.getElementById('birth').addEventListener('change', checkFormValidity);
        
        // ═══════════════════════════════════════════════════════════════════
        // 기존 blur 이벤트 검증 (에러 메시지 표시용)
        // ═══════════════════════════════════════════════════════════════════
        
        // 로그인 ID 검증
        loginId.addEventListener('blur', function() {
            if (this.value.length > 0 && this.value.length < 4) {
                this.classList.add('error');
                document.getElementById('loginIdError').classList.add('show');
            } else {
                this.classList.remove('error');
                document.getElementById('loginIdError').classList.remove('show');
            }
        });
        
        // 비밀번호 검증
        password.addEventListener('blur', function() {
            if (this.value.length > 0 && this.value.length < 8) {
                this.classList.add('error');
                document.getElementById('passwordError').classList.add('show');
            } else {
                this.classList.remove('error');
                document.getElementById('passwordError').classList.remove('show');
            }
        });
        
        // 비밀번호 확인 실시간 검증
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
        
        // 전화번호 입력 시 자동 포맷팅
        phone.addEventListener('input', function() {
            let value = this.value.replace(/\D/g, ''); // 숫자만 추출
            
            // 최대 11자로 제한
            if (value.length > 11) {
                value = value.slice(0, 11);
            }
            
            // 자동 포맷팅: 010-XXXX-XXXX
            let formatted = '';
            if (value.length <= 3) {
                formatted = value;
            } else if (value.length <= 7) {
                formatted = value.slice(0, 3) + '-' + value.slice(3);
            } else {
                formatted = value.slice(0, 3) + '-' + value.slice(3, 7) + '-' + value.slice(7, 11);
            }
            
            this.value = formatted;
        });
        
        // 전화번호 형식 검증
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
        
        // 폼 제출 전 최종 검증
        form.addEventListener('submit', function(e) {
            console.log('=== 폼 제출 시작 ===');
            console.log('Form action:', form.action);
            console.log('Form method:', form.method);
            
            let isValid = true;
            
            // 로그인 ID 검증
            if (loginId.value.length < 4) {
                e.preventDefault();
                loginId.classList.add('error');
                document.getElementById('loginIdError').classList.add('show');
                isValid = false;
                alert('로그인 ID는 4자 이상이어야 합니다.');
                console.log('검증 실패: 로그인 ID');
                return false;
            }
            
            // 비밀번호 길이 검증
            if (password.value.length < 8) {
                e.preventDefault();
                password.classList.add('error');
                document.getElementById('passwordError').classList.add('show');
                isValid = false;
                alert('비밀번호는 8자 이상이어야 합니다.');
                console.log('검증 실패: 비밀번호 길이');
                return false;
            }
            
            // 비밀번호 일치 검증
            if (password.value !== passwordConfirm.value) {
                e.preventDefault();
                passwordConfirm.classList.add('error');
                document.getElementById('passwordConfirmError').classList.add('show');
                isValid = false;
                alert('비밀번호가 일치하지 않습니다.');
                console.log('검증 실패: 비밀번호 불일치');
                return false;
            }
            
            // 전화번호 형식 검증
            const phonePattern = /^01[0-9]-?[0-9]{3,4}-?[0-9]{4}$/;
            if (phone.value && !phonePattern.test(phone.value)) {
                e.preventDefault();
                phone.classList.add('error');
                document.getElementById('phoneError').classList.add('show');
                isValid = false;
                alert('전화번호 형식이 올바르지 않습니다. (예: 010-1234-5678)');
                console.log('검증 실패: 전화번호 형식');
                return false;
            }
            
            // 생년월일 검증
            const birth = document.getElementById('birth');
            if (!birth.value || birth.value.trim() === '') {
                e.preventDefault();
                birth.classList.add('error');
                document.getElementById('birthError').classList.add('show');
                isValid = false;
                alert('생년월일을 선택해주세요.');
                console.log('검증 실패: 생년월일 미선택');
                return false;
            }
            
            if (isValid) {
                console.log('✅ 모든 검증 통과!');
                console.log('제출 데이터:', {
                    loginId: loginId.value,
                    email: email.value,
                    fullName: document.getElementById('fullName').value,
                    phone: phone.value,
                    birth: document.getElementById('birth').value
                });
                document.getElementById('submitBtn').disabled = true;
                document.getElementById('submitBtn').textContent = '처리 중...';
                // 폼 제출 계속 진행
            }
            
            return isValid;
        });
        
        console.log('signup-basic.jsp 로드 완료 - v2.0');
    </script>
</body>
</html>
