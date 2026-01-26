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
    <script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.6.1/sockjs.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
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
                    <div class="header-name" id="headerName"></div>
                    <div class="header-project" id="headerProject"></div>
                </div>
                <button id="exitRoomBtn" onclick="exitRoom()"style="display:none;">나가기</button>
            </div>
        </div>

        <div class="chat-body" id="chatBody"></div>
        <div class="typing" id="typingIndicator"  style="display:none">
            상대방이 입력 중입니다...
        </div>
        <div class="chat-input">
            <button class="file-btn" onclick="openFile()">📎</button>

            <input type="file" id="fileInput" style="display:none">

            <div id="filePreview" class="file-preview" style="display:none">
                📎 <span id="fileNameText"></span>
                <button type="button" class="remove-file" onclick="removeFile()">✕</button>
            </div>

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

    let stompClient = null;
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
                    let timeText = "";
                    if (room.lastMessageAt) {
                        timeText = new Date(room.lastMessageAt)
                            .toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                    }
                    let unreadHtml = "";
                    if (room.unreadCount > 0) {
                        unreadHtml =
                            '<span class="unread-badge" style="background: #e53935; color: #fff; font-size: 11px; padding: 4px 8px; border-radius: 12px; margin-left: 8px;">' +
                            room.unreadCount +
                            '</span>';
                    }
                    let lastMsg = room.lastMessageContent || "아직 메시지가 없습니다.";
                    if (room.lastMessageDeleted === 1) {
                        lastMsg = "메시지가 삭제되었습니다.";
                    }
                    const isSelected = (room.roomId == selectedRoomId) ? " selected" : "";
                     console.log("room.roomId :" , room.roomId )
                    container.innerHTML +=
                        '<div class="chat-room' + isSelected + '" id="room-item-' + room.roomId + '" ' +
                        'data-room-id="' + room.roomId + '" ' +
                        'onclick="selectRoom(' + room.roomId + ')">' +
                        '<div class="avatar-box">' +
                        '<img src="' + (room.profileImageUrl || '/ratelocean/resources/image/default-profile.png') + '" class="avatar">' +
                        '<div class="room-name">' + room.name + '</div>' +
                        '</div>' +
                        '<div class="room-info" style="flex: 1;">' +
                        '<div class="room-top" style="display: flex; justify-content: space-between; font-size: 14px; font-weight: 600;">' +
                        '<span class="room-title">' + room.title + '</span>' +
                        '<span class="room-time">' + timeText + '</span>' +
                        '</div>' +
                        '<div class="room-bottom" style="font-size: 13px; color: #666; margin-top: 4px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">' +
                        '<span class="last-msg-text">' + lastMsg + '</span>' +
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
    }
    // ================== 방 선택 ==================
    let typingTimer = null;
    let isTyping = false;
    messageInput.addEventListener("keydown", () => {
        if (!selectedRoomId) return;
        if (!isTyping) {
            isTyping = true;
            stompClient.send("/pub/chat/room/${selectedRoomId}/typing", {}, JSON.stringify({
                roomId: selectedRoomId,
                typing: true
            }));
        }
        clearTimeout(typingTimer);
        typingTimer = setTimeout(() => {
            isTyping = false;
            stompClient.send("/pub/chat/typing", {}, JSON.stringify({
                roomId: selectedRoomId,
                typing: false
            }));
        }, 1000);
    });
    function openFile() {
        document.getElementById("fileInput").click();
    }
    function removeFile() {
        const fileInput = document.getElementById("fileInput");
        fileInput.value = ""; // 파일 선택 초기화

        document.getElementById("filePreview").style.display = "none";
        document.getElementById("fileNameText").innerText = "";
    }

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
                    if (body.querySelector(`.message[data-message-id='${msg.messageId}']`)) return;
                    const msgDate = new Date(msg.createdAt).toLocaleDateString('ko-KR');

// 2. 이전 메시지와 날짜가 다를 때만 날짜 표시

                    if (msgDate !== prevDate) {
                        const dateDiv = document.createElement("div");
                        dateDiv.className = "date-label";
                        dateDiv.innerText = msgDate;
                        body.appendChild(dateDiv);
                        prevDate = msgDate;
                    }
                    let timeText = "";
                    if (msg.createdAt) {
                        timeText = new Date(msg.createdAt)
                            .toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                    }
                    const mine = msg.senderId == '${loginUserId}';
                    let readMark = "";
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
                        let bubbleHtml = "";

// ✅ 파일 메시지
                        if (msg.fileUrl) {
                            bubbleHtml =
                                '<div class="bubble file-bubble">' +
                                '📎 ' +
                                '<a href="' + msg.fileUrl + '" target="_blank" download>' +
                                escapeHtml(msg.fileName) +
                                '</a>' +
                                (msg.fileSize
                                        ? '<div class="file-size">' + formatFileSize(msg.fileSize) + '</div>'
                                        : ''
                                ) +
                                '</div>';
                        }
// ✅ 일반 텍스트 메시지
                        else {
                            bubbleHtml =
                                '<div class="bubble">' +
                                escapeHtml(msg.content || '') +
                                '</div>';
                        }

                        div.innerHTML =
                            deleteBtn +
                            bubbleHtml +
                            '<div class="meta">' +
                            timeText +
                            (readMark ? ' · ' + readMark : '') +
                            '</div>';


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
                    document.querySelector(".send-btn").disabled = false;
                }
                updateSharedFilesFromMessages(list);
                body.scrollTop = body.scrollHeight;

            });

    }

    // ================== 메시지 전송 ==================
    function sendMessage() {
        const content = messageInput.value.trim();
        const fileInput = document.getElementById("fileInput");
        const file = fileInput.files[0];
        if (!content && !file) return;
        if (!selectedRoomId) return;
        const formData = new FormData();
        formData.append("content", content);
        if (file) {
            formData.append("file", file);
        }
        fetch("/ratelocean/chat/room/" + selectedRoomId + "/message", {
            method: "POST",
            body: formData
        })
            .then(res => res.json())
            .then(message => {

                if (stompClient && stompClient.connected) {
                    stompClient.send("/pub/chat/message", {}, JSON.stringify(message));
                }



                messageInput.value = "";
                fileInput.value = "";
                document.getElementById("filePreview").style.display = "none";
                document.getElementById("fileNameText").innerText = "";
                // 파일 공유 목록 업데이트
                updateSharedFilesFromMessages([message]);
            })
            .catch(err => console.error(err));
        // 보낼 데이터 객체 생성 (ChatMessageDTO와 매핑)
        const chatMessage = {
            roomId: selectedRoomId,
            senderId: loginUserId, // JSP 변수 사용
            content: content,
            type: 'TALK' // 필요시 타입 구분
        };
    }
/*
        // STOMP로 메시지 전송 (/pub/chat/message)
        stompClient.send("/pub/chat/message", {}, JSON.stringify(chatMessage));

        messageInput.value = ""; // 입력창 초기화
        // loadMessages() 호출 불필요 -> 구독 콜백에서 화면에 그리기 때문
        /*
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
    */

    function updateChatListUI(msg) {
        const roomId = msg.roomId;
        const $roomItem = $('#room-item-' + roomId);

        // 1. 목록에 해당 방이 이미 존재하는 경우
        if ($roomItem.length > 0) {

            // (1) 마지막 메시지 내용 업데이트
            let content = msg.content;
            if (msg.fileUrl) {
                content = '📎 ' + (msg.fileName || '파일');
            }
            // escapeHtml 처리는 필요시 추가
            $roomItem.find('.last-msg-text').text(content);

            // (2) 시간 업데이트 (현재 시간 기준 포맷팅)
            const date = new Date(msg.createdAt);
            const timeText = date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
            $roomItem.find('.room-time').text(timeText);

            // (3) 안읽음 뱃지 업데이트
            // 조건: 내가 보낸 메시지가 아니고(상대방이 보냄) && 현재 내가 보고 있는 방이 아닐 때
            if (msg.senderId !== loginUserId && roomId !== selectedRoomId) {
                const $badgeSpan = $roomItem.find('.unread-badge'); // 기존에 뱃지가 있는지 확인

                if ($badgeSpan.length > 0) {
                    // 기존 뱃지 숫자 증가
                    let count = parseInt($badgeSpan.text()) || 0;
                    $badgeSpan.text(count + 1);
                } else {
                    // 뱃지가 없으면 새로 생성 (room.jsp의 CSS 클래스 참고)
                    const newBadge = '<span class="unread-badge" style="background: #e53935; color: #fff; font-size: 11px; padding: 4px 8px; border-radius: 12px; margin-left: 8px;">1</span>';
                    // 방 제목 옆이나 적절한 위치에 append (구조에 따라 조정 필요, 여기서는 .room-top에 추가 예시)
                    $roomItem.find('.room-top').append(newBadge);
                }
            }

            // (4) 목록 최상단으로 이동 (애니메이션 효과 포함 가능)
            const $parent = $roomItem.parent(); // #roomList
            $roomItem.detach().prependTo($parent); // 떼어내서 맨 위로 붙임

        } else {
            // 2. 목록에 없는 새 방인 경우 (예: 신규 채팅 시작)
            // DTO 하나만으로 UI를 다 그리기엔 프로필 이미지 등 정보가 부족할 수 있으므로
            // 목록 전체를 다시 로드하거나, 서버에서 RoomDTO를 받아오는 것이 정확합니다.
            loadChatRooms();
        }
    }

    // [신규] 수신된 메시지를 화면에 그리기
    function showReceivedMessage(msg) {
        const body = document.getElementById("chatBody");
        const mine = (msg.senderId == loginUserId);

        const timeText = new Date(msg.createdAt)
            .toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

        const div = document.createElement("div");
        div.className = "message " + (mine ? "mine" : "");
        div.dataset.messageId = msg.messageId;

        let deleteBtn = "";
        if (mine) {
            deleteBtn =
                '<span class="delete-btn" onclick="deleteMessage(' +
                msg.messageId +
                ')">delete</span>';
        }

        let bubbleHtml = "";
        let fileHtml = "";
        // ===================== 파일 메시지 =====================
        if (msg.fileUrl) {

            let fileSizeHtml = "";

            if (msg.fileUrl !== null && msg.fileUrl !== "") {
                fileSizeHtml =
                    '<span style="font-size: 11px; color: #888; margin-left: 5px;">' +
                    '(' + formatFileSize(msg.fileSize) + ')' +
                    '</span>';
                updateSharedFilesFromMessages([msg]);
            }
            fileHtml =
                '<div class="file-section" style="margin-bottom: 5px; border-bottom: 1px dashed rgba(0,0,0,0.1); padding-bottom: 5px;">' +
                '📎 <a href="' + msg.fileUrl + '" target="_blank" download>' +
                escapeHtml(msg.fileName) + '</a>' +
                fileSizeHtml +
                '</div>';
        }
        let contentHtml = "";
        if (msg.content) {
            contentHtml = '<div>' + escapeHtml(msg.content) + '</div>';
        }
        bubbleHtml =
            '<div class="bubble ' + (msg.fileUrl ? "file-bubble" : "") + '">' +
            fileHtml +
            contentHtml +
            '</div>';

        div.innerHTML =
            deleteBtn +
            bubbleHtml +
            '<div class="meta">' + timeText + '</div>';

        // ===================== 텍스트 메시지 =====================
        body.appendChild(div);
        body.scrollTop = body.scrollHeight;
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
                    '<div class="file-list"></div>' +
                    '</div>';
                updateSharedFiles(roomId);
            })
            .catch(err => console.error("방 정보 로드 실패:", err));
    }
    function updateSharedFilesFromMessages(messages) {
       let fileContainer = document.querySelector("#roomInfo .file-list");
        if (!fileContainer) {
            const infoSection = document.querySelector("#roomInfo .info-section");
            if (infoSection) {
                fileContainer = document.createElement("div");
                fileContainer.className = "file-list";
                infoSection.appendChild(fileContainer);
            } else {
                // infoSection 자체가 없으면 더 이상 진행하지 않음
                return;
            }
        }
        fileContainer.innerHTML = ""; // 기존 내용 초기화
        let filesExist = false;
        messages.forEach(msg => {
            if (msg.fileUrl) {
                filesExist = true;
                const div = document.createElement("div");
                div.className = "file-item";
                div.innerHTML =
                    '📎 <a href="' + msg.fileUrl + '" target="_blank" download>' +
                    escapeHtml(msg.fileName) +
                    '</a>' +
                    (msg.fileSize ? ' (' + formatFileSize(msg.fileSize) + ')' : '');
                fileContainer.appendChild(div);
            }
        });

        if (!filesExist) {
            const div = document.createElement("div");
            div.className = "file-item";
            div.innerText = "공유된 파일 없음";
            fileContainer.appendChild(div);
        }
    }

    function profileDisplay(roomId){
        fetch(`/ratelocean/chat/room/\${roomId}/info`)
            .then(res => res.json())
            .then(room => {
                document.getElementById("headerName").innerText = room.name;
                document.getElementById("headerProject").innerText = room.title;

                const info = document.getElementById("roomInfo");
                info.innerHTML =
                    `<div class="profile-card">
                    <img src="\${room.profileImageUrl || '/assets/img/default-profile.png'}">
                    <h3>\${room.name}</h3>
                    <div class="action-buttons">
                        <a href="/user/profile/\${room.userId}">프로필</a>
                        <a href="/project/\${room.projectId}" class="secondary">프로젝트</a>
                    </div>
                </div>
                <div class="info-section">
                    <h4>공유 파일</h4>
                    <div class="file-list"></div>
                </div>`;
        }).catch(err => console.error("방 정보 로드 실패:", err));
    }
    function initEmptyRoom() {
        // 헤더 비우기
        document.getElementById("headerName").innerText = "";
        document.getElementById("headerProject").innerText = "";

        // 채팅 영역 안내
        document.getElementById("chatBody").innerHTML =
            '<div class="empty-room">채팅방을 선택해주세요</div>';

        // 우측 정보 제거
        document.getElementById("roomInfo").innerHTML = "";

        // 입력 비활성화
        messageInput.disabled = true;
        document.querySelector(".send-btn").disabled = true;

        // ✅ 나가기 버튼 숨김
        document.getElementById("exitRoomBtn").style.display = "none";
    }

    function selectRoom( roomId) {
        // 기존 방 구독 해제 (다른 방으로 이동 시)
        if (stompClient !== null) {
            stompClient.disconnect();
        }

        selectedRoomId = roomId;
        opponentExited = false;
        document.getElementById("exitRoomBtn").style.display = "inline-block";
        loadMessages(roomId);
        const $roomItem = $('#room-item-' + roomId);
        $roomItem.find('.unread-badge').remove();
        fetch(`/ratelocean/chat/room/\${roomId}/read`, {
            method: "POST"
        }).then(() => {
        });

        profileDisplay(roomId);
        opponentExited = false;
                let roomDiv = $('.find-out[data-roomid="' + roomId + '"]');
                let freelancerexitedValue = roomDiv.find('span.freelancerExited').attr('data-free');
                let clientExitedValue = roomDiv.find('span.clientExited').attr('data-client');
                opponentExited = freelancerexitedValue == 1 || clientExitedValue == 1;

        highlightSelectedRoom();
        // WebSocket 연결 시작
        connectStomp(roomId);
    }
    function formatFileSize(bytes) {
        if (!bytes) return "";
        if (bytes < 1024) return bytes + "B";
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + "KB";
        return (bytes / 1024 / 1024).toFixed(1) + "MB";
    }

    // [신규] STOMP 연결 및 구독 함수
    function connectStomp(roomId) {
        const socket = new SockJS('${pageContext.request.contextPath}/ws-stomp');// WebSocketConfig에서 설정한 엔드포인트
        stompClient = Stomp.over(socket);
        stompClient.debug = null; // 디버그 로그 끄기 (개발 중엔 켜두셔도 됩니다)
        stompClient.connect({}, function (frame) {
            console.log('STOMP Connected: ' + frame);
            // 해당 채팅방 구독 (/sub/chat/room/{roomId})
            stompClient.subscribe('/sub/chat/room/' + roomId, function (message) {
                const receivedMsg = JSON.parse(message.body);
                showReceivedMessage(receivedMsg); // 화면에 메시지 추가
            });
            stompClient.subscribe('/sub/chat/room/' + roomId + '/typing', function (message) {
                const typingUserId = Number(message.body);
                const el = document.getElementById("typingIndicator");
                if (typingUserId && typingUserId !== loginUserId) {
                    el.style.display = "block";
                } else {
                    el.style.display = "none";
                }
            });
            // 2. [신규] "나의 채팅 목록" 구독 (왼쪽 사이드바용)
            // 내가 속한 어떤 방에서든 메시지가 오면 이쪽으로 알림이 옴
            stompClient.subscribe('/sub/chat/list/' + loginUserId, function (message) {
                const msg = JSON.parse(message.body);
                updateChatListUI(msg);
            });
        }, function(error) {
            console.error("STOMP connection error:", error);
        });
    }
    document.getElementById("fileInput").addEventListener("change", function () {
        const file = this.files[0];

        if (file) {
            document.getElementById("filePreview").style.display = "flex";
            document.getElementById("fileNameText").innerText = file.name;
        }
    });
    initEmptyRoom();
    loadChatRooms();
</script>
</body>
</html>
