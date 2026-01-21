<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>RatelOcean | 계좌 등록</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/signup-mockup.css">
    <style>
        /* 브랜드 가이드라인 컬러 적용 */
        :root {
            --brand-deep: #4C1D95;    /* Deep Purple */
            --brand-vivid: #7C3AED;   /* Vivid Violet */
            --bg-light: #F9FAFB;
            --text-main: #111827;
            --text-sub: #6B7280;
            --border-color: #E5E7EB;
        }

        body {
            background-color: var(--bg-light);
            font-family: 'Pretendard', -apple-system, sans-serif;
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
        }

        .signup-container {
            width: 100%;
            max-width: 540px;
            padding: 20px;
        }

        /* 카드 디자인 */
        .form-card {
            background: #FFFFFF;
            border: 1px solid var(--border-color);
            border-radius: 16px;
            padding: 48px;
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.05);
        }

        .eyebrow {
            color: var(--brand-vivid);
            font-weight: 700;
            font-size: 0.85rem;
            letter-spacing: 1px;
            margin-bottom: 8px;
            text-transform: uppercase;
        }

        .form-card h2 {
            margin: 0 0 12px 0;
            font-size: 1.75rem;
            font-weight: 800;
            color: var(--text-main);
        }

        .subtitle {
            color: var(--text-sub);
            font-size: 0.95rem;
            line-height: 1.5;
            margin-bottom: 40px;
        }

        /* 입력 그룹 */
        .input-group {
            margin-bottom: 24px;
        }

        .label {
            display: block;
            margin-bottom: 8px;
            font-size: 0.9rem;
            font-weight: 600;
            color: var(--text-main);
        }

        .input {
            width: 100%;
            padding: 14px 16px;
            border: 1px solid #D1D5DB;
            border-radius: 10px;
            font-size: 1rem;
            box-sizing: border-box;
            transition: all 0.2s;
            background-color: #fff;
        }

        .input:focus {
            outline: none;
            border-color: var(--brand-vivid);
            box-shadow: 0 0 0 4px rgba(124, 58, 237, 0.1);
        }

        /* 보안 안내 섹션 */
        .security-note {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 16px;
            background-color: #F3F4F6;
            border-radius: 8px;
            margin: 32px 0;
        }

        .security-note svg {
            color: var(--brand-deep);
            flex-shrink: 0;
        }

        .security-note .text {
            font-size: 0.85rem;
            color: var(--text-sub);
            line-height: 1.4;
        }

        /* 버튼 스타일 */
        .btn.primary {
            background-color: var(--brand-deep);
            color: #FFFFFF;
            width: 100%;
            padding: 18px;
            border-radius: 10px;
            border: none;
            font-size: 1.1rem;
            font-weight: 700;
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .btn.primary:hover {
            background-color: var(--brand-vivid);
        }

        .back-link {
            display: block;
            text-align: center;
            margin-top: 24px;
            font-size: 0.9rem;
            color: var(--text-sub);
            text-decoration: none;
        }

        .back-link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
<main class="signup-container">
    <div class="form-card">
        <p class="eyebrow">Step 2. Payment Information</p>
        <h2>정산 계좌 등록</h2>
        <p class="subtitle">수익금 정산을 위해 본인 명의의 계좌 정보를 입력해 주세요. 입력된 정보는 암호화되어 보호됩니다.</p>

        <form action="${pageContext.request.contextPath}/join/complete" method="post">
            <div class="input-group">
                <label class="label">은행명</label>
                <select name="bankName" class="input" required>
                    <option value="">은행을 선택하세요</option>
                    <option value="신한">신한은행</option>
                    <option value="국민">KB국민은행</option>
                    <option value="우리">우리은행</option>
                    <option value="하나">하나은행</option>
                    <option value="기업">IBK기업은행</option>
                    <option value="농협">NH농협은행</option>
                    <option value="카카오">카카오뱅크</option>
                    <option value="토스">토스뱅크</option>
                </select>
            </div>

            <div class="input-group">
                <label class="label">계좌번호</label>
                <input type="text" name="accountNumber" class="input"
                       placeholder="'-' 없이 숫자만 입력"
                       pattern="[0-9]*" inputmode="numeric" required>
            </div>

            <div class="input-group">
                <label class="label">예금주</label>
                <input type="text" name="accountHolder" class="input"
                       placeholder="실명을 입력하세요" required>
            </div>

            <div class="security-note">
                <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                    <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                </svg>
                <div class="text">
                    입력하신 계좌 정보는 안전한 정산 서비스를 위해 SSL 암호화 기술로 보호됩니다.
                </div>
            </div>

            <button type="submit" class="btn primary">회원가입 완료하기</button>

            <a href="javascript:history.back()" class="back-link">이전 단계로 돌아가기</a>
        </form>
    </div>
</main>
</body>
</html>