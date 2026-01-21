<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RatelOcean | 회원가입</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Pretendard:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Pretendard', sans-serif; letter-spacing: -0.02em; }
        .brand-gradient { background: linear-gradient(135deg, #6366F1 0%, #A855F7 100%); }
        .brand-text-gradient {
            background: linear-gradient(135deg, #6366F1 0%, #A855F7 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .bg-mesh {
            background-color: #f8fafc;
            background-image:
                    radial-gradient(at 0% 0%, rgba(99, 102, 241, 0.08) 0px, transparent 50%),
                    radial-gradient(at 100% 100%, rgba(168, 85, 247, 0.08) 0px, transparent 50%);
        }
        .input-field {
            height: 48px;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            border: 1px solid #E2E8F0;
            background-color: rgba(249, 250, 251, 0.8);
        }
        .input-field:focus {
            border-color: #6366F1;
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.08);
            background-color: #fff;
            outline: none;
        }
        .btn-action {
            height: 48px;
            white-space: nowrap;
            transition: all 0.2s;
        }
        .custom-check {
            width: 18px; height: 18px;
            border: 1.5px solid #E2E8F0;
            border-radius: 4px;
            appearance: none;
            cursor: pointer;
            position: relative;
        }
        .custom-check:checked { background-color: #6366F1; border-color: #6366F1; }
        .custom-check:checked::after {
            content: '✓'; position: absolute; color: white;
            font-size: 12px; top: 50%; left: 50%; transform: translate(-50%, -50%);
        }
        .msg-text { font-size: 12px; margin-top: 4px; min-height: 16px; }
    </style>
</head>
<body class="bg-mesh min-h-screen flex items-center justify-center py-12 px-4">

<div class="w-full max-w-[640px]">
    <div class="text-center mb-8">
        <div class="inline-flex items-center gap-2 mb-3">
            <div class="w-9 h-9 brand-gradient rounded-lg flex items-center justify-center shadow-lg shadow-indigo-100">
                <span class="text-white font-black text-lg">R</span>
            </div>
            <span class="text-xl font-black tracking-tight text-gray-900">Ratel<span class="brand-text-gradient">Ocean</span></span>
        </div>
        <h1 class="text-2xl font-bold text-gray-900 tracking-tight">계정 생성</h1>
        <p class="text-gray-500 mt-1 font-medium text-sm">전문 프리랜서를 위한 비즈니스 운영 플랫폼</p>
    </div>

    <div class="bg-white/90 backdrop-blur-2xl rounded-[2rem] shadow-[0_20px_40px_rgba(0,0,0,0.03)] border border-white p-8 md:p-12">
        <form id="signup-form" action="${pageContext.request.contextPath}/join/signup" method="post" class="space-y-5">
            <input type="hidden" name="userType" value="${userType}">

            <div class="space-y-1.5">
                <label class="text-[13px] font-bold text-gray-700 ml-1">아이디</label>
                <div class="grid grid-cols-[1fr_100px] gap-2">
                    <input type="text" id="loginId" name="loginId" required placeholder="영문, 숫자 6~12자"
                           class="w-full px-4 rounded-xl input-field text-[14px]">
                    <button type="button" id="id-check-btn"
                            class="btn-action bg-gray-900 text-white rounded-xl text-sm font-bold hover:bg-black active:scale-95">중복확인</button>
                </div>
                <div id="id-msg" class="msg-text ml-1"></div>
            </div>

            <div class="space-y-1.5">
                <label class="text-[13px] font-bold text-gray-700 ml-1">비밀번호</label>
                <input type="password" id="password" name="password" required placeholder="8자 이상 입력"
                       class="w-full px-4 rounded-xl input-field text-[14px]">
            </div>

            <div class="space-y-1.5">
                <label class="text-[13px] font-bold text-gray-700 ml-1">비밀번호 확인</label>
                <input type="password" id="passwordConfirm" required placeholder="비밀번호를 한 번 더 입력해주세요"
                       class="w-full px-4 rounded-xl input-field text-[14px]">
                <div id="pw-msg" class="msg-text ml-1"></div>
            </div>

            <div class="space-y-1.5">
                <label class="text-[13px] font-bold text-gray-700 ml-1">이메일 주소</label>
                <div class="grid grid-cols-[1fr_100px] gap-2">
                    <input type="email" id="email" name="email" required placeholder="example@email.com"
                           class="w-full px-4 rounded-xl input-field text-[14px]">
                    <button type="button" id="email-check-btn"
                            class="btn-action border-2 border-gray-900 text-gray-900 rounded-xl text-sm font-bold hover:bg-gray-50 active:scale-95">중복확인</button>
                </div>
                <div id="email-msg" class="msg-text ml-1"></div>
            </div>

            <div class="space-y-1.5">
                <label class="text-[13px] font-bold text-gray-700 ml-1">이름</label>
                <input type="text" name="name" required placeholder="실명을 입력해주세요"
                       class="w-full px-4 rounded-xl input-field text-[14px]">
            </div>

            <div class="space-y-1.5">
                <label class="text-[13px] font-bold text-gray-700 ml-1">휴대폰 번호</label>
                <input type="tel" id="phone" name="phone" maxlength="13" required placeholder="010-0000-0000"
                       class="w-full px-4 rounded-xl input-field text-[14px]">
            </div>

            <div class="space-y-1.5">
                <label class="text-[13px] font-bold text-gray-700 ml-1">생년월일</label>
                <input type="date" name="birth" required
                       class="w-full px-4 rounded-xl input-field text-[14px]">
            </div>

            <div class="mt-2 p-5 bg-gray-50/50 rounded-2xl border border-gray-100 space-y-3">
                <label class="flex items-center gap-3 cursor-pointer group">
                    <input type="checkbox" id="agree-all" class="custom-check">
                    <span class="text-[14px] font-bold text-gray-900">약관 전체 동의</span>
                </label>
                <div class="h-[1px] bg-gray-200/60"></div>
                <div class="space-y-2">
                    <div class="flex items-center justify-between">
                        <label class="flex items-center gap-2 cursor-pointer">
                            <input type="checkbox" id="agree-terms" required class="terms-check custom-check">
                            <span class="text-xs text-gray-600">이용약관 <span class="text-indigo-500 font-bold">(필수)</span></span>
                        </label>
                        <button type="button" class="text-[10px] text-gray-400 border-b">보기</button>
                    </div>
                    <div class="flex items-center justify-between">
                        <label class="flex items-center gap-2 cursor-pointer">
                            <input type="checkbox" id="agree-privacy" required class="terms-check custom-check">
                            <span class="text-xs text-gray-600">개인정보 처리방침 <span class="text-indigo-500 font-bold">(필수)</span></span>
                        </label>
                        <button type="button" class="text-[10px] text-gray-400 border-b">보기</button>
                    </div>
                </div>
            </div>

            <button type="button" id="next-btn" disabled
                    class="w-full h-14 rounded-xl brand-gradient text-white font-bold text-base shadow-lg shadow-indigo-100 mt-4 disabled:opacity-30 disabled:grayscale disabled:cursor-not-allowed hover:-translate-y-0.5 transition-all active:scale-[0.99]">
                프로필 등록 단계로 진행
            </button>
        </form>
    </div>
</div>

<script>
    let idChecked = false;
    let emailChecked = false;

    // 이메일 형식 검사 함수 (Regex)
    function validateEmailFormat(email) {
        const re = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
        return re.test(email);
    }

    // 이메일 입력 시 이벤트
    $("#email").on("input", function() {
        const email = $(this).val();
        emailChecked = false; // 입력이 바뀌면 다시 중복확인 필요

        if (email.length > 0) {
            if (validateEmailFormat(email)) {
                $("#email-msg").text("✓ 올바른 이메일 형식입니다.").attr("class", "msg-text text-blue-500");
            } else {
                $("#email-msg").text("✕ 유효한 이메일 형식이 아닙니다.").attr("class", "msg-text text-rose-500");
            }
        } else {
            $("#email-msg").text("");
        }
        validateForm();
    });

    // 이메일 중복 확인 버튼
    $("#email-check-btn").on("click", function() {
        const email = $("#email").val();
        if(!validateEmailFormat(email)) {
            alert("먼저 올바른 이메일 형식을 입력해주세요.");
            $("#email").focus();
            return;
        }

        $.ajax({
            url: "${pageContext.request.contextPath}/join/check-email",
            data: { email: email },
            success: function(res) {
                if(res === "AVAILABLE") {
                    $("#email-msg").text("✓ 사용 가능한 이메일입니다.").attr("class", "msg-text text-green-500");
                    emailChecked = true;
                } else {
                    $("#email-msg").text("✕ 이미 등록된 이메일입니다.").attr("class", "msg-text text-rose-500");
                    emailChecked = false;
                }
                validateForm();
            }
        });
    });

    // 아이디 중복 확인
    $("#id-check-btn").on("click", function() {
        const id = $("#loginId").val();
        if(!id || id.length < 6) {
            alert("아이디는 6자 이상 입력해주세요.");
            return;
        }
        $.ajax({
            url: "${pageContext.request.contextPath}/join/check-id",
            data: { loginId: id },
            success: function(res) {
                if(res === "AVAILABLE") {
                    $("#id-msg").text("✓ 사용 가능한 아이디입니다.").attr("class", "msg-text text-green-500");
                    idChecked = true;
                } else {
                    $("#id-msg").text("✕ 사용 중인 아이디입니다.").attr("class", "msg-text text-rose-500");
                    idChecked = false;
                }
                validateForm();
            }
        });
    });

    // 비밀번호 일치 확인
    $("#password, #passwordConfirm").on("keyup", function() {
        const p1 = $("#password").val();
        const p2 = $("#passwordConfirm").val();
        if (p2.length > 0) {
            if (p1 === p2) {
                $("#pw-msg").text("✓ 비밀번호가 일치합니다.").attr("class", "msg-text text-green-500");
            } else {
                $("#pw-msg").text("✕ 비밀번호가 서로 다릅니다.").attr("class", "msg-text text-rose-500");
            }
        } else { $("#pw-msg").text(""); }
        validateForm();
    });

    // 휴대폰 번호 하이픈 자동 생성
    $("#phone").on("input", function() {
        let val = $(this).val().replace(/[^0-9]/g, "");
        if (val.length > 3 && val.length <= 7) val = val.slice(0, 3) + "-" + val.slice(3);
        else if (val.length > 7) val = val.slice(0, 3) + "-" + val.slice(3, 7) + "-" + val.slice(7);
        $(this).val(val);
        validateForm();
    });

    // 약관 전체 동의
    $("#agree-all").on("change", function() {
        $(".terms-check").prop("checked", $(this).prop("checked"));
        validateForm();
    });

    $(".terms-check").on("change", function() {
        $("#agree-all").prop("checked", $(".terms-check").length === $(".terms-check:checked").length);
        validateForm();
    });

    // 폼 유효성 검사 (버튼 활성화)
    function validateForm() {
        const p1 = $("#password").val();
        const p2 = $("#passwordConfirm").val();
        const filled = $("input[required]").filter(function() { return !this.value; }).length === 0;
        const termsAgreed = $("#agree-terms").is(":checked") && $("#agree-privacy").is(":checked");

        if (filled && idChecked && emailChecked && (p1 === p2) && termsAgreed) {
            $("#next-btn").prop("disabled", false);
        } else {
            $("#next-btn").prop("disabled", true);
        }
    }

    $("#loginId").on("input", function() {
        idChecked = false;
        $("#id-msg").text("");
        validateForm();
    });

    $("#next-btn").on("click", function() { $("#signup-form").submit(); });
</script>

</body>
</html>