<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>채팅</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/room.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
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
            <div style="display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <div class="header-name" id="headerName">상대방</div>
                    <div class="header-project" id="headerProject">프로젝트</div>
                </div>
                <button id="exitRoomBtn" onclick="exitRoom()">나가기</button>
            </div>
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

    let selectedRoomId = null;
    const loginUserId =  Number('${loginUserId}');
    let opponentExited = false;
    function exitRoom() {
        if (!selectedRoomId) return;
        if (!confirm("채팅방을 나가시겠습니까?")) return;

        fetch(`/ratelocean/chat/room/\${selectedRoomId}/exit`, {
            method: "POST"
        })
            .then(res => res.text())
            .then(resText => {
                if (resText === "ok") {
                    alert("채팅방을 나갔습니다.");

                    // 채팅방 목록에서 방 제거 또는 새로고침


                    // 선택된 방 초기화
                    selectedRoomId = null;
                    document.getElementById("chatBody").innerHTML = "";
                    document.getElementById("headerName").innerText = "";
                    document.getElementById("headerProject").innerText = "";
                    document.getElementById("roomInfo").innerHTML = "";
                    loadChatRooms();
                } else {
                    alert("채팅방 나가기에 실패했습니다.");
                }
            })
            .catch(err => {
                console.error(err);
                alert("채팅방 나가기에 실패했습니다.");
            });
    }

    // ================== 채팅방 목록 로드 ==================
    // ================== 채팅방 목록 로드 (왼쪽 사이드바) ==================
    function loadChatRooms() {
        fetch("/ratelocean/chat/rooms")
            .then(res => res.json())
            .then(list => {
                const container = document.getElementById("roomList"); // room.jsp의 왼쪽 목록 ID
                container.innerHTML = "";
                const filteredList = list.filter(room => {
                    if (loginUserId === room.freelancerId)
                        return room.freelancerExited === 0;
                    if (loginUserId === room.clientId) return room.clientExited === 0;
                    return true;
                });
                filteredList.forEach(room => {
                    // ✅ 시간 문자열 처리
                    let timeText = "";
                    if (room.lastMessageAt) {
                        timeText = new Date(room.lastMessageAt)
                            .toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                    }

                    // ✅ 안 읽은 메시지 개수 (보내주신 코드 로직)
                    let unreadHtml = "";
                    if (room.unreadCount > 0) {
                        unreadHtml =
                            '<span class="unread-badge" style="background: #e53935; color: #fff; font-size: 11px; padding: 4px 8px; border-radius: 12px; margin-left: 8px;">' +
                            room.unreadCount +
                            '</span>';
                    }
                    let lastMsg = room.lastMessageContent || "아직 메시지가 없습니다.";
                    if (room.lastMessageDeleted === 1) { // 서버에서 삭제 여부를 flag로 보내도록
                        lastMsg = "메시지가 삭제되었습니다.";
                    }
                    // ✅ HTML 생성 (보내주신 목록 코드 스타일 적용)
                    // 현재 선택된 방이면 배경색 강조를 위해 클래스 추가
                    const isSelected = (room.roomId == selectedRoomId) ? " selected" : "";
                     console.log("room.roomId :" , room.roomId )
                    container.innerHTML +=
                        '<div class="chat-room' + isSelected + '" ' +
                        'data-room-id="' + room.roomId + '" ' +
                        'onclick="selectRoom(' + room.roomId + ')">'+
                        '<div class="avatar-box">' +
                        '<img src="' + (room.profileImageUrl || '/ratelocean/assets/img/default-profile.png') + '" class="avatar">' +
                        '<div class="room-name">' + room.name + '</div>' +
                        '</div>' +
                        '<div class="room-info" style="flex: 1;">' +
                        '<div class="room-top" style="display: flex; justify-content: space-between; font-size: 14px; font-weight: 600;">' +
                        '<span class="room-title">' + room.title + '</span>' +
                        '<span class="room-time">' + timeText + '</span>' +
                        '</div>' +

                        '<div class="room-bottom" style="font-size: 13px; color: #666; margin-top: 4px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">' +
                        lastMsg +
                        '<div class="find-out" data-roomid="' + room.roomId + '">' +
                        '<span class="freelancerExited" data-free="' + (room.freelancerExited?1:0 )+ '"/>'+
                        '<span class="clientExited" data-client="' + (room.clientExited?1:0 )+ '"/>'+
                        '</div>' +
                        '</div>' +
                        '</div>' +
                        unreadHtml +
                        '</div>';

                });
            });

        selectRoom(${roomId});
    }
    // ================== 방 선택 ==================

    let typingTimer = null;
    let isTyping = false;


    messageInput.addEventListener("keydown", () => {
        if (!selectedRoomId) return;
        if (!isTyping) {
            isTyping = true;

            fetch(`/chat/room/\${selectedRoomId}/typing`, {
                method: "POST",
                body: new URLSearchParams({ typing: true })
            });
        }

        clearTimeout(typingTimer);

        typingTimer = setTimeout(() => {
            isTyping = false;

            fetch(`/chat/room/\${selectedRoomId}/typing`, {
                method: "POST",
                body: new URLSearchParams({ typing: false })
            });
        }, 1000); // 1초 동안 입력 없으면 typing 종료
    });
    function loadTypingStatus() {
        if (!selectedRoomId) return;

        fetch(`/ratelocean/chat/room/\${selectedRoomId}/typing`)
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
    function deleteMessage(messageId) {
        if (!confirm("메시지를 삭제할까요?")) return;

        fetch("/ratelocean/chat/message/" + messageId + "/delete", {
            method: "POST"
        })
            .then(res => {
                if (res.ok) {
                    loadMessages(selectedRoomId);
                } else {
                    alert("삭제에 실패했습니다.");
                }
            })
            .catch(err => console.error(err));
    }

    // ================== 메시지 로드 ==================
    function loadMessages(roomId) {


        fetch(`/ratelocean/chat/room/\${roomId}/messages`)

            .then(res => res.json())

            .then(list => {

                const body = document.getElementById("chatBody");

                body.innerHTML = "";

                let prevDate = "";

                list.forEach(msg => {

                    const msgDate = new Date(msg.createdAt).toLocaleDateString('ko-KR');



// 2. 이전 메시지와 날짜가 다를 때만 날짜 표시

                    if (msgDate !== prevDate) {
                        const dateDiv = document.createElement("div");
                        dateDiv.className = "date-label";

                        dateDiv.innerText = msgDate; // "2024. 5. 20." 형태로 출력됨

                        body.appendChild(dateDiv);



                        prevDate = msgDate; // 날짜 갱신

                    }

                    let timeText = "";



                    if (msg.createdAt) {

                        timeText = new Date(msg.createdAt)

                            .toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

                    }



                    const mine = msg.senderId == '${loginUserId}';



                    let readMark = "";



// ✅ 내가 보낸 메시지만 체크

                    if (mine) {

                        readMark = msg.isRead === 1 ? "읽음" : "";

                    }


                    const div = document.createElement("div");
                    div.className = "message " + (mine ? "mine" : "");
                    div.dataset.messageId = msg.messageId; // 메시지 ID 저장
                    if (msg.isDeleted == 1) {
                        div.innerHTML =
                            '<div class="bubble deleted">삭제된 메시지입니다.</div>';
                    }else {
                        let deleteBtn = "";
                        if (mine) {
                            deleteBtn = '<span class="delete-btn" onclick="deleteMessage(' + msg.messageId + ')">delete</span>';
                        }

// 메시지 HTML
                        div.innerHTML =
                            deleteBtn + // 삭제 버튼 먼저
                            '<div class="bubble">' + escapeHtml(msg.content || '') + '</div>' +
                            '<div class="meta">' + timeText + (readMark ? ' · ' + readMark : '') + '</div>';


                    }




                    body.appendChild(div);

                });

                if (opponentExited) {
                    const exitDiv = document.createElement("div");
                    exitDiv.className = "system-label";
                    exitDiv.innerText = "상대방이 채팅방을 나갔습니다.";

                    body.appendChild(exitDiv);

                    messageInput.disabled = true;
                    messageInput.placeholder = "상대방이 나간 방에서는 메시지를 보낼 수 없습니다.";
                    document.querySelector(".send-btn").disabled = true;
                } else {
                    messageInput.disabled = false;
                    messageInput.placeholder = "메시지를 입력하세요";
                }
                body.scrollTop = body.scrollHeight;

            });

    }

    // ================== 메시지 전송 ==================
    function sendMessage() {
        const content = messageInput.value.trim();
        if (!content || !selectedRoomId) return;

        const formData = new FormData();
        formData.append("content", content);

        fetch("/ratelocean/chat/room/" + selectedRoomId + "/message", {
            method: "POST",
            body: formData
        })
            .then(res => res.json())
            .then(msg => {
                messageInput.value = "";
                loadMessages(selectedRoomId);
            })
            .catch(err => {
                console.error(err);
            });

    }


    // ================== 우측 방 정보 로드 ==================
    function loadRoomInfo(roomId) {

        fetch(`/ratelocean/chat/room/\${selectedRoomId}/info`)
            .then(res => res.json())
            .then(room => {
                document.getElementById("headerName").innerText = room.name;
                document.getElementById("headerProject").innerText = room.title;
                const info = document.getElementById("roomInfo");
                info.innerHTML =
                    '<div class="profile-card">' +
                    '<img src="' + (room.profileImageUrl || '/assets/img/default-profile.png') + '">' +
                    '<h3>' + room.name + '</h3>' +
                    '<div class="action-buttons">' +
                    '<a href="/user/profile/' + room.senderId + '">프로필</a>' +
                    '<a href="/project/' + room.projectId+ '" class="secondary">프로젝트</a>' +
                    '</div>' +
                    '</div>' +
                    '<div class="info-section">' +
                    '<h4>공유 파일</h4>' +
                    '<div class="file-item">공유된 파일 없음</div>' +
                    '</div>';

            });
    }
    function profileDisplay(roomId){
        fetch(`/ratelocean/chat/room/\${roomId}/info`)
            .then(res => res.json())
            .then(room => {
                console.log(room);
                // DTO 필드 그대로 사용
                document.getElementById("headerName").innerText = room.name || "상대방";
                document.getElementById("headerProject").innerText = room.title || "프로젝트";

                const info = document.getElementById("roomInfo");
                info.innerHTML =
                    `<div class="profile-card">
                    <img src="\${room.profileImageUrl || '/assets/img/default-profile.png'}">
                    <h3>\${room.name || "상대방"}</h3>
                    <div class="action-buttons">
                        <a href="/user/profile/\${room.userId}">프로필</a>
                        <a href="/project/\${room.projectId}" class="secondary">프로젝트</a>
                    </div>
                </div>
                <div class="info-section">
                    <h4>공유 파일</h4>
                    <div class="file-item">공유된 파일 없음</div>
                </div>`;
        }).catch(err => console.error("방 정보 로드 실패:", err));
    }
    function selectRoom( roomId) {
        console.log("selectRoom메서드 roomId:" , roomId)

        //let value = $(this).find("span.freelancerExited").attr("data-freelancerExited");
        //console.log("freelancerExited:", value);

        selectedRoomId = roomId;
        loadMessages(roomId);
        // ✅ 읽음 처리
        fetch(`/ratelocean/chat/room/\${roomId}/read`, {
            method: "POST"
        }).then(() => {
        });

        profileDisplay(roomId);
        opponentExited = false;
                let roomDiv = $('.find-out[data-roomid="' + roomId + '"]');
                console.log(roomDiv.html());
                // 자식 span.clientExited의 data-freelancerexited 값 가져오기
                let freelancerexitedValue = roomDiv.find('span.freelancerExited').attr('data-free');
                let clientExitedValue = roomDiv.find('span.clientExited').attr('data-client');
                console.log("freelancerexitedValue:", freelancerexitedValue);
                console.log("clientExitedValue:", clientExitedValue);

                opponentExited = freelancerexitedValue == 1 || clientExitedValue == 1;
                console.log("opponentExited", opponentExited);

                loadMessages(roomId);

        highlightSelectedRoom();
    }

    // ================== 자동 갱신 ==================
    loadChatRooms();

</script>
</body>
</html>
