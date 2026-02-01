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
                <div style="margin-left: auto; display: flex; align-items: center; gap: 8px;">

                    <div id="searchArea" style="display: none; align-items: center; gap: 5px;">
                        <input type="text" id="searchInput" placeholder="메시지 검색"
                               style="padding: 5px 8px; border: 1px solid #ddd; border-radius: 4px; font-size: 12px; width: 130px;">
                        <button onclick="searchMessages()"
                                style="padding: 5px 10px; background: #f8f9fa; border: 1px solid #ccc; border-radius: 4px; cursor: pointer; font-size: 12px;">🔍</button>

                        <div id="searchNav" style="display: none; align-items: center; gap: 5px; background: #fff; padding: 0 5px; border-radius: 4px;">
                            <button onclick="navSearch(-1)" style="border:none; background:none; cursor:pointer; padding:0 2px;">▲</button>
                            <button onclick="navSearch(1)" style="border:none; background:none; cursor:pointer; padding:0 2px;">▼</button>
                            <span id="searchIndex" style="font-size: 11px; color: #666; min-width: 30px; text-align: center;">0/0</span>
                            <button onclick="clearSearch()" style="border:none; background:none; cursor:pointer; color: #ff4d4f; font-weight: bold; margin-left:2px;">✕</button>
                        </div>

            </div>
        </div>
                <div style="display: flex; flex-direction: column; align-items: flex-end; gap: 5px;">
                    <button id="exitRoomBtn" onclick="exitRoom()" style="display:none; font-size: 13px;">나가기</button>
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
        <!-- JS로 로드 -->
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

                    // 선택된 방 초기화
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
    // ================== 채팅방 목록 로드 (왼쪽 사이드바) ==================
    function loadChatRooms() {
        fetch("/ratelocean/chat/rooms")
            .then(res => res.json())
            .then(list => {
                const container = document.getElementById("roomList");
                let finalHtml = ""; // 모든 HTML을 합쳐서 담을 변수D
                if (loginUserType === 'CLIENT') {
                    const projectGroups = {};
                    const projectOrder = [];
                    list.forEach(room => {
                        if (!projectGroups[room.title]) {
                            projectGroups[room.title] = [];
                            projectOrder.push(room.title); // 처음 발견된 순서(정렬된 순서)대로 프로젝트 저장
                        }
                        projectGroups[room.title].push(room);
                    });
                    projectOrder.forEach(title => {
                        const rooms = projectGroups[title];
                        const safeId = btoa(encodeURIComponent(title)).replace(/=/g, "");
                        const totalUnread = rooms.reduce((sum, room) => sum + (room.unreadCount || 0), 0);

                        let unreadBadge = "";
                        if (totalUnread > 0) {
                            unreadBadge = '<span class="total-unread-badge" style="background: #e53935; color: #fff; font-size: 11px; padding: 2px 7px; border-radius: 10px; margin-left: 8px; vertical-align: middle;">' + totalUnread + '</span>';
                        }
                        // 1. 헤더 (프로젝트 바)
                        finalHtml +=
                            '<div class="project-header" onclick="toggleApplicants(\'' + safeId + '\')" ' +
                            'style="padding: 15px; background: #f8f9fa; border-bottom: 1px solid #ddd; cursor: pointer; ' +
                            'display: flex; justify-content: space-between; align-items: center; font-weight: bold; color: #333;">' +
                            '   <div>' +
                            '       <span style="font-size: 15px;">' + title + '</span>' +
                            '       <span style="font-size: 12px; color: #666; font-weight: normal; margin-left: 8px;">지원자 ' + rooms.length + '명</span>' +
                            '       ' + unreadBadge + // 여기에 총 안 읽은 개수 표시
                            '   </div>' +
                            '   <span id="icon-' + safeId + '" style="font-size: 12px; color: #999;">▼</span>' +
                            '</div>';

                        // 2. 지원자 목록 영역 시작 (style="display: none"을 여기서 확실히!)
                        finalHtml += '<div id="group-' + safeId + '" class="applicant-list-container" style="display: none; background: #fff;">';

                        // 3. 내부 지원자들 추가 (renderSingleRoom 호출)
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
            unreadHtml = '<span class="unread-badge" style="background: #e53935; color: #fff; font-size: 11px; padding: 4px 8px; border-radius: 12px; margin-left: 8px;">' + room.unreadCount + '</span>';
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

    // (선택사항) 입력 내용에 따라 입력창 높이가 늘어나는 함수
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
        fileInput.value = ""; // 파일 선택 초기화

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
            if(!res.ok) alert("삭제 실패");
        });
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
                    div.id = "msg-" + msg.messageId;
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
                                '<a href="/ratelocean/chat/file/' + msg.messageId + '">' +
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
        // 해당 messageId를 id로 가진 HTML 요소를 찾아 제거하거나 내용을 변경함
        // 예: <div id="msg-123">...</div>
        const msgElement = document.getElementById("msg-" + messageId);
        if (msgElement) {
            const contentArea = msgElement.querySelector(".bubble");
            if(contentArea) {
                contentArea.innerText = "삭제된 메시지입니다.";
                contentArea.classList.add("deleted-text"); // 스타일링용 클래스
            }
            // 삭제 버튼 등 컨트롤 요소 숨기기
            const actionBtn = msgElement.querySelector(".delete-btn");
            if(actionBtn) actionBtn.style.display = "none";
        }
    }

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

                // ===== 🔥 프로젝트 total unread =====
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
                            '<span class="total-unread-badge" style="background:#e53935;color:#fff;font-size:11px;padding:2px 7px;border-radius:10px;margin-left:8px;">1</span>';
                        $projectHeader.find('div').first().append(newTotalBadge);
                    }
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

    // 수신된 메시지를 화면에 그리기
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
        // ===================== 파일 메시지 =====================
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
                '<div class="file-section" style="margin-bottom: 5px; border-bottom: 1px dashed rgba(0,0,0,0.1); padding-bottom: 5px;">' +
                '📎 <a href="/ratelocean/chat/file/' + msg.messageId + '">' +
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
                info.innerHTML =
                    `<div class="profile-card">
                   <img src="\${profileImg}" class="avatar">
                    <h3>\${room.name}</h3>
                    <div class="action-buttons">
                        <a href="/ratelocean/profile/\${room.opponentId}">프로필</a>
                       <a href="/ratelocean/project/detail?projectId=\${room.projectId}&page=1&size=10&onlyActive=false&keyword="
       class="secondary">프로젝트</a>
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
        const searchArea = document.getElementById("searchArea");
        if (searchArea) {
            searchArea.style.display = "none";
        }
    }

    function selectRoom( roomId) {
        // 기존 방 구독 해제 (다른 방으로 이동 시)
        console.log(roomId);
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
            searchArea.style.display = "flex"; // 검색 영역 내부가 flex 구조이므로 flex로 설정
        }
        loadMessages(roomId);


        const $roomItem = $('#room-item-' + roomId);

        // 1️⃣ 이 방의 unread 개수
        const roomUnread = parseInt(
            $roomItem.find('.unread-badge').text()
        ) || 0;

        // 2️⃣ 방 unread 뱃지 제거
        $roomItem.find('.unread-badge').remove();

        // 3️⃣ 프로젝트 key 가져오기 (renderSingleRoom에서 심어둔 값)
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

    function formatFileSize(bytes) {
        if (!bytes) return "";
        if (bytes < 1024) return bytes + "B";
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + "KB";
        return (bytes / 1024 / 1024).toFixed(1) + "MB";
    }
    let searchResults = []; // 검색된 메시지 엘리먼트 배열
    let currentSearchIdx = -1;
    // [신규 추가] 공유 파일 목록에 항목 하나만 추가하는 함수
    function appendFileToInfo(msg) {
        let fileContainer = document.querySelector("#roomInfo .file-list");
        if (!fileContainer || !msg.fileUrl) return;

        // 만약 '공유된 파일 없음' 문구가 있다면 제거
        if (fileContainer.innerText.includes("공유된 파일 없음")) {
            fileContainer.innerHTML = "";
        }

        const div = document.createElement("div");
        div.className = "file-item";
        div.innerHTML = '📎 <a href="/ratelocean/chat/file/' + msg.messageId + '">' + escapeHtml(msg.fileName) + '</a>' +
            (msg.fileSize ? ' (' + formatFileSize(msg.fileSize) + ')' : '');

        // 맨 아래에 추가
        fileContainer.appendChild(div);
    }
    function searchMessages() {
        const keyword = document.getElementById("searchInput").value.trim().toLowerCase();
        if (!keyword) {
            alert("검색어를 입력하세요.");
            return;
        }

        // 초기화
        clearSearch(false);

        // chatBody 내의 모든 텍스트 메시지(bubble) 추출
        const bubbles = document.querySelectorAll("#chatBody .bubble:not(.deleted)");

        bubbles.forEach(bubble => {
            const text = bubble.innerText;
            if (text.toLowerCase().includes(keyword)) {
                // 키워드 하이라이트 (노란색 배경)
                const regex = new RegExp(`(${keyword})`, "gi");
                bubble.innerHTML = text.replace(regex, '<span class="search-highlight" style="background: yellow; font-weight: bold;">$1</span>');
                searchResults.push(bubble);
            }
        });

        if (searchResults.length > 0) {
            document.getElementById("searchNav").style.display = "flex";
            navSearch(1); // 첫 번째 결과로 스크롤
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

        // 모든 결과에서 포커스 제거 후 현재 타겟에만 오렌지색 테두리
        searchResults.forEach(el => el.style.outline = "none");
        target.style.outline = "2px solid orange";
        target.style.outlineOffset = "2px";

        // 해당 메시지 위치로 부드럽게 이동
        target.scrollIntoView({ behavior: "smooth", block: "center" });

        // 인덱스 표시 (예: 1 / 5)
        document.getElementById("searchIndex").innerText = (currentSearchIdx + 1) + " / " + searchResults.length;
    }

    function clearSearch(clearInput = true) {
        searchResults = [];
        currentSearchIdx = -1;
        if(clearInput) document.getElementById("searchInput").value = "";
        document.getElementById("searchNav").style.display = "none";

        // 하이라이트 및 테두리 복구
        const bubbles = document.querySelectorAll("#chatBody .bubble");
        bubbles.forEach(bubble => {
            bubble.innerHTML = bubble.innerText; // 하이라이트 제거
            bubble.style.outline = "none";
        });
    }

    function connectStompOnce() {
        if (stompClient) return;

        const socket = new SockJS('${pageContext.request.contextPath}/ws-stomp');
        stompClient = Stomp.over(socket);
        stompClient.debug = null;

        stompClient.connect({}, () => {
            // 🔥 목록 구독은 최초 1번만
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



    messageInput.addEventListener("keydown", (e) => {
        if (!selectedRoomId) return;

        // 엔터키 입력 시
        if (e.key === "Enter") {
            if (e.shiftKey) {
                // Shift + Enter: 기본 동작인 줄바꿈을 허용함
                // textarea 높이를 자동 조절하고 싶다면 아래 함수 호출 (선택사항)
            } else {
                // 그냥 Enter: 메시지 전송
                e.preventDefault(); // 줄바꿈 방지
                sendMessage();
                // 전송 후 높이 초기화
                messageInput.style.height = 'auto';
            }
        }
    });
    document.addEventListener("keydown", (e) => {
        const fileInput = document.getElementById("fileInput");
        const hasFile = fileInput && fileInput.files.length > 0; // 파일이 선택되었는지 확인

        // 엔터키를 눌렀고, 파일이 선택된 상태이며, 채팅방이 선택되어 있을 때
        if (e.key === "Enter" && !e.shiftKey && hasFile && selectedRoomId) {
            // 단, 검색창(searchInput)이나 다른 입력창에 있을 때는 제외
            if (e.target.tagName !== "TEXTAREA" && e.target.tagName !== "INPUT") {
                e.preventDefault();
                sendMessage();
            }
        }
    });
    document.addEventListener("DOMContentLoaded", function() {
        const searchInput = document.getElementById("searchInput");
        if (searchInput) {
            searchInput.addEventListener("keydown", function(event) {
                // 1. 엔터키를 누르면 검색 실행
                if (event.key === "Enter") {
                    event.preventDefault();
                    searchMessages();
                }
                // 2. 위쪽 방향키를 누르면 이전 결과로 이동 (▲ 버튼과 동일)
                else if (event.key === "ArrowUp") {
                    event.preventDefault();
                    if (typeof navSearch === "function") navSearch(-1);
                }
                // 3. 아래쪽 방향키를 누르면 다음 결과로 이동 (▼ 버튼과 동일)
                else if (event.key === "ArrowDown") {
                    event.preventDefault();
                    if (typeof navSearch === "function") navSearch(1);
                }
            });
        }
    });
    document.getElementById("fileInput").addEventListener("change", function () {
        const file = this.files[0];

        if (file) {
            document.getElementById("filePreview").style.display = "flex";
            document.getElementById("fileNameText").innerText = file.name;
        }
    });
    $(document).ready(function() {
        const urlParams = new URLSearchParams(window.location.search);
        const mode = urlParams.get('mode');

        if (mode === 'view') {
            $(".app").addClass("full-chat");
        }

        loadChatRooms();
        connectStompOnce();

        if (!autoRoomId) {
            initEmptyRoom();
        }
        tryAutoEnter(); // ✅ 여기 딱 한 번

    });

    window.addEventListener("beforeunload", () => {
        if (stompClient) {
            stompClient.disconnect();
        }
    });

</script>
</body>
</html>
