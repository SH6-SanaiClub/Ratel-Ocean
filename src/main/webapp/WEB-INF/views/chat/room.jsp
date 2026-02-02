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
<c:if test="${param.mode ne 'view'}">
    <jsp:include page="/WEB-INF/views/common/headerBase.jsp" />
</c:if>
<div class="app">
    <!-- LEFT: 채팅방 목록 -->
    <aside class="chat-list" id="roomList">
    </aside>
    <!-- CENTER: 채팅 영역 -->
    <main class="chat-area">
        <div class="chat-header" id="chatHeader">
            <div style="display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <div class="header-name" id="headerName"></div>
                    <div class="header-project" id="headerProject"></div>
                </div>
                <div style="margin-left: auto; display: flex; align-items: center; gap: 8px;">
                    <div id="searchArea" style="display: none; align-items: center; gap: 5px;">
                        <input type="text" id="searchInput" placeholder="메시지 검색"
                               style="padding: 6px 12px; border: 1px solid #ddd; border-radius: 4px; font-size: 12px; width: 130px;">
                        <button onclick="searchMessages()"
                                style="padding: 6px 12px; background: rgba(59,111,220,.1); border: 1px solid rgba(59,111,220,.35); border-radius: 4px; cursor: pointer; font-size: 12px;">🔍</button>
                        <div id="searchNav" style="display: none; align-items: center; gap: 5px; background: #fff; padding: 0 5px; border-radius: 4px;">
                            <button onclick="navSearch(-1)" style="border:none; background:none; cursor:pointer; padding:0 2px;">▲</button>
                            <button onclick="navSearch(1)" style="border:none; background:none; cursor:pointer; padding:0 2px;">▼</button>
                            <span id="searchIndex" style="font-size: 11px; color: #666; min-width: 30px; text-align: center;">0/0</span>
                            <button onclick="clearSearch()" style="border:none; background:none; cursor:pointer; color: #ff4d4f; font-weight: bold; margin-left:2px;">✕</button>
                        </div>

            </div>
                    <button id="exitRoomBtn"
                            onclick="exitRoom()"
                            style="display:none; font-size: 12px; color:#ffffff;  background-color: #173160; margin-left: 8px;">
                        나가기
                    </button>
            </div>
        </div>
        </div>
        <div class="chat-body" id="chatBody"></div>
        <div class="chat-input">
            <button class="file-btn" onclick="openFile()">📎</button>

            <input type="file" id="fileInput" style="display:none">

            <div id="filePreview" class="file-preview" style="display:none">
                📎 <span id="fileNameText"></span>
                <button type="button" class="remove-file" onclick="removeFile()">✕</button>
            </div>
            <textarea id="messageInput" placeholder="메시지를 입력하세요" rows="1"
                      style="flex: 1; border: none; outline: none; padding: 10px; resize: none; overflow-y: hidden; max-height: 150px; font-family: inherit;"></textarea>
            <button class="send-btn" onclick="sendMessage()">전송</button>
        </div>
    </main>

    <!-- RIGHT: 프로필/프로젝트/공유파일 -->
    <aside class="info" id="roomInfo">
    </aside>
</div>

<script>
    const urlParams = new URLSearchParams(window.location.search);
    const autoRoomId = Number(urlParams.get("roomId"));
    const messageInput = document.getElementById("messageInput");
    const loginUserType = '${userType}';
    let roomSubscription = null;
    let listSubscription = null;
    let pendingRoomId = null;

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

    let autoEntered = false;

    function tryAutoEnter() {
        if (autoEntered || !autoRoomId) return;
        autoEntered = true;
        selectRoom(autoRoomId);
    }

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
                    selectedRoomId = null;
                    document.getElementById("chatBody").innerHTML = "";
                    document.getElementById("headerName").innerText = "";
                    document.getElementById("headerProject").innerText = "";
                    document.getElementById("roomInfo").innerHTML = "";
                    loadChatRooms();

                    if (roomSubscription) {
                        roomSubscription.unsubscribe();
                        roomSubscription = null;
                    }
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
    function loadChatRooms() {
        fetch("/ratelocean/chat/rooms")
            .then(res => res.json())
            .then(list => {
                const container = document.getElementById("roomList");
                let finalHtml = "";
                if (loginUserType === 'CLIENT') {
                    const projectGroups = {};
                    const projectOrder = [];
                    list.forEach(room => {
                        if (!projectGroups[room.title]) {
                            projectGroups[room.title] = [];
                            projectOrder.push(room.title);
                        }
                        projectGroups[room.title].push(room);
                    });
                    projectOrder.forEach(title => {
                        const rooms = projectGroups[title];
                        const safeId = btoa(encodeURIComponent(title)).replace(/=/g, "");
                        const totalUnread = rooms.reduce((sum, room) => sum + (room.unreadCount || 0), 0);
                        let unreadBadge = "";
                        if (totalUnread > 0) {
                            unreadBadge = '<span class="total-unread-badge" style="background: #173160; color: #fff; font-size: 11px; padding: 2px 7px; border-radius: 10px; margin-left: 8px; vertical-align: middle;">' + totalUnread + '</span>';
                        }

                        finalHtml +=
                            '<div class="project-header" onclick="toggleApplicants(\'' + safeId + '\')" ' +
                            'style="padding: 15px; background: rgba(23,49,96,.17); border-bottom: 1px solid #ddd; cursor: pointer; ' +
                            'display: flex; justify-content: space-between; align-items: center; font-weight: bold; color: #333;">' +
                            '   <div>' +
                            '       <span style="font-size: 15px;">' + title + '</span>' +
                            '       <span style="font-size: 12px; color: #3b6fdc; font-weight: normal; margin-left: 8px;">지원자 ' + rooms.length + '명</span>' +
                            '       ' + unreadBadge +
                            '   </div>' +
                            '   <span id="icon-' + safeId + '" style="font-size: 12px; color: #173160;">▼</span>' +
                            '</div>';

                        finalHtml += '<div id="group-' + safeId + '" class="applicant-list-container" style="display: none; background: #fff;">';
                        rooms.forEach(room => {
                            finalHtml += renderSingleRoom(room);
                        });
                        finalHtml += '</div>';
                    });
                } else {
                    list.forEach(room => {
                        finalHtml += renderSingleRoom(room);
                    });
                }
                container.innerHTML = finalHtml;

            })
            .catch(err => console.error("로드 에러:", err));

    }
    // ================== 방 선택 ==================
    function renderSingleRoom(room) {
        const profileImg = room.profileImageUrl
            ? '/ratelocean' + room.profileImageUrl
            : '/ratelocean/resources/image/default-profile.png';
        let timeText = "";
        if (room.lastMessageAt) {
            timeText = new Date(room.lastMessageAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        }
        let unreadHtml = "";
        if (room.unreadCount > 0) {
            unreadHtml = '<span class="unread-badge" style="background:#173160; color: #fff; font-size: 11px; padding: 4px 8px; border-radius: 50%; margin-left: 8px;">' + room.unreadCount + '</span>';
        }
        let lastMsg = room.lastMessageContent || "아직 메시지가 없습니다.";
        if (room.lastMessageDeleted === 1) lastMsg = "메시지가 삭제되었습니다.";
        const isSelected = (room.roomId == selectedRoomId) ? " selected" : "";
        let nameHtml = "";
        let underAvatarHtml = '';
        if (loginUserType === 'FREELANCER') {
            nameHtml = '<span class="room-project-tag" style="font-size: 13px; font-weight: bold; color: #333;">[' + room.title + ']</span>';
            underAvatarHtml = '<span class="name-under-avatar">' + room.name + '</span>';
        } else {
            nameHtml = '<span class="room-name-main" style="font-size: 15px; font-weight: bold; color: #333;">' + room.name + '</span>';
        }
        const projectKey = btoa(encodeURIComponent(room.title)).replace(/=/g, "");
        return '<div class="chat-room' + isSelected + '" id="room-item-' + room.roomId + '" data-room-id="' + room.roomId + '" data-project-key="' + projectKey + '"' + '" onclick="selectRoom(' + room.roomId + ')">' +
            '<div class="avatar-box">' +
            '<img src="' + profileImg + '" class="avatar">' +
            underAvatarHtml+
            '</div>' +
            '<div class="room-info" style="flex: 1; min-width: 0;">' +
            '<div class="room-top" style="display: flex; justify-content: space-between; font-size: 14px; font-weight: 600;">' +
            '<div style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 180px;">' + nameHtml + '</div>' +
            '<span class="room-time">' + timeText + '</span>' +
            '</div>' +
            '<div class="room-bottom" style="font-size: 13px; color: #666; margin-top: 4px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; min-width: 0;">' +
            '<span class="last-msg-text">' + lastMsg + '</span>' +
            '<div class="find-out" data-roomid="' + room.roomId + '">' +
            '<span class="freelancerExited" data-free="' + (room.freelancerExited?1:0 )+ '"/>'+
            '<span class="clientExited" data-client="' + (room.clientExited?1:0 )+ '"/>'+
            '</div>' +
            '</div>' +
            '</div>' +
            unreadHtml +
            '</div>';
    }

    function toggleApplicants(safeId) {
        const el = document.getElementById("group-" + safeId);
        const icon = document.getElementById("icon-" + safeId);
        if (el) {
            if (el.style.display === "none") {
                el.style.display = "block"; // 열기
                if(icon) icon.innerText = "▲";
            } else {
                el.style.display = "none";  // 닫기
                if(icon) icon.innerText = "▼";
            }
        }
    }

    function autoResize(textarea) {
        textarea.style.height = 'auto';
        textarea.style.height = textarea.scrollHeight + 'px';
    }
    messageInput.addEventListener("input", function() {
        autoResize(this);
    });

    function openFile() {
        document.getElementById("fileInput").click();
    }

    function removeFile() {
        const fileInput = document.getElementById("fileInput");
        fileInput.value = "";
        document.getElementById("filePreview").style.display = "none";
        document.getElementById("fileNameText").innerText = "";
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
        if (!confirm("메시지를 삭제하시겠습니까?")) return;
        const roomId = selectedRoomId;
        fetch("/ratelocean/chat/message/" + messageId + "/delete", {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ roomId: parseInt(roomId) })
        }).then(res => {
            if(res.ok){
                // 1. 메시지 UI 업데이트
                handleDeleteMessageUI(messageId);

                // 2. 공유 파일 목록 업데이트
                // 현재 화면에 있는 메시지 DOM에서 파일만 뽑아서 반영
                const messages = Array.from(document.querySelectorAll("#chatBody .message")).map(msgDiv => {
                    const fileLink = msgDiv.querySelector(".bubble a");
                    return {
                        fileUrl: fileLink ? fileLink.getAttribute("href") : null,
                        fileName: fileLink ? fileLink.innerText : null,
                        isDeleted: msgDiv.querySelector(".bubble").classList.contains("deleted") ? 1 : 0
                    };
                });
                updateSharedFilesFromMessages(messages);
            } else {
                alert("삭제 실패");
            }
        })
            .catch(err => {
                console.error(err);
                alert("삭제 실패");
            });
    }

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
                    div.id = "msg-" + msg.messageId;
                    div.dataset.messageId = msg.messageId;
                    if (msg.isDeleted == 1) {
                        div.innerHTML =
                            '<div class="bubble deleted">삭제된 메시지입니다.</div>';
                    }else {
                        let deleteBtn = "";
                        if (mine) {
                            deleteBtn = '<span class="delete-btn" onclick="deleteMessage(' + msg.messageId + ')">delete</span>';
                        }
                        let bubbleHtml = "";
                        if (msg.fileUrl) {
                            bubbleHtml =
                                '<div class="bubble file-bubble">' +
                                '📎 ' +
                                '<a href="/ratelocean/chat/file/' + msg.messageId + '">' +
                                escapeHtml(msg.fileName) +
                                '</a>' +
                                (msg.fileSize
                                        ? '<span style="font-size: 11px; color: #888; margin-left: 5px;">' + formatFileSize(msg.fileSize) + '</span>'
                                        : ''
                                ) + '</div>';
                        }
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

    function sendMessage() {
        const content = messageInput.value.trim();
        const file = document.getElementById("fileInput").files[0];
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
                messageInput.value = "";
                fileInput.value = "";
                document.getElementById("filePreview").style.display = "none";
                document.getElementById("fileNameText").innerText = "";

            })
            .catch(err => console.error("Message send error:", err));
    }

    function handleDeleteMessageUI(messageId) {
        const msgElement = document.getElementById("msg-" + messageId);
        if (msgElement) {
            const contentArea = msgElement.querySelector(".bubble");
            if(contentArea) {
                contentArea.innerText = "삭제된 메시지입니다.";
                contentArea.classList.remove("file-bubble");
                contentArea.classList.add("deleted");
            }
            const actionBtn = msgElement.querySelector(".delete-btn");
            if(actionBtn) actionBtn.style.display = "none";
        }
    }

    function updateChatListUI(msg) {
        const roomId = msg.roomId;
        const $roomItem = $('#room-item-' + roomId);
        if ($roomItem.length > 0) {
            let content = msg.content;
            if (msg.fileUrl) {
                content = '📎 ' + (msg.fileName || '파일');
            }
            $roomItem.find('.last-msg-text').text(content);
            const date = new Date(msg.createdAt);
            const timeText = date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
            $roomItem.find('.room-time').text(timeText);
            if (msg.senderId !== loginUserId && roomId !== selectedRoomId) {
                const $badgeSpan = $roomItem.find('.unread-badge');
                if ($badgeSpan.length > 0) {
                    let count = parseInt($badgeSpan.text()) || 0;
                    $badgeSpan.text(count + 1);
                } else {
                    const newBadge = '<span class="unread-badge" style="background: #e53935; color: #fff; font-size: 11px; padding: 4px 8px; border-radius: 12px; margin-left: 8px;">1</span>';
                    $roomItem.find('.room-top').append(newBadge);
                }

                const projectKey = $roomItem.data('project-key');
                if (projectKey) {
                    const $projectHeader = $('.project-header')
                        .filter(function () {
                            return $(this).find('#icon-' + projectKey).length > 0;
                        });

                    let $totalBadge = $projectHeader.find('.total-unread-badge');
                    if ($totalBadge.length > 0) {
                        let total = parseInt($totalBadge.text()) || 0;
                        $totalBadge.text(total + 1);
                    } else {
                        const newTotalBadge =
                            '<span class="total-unread-badge" style="background:#173160;color:#fff;font-size:11px;padding:2px 7px;border-radius:10px;margin-left:8px;">1</span>';
                        $projectHeader.find('div').first().append(newTotalBadge);
                    }
                }
            }
            const $parent = $roomItem.parent();
            $roomItem.detach().prependTo($parent);
        } else {
            loadChatRooms();
        }
    }

    function showReceivedMessage(msg) {
        const body = document.getElementById("chatBody");
        const mine = (msg.senderId == loginUserId);

        const timeText = new Date(msg.createdAt)
            .toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

        const div = document.createElement("div");
        div.className = "message " + (mine ? "mine" : "");
        div.id = "msg-" + msg.messageId;
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
        if (msg.fileUrl) {
            let fileSizeHtml = "";
            if (msg.fileUrl !== null && msg.fileUrl !== "") {
                fileSizeHtml =
                    '<span style="font-size: 11px; color: #888; margin-left: 5px;">' +
                    '(' + formatFileSize(msg.fileSize) + ')' +
                    '</span>';
                appendFileToInfo(msg);
            }
            fileHtml =
                '📎 <a href="/ratelocean/chat/file/' + msg.messageId + '">' +
                escapeHtml(msg.fileName) + '</a>' +
                fileSizeHtml;
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
        body.appendChild(div);
        body.scrollTop = body.scrollHeight;
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
                return;
            }
        }
        fileContainer.innerHTML = "";
        let filesExist = false;
        messages.forEach(msg => {
            if (msg.fileUrl && msg.isDeleted != 1) {
                filesExist = true;
                const div = document.createElement("div");
                div.className = "file-item";
                div.innerHTML =
                    '📎 <a href="/ratelocean/chat/file/' + msg.messageId + '">' +
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
                const profileImg = room.profileImageUrl
                    ? '/ratelocean' + room.profileImageUrl
                    : '/ratelocean/resources/image/default-profile.png';
                const info = document.getElementById("roomInfo");
                let contractBtnHtml = "";
                if (loginUserType  === 'CLIENT') {  // 로그인 유저 타입이 CLIENT일 때만
                    contractBtnHtml =
                        '<a href="/ratelocean/client/contract/form" ' +
                        'style="background-color: #3b6fdc; color: white; margin-top: 5px;">계약하기</a>';
                }
                info.innerHTML =
                    '<div class="profile-card">' +
                    '   <img src="' + profileImg + '" class="avatar">' +
                    '   <h3>' + room.name + '</h3>' +
                    '   <div class="action-buttons" style="display: flex; flex-direction: column; gap: 8px;">' +
                    '       <div style="display: flex; gap: 8px; width: 100%;">' +
                    '           <a href="/ratelocean/profile/' + room.opponentId + '" style="flex: 1;">프로필</a>' +
                    '           <a href="/ratelocean/project/detail?projectId=' + room.projectId +
                    '&page=1&size=10&onlyActive=false&keyword=" class="secondary" style="flex: 1;">프로젝트</a>' +
                    '       </div>' +
                    contractBtnHtml +
                    '   </div>' +
                    '</div>' +
                    '<div class="info-section">' +
                    '   <h4>공유 파일</h4>' +
                    '   <div class="file-list"></div>' +
                    '</div>';
        }).catch(err => console.error("방 정보 로드 실패:", err));
    }
    function initEmptyRoom() {
        document.getElementById("headerName").innerText = "";
        document.getElementById("headerProject").innerText = "";
        document.getElementById("chatBody").innerHTML =
            '<div class="empty-room">채팅방을 선택해주세요</div>';
        document.getElementById("roomInfo").innerHTML = "";
        messageInput.disabled = true;
        document.querySelector(".send-btn").disabled = true;
        document.getElementById("exitRoomBtn").style.display = "none";
        const searchArea = document.getElementById("searchArea");
        if (searchArea) {
            searchArea.style.display = "none";
        }
    }

    function selectRoom(roomId) {
        messageInput.value = "";
        const fileInput = document.getElementById("fileInput");
        if (fileInput) fileInput.value = "";
        const filePreview = document.getElementById("filePreview");
        if (filePreview) filePreview.style.display = "none";
        if (selectedRoomId === roomId) return;
        selectedRoomId = roomId;
        opponentExited = false;
        document.getElementById("exitRoomBtn").style.display = "inline-block";
        const searchArea = document.getElementById("searchArea");
        if (searchArea) {
            searchArea.style.display = "flex";
        }
        loadMessages(roomId);
        const $roomItem = $('#room-item-' + roomId);
        changeTotalBadge(roomId, $roomItem);

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
        subscribeRoom(roomId);
    }
    function changeTotalBadge(roomId, $roomItem){

        const roomUnread = parseInt(
            $roomItem.find('.unread-badge').text()
        ) || 0;
        $roomItem.find('.unread-badge').remove();
        const projectKey = $roomItem.data('project-key');
        if (projectKey && roomUnread > 0) {
            const $projectHeader = $('.project-header')
                .filter(function () {
                    return $(this).find('#icon-' + projectKey).length > 0;
                });

            const $totalBadge = $projectHeader.find('.total-unread-badge');

            if ($totalBadge.length > 0) {
                let total = parseInt($totalBadge.text()) || 0;
                total -= roomUnread;
                if (total <= 0) {
                    $totalBadge.remove();
                } else {
                    $totalBadge.text(total);
                }
            }
        }
    }
    function formatFileSize(bytes) {
        if (!bytes) return "";
        if (bytes < 1024) return bytes + "B";
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + "KB";
        return (bytes / 1024 / 1024).toFixed(1) + "MB";
    }
    let searchResults = [];
    let currentSearchIdx = -1;
    function appendFileToInfo(msg) {
        let fileContainer = document.querySelector("#roomInfo .file-list");
        if (!fileContainer || !msg.fileUrl) return;
        if (fileContainer.innerText.includes("공유된 파일 없음")) {
            fileContainer.innerHTML = "";
        }

        const div = document.createElement("div");
        div.className = "file-item";
        div.innerHTML = '📎 <a href="/ratelocean/chat/file/' + msg.messageId + '">' + escapeHtml(msg.fileName) + '</a>' +
            (msg.fileSize ? ' (' + formatFileSize(msg.fileSize) + ')' : '');
        fileContainer.appendChild(div);
    }
    function searchMessages() {
        const keyword = document.getElementById("searchInput").value.trim().toLowerCase();
        if (!keyword) {
            alert("검색어를 입력하세요.");
            return;
        }
        clearSearch(false);
        const bubbles = document.querySelectorAll("#chatBody .bubble:not(.deleted)");
        bubbles.forEach(bubble => {
            const text = bubble.innerText;
            if (text.toLowerCase().includes(keyword)) {
                const regex = new RegExp(`(${keyword})`, "gi");
                bubble.innerHTML = text.replace(regex, '<span class="search-highlight" style="background:#173160; font-weight: bold;">$1</span>');
                searchResults.push(bubble);
            }
        });

        if (searchResults.length > 0) {
            document.getElementById("searchNav").style.display = "flex";
            navSearch(1);
        } else {
            alert("검색 결과가 없습니다.");
            document.getElementById("searchNav").style.display = "none";
        }
    }

    function navSearch(direction) {
        if (searchResults.length === 0) return;
        currentSearchIdx += direction;
        if (currentSearchIdx < 0) currentSearchIdx = searchResults.length - 1;
        if (currentSearchIdx >= searchResults.length) currentSearchIdx = 0;

        const target = searchResults[currentSearchIdx];

        searchResults.forEach(el => el.style.outline = "none");
        target.style.outline = "2px solid #173160";
        target.style.outlineOffset = "2px";
        target.scrollIntoView({ behavior: "smooth", block: "center" });
        document.getElementById("searchIndex").innerText = (currentSearchIdx + 1) + " / " + searchResults.length;
    }

    function clearSearch(clearInput = true) {
        searchResults = [];
        currentSearchIdx = -1;
        if(clearInput) document.getElementById("searchInput").value = "";
        document.getElementById("searchNav").style.display = "none";

        const bubbles = document.querySelectorAll("#chatBody .bubble");
        bubbles.forEach(bubble => {
            bubble.innerHTML = bubble.innerText;
            bubble.style.outline = "none";
        });
    }

    function connectStompOnce() {
        if (stompClient) return;
        const socket = new SockJS('${pageContext.request.contextPath}/ws-stomp');
        stompClient = Stomp.over(socket);
        stompClient.debug = null;
        stompClient.connect({}, () => {
            listSubscription = stompClient.subscribe(
                '/sub/chat/list/' + loginUserId,
                msg => updateChatListUI(JSON.parse(msg.body))
            );
            if (pendingRoomId) {
                subscribeRoom(pendingRoomId);
                pendingRoomId = null;
            }
        });
    }

    function subscribeRoom(roomId) {
        if (!stompClient || !stompClient.connected) {
            pendingRoomId = roomId;
            connectStompOnce();
            return;
        }
        if (roomSubscription) {
            roomSubscription.unsubscribe();
        }
        roomSubscription = stompClient.subscribe(
            '/sub/chat/room/' + roomId,
            msg => {
                const received = JSON.parse(msg.body);
                if (received.type === 'DELETE') {
                    handleDeleteMessageUI(received.messageId);
                } else {
                    showReceivedMessage(received);
                }
            }
        );
    }







</script>
<script src="/ratelocean/resources/js/chat.js"></script>
</body>
</html>
