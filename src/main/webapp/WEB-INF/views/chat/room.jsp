<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>채팅</title>

    <style>
                * {
                    box-sizing: border-box;
                    font-family: Arial;
                }

                body {
                    margin: 0;
                    background: #f5f6f7;
                }

                .app {
                    display: flex;
                    height: 100vh;
                }

                /* ================= LEFT ================= */
                .meta {
                    font-size: 11px;
                    color: #666;
                    margin-top: 4px;
                    text-align: right;
                }
                .chat-list {
                    width: 320px;
                    background: #fff;
                    border-right: 1px solid #ddd;
                    overflow-y: auto;
                }

                .chat-room {
                    display: flex;
                    gap: 12px;
                    padding: 14px;
                    cursor: pointer;
                    border-bottom: 1px solid #f0f0f0;
                }

                .chat-room:hover {
                    background: #f7f9fa;
                }

                .chat-room.selected {
                    background: #e8f4f5;
                }

                .chat-room img {
                    width: 48px;
                    height: 48px;
                    border-radius: 50%;
                }

                .room-text {
                    flex: 1;
                }

                .room-name {
                    font-weight: bold;
                    font-size: 14px;
                }

                .room-last {
                    font-size: 13px;
                    color: #777;
                    margin-top: 4px;
                }

                /* ================= CENTER ================= */

                .chat-area {
                    flex: 1;
                    display: flex;
                    flex-direction: column;
                    background: #f9fafb;
                }

                .chat-header {
                    height: 60px;
                    border-bottom: 1px solid #ddd;
                    padding: 16px;
                    font-weight: bold;
                    background: #fff;
                }

                .chat-body {
                    flex: 1;
                    padding: 20px;
                    overflow-y: auto;
                }

                .message {
                    margin-bottom: 10px;
                }

                .message.mine {
                    text-align: right;
                }

                .bubble {
                    display: inline-block;
                    padding: 10px 14px;
                    border-radius: 16px;
                    background: #fff;
                    max-width: 60%;
                }

                .message.mine .bubble {
                    background: #9ad9db;
                }

                .chat-input {
                    display: flex;
                    padding: 12px;
                    background: #fff;
                    border-top: 1px solid #ddd;
                }

                .chat-input input {
                    flex: 1;
                    padding: 10px;
                    border: 1px solid #ccc;
                    border-radius: 6px;
                }

                .chat-input button {
                    margin-left: 10px;
                    padding: 10px 16px;
                }
                /* ================= RIGHT INFO ================= */

                .info {
                    width: 280px;
                    background: #ffffff;
                    border-left: 1px solid #ddd;
                    padding: 20px;
                    overflow-y: auto;
                }

                .profile-card {
                    text-align: center;
                    padding: 20px 10px;
                    border-bottom: 1px solid #eee;
                }

                .profile-card img {
                    width: 80px;
                    height: 80px;
                    border-radius: 50%;
                    object-fit: cover;
                    margin-bottom: 12px;
                }

                .profile-card h3 {
                    margin: 0;
                    font-size: 16px;
                }

                .profile-card p {
                    font-size: 13px;
                    color: #777;
                    margin-top: 6px;
                }

                /* 버튼 영역 */
                .action-buttons {
                    margin-top: 14px;
                    display: flex;
                    gap: 8px;
                }

                .action-buttons a {
                    flex: 1;
                    text-align: center;
                    padding: 8px 0;
                    border-radius: 6px;
                    font-size: 13px;
                    text-decoration: none;
                    color: #fff;
                    background: #4bb6b8;
                }

                .action-buttons a.secondary {
                    background: #9aa0a6;
                }

                /* 섹션 공통 */
                .info-section {
                    margin-top: 20px;
                }

                .info-section h4 {
                    font-size: 13px;
                    margin-bottom: 10px;
                    color: #444;
                }

                /* 파일 리스트 */
                .file-item {
                    font-size: 13px;
                    padding: 6px 0;
                    border-bottom: 1px solid #f0f0f0;
                    color: #555;
                    cursor: pointer;
                }

                .file-item:hover {
                    text-decoration: underline;
                }
                .chat-header {
                    height: 64px;
                    padding: 10px 16px;
                    border-bottom: 1px solid #ddd;
                    background: #fff;
                    display: flex;
                    flex-direction: column;
                    justify-content: center;
                }

                .header-name {
                    font-size: 15px;
                    font-weight: bold;
                }

                .header-project {
                    font-size: 12px;
                    color: #777;
                    margin-top: 2px;
                }
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
        <div class="chat-header" id="chatHeader">
            <div class="header-name" id="headerName">상대방</div>
            <div class="header-project" id="headerProject">프로젝트</div>
        </div>
        <div class="chat-body" id="chatBody"></div>
        <div class="typing" id="typingIndicator"  style="display:none">
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
    const messageInput = document.getElementById("messageInput");

    function escapeHtml(text) {
        if (!text) return "";
        return text
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;");
    }

    let selectedRoom_id = null;
    const login_user_id =  Number('${login_user_id}');


    // ================== 채팅방 목록 로드 ==================
    // ================== 채팅방 목록 로드 (왼쪽 사이드바) ==================
    function loadChatRooms() {
        fetch("/ratelocean/chat/rooms")
            .then(res => res.json())
            .then(list => {
                const container = document.getElementById("roomList"); // room.jsp의 왼쪽 목록 ID
                container.innerHTML = "";

                list.forEach(room => {
                    // ✅ 시간 문자열 처리
                    let timeText = "";
                    if (room.last_message_at) {
                        timeText = new Date(room.last_message_at)
                            .toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                    }

                    // ✅ 안 읽은 메시지 개수 (보내주신 코드 로직)
                    let unreadHtml = "";
                    if (room.unread_count > 0) {
                        unreadHtml =
                            '<span class="unread-badge" style="background: #e53935; color: #fff; font-size: 11px; padding: 4px 8px; border-radius: 12px; margin-left: 8px;">' +
                            room.unread_count +
                            '</span>';
                    }

                    // ✅ HTML 생성 (보내주신 목록 코드 스타일 적용)
                    // 현재 선택된 방이면 배경색 강조를 위해 클래스 추가
                    const isSelected = (room.room_id == selectedRoom_id) ? " selected" : "";
                     console.log("room.room_id :" , room.room_id )
                    container.innerHTML +=
                        '<div class="chat-room' + isSelected + '" onclick="selectRoom(' + room.room_id + ')" style="display: flex; align-items: center; padding: 12px 16px; border-bottom: 1px solid #f0f0f0; cursor: pointer;">' +

                        '<img src="' + (room.profile_image_url || '/ratelocean/assets/img/default-profile.png') +
                        '" class="avatar" style="width: 44px; height: 44px; border-radius: 50%; margin-right: 12px; object-fit: cover;">' +

                        '<div class="room-info" style="flex: 1;">' +
                        '<div class="room-top" style="display: flex; justify-content: space-between; font-size: 14px; font-weight: 600;">' +
                        '<span>' + room.name + '</span>' +
                        '<span>' + timeText + '</span>' +
                        '</div>' +

                        '<div class="room-bottom" style="font-size: 13px; color: #666; margin-top: 4px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">' +
                        (room.last_message_content || '아직 메시지가 없습니다.') +
                        '</div>' +
                        '</div>' +

                        unreadHtml +

                        '</div>';

                });
            });

        selectRoom(${room_id});
    }
    // ================== 방 선택 ==================

    let typingTimer = null;
    let isTyping = false;


    messageInput.addEventListener("keydown", () => {
        if (!selectedRoom_id) return;
        if (!isTyping) {
            isTyping = true;

            fetch(`/chat/room/${selectedRoom_id}/typing`, {
                method: "POST",
                body: new URLSearchParams({ typing: true })
            });
        }

        clearTimeout(typingTimer);

        typingTimer = setTimeout(() => {
            isTyping = false;

            fetch(`/chat/room/${selectedRoom_id}/typing`, {
                method: "POST",
                body: new URLSearchParams({ typing: false })
            });
        }, 1000); // 1초 동안 입력 없으면 typing 종료
    });
    function loadTypingStatus() {
        if (!selectedRoom_id) return;

        fetch(`/ratelocean/chat/room/${selectedRoom_id}/typing`)
            .then(res => res.json())
            .then(user_id => {
                const el = document.getElementById("typingIndicator");

                if (user_id && user_id !== login_user_id) {
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
                div.dataset.room_id == selectedRoom_id
            );
        });
    }

    // ================== 메시지 로드 ==================
    function loadMessages(room_id) {
        //if (selectedRoom_id == null) return;
        console.log(room_id);
        fetch(`/ratelocean/chat/room/\${room_id}/messages`)
            .then(res => res.json())
            .then(list => {
                console.log(list);
                const body = document.getElementById("chatBody");
                body.innerHTML = "";
                list.forEach(msg => {
                    let timeText = "";

                    if (msg.created_at) {
                        timeText = new Date(msg.created_at)
                            .toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                    }

                    const mine = msg.sender_id == login_user_id;

                    let readMark = "";

                    // ✅ 내가 보낸 메시지만 체크
                    if (mine) {
                        readMark = msg.is_read === 1 ? "0" : "1";
                    }

                    const div = document.createElement("div");
                    div.className = "message " + (mine ? "mine" : "");

                    div.innerHTML =
    '<div class="bubble">'
  + escapeHtml(msg.content || '')
  + '<div class="meta">'
  + timeText
  + '<span class="read-mark">' + readMark + '</span>'
  + '</div></div>';


                    body.appendChild(div);
                });

                body.scrollTop = body.scrollHeight;
            });
    }

    // ================== 메시지 전송 ==================
    function sendMessage() {
        const content = messageInput.value.trim();
        if (!content || !selectedRoom_id) return;

        const formData = new FormData();
        formData.append("content", content);

        fetch("/ratelocean/chat/room/" + selectedRoom_id + "/message", {
            method: "POST",
            body: formData
        })
            .then(res => res.json())
            .then(msg => {
                messageInput.value = "";
                loadMessages();
            })
            .catch(err => {
                console.error(err);
            });

    }


    // ================== 우측 방 정보 로드 ==================
    function loadRoomInfo() {
        if (!selectedRoom_id) return;

        fetch(`/ratelocean/chat/room/${selectedRoom_id}/info`)
            .then(res => res.json())
            .then(room => {
                document.getElementById("headerName").innerText = room.name;
                document.getElementById("headerProject").innerText = room.project_name;
                const info = document.getElementById("roomInfo");
                info.innerHTML =
                    '<div class="profile-card">' +
                    '<img src="' + (room.profile_image_url || '/assets/img/default-profile.png') + '">' +
                    '<h3>' + room.name + '</h3>' +
                    '<div class="action-buttons">' +
                    '<a href="/user/profile/' + room.user_id + '">프로필</a>' +
                    '<a href="/project/' + room.project_id + '" class="secondary">프로젝트</a>' +
                    '</div>' +
                    '</div>' +
                    '<div class="info-section">' +
                    '<h4>공유 파일</h4>' +
                    '<div class="file-item">공유된 파일 없음</div>' +
                    '</div>';

            });
    }

    function selectRoom(room_id) {
        console.log("selectRoom메서드 room_id:" , room_id)
        selectedRoom_id = room_id;
        // fetch(`/ratelocean/chat/room/\${room_id}/typing/reset`, {
        //     method: "POST"
        // });
        loadRoomInfo(room_id);
        loadMessages(room_id);
        // ✅ 읽음 처리
        fetch(`/ratelocean/chat/room/\${room_id}/read`, {
            method: "POST"
        }).then(() => {
        });


        fetch(`/ratelocean/chat/room/\${room_id}/info`)
            .then(res => res.json())
            .then(room => {
                // DTO 필드 그대로 사용
                document.getElementById("headerName").innerText = room.name || "상대방";
                document.getElementById("headerProject").innerText = room.project_name || "프로젝트";

                const info = document.getElementById("roomInfo");
                info.innerHTML =
                    `<div class="profile-card">
                    <img src="\${room.profile_image_url || '/assets/img/default-profile.png'}">
                    <h3>\${room.name || "상대방"}</h3>
                    <div class="action-buttons">
                        <a href="/user/profile/\${room.room_id}">프로필</a>
                        <a href="/project/\${room.project_id}" class="secondary">프로젝트</a>
                    </div>
                </div>
                <div class="info-section">
                    <h4>공유 파일</h4>
                    <div class="file-item">공유된 파일 없음</div>
                </div>`;
            })
            .catch(err => console.error("방 정보 로드 실패:", err));

        highlightSelectedRoom();
    }

    // ================== 자동 갱신 ==================
    loadChatRooms();
    // setInterval(() => {
    //     loadChatRooms();
    //     if (selectedRoom_id) {
    //         loadMessages();
    //         loadTypingStatus();
    //     }
    // }, 3000);

</script>
</body>
</html>
