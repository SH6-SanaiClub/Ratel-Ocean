<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>클라이언트 유형 선택 - Ratel Ocean</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
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
            background:
                    radial-gradient(1200px 600px at 20% 10%, rgba(59,111,220,.08), transparent 55%),
                    radial-gradient(900px 500px at 80% 0%, rgba(23,49,96,.10), transparent 60%),
                    var(--primary);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 120px 20px 20px;
            color: var(--text);
            font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Apple SD Gothic Neo", "Noto Sans KR", "Malgun Gothic", Arial, "Helvetica Neue", sans-serif;
            letter-spacing: -0.02em;
        }

        .shell{
            background: rgba(255,255,255);
            border: 1px solid rgba(15,23,42,.08);
            box-shadow: 0 20px 40px rgba(15,23,42,.06);
            backdrop-filter: blur(16px);
        }

        .type-card{
            padding: 32px 24px;
            border: 2px solid var(--neutral-line);
            border-radius: 20px;
            cursor: pointer;
            transition: transform .25s cubic-bezier(.4,0,.2,1), box-shadow .25s cubic-bezier(.4,0,.2,1), border-color .25s cubic-bezier(.4,0,.2,1), background-color .25s cubic-bezier(.4,0,.2,1);
            text-align: center;
            background: white;
            box-shadow: none;
        }

        .type-card:hover{
            border-color: var(--primary);
            box-shadow: 0 18px 28px rgba(15,23,42,.10);
            transform: translateY(-4px);
            background: linear-gradient(180deg, #ffffff 0%, rgba(59,111,220,.04) 100%);
        }

        .type-card.selected{
            border-color: var(--primary);
            background: linear-gradient(180deg, rgba(59,111,220,.06) 0%, rgba(23,49,96,.05) 100%);
            box-shadow: 0 22px 34px rgba(15,23,42,.12);
        }

        .type-title{
            color: var(--text);
        }

        .muted{
            color: rgba(15,23,42,.60);
        }

        .muted2{
            color: rgba(15,23,42,.72);
        }

        .btn-primary{
            background: var(--primary);
            color: white;
            padding: 16px 24px;
            border-radius: 16px;
            font-weight: 800;
            border: none;
            cursor: pointer;
            transition: transform .15s ease, filter .15s ease;
            box-shadow: 0 16px 30px rgba(15,23,42,.10);
        }

        .btn-primary:hover{
            transform: translateY(-1px);
            filter: brightness(1.02);
        }

        .btn-primary:active{
            transform: scale(.99);
        }

        .btn-primary:disabled{
            background: var(--neutral-bg);
            color: var(--neutral-text);
            cursor: not-allowed;
            border: 1px solid var(--neutral-line);
            box-shadow: none;
            filter: none;
            transform: none;
        }

        .btn-secondary{
            background: #fff;
            color: var(--text);
            border: 2px solid var(--neutral-line);
            border-radius: 16px;
            font-weight: 800;
            transition: background-color .15s ease, border-color .15s ease, transform .15s ease;
        }

        .btn-secondary:hover{
            background: rgba(15,23,42,.03);
            border-color: rgba(15,23,42,.18);
        }

        .btn-secondary:active{
            transform: scale(.99);
        }

        .spinner{
            border: 3px solid rgba(15,23,42,.10);
            border-top: 3px solid rgba(59,111,220,1);
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto;
        }

        @keyframes spin{
            0%{ transform: rotate(0deg); }
            100%{ transform: rotate(360deg); }
        }
    </style>
</head>
<body>

<div class="w-full max-w-2xl shell rounded-3xl p-12">
    <div class="text-center mb-10">
        <h1 class="text-3xl font-extrabold mb-2 type-title">클라이언트 유형 선택</h1>
        <p class="muted">프로젝트 규모와 비즈니스 형태에 맞는 유형을 선택하세요</p>
    </div>

    <div class="grid grid-cols-2 gap-6 mb-8">
        <div class="type-card" data-type="PERSONAL">
            <div class="text-5xl mb-4">🧑</div>
            <h3 class="text-xl font-extrabold mb-2 type-title">개인 클라이언트</h3>
            <p class="text-sm muted mb-3">사업자 등록 없이 진행하는 개인 프로젝트</p>
            <ul class="text-xs muted text-left space-y-1">
                <li>✓ 소규모 프로젝트 발주</li>
                <li>✓ 간편한 계약 프로세스</li>
                <li>✓ 빠른 프로젝트 시작</li>
            </ul>
        </div>

        <div class="type-card" data-type="CORPORATION">
            <div class="text-5xl mb-4">🏢</div>
            <h3 class="text-xl font-extrabold mb-2 type-title">법인 클라이언트</h3>
            <p class="text-sm muted mb-3">사업자 등록이 있는 기업 또는 개인사업자</p>
            <ul class="text-xs muted text-left space-y-1">
                <li>✓ 대규모 프로젝트 관리</li>
                <li>✓ 장기 계약 지원</li>
                <li>✓ 세금계산서 발행</li>
            </ul>
        </div>
    </div>

    <div id="loadingArea" style="display:none;" class="text-center py-8">
        <div class="spinner"></div>
        <p class="mt-4 text-sm muted2">처리 중...</p>
    </div>

    <div id="btnGroup" class="flex gap-4">
        <a href="${pageContext.request.contextPath}/join/signup"
           class="flex-1 text-center py-4 px-6 btn-secondary">
            이전
        </a>
        <button type="button" id="nextBtn" class="flex-1 btn-primary" disabled>다음</button>
    </div>
</div>

<script>
    const contextPath = '${pageContext.request.contextPath}';
    let selectedType = null;

    $(document).ready(function() {
        $('.type-card').click(function() {
            $('.type-card').removeClass('selected');
            $(this).addClass('selected');
            selectedType = $(this).data('type');
            $('#nextBtn').prop('disabled', false);
        });

        $('#nextBtn').click(function() {
            if (!selectedType) {
                alert('클라이언트 유형을 선택해주세요.');
                return;
            }

            $('#btnGroup').hide();
            $('#loadingArea').show();

            $.ajax({
                url: contextPath + '/join/client/select-type',
                method: 'POST',
                data: { clientType: selectedType },
                success: function(response) {
                    if (response.success && response.redirect) {
                        window.location.href = contextPath + response.redirect;
                    } else {
                        alert(response.message || '오류가 발생했습니다.');
                        $('#btnGroup').show();
                        $('#loadingArea').hide();
                    }
                },
                error: function() {
                    alert('서버 연결에 실패했습니다.');
                    $('#btnGroup').show();
                    $('#loadingArea').hide();
                }
            });
        });
    });
</script>

</body>
</html>
