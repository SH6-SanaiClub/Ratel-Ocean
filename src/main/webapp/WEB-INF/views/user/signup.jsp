<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>회원 기본 정보 입력</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/select-role.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/signup-mockup.css">
</head>
<body>
<header class="site-header">
    <div class="container header-inner">
        <a class="logo" href="${pageContext.request.contextPath}/">
            <img src="${pageContext.request.contextPath}/resources/images/ratelogo.png" alt="Ratel Ocean 로고">
        </a>
        <nav class="top-nav">
            <a href="${pageContext.request.contextPath}/service">서비스 소개</a>
            <a href="${pageContext.request.contextPath}/support">고객센터</a>
        </nav>
    </div>
</header>

<main class="select-role">
    <div class="container signup-container">
        <p class="eyebrow">회원 가입</p>
        <h1 class="title">회원 기본 정보 입력</h1>
        <p class="subtitle">아래 정보를 입력해 주세요. 이 페이지는 공통 가입 단계입니다.</p>

        <form id="signup-form" method="post" action="${pageContext.request.contextPath}/join/signup.do" class="card signup-card" novalidate>
            <div class="card-inner">
                <div class="form-section">
                    <h3 class="section-title">계정 정보</h3>
                    <div class="grid two-col">
                        <label class="field" for="loginId">
                            <div class="label">Login ID</div>
                            <div class="input-row">
                                <input id="loginId" name="loginId" class="input" placeholder="example_id" autocomplete="username" />
                                <button id="id-check" class="btn small outline" type="button">중복확인</button>
                            </div>
                            <div id="id-msg" class="inline-msg" aria-live="polite"></div>
                        </label>

                        <label class="field" for="email">
                            <div class="label">이메일</div>
                            <div class="input-row">
                                <input id="email" name="email" class="input" placeholder="you@example.com" autocomplete="email" />
                                <button id="email-check" class="btn small outline" type="button">중복확인</button>
                            </div>
                            <div id="email-msg" class="inline-msg" aria-live="polite"></div>
                        </label>

                        <label class="field" for="password">
                            <div class="label">비밀번호</div>
                            <input id="password" name="password" class="input" placeholder="비밀번호 입력" type="password" autocomplete="new-password" />
                        </label>

                        <label class="field" for="passwordConfirm">
                            <div class="label">비밀번호 확인</div>
                            <input id="passwordConfirm" name="passwordConfirm" class="input" placeholder="비밀번호 확인" type="password" autocomplete="new-password" />
                        </label>
                    </div>
                </div>

                <div class="form-section">
                    <h3 class="section-title">개인 정보</h3>
                    <div class="grid two-col">
                        <div class="upload-area" aria-hidden="true">
                            <div class="avatar-placeholder" role="img" aria-label="프로필 이미지 업로드">
                                <svg width="40" height="40" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                    <path d="M12 5V3" stroke="#1F7A8C" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                                    <path d="M12 21v-2" stroke="#1F7A8C" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                                    <path d="M5 12H3" stroke="#1F7A8C" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                                    <path d="M21 12h-2" stroke="#1F7A8C" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                                    <circle cx="12" cy="12" r="3" stroke="#1F7A8C" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                                </svg>
                            </div>
                            <div class="label small muted">이미지 등록</div>
                        </div>

                        <label class="field" for="fullName">
                            <div class="label">이름</div>
                            <input id="fullName" name="fullName" class="input" placeholder="홍길동" autocomplete="name" />
                        </label>

                        <label class="field" for="phone">
                            <div class="label">전화번호 <span class="small muted">(인증필수)</span></div>
                            <div class="input-row">
                                <input id="phone" name="phone" class="input" placeholder="010-1234-5678" autocomplete="tel" />
                                <button id="send-code" class="btn small outline" type="button">인증번호 전송</button>
                            </div>
                            <div id="phone-msg" class="inline-msg" aria-live="polite"></div>
                            <div id="verify-area" class="verify-area" aria-live="polite" style="display:none">
                                <input id="verify-code-input" class="input" name="verifyCode" placeholder="인증번호 6자리" />
                                <button id="verify-code-btn" class="btn small outline" type="button">확인</button>
                                <span id="verify-timer" class="timer"></span>
                                <div id="verify-msg" class="inline-msg" style="margin-top:6px"></div>
                            </div>
                        </label>

                        <label class="field" for="birth">
                            <div class="label">생년월일</div>
                            <input id="birth" name="birth" class="input" placeholder="YYYY.MM.DD" autocomplete="bday" />
                        </label>
                    </div>
                </div>
            </div>
        </form>

        <div class="actions text-center">
            <button id="next-btn" class="btn primary large disabled" type="button" disabled>다음으로</button>
        </div>
    </div>
</main>

<section class="login-banner">
    <div class="container">이미 계정이 있으신가요? <a class="login-btn" href="${pageContext.request.contextPath}/login">로그인</a></div>
</section>

<footer class="site-footer">
    <div class="container">© 2024 Ratel Ocean. All rights reserved.</div>
</footer>

<script src="${pageContext.request.contextPath}/resources/js/signup.js"></script>
</body>
</html>