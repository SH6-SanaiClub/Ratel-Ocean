<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.6.1/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>

<style>
    /* [핵심 해결] 부모(chatContainer) 내부에 절대적으로 꽉 차게 고정 */
    #embed-chat-wrapper {
        position: absolute !important;
        top: 0 !important;
        bottom: 0 !important;
        left: 0 !important;
        right: 0 !important;

        display: flex !important;
        flex-direction: column !important;
        background-color: #fff !important;
        overflow: hidden !important;
        z-index: 10 !important;
    }

    /* 채팅 내용 영역 (스크롤) */
    #embed-chat-body {
        flex: 1 !important;
        overflow-y: auto !important;
        padding: 15px !important;
        background-color: #f8f9fa !important;
        display: flex !important;
        flex-direction: column !important;
        gap: 10px !important;
        width: 100% !important;
    }

    /* 입력 영역 (하단 고정) */
    #embed-chat-input-area {
        flex-shrink: 0 !important;
        padding: 10px !important;
        background: #fff !important;
        border-top: 1px solid #eee !important;
        display: none; /* 연결 시 flex로 변경 */
        gap: 8px !important;
        align-items: center !important;
        width: 100% !important;
        box-sizing: border-box !important;
    }

    #embed-message-input {
        flex: 1 !important;
        border: 1px solid #ddd !important;
        border-radius: 4px !important;
        padding: 8px !important;
        height: 40px !important;
        font-size: 13px !important;
        resize: none !important;
        outline: none !important;
    }

    .embed-btn-send {
        width: 60px !important;
        height: 40px !important;
        background: #173160 !important;
        color: white !important;
        border: none !important;
        border-radius: 4px !important;
        cursor: pointer !important;
        font-weight: bold !important;
    }

    /* 기타 스타일 */
    .embed-msg { max-width: 80%; padding: 8px 12px; border-radius: 8px; font-size: 13px; line-height: 1.4; word-wrap: break-word; }
    .embed-msg.mine { align-self: flex-end; background-color: rgba(59, 111, 220, .10); color: #333; border-bottom-right-radius: 0; }
    .embed-msg.other { align-self: flex-start; background-color: #fff; border: 1px solid #ddd; color: #333; border-bottom-left-radius: 0; }
    .embed-placeholder { height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center; color: #999; font-size: 13px; }
</style>

<div id="embed-chat-wrapper">
    <div id="embed-chat-body">
        <div class="embed-placeholder">
            <i class="fa-regular fa-comments" style="font-size: 30px; margin-bottom: 10px;"></i>
            <p>프로젝트를 선택하면<br>담당자와 연결됩니다.</p>
        </div>
    </div>
    <div id="embed-chat-input-area">
        <input type="file" id="embed-file-input" style="display:none">
        <button type="button" onclick="document.getElementById('embed-file-input').click()" style="background:none; border:1px solid #ddd; border-radius:4px; width:40px; height:40px; cursor:pointer;">📎</button>
        <textarea id="embed-message-input" placeholder="메시지 입력..."></textarea>
        <button class="embed-btn-send" onclick="sendEmbedMessage()">전송</button>
    </div>
</div>

<script>
    var currentEmbedLoginUserId = Number('${userId}' || '0');
    var embedStompClient = null;
    var currentEmbedRoomId = null;
    var embedSubscription = null;

    // 연결 함수 (전역)
    window.connectProjectChat = function(projectId, freelancerId) {
        if (!projectId || !freelancerId) {
            console.error("[Chat] 정보 부족");
            return;
        }

        var body = document.getElementById("embed-chat-body");
        body.innerHTML = '<div class="embed-placeholder"><i class="fa-solid fa-spinner fa-spin"></i><br>연결 중...</div>';

        fetch('${pageContext.request.contextPath}/chat/create-or-get-room?projectId=' + projectId + '&freelancerId=' + freelancerId, {
            method: 'POST'
        })
            .then(function(res) { return res.json(); })
            .then(function(roomId) {
                currentEmbedRoomId = roomId;
                // 입력창 보이기
                document.getElementById("embed-chat-input-area").style.display = "flex";
                document.getElementById("embed-chat-body").innerHTML = "";
                connectEmbedSocket(roomId);
            })
            .catch(function(err) {
                console.error("[Chat] 연결 실패:", err);
                body.innerHTML = '<div class="embed-placeholder" style="color:red;">연결 실패</div>';
            });
    };

    function connectEmbedSocket(roomId) {
        if (!embedStompClient || !embedStompClient.connected) {
            var socket = new SockJS('${pageContext.request.contextPath}/ws-stomp');
            embedStompClient = Stomp.over(socket);
            embedStompClient.debug = null;
            embedStompClient.connect({}, function() {
                subscribeEmbedRoom(roomId);
            });
        } else {
            subscribeEmbedRoom(roomId);
        }
    }

    function subscribeEmbedRoom(roomId) {
        if (embedSubscription) embedSubscription.unsubscribe();

        // 1. 이전 메시지
        fetch('${pageContext.request.contextPath}/chat/room/' + roomId + '/messages')
            .then(function(res) { return res.json(); })
            .then(function(msgs) {
                var body = document.getElementById("embed-chat-body");
                body.innerHTML = "";
                msgs.forEach(appendEmbedMessage);
                body.scrollTop = body.scrollHeight;
            });

        // 2. 실시간 구독
        embedSubscription = embedStompClient.subscribe('/sub/chat/room/' + roomId, function(res) {
            var msg = JSON.parse(res.body);
            if (msg.type !== 'DELETE') {
                appendEmbedMessage(msg);
                var body = document.getElementById("embed-chat-body");
                body.scrollTop = body.scrollHeight;
            }
        });
    }

    function appendEmbedMessage(msg) {
        var body = document.getElementById("embed-chat-body");
        var isMine = (msg.senderId == currentEmbedLoginUserId);

        var content = msg.content || "";
        if (msg.fileUrl) {
            content = '📎 <a href="${pageContext.request.contextPath}/chat/file/' + msg.messageId + '" target="_blank" style="color:inherit;">' + (msg.fileName || '파일') + '</a>';
        }

        var div = document.createElement("div");
        div.className = "embed-msg " + (isMine ? "mine" : "other");
        div.innerHTML = content;
        body.appendChild(div);
    }

    window.sendEmbedMessage = function() {
        var input = document.getElementById("embed-message-input");
        var text = input.value.trim();
        var fileInput = document.getElementById("embed-file-input");

        if ((!text && !fileInput.files.length) || !currentEmbedRoomId) return;

        var formData = new FormData();
        formData.append("content", text);
        if (fileInput.files.length > 0) formData.append("file", fileInput.files[0]);

        fetch('${pageContext.request.contextPath}/chat/room/' + currentEmbedRoomId + '/message', {
            method: "POST",
            body: formData
        }).then(function() {
            input.value = "";
            fileInput.value = "";
        });
    };

    document.getElementById("embed-message-input").addEventListener("keypress", function(e) {
        if (e.key === "Enter" && !e.shiftKey) {
            e.preventDefault();
            sendEmbedMessage();
        }
    });
</script>