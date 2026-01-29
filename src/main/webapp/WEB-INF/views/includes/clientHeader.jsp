<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<style>
    /* 헤더 네비게이션 */
    .header {
        background: white;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        position: sticky;
        top: 0;
        z-index: 100;
    }

    .header-inner {
        max-width: 1400px;
        margin: 0 auto;
        padding: 0 2rem;
        display: flex;
        align-items: center;
        gap: 2rem;
    }

    .logo {
        font-size: 1.25rem;
        font-weight: bold;
        color: #1F7A8C;
        text-decoration: none;
        padding: 1rem 0;
        display: flex;
        align-items: center;
        gap: 0.5rem;
    }

    .logo-icon {
        width: 28px;
        height: 28px;
        background: #1F7A8C;
        border-radius: 6px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-size: 0.9rem;
        font-weight: bold;
    }

    .nav-menu {
        display: flex;
        gap: 0.5rem;
        flex: 1;
    }

    .nav-link {
        color: #2B2B2B;
        text-decoration: none;
        padding: 1rem 1.25rem;
        border-bottom: 3px solid transparent;
        transition: all 0.2s;
        font-weight: 500;
        font-size: 0.95rem;
    }

    .nav-link:hover {
        color: #1F7A8C;
    }

    .nav-link.active {
        color: #1F7A8C;
        border-bottom-color: #1F7A8C;
    }

    .nav-icons {
        display: flex;
        align-items: center;
        gap: 1rem;
    }

    .icon-btn {
        width: 40px;
        height: 40px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: #F1F6EE;
        border: none;
        border-radius: 50%;
        cursor: pointer;
        transition: all 0.2s;
        position: relative;
    }

    .icon-btn:hover {
        background: #A9D9DB;
    }

    .icon-btn .badge {
        position: absolute;
        top: 5px;
        right: 5px;
        width: 8px;
        height: 8px;
        background: #ef4444;
        border-radius: 50%;
    }

    .profile-dropdown {
        position: relative;
    }

    .profile-btn {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        padding: 0.5rem 1rem;
        background: #F1F6EE;
        border: none;
        border-radius: 20px;
        cursor: pointer;
        font-weight: 500;
        transition: all 0.2s;
    }

    .profile-btn:hover {
        background: #A9D9DB;
    }

    .dropdown-menu {
        display: none;
        position: absolute;
        top: 100%;
        right: 0;
        margin-top: 0.5rem;
        background: white;
        border-radius: 10px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        min-width: 180px;
        overflow: hidden;
    }

    .dropdown-menu.show {
        display: block;
    }

    .dropdown-item {
        display: block;
        padding: 0.875rem 1.25rem;
        color: #2B2B2B;
        text-decoration: none;
        transition: background 0.2s;
    }

    .dropdown-item:hover {
        background: #F1F6EE;
    }

    .dropdown-divider {
        height: 1px;
        background: #e2e8f0;
        margin: 0.5rem 0;
    }
</style>

<!-- 헤더 네비게이션 -->
<header class="header">
    <div class="header-inner">
        <a href="${pageContext.request.contextPath}/" class="logo">
            <div class="logo-icon">R</div>
            <span>Ratel-Ocean</span>
        </a>

        <nav class="nav-menu">
            <a href="${pageContext.request.contextPath}/client/dashboard" class="nav-link ${requestScope.activeMenu eq 'dashboard' ? 'active' : ''}">대시보드</a>
            <a href="${pageContext.request.contextPath}/project/create" class="nav-link ${requestScope.activeMenu eq 'project-create' ? 'active' : ''}">프로젝트 등록</a>
            <a href="${pageContext.request.contextPath}/client/manage" class="nav-link ${requestScope.activeMenu eq 'manage' ? 'active' : ''}">내 프로젝트</a>
            <a href="${pageContext.request.contextPath}/client/applicants" class="nav-link ${requestScope.activeMenu eq 'applicants' ? 'active' : ''}">지원자 관리</a>
            <a href="${pageContext.request.contextPath}/client/contracts" class="nav-link ${requestScope.activeMenu eq 'contracts' ? 'active' : ''}">계약 관리</a>
        </nav>

        <div class="nav-icons">
            <!-- 알림 -->
            <button class="icon-btn" title="알림">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
                    <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
                </svg>
                <span class="badge"></span>
            </button>

            <!-- 채팅 -->
            <button class="icon-btn" title="채팅">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
                </svg>
            </button>

            <!-- 프로필 드롭다운 -->
            <div class="profile-dropdown">
                <button class="profile-btn" onclick="toggleDropdown()">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                        <circle cx="12" cy="7" r="4"></circle>
                    </svg>
                    <span>${sessionScope.loginId}</span>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                        <polyline points="6 9 12 15 18 9"></polyline>
                    </svg>
                </button>

                <div id="dropdownMenu" class="dropdown-menu">
                    <a href="${pageContext.request.contextPath}/client/mypage" class="dropdown-item">마이페이지</a>
                    <a href="${pageContext.request.contextPath}/client/company" class="dropdown-item">회사 정보</a>
                    <div class="dropdown-divider"></div>
                    <a href="#" onclick="logout(event)" class="dropdown-item">로그아웃</a>
                </div>
            </div>
        </div>
    </div>
</header>

<script>
// 드롭다운 토글
function toggleDropdown() {
    const dropdown = document.getElementById('dropdownMenu');
    if (dropdown) {
        dropdown.classList.toggle('show');
    }
}

// 외부 클릭 시 드롭다운 닫기
document.addEventListener('click', function(e) {
    const profileDropdown = document.querySelector('.profile-dropdown');
    if (profileDropdown && !profileDropdown.contains(e.target)) {
        const dropdown = document.getElementById('dropdownMenu');
        if (dropdown) {
            dropdown.classList.remove('show');
        }
    }
});

// 로그아웃
async function logout(e) {
    e.preventDefault();

    try {
        const response = await fetch('${pageContext.request.contextPath}/logout', {
            method: 'POST'
        });

        if (response.ok) {
            window.location.href = '${pageContext.request.contextPath}/login';
        }
    } catch (error) {
        console.error('로그아웃 오류:', error);
        alert('로그아웃에 실패했습니다.');
    }
}
</script>
