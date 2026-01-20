<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head>
    <title>채팅</title>
    <style>
        /* CSS는 기존과 동일, 필요 시 강조색 등 추가 */
        .chat-room.selected { background: #9ad9db; }
        .unread { background: #e53935; color: #fff; font-size: 10px; padding: 2px 6px; border-radius: 10px; }
    </style>
</head>
<body>
<div class="app">

    <!-- LEFT: 채팅방 목록 -->
    <aside class="chat-list" id="roomList">
        <!-- JS로 로드 -->
    </aside>

    <!-- CENTER: 채팅 영역 -->
    <main class="chat-area">
        <div class="chat-header" id="chatHeader">채팅방</div>
        <div class="chat-body" id="chatBody"></div>
        <div class="typing" id="typingIndicator">
            상대방이 입력 중입니다...
        </div>
        <div class="chat-input">
            <input type="text" id="messageInput" placeholder="메시지를 입력하세요">
            <button class="send-btn" onclick="sendMessage()">전송</button>
        </div>
    </main>

    <!-- RIGHT: 프로필/프로젝트/공유파일 -->
    <aside class="info" id="roomInfo">
        <!-- JS로 로드 -->
    </aside>
</div>

<script>
    function escapeHtml(text) {
        if (!text) return "";
        return text
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;");
    }

    let selectedRoomId = null;
    const loginUserId = '${sessionScope.loginUser != null ? sessionScope.loginUser.user_id : 0}';

    // ================== 채팅방 목록 로드 ==================
    function loadChatRooms() {
        fetch("/ratelocean/chat/rooms")
            .then(res => res.json())
            .then(list => {
                const roomList = document.getElementById("roomList");
                roomList.innerHTML = "";

                list.forEach(room => {
                    let roomTimeText = "";

                    if (room.last_message_at) {
                        roomTimeText = new Date(room.last_message_at)
                            .toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                    }

                    const roomDiv = document.createElement("div");
                    roomDiv.dataset.roomId = room.room_id;
                    roomDiv.className = "chat-room" + (room.room_id === selectedRoomId ? " selected" : "");
                    roomDiv.innerHTML = `
                        <img src="${room.profile_image_url || '/assets/img/default-profile.png'}" class="avatar">
                        <div style="flex:1;">
                            <div class="room-top">
                                <span>${room.name}</span>
                                <span>${roomTimeText}</span>
                            </div>
                            <div class="room-bottom">
                                ${room.last_message_content || '아직 메시지가 없습니다.'}
                            </div>
                        </div>
                        ${room.has_new_message ? '<span class="unread">N</span>' : ''}
                    `;
                    roomDiv.addEventListener("click", () => selectRoom(room.room_id));
                    roomList.appendChild(roomDiv);
                });
            });
    }
    // ================== 방 선택 ==================

    let typingTimer = null;

    document.getElementById("messageInput").addEventListener("input", () => {
        if (!selectedRoomId) return;

        fetch(`/ratelocean/chat/room/${selectedRoomId}/typing`, {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: "typing=true"
        });

        clearTimeout(typingTimer);
        typingTimer = setTimeout(() => {
            fetch(`/ratelocean/chat/room/${selectedRoomId}/typing`, {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: "typing=false"
            });
        }, 1500);
    });
    function loadTypingStatus() {
        if (!selectedRoomId) return;

        fetch(`/ratelocean/chat/room/${selectedRoomId}/typing`)
            .then(res => res.json())
            .then(userId => {
                const el = document.getElementById("typingIndicator");

                if (userId && userId !== loginUserId) {
                    el.style.display = "block";
                } else {
                    el.style.display = "none";
                }
            });
    }
    function highlightSelectedRoom() {
        document.querySelectorAll(".chat-room").forEach(div => {
            div.classList.toggle(
                "selected",
                div.dataset.roomId == selectedRoomId
            );
        });
    }

    // ================== 메시지 로드 ==================
    function loadMessages() {
        if (!selectedRoomId) return;
        fetch(`/ratelocean/chat/room/${selectedRoomId}/messages`)
            .then(res => res.json())
            .then(list => {
                const body = document.getElementById("chatBody");
                body.innerHTML = "";
                list.forEach(msg => {
                    let timeText = "";

                    if (msg.created_at) {
                        timeText = new Date(msg.created_at)
                            .toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                    }

                    const mine = msg.sender_id === loginUserId;

                    let readMark = "";

                    // ✅ 내가 보낸 메시지만 체크
                    if (mine) {
                        readMark = msg.is_read === 1 ? "0" : "1";
                    }

                    const div = document.createElement("div");
                    div.className = "message " + (mine ? "mine" : "");

                    div.innerHTML = `
        <div class="bubble">
            ${escapeHtml(msg.content || "")}
            <div class="meta">
                        ${timeText}
                <span class="read-mark">${readMark}</span>
            </div>
        </div>
    `;

                    body.appendChild(div);
                });

                body.scrollTop = body.scrollHeight;
            });
    }

    // ================== 메시지 전송 ==================
    function sendMessage() {
        const input = document.getElementById("messageInput");
        const content = input.value.trim();
        if (!content || !selectedRoomId) return;

        fetch("/ratelocean/chat/room/" + selectedRoomId + "/message", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: new URLSearchParams({ content: content })
        }).then(res => {
            if (!res.ok) throw new Error("send fail");
            input.value = "";
            loadMessages();
            loadChatRooms();
        });
    }

    // ================== 우측 방 정보 로드 ==================
    function loadRoomInfo() {
        if (!selectedRoomId) return;

        fetch(`/ratelocean/chat/room/${selectedRoomId}/info`)
            .then(res => res.json())
            .then(room => {
                const info = document.getElementById("roomInfo");
                info.innerHTML = `
                <div class="profile-card">
                    <img src="${room.profile_image_url || '/assets/img/default-profile.png'}" class="avatar">
                    <h3>${room.name}</h3>

                    <div class="action-buttons">
                        <a href="/user/profile/${room.user_id}" class="btn">프로필</a>
                        <a href="/project/${room.project_id}" class="btn secondary">프로젝트</a>
                    </div>
                </div>
            `;
            });
    }

    function selectRoom(room_id) {
        selectedRoomId = room_id;

        // ✅ 읽음 처리
        fetch(`/ratelocean/chat/room/${room_id}/read`, {
            method: "POST"
        });

        loadMessages();
        loadChatRooms();
        loadRoomInfo(); // 누락되지 않도록
        highlightSelectedRoom();
    }

    // ================== 자동 갱신 ==================
    loadChatRooms();
    setInterval(() => {
        loadChatRooms();
        if (selectedRoomId) {
            loadMessages();
        }
    }, 3000);

</script>
</body>
</html>
