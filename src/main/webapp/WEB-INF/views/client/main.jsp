<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>클라이언트 메인 - Ratel Ocean</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif; 
            background-color: #F5F5F5; 
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }
        main { flex: 1; padding: 2rem; }
        .container { max-width: 1200px; margin: 0 auto; }
        
        /* 정보 카드 */
        .profile-section { background: white; padding: 2rem; border-radius: 12px; margin-bottom: 2rem; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
        .profile-title { font-size: 1.8rem; font-weight: 700; color: #2B2B2B; margin-bottom: 0.5rem; }
        .profile-subtitle { color: #999; font-size: 0.95rem; margin-bottom: 2rem; }
        
        .info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.5rem; }
        .info-card { background: #f9f9f9; border-left: 4px solid #1F7A8C; padding: 1.5rem; border-radius: 6px; }
        .info-label { font-weight: 600; color: #1F7A8C; margin-bottom: 0.5rem; font-size: 0.85rem; text-transform: uppercase; }
        .info-value { color: #2B2B2B; font-size: 1.1rem; word-break: break-word; }
        .info-value.empty { color: #999; font-style: italic; }
        
        /* 연락처 정보 */
        .contact-section { margin-top: 2rem; padding-top: 2rem; border-top: 1px solid #eee; }
        .contact-title { font-size: 1.1rem; font-weight: 600; color: #2B2B2B; margin-bottom: 1rem; }
        
        footer { margin-top: 2rem; }
    </style>
</head>
<body>
    <!-- 클라이언트 상단바 -->
    <%@ include file="/WEB-INF/views/common/client_header.jsp" %>
    
    <main>
        <div class="container">
            <!-- 프로필 정보 섹션 -->
            <div class="profile-section">
                <h1 class="profile-title">
                    <%
                        Object userObj = session.getAttribute("loginUser");
                        String userName = "클라이언트";
                        if (userObj != null) {
                            try {
                                java.lang.reflect.Method getNameMethod = userObj.getClass().getMethod("getName");
                                Object nameObj = getNameMethod.invoke(userObj);
                                userName = nameObj != null ? nameObj.toString() : "클라이언트";
                            } catch (Exception e) {}
                        }
                    %>
                    <%= userName %> 님의 클라이언트 정보
                </h1>
                <p class="profile-subtitle">프로젝트를 등록하고 우수한 프리랜서를 찾아보세요.</p>
                
                <div class="info-grid">
                    <!-- 사용자 정보 -->
                    <div class="info-card">
                        <div class="info-label">👤 이름</div>
                        <div class="info-value">${loginUser.name != null ? loginUser.name : '<span class="empty">미입력</span>'}</div>
                    </div>
                    
                    <div class="info-card">
                        <div class="info-label">📧 이메일</div>
                        <div class="info-value">${loginUser.email != null ? loginUser.email : '<span class="empty">미입력</span>'}</div>
                    </div>
                    
                    <div class="info-card">
                        <div class="info-label">📱 전화번호</div>
                        <div class="info-value">${loginUser.phone != null ? loginUser.phone : '<span class="empty">미입력</span>'}</div>
                    </div>
                    
                    <div class="info-card">
                        <div class="info-label">🎂 생년월일</div>
                        <div class="info-value">${loginUser.birthDate != null ? loginUser.birthDate : '<span class="empty">미입력</span>'}</div>
                    </div>
                </div>
                
                <!-- 연락처 섹션 -->
                <div class="contact-section">
                    <h3 class="contact-title">📞 연락처</h3>
                    <p style="color: #666; margin-top: 0.5rem;">
                        프리랜서에게 프로젝트 제안을 하고 서로 소통할 수 있습니다.
                    </p>
                </div>
            </div>
        </div>
    </main>
    
    <!-- 공통 하단바 -->
    <%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>
