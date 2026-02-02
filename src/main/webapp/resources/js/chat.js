
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
    tryAutoEnter();
});

window.addEventListener("beforeunload", () => {
    if (stompClient) {
        stompClient.disconnect();
    }
});

document.addEventListener("keydown", (e) => {
    const fileInput = document.getElementById("fileInput");
    const hasFile = fileInput && fileInput.files.length > 0;
    if (e.key === "Enter" && !e.shiftKey && hasFile && selectedRoomId) {
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
            if (event.key === "Enter") {
                event.preventDefault();
                searchMessages();
            }

            else if (event.key === "ArrowUp") {
                event.preventDefault();
                if (typeof navSearch === "function") navSearch(-1);
            }

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

messageInput.addEventListener("keydown", (e) => {
    if (!selectedRoomId) return;
    if (e.key === "Enter") {
        if (e.shiftKey) {
        } else {
            e.preventDefault();
            sendMessage();
            messageInput.style.height = 'auto';
        }
    }
});
