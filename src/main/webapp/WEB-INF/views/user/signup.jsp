<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>회원 기본 정보 입력</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/select-role.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/signup-mockup.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        .inline-msg { font-size: 12px; margin-top: 4px; min-height: 18px; }
        .msg-success { color: #1F7A8C; }
        .msg-error { color: #ff4d4d; }
        /* 달력 아이콘 색상 조정 등 스타일 유지 */
        input[type="date"]::-webkit-calendar-picker-indicator {
            cursor: pointer;
        }
    </style>
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
        <p class="subtitle">아래 정보를 입력해 주세요. [${userType}] 유형으로 가입을 진행합니다.</p>

        <form id="signup-form" method="post" action="${pageContext.request.contextPath}/join/signup" class="card signup-card" novalidate>
            <div class="card-inner">
                <div class="form-section">
                    <h3 class="section-title">계정 정보</h3>
                    <div class="grid two-col">
                        <label class="field" for="loginId">
                            <div class="label">Login ID</div>
                            <div class="input-row">
                                <input id="loginId" name="loginId" class="input" placeholder="example_id" required />
                                <button id="check-id-btn" class="btn small outline" type="button">중복확인</button>
                            </div>
                            <div id="id-msg" class="inline-msg"></div>
                        </label>

                        <label class="field" for="email">
                            <div class="label">이메일</div>
                            <div class="input-row">
                                <input id="email" name="email" class="input" placeholder="you@example.com" required />
                                <button id="email-check-btn" class="btn small outline" type="button">중복확인</button>
                            </div>
                            <div id="email-msg" class="inline-msg"></div>
                        </label>

                        <label class="field" for="password">
                            <div class="label">비밀번호</div>
                            <input id="password" name="password" class="input" type="password" required />
                        </label>

                        <label class="field" for="passwordConfirm">
                            <div class="label">비밀번호 확인</div>
                            <input id="passwordConfirm" name="passwordConfirm" class="input" type="password" required />
                        </label>
                    </div>
                </div>

                <div class="form-section">
                    <h3 class="section-title">개인 정보</h3>
                    <div class="grid two-col">
                        <label class="field" for="name">
                            <div class="label">이름</div>
                            <input id="name" name="name" class="input" placeholder="홍길동" required />
                        </label>
                        <label class="field" for="phone">
                            <div class="label">전화번호</div>
                            <input id="phone" name="phone" class="input" placeholder="010-1234-5678" required />
                        </label>
                        <label class="field" for="birth">
                            <div class="label">생년월일</div>
                            <input type="date" id="birth" name="birth" class="input" required />
                        </label>
                    </div>
                </div>

                <div class="form-section">
                    <h3 class="section-title">약관 동의</h3>
                    <div class="grid">
                        <label class="field checkbox-row">
                            <input type="checkbox" name="termAgreed" id="termAgreed" value="true">
                            <span>[필수] 이용약관 동의</span>
                        </label>
                        <label class="field checkbox-row">
                            <input type="checkbox" name="privacyAgreed" id="privacyAgreed" value="true">
                            <span>[필수] 개인정보 수집 및 이용 동의</span>
                        </label>
                    </div>
                </div>
            </div>
        </form>

        <div class="actions text-center">
            <button id="next-btn" class="btn primary large disabled" type="button" disabled>회원가입 완료</button>
        </div>
    </div>
</main>

<section class="login-banner">
    <div class="container">
        이미 계정이 있으신가요? <a class="login-btn" href="${pageContext.request.contextPath}/login">로그인</a>
    </div>
</section>

<footer class="site-footer">
    <div class="container">© 2024 Ratel Ocean. All rights reserved.</div>
</footer>

<script>
    $(document).ready(function() {
        let idChecked = false;
        let emailChecked = false;

        function validateForm() {
            const isTerm = $("#termAgreed").is(":checked");
            const isPrivacy = $("#privacyAgreed").is(":checked");
            const hasId = idChecked;
            const hasEmail = emailChecked;
            const hasBirth = $("#birth").val() !== "";
            const hasPass = $("#password").val() !== "" && ($("#password").val() === $("#passwordConfirm").val());

            if (isTerm && isPrivacy && hasId && hasEmail && hasPass && hasBirth) {
                $("#next-btn").removeClass("disabled").prop("disabled", false);
            } else {
                $("#next-btn").addClass("disabled").prop("disabled", true);
            }
        }

        // 아이디 중복확인
        $("#check-id-btn").on("click", function() {
            const loginId = $("#loginId").val();
            if(!loginId) { alert("아이디를 입력하세요."); return; }
            $.ajax({
                url: "${pageContext.request.contextPath}/join/check-id",
                data: { loginId: loginId },
                success: function(res) {
                    if(res === "AVAILABLE") {
                        $("#id-msg").text("✅ 사용 가능한 아이디입니다.").attr("class", "inline-msg msg-success");
                        idChecked = true;
                    } else {
                        $("#id-msg").text("❌ 이미 사용 중인 아이디입니다.").attr("class", "inline-msg msg-error");
                        idChecked = false;
                    }
                    validateForm();
                }
            });
        });

        // 이메일 중복확인
        $("#email-check-btn").on("click", function() {
            const email = $("#email").val();
            if(!email) { alert("이메일을 입력하세요."); return; }
            $.ajax({
                url: "${pageContext.request.contextPath}/join/check-email",
                data: { email: email },
                success: function(res) {
                    if(res === "AVAILABLE") {
                        $("#email-msg").text("✅ 사용 가능한 이메일입니다.").attr("class", "inline-msg msg-success");
                        emailChecked = true;
                    } else {
                        $("#email-msg").text("❌ 이미 사용 중인 이메일입니다.").attr("class", "inline-msg msg-error");
                        emailChecked = false;
                    }
                    validateForm();
                }
            });
        });

        $("#loginId").on("input", function() { idChecked = false; $("#id-msg").text(""); validateForm(); });
        $("#email").on("input", function() { emailChecked = false; $("#email-msg").text(""); validateForm(); });
        $("input").on("change input", validateForm);

        // 최종 제출 로직
        $("#next-btn").on("click", function() {
            // [사나이의 팁] 서버의 UserService가 YYYY.MM.DD 형식을 원하므로 변환해줌
            const rawDate = $("#birth").val(); // YYYY-MM-DD
            if(rawDate) {
                const formattedDate = rawDate.replace(/-/g, ".");
                // 폼 제출 직전에 값을 살짝 바꿔치기함
                $("#birth").attr("type", "text").val(formattedDate);
            }
            $("#signup-form").submit();
        });
    });
</script>
</body>
</html>