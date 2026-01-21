<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RatelOcean | Freelancer Profile</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --brand-main: #2C1A52;      /* Deep Purple */
            --brand-accent: #00F0FF;    /* Neon Cyan */
            --brand-purple: #8A2BE2;    /* Radiant Purple */
            --bg-light: #F8F9FD;        /* 아주 밝은 라벤더 톤 배경 */
            --text-dark: #2D2D2D;
            --text-muted: #6C757D;
            --white: #FFFFFF;
            --border-color: #E2E8F0;
        }

        body {
            background-color: var(--bg-light);
            background-image:
                    radial-gradient(at 0% 0%, rgba(0, 240, 255, 0.05) 0px, transparent 50%),
                    radial-gradient(at 100% 100%, rgba(138, 43, 226, 0.05) 0px, transparent 50%);
            color: var(--text-dark);
            font-family: 'Noto Sans KR', sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            padding: 20px;
        }

        .container {
            width: 100%;
            max-width: 580px;
            background: var(--white);
            border-radius: 20px;
            padding: 50px 45px;
            box-shadow: 0 10px 30px rgba(44, 26, 82, 0.08); /* 브랜드 컬러를 섞은 그림자 */
            border: 1px solid var(--border-color);
        }

        /* 헤더 섹션 */
        .header {
            text-align: center;
            margin-bottom: 35px;
        }
        .header img {
            width: 170px;
            margin-bottom: 15px;
        }
        .header h1 {
            font-size: 1.6rem;
            font-weight: 700;
            color: var(--brand-main);
            margin: 0;
        }

        /* 단계 표시기 */
        .step-container {
            display: flex;
            justify-content: center;
            margin-bottom: 40px;
            gap: 20px;
        }
        .step-box {
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--text-muted);
            font-size: 0.85rem;
            font-weight: 500;
        }
        .step-box.active {
            color: var(--brand-purple);
        }
        .step-number {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            background: var(--border-color);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.7rem;
        }
        .active .step-number {
            background: var(--brand-purple);
            box-shadow: 0 0 8px rgba(138, 43, 226, 0.4);
        }

        /* 폼 구성 */
        .form-body {
            display: flex;
            flex-direction: column;
            gap: 22px;
        }
        .input-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .label-text {
            font-size: 0.9rem;
            font-weight: 600;
            color: var(--brand-main);
            display: flex;
            align-items: center;
            gap: 6px;
        }

        input[type="text"], input[type="url"], textarea, select {
            width: 100%;
            padding: 13px 16px;
            border: 1.5px solid var(--border-color);
            border-radius: 10px;
            font-size: 0.95rem;
            box-sizing: border-box;
            transition: all 0.2s ease;
            color: var(--text-dark);
            background-color: #FAFAFA;
        }

        input:focus, textarea:focus, select:focus {
            outline: none;
            border-color: var(--brand-accent);
            background-color: var(--white);
            box-shadow: 0 0 0 3px rgba(0, 240, 255, 0.1);
        }

        .grid-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }

        textarea {
            height: 110px;
            resize: none;
            line-height: 1.5;
        }

        /* 버튼 */
        .submit-area {
            margin-top: 15px;
        }
        .btn-primary {
            width: 100%;
            background: var(--brand-main);
            color: white;
            border: none;
            padding: 16px;
            border-radius: 12px;
            font-size: 1.05rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 8px;
        }
        .btn-primary:hover {
            background: var(--brand-purple);
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(44, 26, 82, 0.2);
        }

        ::placeholder {
            color: #ADB5BD;
        }

        /* 커스텀 셀렉트 화살표 */
        select {
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 24 24' fill='none' stroke='%232C1A52' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 12px center;
            background-size: 16px;
        }
    </style>
</head>
<body>

<div class="container">
    <header class="header">
        <h1>전문가 프로필 등록</h1>
    </header>

    <form action="${pageContext.request.contextPath}/join/freelancer-profile" method="post" class="form-body">

        <div class="input-group">
            <label class="label-text"><i class="fas fa-id-badge"></i> 활동 닉네임</label>
            <input type="text" name="nickname" placeholder="플랫폼에서 사용하실 닉네임을 입력하세요" required>
        </div>

        <div class="input-group">
            <label class="label-text"><i class="fas fa-user-edit"></i> 전문 분야 및 소개</label>
            <textarea name="introduction" placeholder="본인의 전문 스택 및 프로젝트 강점을 200자 내외로 요약해 주세요."></textarea>
        </div>

        <div class="input-group">
            <label class="label-text"><i class="fas fa-graduation-cap"></i> 최종 학력</label>
            <div class="grid-row" style="margin-bottom: 10px;">
                <input type="text" name="schoolName" placeholder="학교명 (예: OO대학교)">
                <input type="text" name="major" placeholder="전공명 (예: 컴퓨터공학)">
            </div>
            <div class="grid-row">
                <select name="degree">
                    <option value="" disabled selected>학위 선택</option>
                    <option value="ASSOCIATE">전문학사</option>
                    <option value="BACHELOR">학사</option>
                    <option value="MASTER">석사</option>
                    <option value="DOCTOR">박사</option>
                </select>
                <select name="gradStatus">
                    <option value="" disabled selected>졸업 상태</option>
                    <option value="GRADUATED">졸업</option>
                    <option value="ATTENDING">재학</option>
                    <option value="DROPOUT">중퇴</option>
                    <option value="LEAVE_OF_ABSENCE">휴학</option>
                </select>
            </div>
        </div>

        <div class="input-group">
            <label class="label-text"><i class="fas fa-link"></i> 소셜 및 포트폴리오</label>
            <div style="display: flex; flex-direction: column; gap: 10px;">
                <input type="url" name="githubUrl" placeholder="GitHub 주소 (https://...)">
                <input type="url" name="websiteUrl" placeholder="포트폴리오 주소 (https://...)">
            </div>
        </div>

        <div class="submit-area">
            <button type="submit" class="btn-primary">
                프로필 저장 후 다음 단계 <i class="fas fa-arrow-right"></i>
            </button>
        </div>
    </form>
</div>

</body>
</html>