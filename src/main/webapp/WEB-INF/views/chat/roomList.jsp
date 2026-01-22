<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>채팅 목록</title>

    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f5f6f7;
        }

        .chat-list-wrapper {
            max-width: 420px;
            height: 100vh;
            margin: 0 auto;
            background: #fff;
            border-left: 1px solid #ddd;
            border-right: 1px solid #ddd;
            display: flex;
            flex-direction: column;
        }

        .chat-header {
            padding: 16px;
            font-size: 18px;
            font-weight: bold;
            border-bottom: 1px solid #eee;
        }

        .chat-list {
            flex: 1;
            overflow-y: auto;
        }

        .chat-room-link {
            text-decoration: none;
            color: inherit;
        }

        .chat-room {
            display: flex;
            align-items: center;
            padding: 12px 16px;
            border-bottom: 1px solid #f0f0f0;
            cursor: pointer;
        }

        .chat-room:hover {
            background: #f9f9f9;
        }

        .avatar {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            margin-right: 12px;
            object-fit: cover;
        }

        .room-info {
            flex: 1;
        }

        .room-top {
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            font-weight: 600;
        }

        .room-bottom {
            font-size: 13px;
            color: #666;
            margin-top: 4px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .unread-badge {
            background: #e53935;
            color: #fff;
            font-size: 11px;
            padding: 4px 8px;
            border-radius: 12px;
            margin-left: 8px;
        }
        .room-top {
            display: flex;
            align-items: center;
            gap: 6px;
        }

        /* 이름 (작게) */
        .room-name {
            font-size: 12px;
            color: #777;
        }

        /* 프로젝트명 (크게, 강조) */
        .room-title {
            font-size: 14px;
            font-weight: 600;
            color: #222;
        }

        /* 시간 */
        .room-time {
            margin-left: auto;
            font-size: 11px;
            color: #999;
        }

    </style>
</head>

<body>

<div class="chat-list-wrapper">

    <!-- 상단 -->
    <div class="chat-header">
        채팅
    </div>

    <!-- 채팅방 목록 -->
    <div class="chat-list" id="roomList">
        <!-- AJAX로 채워짐 -->
    </div>

</div>

<script>
    function loadChatRooms() {
        fetch("/ratelocean/chat/rooms")
            .then(res => res.json())
            .then(list => {
                const container = document.getElementById("roomList");
                container.innerHTML = "";

                list.forEach(room => {

                    // ✅ 시간 문자열
                    let timeText = "";
                    if (room.lastMessageAt) {
                        timeText = new Date(room.lastMessageAt)
                            .toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                    }

                    // ✅ 안 읽은 메시지 개수
                    let unreadHtml = "";
                    if (room.unreadCount > 0) {
                        unreadHtml =
                            '<span class="unread-badge">' +
                            room.unreadCount +
                            '</span>';
                    }

                    container.innerHTML +=
                        '<a href="/ratelocean/chat/room/' + room.roomId + '" class="chat-room-link">' +
                        '<div class="chat-room">' +

                        '<img src="' + (room.profileImageUrl || '/assets/img/default-profile.png') +
                        '" class="avatar">' +

                        '<div class="room-info">' +
                        '<div class="room-top">' +
                        '<span class="room-title">' + room.title + '</span>' + "  -  "+
                        '<span class="room-name">' + room.name + '</span>' +
                        '<span class="room-time">' + timeText + '</span>' +
                        '</div>' +

                        '<div class="room-bottom">' +
                        (room.lastMessageContent || '아직 메시지가 없습니다.') +
                        '</div>' +
                        '</div>' +

                        unreadHtml +

                        '</div>' +
                        '</a>';
                });
            });
    }

    loadChatRooms();
    setInterval(loadChatRooms, 3000);
</script>


</body>
</html>
