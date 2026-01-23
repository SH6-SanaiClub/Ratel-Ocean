<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>RatelOcean | 역할 선택</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body { background-color: #F9FAFB; font-family: 'Inter', sans-serif; }
        .brand-gradient { background: linear-gradient(135deg, #4F46E5 0%, #7C3AED 100%); }
        .role-card { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .role-card:hover { transform: translateY(-8px); border-color: #4F46E5; box-shadow: 0 20px 25px -5px rgba(79, 70, 229, 0.1); }
    </style>
</head>
<body class="flex items-center justify-center min-h-screen">

<div class="max-w-4xl w-full px-6">
    <div class="text-center mb-12">
        <div class="inline-block p-3 rounded-2xl brand-gradient mb-6 shadow-lg shadow-indigo-200">
            <span class="text-white font-bold text-2xl tracking-tighter">RatelOcean</span>
        </div>
        <h1 class="text-3xl font-extrabold text-gray-900 tracking-tight">어떤 유형으로 가입하시겠습니까?</h1>
        <p class="mt-4 text-gray-500">전문 프리랜서와 클라이언트를 위한 신뢰 기반의 프로젝트 매칭 플랫폼</p>
    </div>

    <form id="roleForm" method="post" action="${pageContext.request.contextPath}/join/select-role">
        <input type="hidden" name="userType" id="userTypeInput">

        <div class="grid md:grid-cols-2 gap-8">
            <button type="button" onclick="selectAndSubmit('FREELANCER')"
                    class="role-card bg-white border-2 border-gray-100 p-10 rounded-[2.5rem] text-left group">
                <div class="w-16 h-16 rounded-2xl bg-indigo-50 flex items-center justify-center mb-8 group-hover:bg-indigo-600 transition-colors">
                    <span class="text-3xl group-hover:scale-110 transition-transform">👨‍💻</span>
                </div>
                <h3 class="text-2xl font-bold text-gray-900 mb-3">프리랜서</h3>
                <p class="text-gray-500 leading-relaxed">내 기술로 프로젝트를 수행하고<br>안전하게 정산받습니다.</p>
            </button>

            <button type="button" onclick="selectAndSubmit('CLIENT')"
                    class="role-card bg-white border-2 border-gray-100 p-10 rounded-[2.5rem] text-left group">
                <div class="w-16 h-16 rounded-2xl bg-purple-50 flex items-center justify-center mb-8 group-hover:bg-purple-600 transition-colors">
                    <span class="text-3xl group-hover:scale-110 transition-transform">🏢</span>
                </div>
                <h3 class="text-2xl font-bold text-gray-900 mb-3">클라이언트</h3>
                <p class="text-gray-500 leading-relaxed">우수한 전문가를 고용하여<br>프로젝트를 성공으로 이끕니다.</p>
            </button>
        </div>
    </form>

    <div class="mt-12 text-center">
        <span class="text-gray-400">이미 계정이 있으신가요?</span>
        <a href="${pageContext.request.contextPath}/login" class="ml-2 text-indigo-600 font-bold hover:text-indigo-700 underline underline-offset-4">로그인하기</a>
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