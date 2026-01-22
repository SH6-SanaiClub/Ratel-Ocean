<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>RatelOcean | 클라이언트 유형 선택</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body { background-color: #F9FAFB; font-family: 'Inter', sans-serif; }
        .brand-gradient { background: linear-gradient(135deg, #7C3AED 0%, #A855F7 100%); }
        .type-card {
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            cursor: pointer;
        }
        .type-card:hover {
            transform: translateY(-8px);
            border-color: #7C3AED;
            box-shadow: 0 20px 25px -5px rgba(124, 58, 237, 0.1);
        }
        .type-card.selected {
            border-color: #7C3AED;
            background: linear-gradient(135deg, #F3E8FF 0%, #FAF5FF 100%);
        }
    </style>
</head>
<body class="flex items-center justify-center min-h-screen">

<div class="max-w-4xl w-full px-6">
    <div class="text-center mb-12">
        <div class="inline-block p-3 rounded-2xl brand-gradient mb-6 shadow-lg shadow-purple-200">
            <span class="text-white font-bold text-2xl tracking-tighter">RatelOcean</span>
        </div>
        <h1 class="text-3xl font-extrabold text-gray-900 tracking-tight">클라이언트 유형을 선택해주세요</h1>
        <p class="mt-4 text-gray-500">프로젝트 규모와 사업자 유무에 따라 선택해주세요</p>
    </div>

    <form id="typeForm" method="post" action="${pageContext.request.contextPath}/join/client/select-type">
        <input type="hidden" name="clientType" id="clientTypeInput">

        <div class="grid md:grid-cols-2 gap-8 mb-8">
            <div class="type-card bg-white border-2 border-gray-100 p-10 rounded-[2.5rem]" data-type="PERSONAL">
                <div class="w-16 h-16 rounded-2xl bg-blue-50 flex items-center justify-center mb-8">
                    <span class="text-3xl">🧑</span>
                </div>
                <h3 class="text-2xl font-bold text-gray-900 mb-3">개인 클라이언트</h3>
                <p class="text-gray-500 leading-relaxed mb-4">사업자 번호가 없는 개인</p>
                <ul class="text-sm text-gray-400 space-y-2">
                    <li>✓ 소규모 프로젝트 발주</li>
                    <li>✓ 프리랜서 1:1 고용</li>
                    <li>✓ 간편한 절차</li>
                </ul>
            </div>

            <div class="type-card bg-white border-2 border-gray-100 p-10 rounded-[2.5rem]" data-type="CORPORATION">
                <div class="w-16 h-16 rounded-2xl bg-purple-50 flex items-center justify-center mb-8">
                    <span class="text-3xl">🏢</span>
                </div>
                <h3 class="text-2xl font-bold text-gray-900 mb-3">법인 클라이언트</h3>
                <p class="text-gray-500 leading-relaxed mb-4">사업자 번호가 있는 개인사업자/법인</p>
                <ul class="text-sm text-gray-400 space-y-2">
                    <li>✓ 대규모 프로젝트</li>
                    <li>✓ 장기 계약</li>
                    <li>✓ 세금계산서 발행</li>
                </ul>
            </div>
        </div>

        <div class="flex gap-4">
            <a href="${pageContext.request.contextPath}/join/signup"
               class="flex-1 text-center py-4 px-6 rounded-2xl border-2 border-gray-300 text-gray-700 font-bold hover:bg-gray-50 transition">
                이전
            </a>
            <button type="submit" id="nextBtn" disabled
                    class="flex-1 py-4 px-6 rounded-2xl bg-gray-300 text-white font-bold cursor-not-allowed transition">
                다음
            </button>
        </div>
    </form>
</div>

<script>
    let selectedType = null;

    document.querySelectorAll('.type-card').forEach(card => {
        card.addEventListener('click', function() {
            // 이전 선택 제거
            document.querySelectorAll('.type-card').forEach(c => c.classList.remove('selected'));

            // 현재 선택 추가
            this.classList.add('selected');
            selectedType = this.dataset.type;

            // hidden input 설정
            document.getElementById('clientTypeInput').value = selectedType;

            // 다음 버튼 활성화
            const nextBtn = document.getElementById('nextBtn');
            nextBtn.disabled = false;
            nextBtn.classList.remove('bg-gray-300', 'cursor-not-allowed');
            nextBtn.classList.add('brand-gradient', 'hover:opacity-90', 'cursor-pointer');
        });
    });
</script>
</body>
</html>
