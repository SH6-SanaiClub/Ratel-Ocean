<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>채팅방</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: Pretendard, Arial, sans-serif;
            background: #f8fafc;
            color: #111827;
            height: 100vh;
            display: flex;
            flex-direction: column;
        }
        .chat-container {
            flex: 1;
            display: flex;
            height: 100vh;
        }
        .chat-list {
            width: 320px;
            background: white;
            border-right: 1px solid #eef2f7;
            display: flex;
            flex-direction: column;
            padding-top: 10px;
        }
        .chat-window {
            flex: 1;
            display: flex;
            flex-direction: column;
            background: white;
        }
        .chat-header {
            padding: 20px;
            border-bottom: 1px solid #eef2f7;
            font-weight: 900;
            font-size: 16px;
        }
        .chat-messages {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #6b7280;
        }
        .chat-input-area {
            padding: 20px;
            border-top: 1px solid #eef2f7;
            display: flex;
            gap: 10px;
        }
        .chat-input {
            flex: 1;
            padding: 10px 12px;
            border: 1px solid #d1d5db;
            border-radius: 12px;
            font-family: Pretendard, Arial, sans-serif;
            outline: none;
        }
        .chat-send-btn {
            padding: 10px 20px;
            background: #5c3cce;
            color: white;
            border: none;
            border-radius: 12px;
            font-weight: 900;
            cursor: pointer;
        }
        .empty-state {
            text-align: center;
            color: #6b7280;
        }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="chat-container">
    <!-- 채팅 목록 (좌측) -->
    <div class="chat-list">
        <div style="padding: 16px 12px; border-bottom: 1px solid #eef2f7; font-weight: 900;">대화</div>
        <div style="flex: 1; padding: 12px; color: #6b7280; font-size: 13px;">
            <p>아직 활성화되지 않았습니다.</p>
        </div>
    </div>

    <!-- 채팅 윈도우 (우측) -->
    <div class="chat-window">
        <div class="chat-header">채팅방을 선택해주세요</div>
        <div class="chat-messages">
            <div class="empty-state">
                <p>대화를 시작하려면 좌측에서 대화를 선택하세요.</p>
            </div>
        </div>
        <div class="chat-input-area" style="display: none;">
            <input type="text" class="chat-input" placeholder="메시지를 입력하세요">
            <button class="chat-send-btn">전송</button>
        </div>
    </div>
</div>

</body>
</html>
