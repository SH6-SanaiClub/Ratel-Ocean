<%@ page contentType="text/html;charset=UTF-8" %>
<%
    Object userObj = session.getAttribute("loginUser");
    String headerNickname = "Guest";
    if (userObj != null) {
        try {
            java.lang.reflect.Method getNameMethod = userObj.getClass().getMethod("getName");
            Object nameObj = getNameMethod.invoke(userObj);
            headerNickname = nameObj != null ? nameObj.toString() : "Guest";
        } catch (Exception e) {
            headerNickname = "Guest";
        }
    }
%>
<style>
    .freelancer-header { background: linear-gradient(135deg, #1F7A8C 0%, #165f6d 100%); color: white; padding: 1rem 0; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
    .freelancer-header-container { max-width: 1200px; margin: 0 auto; padding: 0 2rem; display: flex; justify-content: space-between; align-items: center; }
    .freelancer-header-logo { font-size: 1.5rem; font-weight: 700; text-decoration: none; color: white; }
    .freelancer-header-nav { display: flex; gap: 2rem; align-items: center; }
    .freelancer-header-nav a { color: white; text-decoration: none; font-weight: 500; transition: opacity 0.2s; }
    .freelancer-header-nav a:hover { opacity: 0.8; }
    .freelancer-header-user { display: flex; align-items: center; gap: 1rem; }
    .freelancer-header-avatar { width: 36px; height: 36px; border-radius: 50%; background: white; color: #1F7A8C; display: flex; align-items: center; justify-content: center; font-weight: 600; }
</style>

<header class="freelancer-header">
    <div class="freelancer-header-container">
        <a href="${pageContext.request.contextPath}/freelancer/main" class="freelancer-header-logo">Ratel Ocean</a>
        
        <nav class="freelancer-header-nav">
            <a href="${pageContext.request.contextPath}/freelancer/projects">프로젝트</a>
            <a href="${pageContext.request.contextPath}/freelancer/applications">지원 내역</a>
            <a href="${pageContext.request.contextPath}/freelancer/profile">프로필</a>
            <a href="${pageContext.request.contextPath}/freelancer/messages">메시지</a>
            
            <div class="freelancer-header-user">
                <div class="freelancer-header-avatar"><%= headerNickname.substring(0, 1) %></div>
                <span><%= headerNickname %></span>
                <a href="${pageContext.request.contextPath}/logout">로그아웃</a>
            </div>
        </nav>
    </div>
</header>
