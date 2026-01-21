<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>RatelOcean - 클라이언트 프로필</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/signup-mockup.css">
    <style>
        /* freelancer_profile.jsp의 <style> 내용 복사해서 사용하거나 공통 CSS로 분리 권장 */
        /* 여기서는 핵심 레이아웃만 간단히 명시 */
        .input-field { width: 100%; padding: 14px; border: 1px solid #DDE2E5; border-radius: 8px; margin-bottom: 20px; box-sizing: border-box; }
        .label { font-weight: 600; display: block; margin-bottom: 8px; color: #2B2B2B; }
        .section-title { font-size: 1.1rem; font-weight: 700; margin: 30px 0 15px 0; color: #1F7A8C; }
        .btn-primary { background-color: #1F7A8C; color: white; padding: 16px; width: 100%; border: none; border-radius: 8px; font-weight: bold; cursor: pointer; }
    </style>
</head>
<body>
<main class="container" style="max-width: 600px; margin: 50px auto; padding: 20px;">
    <div style="text-align: center; margin-bottom: 40px;">
        <h1 style="font-size: 2rem;">클라이언트 정보 입력</h1>
        <p style="color: #6F7272;">프로젝트 등록 및 계약을 위해 기업/단체 정보를 입력해주세요.</p>
    </div>

    <form action="${pageContext.request.contextPath}/join/client-profile" method="post">

        <div class="section-title">🏢 기업/단체 정보</div>

        <label class="label">회사명 (단체명)</label>
        <input type="text" name="companyName" class="input-field" placeholder="예: (주)사나이클럽" required>

        <label class="label">사업자 등록번호</label>
        <input type="text" name="businessNumber" class="input-field" placeholder="'-' 없이 숫자만 입력" required>

        <label class="label">대표자명</label>
        <input type="text" name="ceoName" class="input-field" required>

        <div style="display: flex; gap: 10px;">
            <div style="flex: 1;">
                <label class="label">기업 규모</label>
                <select name="companySize" class="input-field">
                    <option value="STARTUP">스타트업</option>
                    <option value="SMALL">중소기업</option>
                    <option value="MEDIUM">중견기업</option>
                    <option value="LARGE">대기업</option>
                </select>
            </div>
            <div style="flex: 1;">
                <label class="label">클라이언트 유형</label>
                <select name="clientType" class="input-field">
                    <option value="CORPORATION">법인 사업자</option>
                    <option value="PERSONAL">개인 사업자</option>
                    <option value="GENERAL">개인 (비사업자)</option>
                </select>
            </div>
        </div>

        <div class="section-title">📍 추가 정보</div>
        <label class="label">회사 주소</label>
        <input type="text" name="address" class="input-field" placeholder="서울특별시 중구 ...">

        <label class="label">웹사이트 URL</label>
        <input type="url" name="websiteUrl" class="input-field" placeholder="https://www.company.com">

        <button type="submit" class="btn-primary" style="margin-top: 30px;">저장 및 다음 단계로 →</button>
    </form>
</main>
</body>
</html>