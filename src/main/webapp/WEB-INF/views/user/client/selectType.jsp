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
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 120px 20px 20px; }
        .type-card { padding: 32px 24px; border: 3px solid #e5e7eb; border-radius: 20px; cursor: pointer; transition: all 0.3s; text-align: center; background: white; }
        .type-card:hover { border-color: #667eea; box-shadow: 0 8px 24px rgba(102,126,234,0.15); transform: translateY(-4px); }
        .type-card.selected { border-color: #667eea; background: linear-gradient(135deg, rgba(102,126,234,0.05) 0%, rgba(118,75,162,0.05) 100%); box-shadow: 0 12px 32px rgba(102,126,234,0.2); }
        .btn-primary { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 16px 24px; border-radius: 16px; font-weight: 700; border: none; cursor: pointer; }
        .btn-primary:disabled { background: #e5e7eb; color: #9ca3af; cursor: not-allowed; }
        .spinner { border: 3px solid #f3f3f3; border-top: 3px solid #667eea; border-radius: 50%; width: 40px; height: 40px; animation: spin 1s linear infinite; margin: 0 auto; }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
    </style>
</head>
<body>

<div class="w-full max-w-2xl bg-white rounded-3xl shadow-2xl p-12">
    <div class="text-center mb-10">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">클라이언트 유형 선택</h1>
        <p class="text-gray-500">프로젝트 규모와 비즈니스 형태에 맞는 유형을 선택하세요</p>
    </div>

    <div class="grid grid-cols-2 gap-6 mb-8">
        <div class="type-card" data-type="PERSONAL">
            <div class="text-5xl mb-4">🧑</div>
            <h3 class="text-xl font-bold mb-2">개인 클라이언트</h3>
            <p class="text-sm text-gray-600 mb-3">사업자 등록 없이 진행하는 개인 프로젝트</p>
            <ul class="text-xs text-gray-500 text-left space-y-1">
                <li>✓ 소규모 프로젝트 발주</li>
                <li>✓ 간편한 계약 프로세스</li>
                <li>✓ 빠른 프로젝트 시작</li>
            </ul>
        </div>

        <div class="type-card" data-type="CORPORATION">
            <div class="text-5xl mb-4">🏢</div>
            <h3 class="text-xl font-bold mb-2">법인 클라이언트</h3>
            <p class="text-sm text-gray-600 mb-3">사업자 등록이 있는 기업 또는 개인사업자</p>
            <ul class="text-xs text-gray-500 text-left space-y-1">
                <li>✓ 대규모 프로젝트 관리</li>
                <li>✓ 장기 계약 지원</li>
                <li>✓ 세금계산서 발행</li>
            </ul>
        </div>
    </div>

    <div id="loadingArea" style="display:none;" class="text-center py-8">
        <div class="spinner"></div>
        <p class="mt-4 text-gray-600 text-sm">처리 중...</p>
    </div>

    <div id="btnGroup" class="flex gap-4">
        <a href="${pageContext.request.contextPath}/join/signup" class="flex-1 text-center py-4 px-6 rounded-xl border-2 border-gray-300 text-gray-700 font-bold hover:bg-gray-50">이전</a>
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
