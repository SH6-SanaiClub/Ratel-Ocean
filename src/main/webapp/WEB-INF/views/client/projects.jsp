<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>프로젝트 등록 및 검색 - 클라이언트</title>

    <style>
        :root{
            --bg:#f8fafc;
            --card:#ffffff;
            --text:#111827;
            --muted:#6b7280;
            --line:#eef2f7;

            --primary:#5c3cce;
            --chip-skill-bg:#eef2ff;
            --chip-skill-fg:#3730a3;

            --chip-pos-bg:#ecfeff;
            --chip-pos-fg:#0f766e;

            --danger:#dc2626;
            --shadow:0 10px 28px rgba(15,23,42,0.08);
            --radius:18px;
        }

        *{ box-sizing:border-box; }
        body{
            margin:0;
            font-family:Pretendard, Arial, sans-serif;
            background:var(--bg);
            color:var(--text);
        }

        .dashboard-wrap{
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 16px;
        }

        .tabs {
            display: flex;
            gap: 20px;
            border-bottom: 2px solid var(--line);
            margin-bottom: 24px;
        }

        .tab {
            padding: 12px 0;
            font-weight: 900;
            font-size: 16px;
            cursor: pointer;
            border-bottom: 3px solid transparent;
            color: var(--muted);
            transition: all 0.2s ease;
            margin-bottom: -2px;
        }

        .tab.active {
            color: var(--primary);
            border-bottom-color: var(--primary);
        }

        .tab-content {
            display: none;
        }

        .tab-content.active {
            display: block;
        }

        /* 새 프로젝트 등록 폼 */
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            background: white;
            padding: 30px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group.full {
            grid-column: 1 / -1;
        }

        .form-label {
            font-weight: 900;
            margin-bottom: 8px;
            font-size: 14px;
            color: var(--text);
        }

        .form-input, .form-textarea {
            padding: 10px 12px;
            border: 1px solid #d1d5db;
            border-radius: 12px;
            font-family: Pretendard, Arial, sans-serif;
            font-size: 14px;
            outline: none;
        }

        .form-textarea {
            min-height: 120px;
            resize: vertical;
        }

        .form-input:focus, .form-textarea:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(92, 60, 206, 0.1);
        }

        .submit-btn {
            padding: 12px 24px;
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 12px;
            font-weight: 900;
            cursor: pointer;
            font-size: 14px;
            margin-top: 16px;
        }

        .submit-btn:hover {
            opacity: 0.9;
        }

        /* 프로젝트 리스트 */
        .project-list {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .project-card {
            background: white;
            border-radius: var(--radius);
            padding: 18px 20px;
            box-shadow: var(--shadow);
            display: flex;
            gap: 22px;
        }

        .project-card-left {
            flex: 1;
        }

        .project-card-title {
            font-size: 18px;
            font-weight: 950;
            margin-bottom: 10px;
        }

        .project-card-meta {
            display: flex;
            gap: 20px;
            font-size: 13px;
            color: var(--muted);
            font-weight: 800;
        }

        .empty {
            background: white;
            padding: 40px 22px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            font-weight: 900;
            color: var(--muted);
            text-align: center;
        }

        @media (max-width: 860px) {
            .form-grid {
                grid-template-columns: 1fr;
            }
            .tabs {
                gap: 12px;
            }
            .tab {
                font-size: 14px;
            }
        }

    </style>
</head>

<body>

<%@ include file="/WEB-INF/views/common/client_header.jsp" %>

<div class="dashboard-wrap">
    <div class="tabs">
        <div class="tab active" onclick="switchTab(event, 'register')">새 프로젝트 등록</div>
        <div class="tab" onclick="switchTab(event, 'list')">프로젝트 목록</div>
    </div>

    <!-- 새 프로젝트 등록 탭 -->
    <div id="register" class="tab-content active">
        <div class="form-grid">
            <div class="form-group">
                <label class="form-label">프로젝트 제목 *</label>
                <input type="text" class="form-input" placeholder="프로젝트 이름을 입력하세요">
            </div>

            <div class="form-group">
                <label class="form-label">예산 *</label>
                <input type="number" class="form-input" placeholder="예상 예산 (₩)">
            </div>

            <div class="form-group">
                <label class="form-label">필요 포지션 *</label>
                <select class="form-input">
                    <option value="">포지션을 선택하세요</option>
                    <option value="frontend">Frontend</option>
                    <option value="backend">Backend</option>
                    <option value="fullstack">Fullstack</option>
                    <option value="design">Design</option>
                </select>
            </div>

            <div class="form-group">
                <label class="form-label">예상 기간 *</label>
                <input type="text" class="form-input" placeholder="예: 3개월, 6주">
            </div>

            <div class="form-group full">
                <label class="form-label">상세 설명 *</label>
                <textarea class="form-textarea" placeholder="프로젝트 상세 설명을 입력하세요"></textarea>
            </div>

            <button class="submit-btn full">프로젝트 등록</button>
        </div>
    </div>

    <!-- 프로젝트 목록 탭 -->
    <div id="list" class="tab-content">
        <div class="project-list">
            <div class="empty">등록된 프로젝트가 없습니다.</div>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

<script>
function switchTab(event, tabName) {
    // 모든 탭 내용 숨기기
    var contents = document.querySelectorAll('.tab-content');
    contents.forEach(function(content) {
        content.classList.remove('active');
    });
    
    // 모든 탭 비활성화
    var tabs = document.querySelectorAll('.tab');
    tabs.forEach(function(tab) {
        tab.classList.remove('active');
    });
    
    // 선택된 탭 활성화
    event.target.classList.add('active');
    document.getElementById(tabName).classList.add('active');
}
</script>

</body>
</html>
