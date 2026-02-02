<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>RatelOcean | 역할 선택</title>
    <script src="https://cdn.tailwindcss.com"></script>
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
        }

        body{
            background: radial-gradient(1200px 600px at 20% 10%, rgba(59,111,220,.08), transparent 55%),
            radial-gradient(900px 500px at 80% 0%, rgba(23,49,96,.10), transparent 60%),
            var(--primary);
            color: var(--text);
            font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Apple SD Gothic Neo", "Noto Sans KR", "Malgun Gothic", Arial, "Helvetica Neue", sans-serif;
        }

        .brand-gradient{
            background: var(--primary);
        }

        .role-card{
            transition: transform .25s cubic-bezier(.4,0,.2,1), box-shadow .25s cubic-bezier(.4,0,.2,1), border-color .25s cubic-bezier(.4,0,.2,1), background-color .25s cubic-bezier(.4,0,.2,1);
            border-color: var(--neutral-line);
            box-shadow: none;
        }

        .role-card:hover{
            transform: translateY(-8px);
            border-color: var(--primary);
            box-shadow: 0 20px 25px -5px rgba(15, 23, 42, .10), 0 8px 10px -6px rgba(15, 23, 42, .08);
            background: linear-gradient(180deg, #ffffff 0%, rgba(59,111,220,.04) 100%);
        }

        .role-card:focus-visible{
            outline: none;
            box-shadow: 0 0 0 4px var(--tint), 0 20px 25px -5px rgba(15, 23, 42, .10), 0 8px 10px -6px rgba(15, 23, 42, .08);
            border-color: rgba(59,111,220,.38);
        }

        .icon-box{
            background: var(--tint);
            border: 1px solid var(--line);
            transition: background-color .25s cubic-bezier(.4,0,.2,1), transform .25s cubic-bezier(.4,0,.2,1), border-color .25s cubic-bezier(.4,0,.2,1);
        }

        .role-card:hover .icon-box{
            background: rgba(23,49,96,.12);
            border-color: rgba(23,49,96,.28);
        }

        .role-card:hover .emoji{
            transform: scale(1.08);
        }

        .emoji{
            transition: transform .25s cubic-bezier(.4,0,.2,1);
        }

        .muted{
            color: rgba(15,23,42,.64);
        }

        .login-link{
            color: rgba(23,49,96,.92);
        }

        .login-link:hover{
            color: rgba(59,111,220,1);
        }

        .badge-shadow{
            box-shadow: 0 16px 30px rgba(15, 23, 42, .10);
        }

        .panel{
            border: 1px solid rgba(15,23,42,.08);
            background: rgb(255,255,255);
            backdrop-filter: blur(10px);
        }
    </style>
</head>
<body class="flex items-center justify-center min-h-screen">
<div class="max-w-4xl w-full px-6">
    <div class="panel rounded-[2.75rem] p-10 md:p-12">
        <div class="text-center mb-10">
            <div class="inline-flex items-center gap-3 px-5 py-3 rounded-2xl brand-gradient badge-shadow">
                <span class="text-white font-extrabold text-2xl tracking-tight">RatelOcean</span>
            </div>
            <h1 class="mt-7 text-3xl md:text-[2.1rem] font-extrabold tracking-tight" style="color:var(--text);">
                어떤 유형으로 가입하시겠습니까?
            </h1>
            <p class="mt-4 muted">
                전문 프리랜서와 클라이언트를 위한 신뢰 기반의 프로젝트 매칭 플랫폼
            </p>
        </div>

        <form id="roleForm" method="post" action="${pageContext.request.contextPath}/join/select-role">
            <input type="hidden" name="userType" id="userTypeInput">

            <div class="grid md:grid-cols-2 gap-6 md:gap-8">
                <button type="button" onclick="selectAndSubmit('FREELANCER')"
                        class="role-card w-full bg-white border-2 p-9 md:p-10 rounded-[2.5rem] text-left group">
                    <div class="icon-box w-16 h-16 rounded-2xl flex items-center justify-center mb-7">
                        <span class="emoji text-3xl">👨‍💻</span>
                    </div>
                    <div class="flex items-start justify-between gap-4">
                        <div>
                            <h3 class="text-2xl font-extrabold mb-2" style="color:var(--text);">프리랜서</h3>
                            <p class="muted leading-relaxed">
                                내 기술로 프로젝트를 수행하고<br>안전하게 정산받습니다.
                            </p>
                        </div>
                        <div class="mt-1 shrink-0 px-3 py-1.5 rounded-full text-sm font-semibold"
                             style="background: rgba(59,111,220,.10); border: 1px solid rgba(59,111,220,.22); color: var(--text);">
                            작업자
                        </div>
                    </div>
                </button>

                <button type="button" onclick="selectAndSubmit('CLIENT')"
                        class="role-card w-full bg-white border-2 p-9 md:p-10 rounded-[2.5rem] text-left group">
                    <div class="icon-box w-16 h-16 rounded-2xl flex items-center justify-center mb-7">
                        <span class="emoji text-3xl">🏢</span>
                    </div>
                    <div class="flex items-start justify-between gap-4">
                        <div>
                            <h3 class="text-2xl font-extrabold mb-2" style="color:var(--text);">클라이언트</h3>
                            <p class="muted leading-relaxed">
                                우수한 전문가를 고용하여<br>프로젝트를 성공으로 이끕니다.
                            </p>
                        </div>
                        <div class="mt-1 shrink-0 px-3 py-1.5 rounded-full text-sm font-semibold"
                             style="background: rgba(59,111,220,.10); border: 1px solid rgba(59,111,220,.22); color: var(--text);">
                            의뢰자
                        </div>
                    </div>
                </button>
            </div>
        </form>

        <div class="mt-10 text-center">
            <span class="muted">이미 계정이 있으신가요?</span>
            <a href="${pageContext.request.contextPath}/login"
               class="login-link ml-2 font-extrabold underline underline-offset-4">
                로그인하기
            </a>
        </div>
    </div>
</div>

<script>
    function selectAndSubmit(role) {
        document.getElementById('userTypeInput').value = role;
        document.getElementById('roleForm').submit();
    }
</script>
</body>
</html>
