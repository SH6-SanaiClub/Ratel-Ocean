<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>경력 관리 - 프리랜서</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: Pretendard, Arial, sans-serif;
            background: #f8fafc;
            color: #111827;
        }
        .container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 16px;
        }
        .tabs {
            display: flex;
            gap: 24px;
            border-bottom: 1px solid #eef2f7;
            margin-bottom: 30px;
        }
        .tab {
            padding: 12px 0;
            font-weight: 900;
            cursor: pointer;
            border-bottom: 3px solid transparent;
            color: #6b7280;
            transition: all 0.2s ease;
        }
        .tab.active {
            color: #5c3cce;
            border-bottom-color: #5c3cce;
        }
        .card {
            background: white;
            border-radius: 18px;
            padding: 24px;
            box-shadow: 0 10px 28px rgba(15,23,42,0.08);
            margin-bottom: 16px;
        }
        .empty-section {
            text-align: center;
            padding: 40px 20px;
            color: #6b7280;
        }
        .edit-btn {
            display: inline-block;
            margin-top: 12px;
            padding: 8px 16px;
            background: #5c3cce;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 800;
            font-size: 13px;
        }
        .edit-btn:hover {
            background: #4c2dbd;
        }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/views/common/freelancer_header.jsp" %>

<div class="container">
    <h1 style="font-size: 28px; margin-bottom: 24px; font-weight: 950;">경력 관리</h1>
    
    <!-- 탭 -->
    <div class="tabs">
        <div class="tab active" onclick="switchTab(event, 'profile')">프로필</div>
        <div class="tab" onclick="switchTab(event, 'portfolio')">포트폴리오</div>
        <div class="tab" onclick="switchTab(event, 'review')">평가</div>
    </div>

    <!-- 프로필 탭 -->
    <div id="profile" class="tab-content">
        <div class="card">
            <h2 style="font-size: 18px; margin-bottom: 16px; font-weight: 900;">프로필 정보</h2>
            <div class="empty-section">
                <p>프로필 정보가 등록되어 있습니다.</p>
                <button class="edit-btn">프로필 수정</button>
            </div>
        </div>
    </div>

    <!-- 포트폴리오 탭 -->
    <div id="portfolio" class="tab-content" style="display: none;">
        <div class="card">
            <h2 style="font-size: 18px; margin-bottom: 16px; font-weight: 900;">포트폴리오</h2>
            <div class="empty-section">
                <p>등록된 포트폴리오가 없습니다.</p>
                <button class="edit-btn">포트폴리오 추가</button>
            </div>
        </div>
    </div>

    <!-- 평가 탭 -->
    <div id="review" class="tab-content" style="display: none;">
        <div class="card">
            <h2 style="font-size: 18px; margin-bottom: 16px; font-weight: 900;">받은 평가</h2>
            <div class="empty-section">
                <p>아직 받은 평가가 없습니다.</p>
            </div>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

<script>
function switchTab(event, tabName) {
    // 모든 탭 내용 숨기기
    var contents = document.querySelectorAll('.tab-content');
    contents.forEach(function(content) {
        content.style.display = 'none';
    });
    
    // 모든 탭 비활성화
    var tabs = document.querySelectorAll('.tab');
    tabs.forEach(function(tab) {
        tab.classList.remove('active');
    });
    
    // 선택된 탭 활성화
    event.target.classList.add('active');
    document.getElementById(tabName).style.display = 'block';
}
</script>

</body>
</html>
