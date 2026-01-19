/**
 * ═══════════════════════════════════════════════════════════════════════
 * signup.js - 회원가입 페이지 스크립트
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [기능]
 * - 로그인 ID 중복 확인
 * - 이메일 중복 확인
 * - 비밀번호 확인 검증
 * - 전화번호 인증 (Mock)
 * - 폼 제출 전 유효성 검사
 */

(function() {
    'use strict';

    // DOM 요소
    const form = document.getElementById('signup-form');
    const loginIdInput = document.getElementById('loginId');
    const emailInput = document.getElementById('email');
    const passwordInput = document.getElementById('password');
    const passwordConfirmInput = document.getElementById('passwordConfirm');
    const fullNameInput = document.getElementById('fullName');
    const phoneInput = document.getElementById('phone');
    
    const idCheckBtn = document.getElementById('id-check');
    const emailCheckBtn = document.getElementById('email-check');
    const sendCodeBtn = document.getElementById('send-code');
    const verifyCodeBtn = document.getElementById('verify-code-btn');
    const nextBtn = document.getElementById('next-btn');

    const idMsg = document.getElementById('id-msg');
    const emailMsg = document.getElementById('email-msg');
    const phoneMsg = document.getElementById('phone-msg');
    const verifyArea = document.getElementById('verify-area');
    const verifyMsg = document.getElementById('verify-msg');

    // 검증 상태
    let validation = {
        loginId: false,
        email: false,
        password: false,
        passwordConfirm: false,
        fullName: false,
        phone: false,
        phoneVerified: false
    };

    // 컨텍스트 패스 (루트 경로)
    const contextPath = form.action.split('/join')[0];

    // 전화번호 인증 상태 관리
    let phoneAuthState = {
        currentPhone: '',
        verificationCode: '',
        timerInterval: null,
        timeRemaining: 300, // 5분 = 300초
        isCodeSent: false,
        isVerified: false
    };

    /**
     * 로그인 ID 중복 확인
     */
    idCheckBtn.addEventListener('click', function() {
        const loginId = loginIdInput.value.trim();
        
        if (!loginId) {
            showMessage(idMsg, '로그인 ID를 입력해주세요.', 'error');
            return;
        }

        if (loginId.length < 4) {
            showMessage(idMsg, '로그인 ID는 4자 이상이어야 합니다.', 'error');
            return;
        }

        // AJAX 요청
        fetch(contextPath + '/join/check-loginid?loginId=' + encodeURIComponent(loginId))
            .then(response => response.json())
            .then(data => {
                if (data.available) {
                    showMessage(idMsg, '✓ 사용 가능한 ID입니다.', 'success');
                    validation.loginId = true;
                    checkFormValidity();
                } else {
                    showMessage(idMsg, '이미 사용 중인 ID입니다.', 'error');
                    validation.loginId = false;
                }
            })
            .catch(err => {
                showMessage(idMsg, '중복 확인 중 오류가 발생했습니다.', 'error');
                validation.loginId = false;
            });
    });

    /**
     * 이메일 중복 확인
     */
    emailCheckBtn.addEventListener('click', function() {
        const email = emailInput.value.trim();
        
        if (!email) {
            showMessage(emailMsg, '이메일을 입력해주세요.', 'error');
            return;
        }

        if (!isValidEmail(email)) {
            showMessage(emailMsg, '올바른 이메일 형식이 아닙니다.', 'error');
            return;
        }

        // AJAX 요청
        fetch(contextPath + '/join/check-email?email=' + encodeURIComponent(email))
            .then(response => response.json())
            .then(data => {
                if (data.available) {
                    showMessage(emailMsg, '✓ 사용 가능한 이메일입니다.', 'success');
                    validation.email = true;
                    checkFormValidity();
                } else {
                    showMessage(emailMsg, '이미 사용 중인 이메일입니다.', 'error');
                    validation.email = false;
                }
            })
            .catch(err => {
                showMessage(emailMsg, '중복 확인 중 오류가 발생했습니다.', 'error');
                validation.email = false;
            });
    });

    /**
     * 비밀번호 확인 검증
     */
    passwordConfirmInput.addEventListener('input', function() {
        const password = passwordInput.value;
        const passwordConfirm = passwordConfirmInput.value;

        if (password && passwordConfirm && password === passwordConfirm) {
            validation.passwordConfirm = true;
        } else {
            validation.passwordConfirm = false;
        }
        checkFormValidity();
    });

    passwordInput.addEventListener('input', function() {
        const password = passwordInput.value;
        validation.password = password.length >= 6;
        
        // 비밀번호 확인도 다시 체크
        if (passwordConfirmInput.value) {
            validation.passwordConfirm = password === passwordConfirmInput.value;
        }
        checkFormValidity();
    });

    /**
     * 이름 입력 검증
     */
    fullNameInput.addEventListener('input', function() {
        validation.fullName = fullNameInput.value.trim().length >= 2;
        checkFormValidity();
    });

    /**
     * 전화번호 입력 시 자동 포맷팅 및 인증 상태 초기화
     * 형식: 010-1234-5678
     */
    phoneInput.addEventListener('input', function() {
        let value = phoneInput.value.replace(/\D/g, ''); // 숫자만 추출
        
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
        
        phoneInput.value = formatted;
        
        const currentPhone = formatted.trim();
        
        // 전화번호가 변경되었고, 이미 인증이 완료된 경우
        if (phoneAuthState.currentPhone && currentPhone !== phoneAuthState.currentPhone && phoneAuthState.isVerified) {
            clearPhoneAuth();
            validation.phoneVerified = false;
            checkFormValidity();
        }
    });

    /**
     * 전화번호 인증 - 인증번호 전송
     * Mock 기반 구현 (실제 SMS 발송 대신 서버에서 코드 생성)
     */
    sendCodeBtn.addEventListener('click', function() {
        const phone = phoneInput.value.trim();
        
        if (!phone) {
            showMessage(phoneMsg, '전화번호를 입력해주세요.', 'error');
            return;
        }

        if (!isValidPhone(phone)) {
            showMessage(phoneMsg, '올바른 전화번호 형식입니다. (예: 010-1234-5678)', 'error');
            return;
        }

        // 전화번호 변경 감지 (기존 인증 초기화)
        if (phoneAuthState.currentPhone !== '' && phoneAuthState.currentPhone !== phone) {
            phoneAuthState.isVerified = false;
            phoneAuthState.isCodeSent = false;
            clearPhoneAuth();
            showMessage(phoneMsg, '⚠️ 전화번호가 변경되었습니다. 재인증이 필요합니다.', 'error');
        }

        phoneAuthState.currentPhone = phone;

        // 서버에서 인증번호 생성 (Mock)
        generateVerificationCode();
        
        // UI 업데이트
        verifyArea.style.display = 'flex';
        sendCodeBtn.disabled = true;
        phoneAuthState.isCodeSent = true;
        
        // 타이머 시작
        startPhoneAuthTimer();
        showMessage(phoneMsg, '✓ 인증번호가 생성되었습니다.', 'success');
    });

    /**
     * 전화번호 인증 - 인증코드 확인
     */
    verifyCodeBtn.addEventListener('click', function() {
        const inputCode = document.getElementById('verify-code-input').value.trim();
        
        if (!inputCode) {
            showMessage(verifyMsg, '인증번호를 입력해주세요.', 'error');
            return;
        }

        if (inputCode === phoneAuthState.verificationCode) {
            showMessage(verifyMsg, '✓ 인증이 완료되었습니다.', 'success');
            validation.phoneVerified = true;
            phoneAuthState.isVerified = true;
            
            // UI 업데이트
            verifyCodeBtn.disabled = true;
            document.getElementById('verify-code-input').disabled = true;
            phoneInput.disabled = true;
            sendCodeBtn.disabled = true;
            
            clearInterval(phoneAuthState.timerInterval);
            
            checkFormValidity();
        } else {
            showMessage(verifyMsg, '❌ 인증번호가 일치하지 않습니다.', 'error');
            validation.phoneVerified = false;
        }
    });

    /**
     * 인증번호 생성 (Mock - 서버에서 생성하는 것처럼)
     * 실제 구현: 서버에서 Random code를 생성하고 세션에 저장
     */
    function generateVerificationCode() {
        // Mock: 간단한 6자리 랜덤 숫자 생성
        // 실제 구현에서는 서버에서 AJAX로 받아야 함
        phoneAuthState.verificationCode = String(Math.floor(Math.random() * 900000) + 100000);
        
        // 테스트용 로그
        console.log('🔐 테스트용 인증번호: ' + phoneAuthState.verificationCode);
    }

    /**
     * 전화번호 인증 타이머
     */
    function startPhoneAuthTimer() {
        phoneAuthState.timeRemaining = 300; // 5분
        const timerElement = document.getElementById('verify-timer');
        
        clearInterval(phoneAuthState.timerInterval);
        
        phoneAuthState.timerInterval = setInterval(function() {
            phoneAuthState.timeRemaining--;
            
            const minutes = Math.floor(phoneAuthState.timeRemaining / 60);
            const seconds = phoneAuthState.timeRemaining % 60;
            const timeStr = minutes + ':' + (seconds < 10 ? '0' : '') + seconds;
            
            timerElement.textContent = timeStr;
            
            if (phoneAuthState.timeRemaining <= 0) {
                clearInterval(phoneAuthState.timerInterval);
                clearPhoneAuth();
                showMessage(phoneMsg, '❌ 인증 시간이 만료되었습니다. 다시 인증해주세요.', 'error');
            }
        }, 1000);
    }

    /**
     * 전화번호 인증 초기화
     */
    function clearPhoneAuth() {
        phoneAuthState.isCodeSent = false;
        phoneAuthState.isVerified = false;
        phoneAuthState.verificationCode = '';
        validation.phoneVerified = false;
        
        verifyArea.style.display = 'none';
        document.getElementById('verify-code-input').value = '';
        document.getElementById('verify-code-input').disabled = false;
        verifyCodeBtn.disabled = false;
        sendCodeBtn.disabled = false;
        phoneInput.disabled = false;
        
        clearInterval(phoneAuthState.timerInterval);
    }

    /**
     * 전화번호 형식 검증
     */
    function isValidPhone(phone) {
        // 정규표현식: 010-1234-5678 형식
        const phoneRegex = /^01[0-9]-\d{3,4}-\d{4}$/;
        return phoneRegex.test(phone);
    }

    /**
     * 다음 버튼 클릭 시 폼 제출
     */
    nextBtn.addEventListener('click', function() {
        if (!nextBtn.classList.contains('disabled')) {
            // 최종 검증
            if (validateForm()) {
                // 폼 제출 전 숨겨진 필드로 인증 상태 저장
                const phoneVerifiedInput = document.createElement('input');
                phoneVerifiedInput.type = 'hidden';
                phoneVerifiedInput.name = 'phoneVerified';
                phoneVerifiedInput.value = validation.phoneVerified ? 'true' : 'false';
                form.appendChild(phoneVerifiedInput);
                
                console.log('📝 폼 제출:', {
                    loginId: loginIdInput.value,
                    email: emailInput.value,
                    fullName: fullNameInput.value,
                    phone: phoneInput.value,
                    phoneVerified: validation.phoneVerified,
                    bankName: document.querySelector('select[name="bank_name"]').value,
                    accountNumber: '****' + document.getElementById('account_number').value.slice(-4),
                    accountHolder: document.getElementById('account_holder').value
                });
                
                form.submit();
            } else {
                console.warn('❌ 폼 검증 실패:', validation);
            }
        }
    });

    /**
     * 계좌번호 검증 (숫자만)
     */
    const accountNumberInput = document.getElementById('account_number');
    if (accountNumberInput) {
        accountNumberInput.addEventListener('input', function() {
            this.value = this.value.replace(/[^0-9]/g, '');
        });
    }

    /**
     * 폼 유효성 검사
     */
    function validateForm() {
        // 필수 필드 검증
        if (!validation.loginId) {
            showMessage(idMsg, '⚠️ 로그인 ID 중복확인을 완료해주세요.', 'error');
            return false;
        }
        if (!validation.email) {
            showMessage(emailMsg, '⚠️ 이메일 중복확인을 완료해주세요.', 'error');
            return false;
        }
        if (!validation.password) {
            alert('⚠️ 비밀번호는 6자 이상이어야 합니다.');
            return false;
        }
        if (!validation.passwordConfirm) {
            alert('⚠️ 비밀번호가 일치하지 않습니다.');
            return false;
        }
        if (!validation.fullName) {
            alert('⚠️ 이름은 2자 이상이어야 합니다.');
            return false;
        }
        if (!validation.phoneVerified) {
            showMessage(verifyMsg, '⚠️ 전화번호 인증을 완료해주세요.', 'error');
            if (phoneInput) phoneInput.focus();
            return false;
        }
        
        // 계좌 정보 검증
        const bankName = document.querySelector('select[name="bank_name"]')?.value;
        const accountNumber = document.getElementById('account_number')?.value;
        const accountHolder = document.getElementById('account_holder')?.value;
        
        if (!bankName || bankName === '') {
            alert('⚠️ 은행명을 선택해주세요.');
            return false;
        }
        if (!accountNumber || accountNumber.trim() === '') {
            alert('⚠️ 계좌번호를 입력해주세요.');
            return false;
        }
        if (accountNumber.length < 10) {
            alert('⚠️ 유효한 계좌번호를 입력해주세요.');
            return false;
        }
        if (!accountHolder || accountHolder.trim() === '') {
            alert('⚠️ 예금주명을 입력해주세요.');
            return false;
        }
        if (accountHolder !== fullNameInput.value.trim()) {
            if (!confirm('⚠️ 예금주명과 입력한 이름이 다릅니다.\n계속 진행하시겠습니까?')) {
                return false;
            }
        }
        
        return true;
    }

    /**
     * 다음 버튼 활성화/비활성화
     */
    function checkFormValidity() {
        if (validateForm()) {
            nextBtn.classList.remove('disabled');
            nextBtn.disabled = false;
        } else {
            nextBtn.classList.add('disabled');
            nextBtn.disabled = true;
        }
    }

    /**
     * 메시지 표시
     */
    function showMessage(element, message, type) {
        element.textContent = message;
        element.className = 'inline-msg ' + type;
    }

    /**
     * 이메일 형식 검증
     */
    function isValidEmail(email) {
        const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return re.test(email);
    }

})();
