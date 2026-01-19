<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>프로필 관리 - 클라이언트</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: Pretendard, Arial, sans-serif;
            background: #f8fafc;
            color: #111827;
        }
        .container {
            max-width: 800px;
            margin: 40px auto;
            padding: 0 16px;
        }
        .card {
            background: white;
            border-radius: 18px;
            padding: 30px;
            box-shadow: 0 10px 28px rgba(15,23,42,0.08);
            margin-bottom: 24px;
        }
        .form-group {
            display: flex;
            flex-direction: column;
            margin-bottom: 20px;
        }
        .form-label {
            font-weight: 900;
            margin-bottom: 8px;
            font-size: 14px;
            color: #111827;
        }
        .form-input {
            padding: 10px 12px;
            border: 1px solid #d1d5db;
            border-radius: 12px;
            font-family: Pretendard, Arial, sans-serif;
            font-size: 14px;
            outline: none;
        }
        .form-input:focus {
            border-color: #5c3cce;
            box-shadow: 0 0 0 3px rgba(92, 60, 206, 0.1);
        }
        .save-btn {
            padding: 12px 24px;
            background: #5c3cce;
            color: white;
            border: none;
            border-radius: 12px;
            font-weight: 900;
            cursor: pointer;
            font-size: 14px;
        }
        .save-btn:hover {
            opacity: 0.9;
        }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/views/common/client_header.jsp" %>

<div class="container">
    <h1 style="font-size: 28px; margin-bottom: 24px; font-weight: 950;">프로필 관리</h1>

    <div class="card">
        <h2 style="font-size: 18px; margin-bottom: 20px; font-weight: 900;">회사 정보</h2>

        <div class="form-group">
            <label class="form-label">회사명</label>
            <input type="text" class="form-input" placeholder="회사명을 입력하세요">
        </div>

        <div class="form-group">
            <label class="form-label">담당자 이메일</label>
            <input type="email" class="form-input" placeholder="이메일을 입력하세요">
        </div>

        <div class="form-group">
            <label class="form-label">담당자 연락처</label>
            <input type="tel" class="form-input" placeholder="연락처를 입력하세요">
        </div>

        <div class="form-group">
            <label class="form-label">회사 소개</label>
            <textarea class="form-input" style="min-height: 100px; resize: vertical;" placeholder="회사 소개를 입력하세요"></textarea>
        </div>

        <button class="save-btn">저장하기</button>
    </div>

    <div class="card">
        <h2 style="font-size: 18px; margin-bottom: 20px; font-weight: 900;">계좌 정보</h2>
        <p style="color: #6b7280; margin-bottom: 16px;">프로젝트 비용 정산을 위한 계좌 정보입니다.</p>

        <div class="form-group">
            <label class="form-label">계좌 은행</label>
            <select class="form-input">
                <option value="">은행을 선택하세요</option>
                <option value="kb">국민은행</option>
                <option value="shinhan">신한은행</option>
                <option value="woori">우리은행</option>
            </select>
        </div>

        <div class="form-group">
            <label class="form-label">계좌번호</label>
            <input type="text" class="form-input" placeholder="계좌번호를 입력하세요">
        </div>

        <div class="form-group">
            <label class="form-label">예금주명</label>
            <input type="text" class="form-input" placeholder="예금주 이름을 입력하세요">
        </div>

        <button class="save-btn">저장하기</button>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

</body>
</html>
