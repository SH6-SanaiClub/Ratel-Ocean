<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>프리랜서 메인 - Ratel Ocean</title>
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
        
        /* URL 링크 */
        .info-value a { color: #1F7A8C; text-decoration: none; }
        .info-value a:hover { text-decoration: underline; }
        
        /* 기술 스택 */
        .skills-section { margin-top: 2rem; padding-top: 2rem; border-top: 1px solid #eee; }
        .skills-title { font-size: 1.1rem; font-weight: 600; color: #2B2B2B; margin-bottom: 1rem; }
        .skill-tags { display: flex; flex-wrap: wrap; gap: 0.8rem; }
        .skill-tag { 
            background: #E8F4F5; 
            color: #1F7A8C; 
            padding: 0.6rem 1rem; 
            border-radius: 20px; 
            font-size: 0.9rem;
            font-weight: 500;
        }
        
        /* 계좌 정보 */
        .account-info { 
            background: #FFF3CD; 
            border-left: 4px solid #FF9800; 
            padding: 1.5rem; 
            border-radius: 6px;
            margin-top: 1.5rem;
        }
        .account-info .info-label { color: #FF9800; }
        
        footer { margin-top: 2rem; }
    </style>
</head>
<body>
    <!-- 프리랜서 상단바 -->
    <%@ include file="/WEB-INF/views/common/freelancer_header.jsp" %>
    
    <main>
        <div class="container">
            <!-- 프로필 정보 섹션 -->
            <div class="profile-section">
                <h1 class="profile-title">
                    <%
                        Object userObj = session.getAttribute("loginUser");
                        String userName = "프리랜서";
                        if (userObj != null) {
                            try {
                                java.lang.reflect.Method getNameMethod = userObj.getClass().getMethod("getName");
                                Object nameObj = getNameMethod.invoke(userObj);
                                userName = nameObj != null ? nameObj.toString() : "프리랜서";
                            } catch (Exception e) {}
                        }
                    %>
                    <%= userName %> 님의 프리랜서 정보
                </h1>
                <p class="profile-subtitle">프로필 완성 후 확인하실 수 있습니다.</p>
                
                <div class="info-grid">
                    <!-- 기본 정보 -->
                    <div class="info-card">
                        <div class="info-label">👤 닉네임</div>
                        <div class="info-value" id="nickname">${freelancerProfile.nickname != null ? freelancerProfile.nickname : '<span class="empty">미입력</span>'}</div>
                    </div>
                    
                    <div class="info-card">
                        <div class="info-label">📝 자기소개</div>
                        <div class="info-value" id="introduction">${freelancerProfile.introduction != null ? freelancerProfile.introduction : '<span class="empty">미입력</span>'}</div>
                    </div>
                    
                    <!-- 학력 정보 -->
                    <div class="info-card">
                        <div class="info-label">🎓 학교</div>
                        <div class="info-value" id="schoolName">${freelancerProfile.schoolName != null ? freelancerProfile.schoolName : '<span class="empty">미입력</span>'}</div>
                    </div>
                    
                    <div class="info-card">
                        <div class="info-label">📚 전공</div>
                        <div class="info-value" id="major">${freelancerProfile.major != null ? freelancerProfile.major : '<span class="empty">미입력</span>'}</div>
                    </div>
                    
                    <div class="info-card">
                        <div class="info-label">🎯 학위</div>
                        <div class="info-value" id="degree">${freelancerProfile.degree != null ? freelancerProfile.degree : '<span class="empty">미입력</span>'}</div>
                    </div>
                    
                    <div class="info-card">
                        <div class="info-label">✅ 졸업 상태</div>
                        <div class="info-value" id="gradStatus">${freelancerProfile.gradStatus != null ? freelancerProfile.gradStatus : '<span class="empty">미입력</span>'}</div>
                    </div>
                    
                    <!-- 포트폴리오 -->
                    <div class="info-card">
                        <div class="info-label">🔗 GitHub</div>
                        <div class="info-value" id="github">
                            ${freelancerProfile.githubUrl != null ? '<a href="'.concat(freelancerProfile.githubUrl).concat('" target="_blank">').concat(freelancerProfile.githubUrl).concat('</a>') : '<span class="empty">미입력</span>'}
                        </div>
                    </div>
                    
                    <div class="info-card">
                        <div class="info-label">🌐 개인 웹사이트</div>
                        <div class="info-value" id="website">
                            ${freelancerProfile.websiteUrl != null ? '<a href="'.concat(freelancerProfile.websiteUrl).concat('" target="_blank">').concat(freelancerProfile.websiteUrl).concat('</a>') : '<span class="empty">미입력</span>'}
                        </div>
                    </div>
                </div>
                
                <!-- 계좌 정보 -->
                <div class="account-info">
                    <div class="info-label">💳 계좌 정보</div>
                    <div class="info-value">${accountInfo != null ? accountInfo : '<span class="empty">미입력</span>'}</div>
                </div>
            </div>
        </div>
    </main>
    
    <!-- 공통 하단바 -->
    <%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>

