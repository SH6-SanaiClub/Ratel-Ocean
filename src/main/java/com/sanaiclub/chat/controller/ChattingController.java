package com.sanaiclub.chat.controller;

import com.sanaiclub.chat.model.dto.ChatMessageDTO;
import com.sanaiclub.chat.model.dto.ChatRoomDTO;
import com.sanaiclub.chat.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/chat")
@RequiredArgsConstructor
public class ChattingController {

    private final ChatService chatService;

    // 채팅 아이콘 → 목록 화면
    @GetMapping
    public String roomList() {

        return "chat/roomList";
    }


    @GetMapping("/room/{roomId}/info")
    @ResponseBody
    public ChatRoomDTO roomInfo(
            @PathVariable Integer roomId,
            HttpSession session
    ) {
        Integer loginUserId = 5; // 실제 세션 로그인 유저 id로 교체

        // 서비스에서 ChatRoomDTO 반환하도록
        return chatService.findRoomInfo(roomId, loginUserId);
    }

    @PostMapping("/room/{roomId}/read")
    @ResponseBody
    public void markAsRead(@PathVariable Integer roomId) {
        chatService.markRoomAsRead(roomId);
    }

    // 채팅방 목록 데이터 (AJAX)
    @GetMapping("/rooms")
    @ResponseBody
    public List<ChatRoomDTO> rooms() {
        return chatService.findMyRooms();
    }

    // 메시지 목록 조회
    @GetMapping("/room/{roomId}/messages")
    @ResponseBody
    public List<ChatMessageDTO> getMessages(@PathVariable Integer roomId) {
        return chatService.findMessages(roomId);
    }
    //방 나가기
    @PostMapping("/room/{roomId}/exit")
    @ResponseBody
    public String exitRoom(@PathVariable Integer roomId, HttpSession session) {
        Integer loginUserId = 5;
        chatService.exitRoom(roomId, loginUserId);

        return "ok";
    }


    @GetMapping("/room/{roomId}/typing")
    @ResponseBody
    public Integer getTyping(@PathVariable Integer roomId) {
        return chatService.getTypingUser(roomId);
    }

    @PostMapping("/room/{roomId}/typing")
    @ResponseBody
    public void typing(
            @PathVariable Integer roomId,
            @RequestParam boolean typing
    ) {
        chatService.updateTyping(roomId, typing);
    }

    @PostMapping("/room/{roomId}/typing/reset")
    @ResponseBody
    public void resetTyping(@PathVariable Integer roomId) {
        chatService.resetTyping(roomId);
    }

    // 메시지 전송
    @PostMapping("/room/{roomId}/message")
    public ResponseEntity<ChatMessageDTO> sendMessage(
            @PathVariable Integer roomId,
            @RequestParam String content,
            @RequestParam(required = false) MultipartFile file,
            HttpSession session
    ) throws IOException {
        String fileName = null;
        String fileUrl = null;
        Long fileSize = null;
        if (file != null && !file.isEmpty()) {
            fileName = file.getOriginalFilename();
            fileSize = file.getSize();
            String uploadDir = "C:/upload/chat";
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();
            File savedFile = new File(uploadDir, fileName);
            file.transferTo(savedFile);
            fileUrl = "/upload/chat/" + fileName;
        }
        Integer senderId = 1;
        ChatMessageDTO message =
                chatService.sendAndReturnMessage(
                        roomId,
                        senderId,
                        content,
                        fileName,
                        fileUrl,
                        fileSize
                );
        return ResponseEntity.ok(message);
    }

    // 채팅방 진입 (화면)
    @GetMapping("/room/{roomId}") // room_id -> roomId
    public String roomPage(@PathVariable Integer roomId, Model model, HttpSession httpSession) {
        // login_user_id -> loginUserId
        Integer loginUserId = (Integer) httpSession.getAttribute("loginUserId");
        model.addAttribute("roomId", roomId); // room_id -> roomId
        httpSession.setAttribute("loginUserId", 5);
        return "chat/room";
    }

    @PostMapping("/message/{messageId}/delete") // message_id -> messageId
    @ResponseBody
    public ResponseEntity<?> deleteMessage(@PathVariable int messageId) {
        try {
            chatService.deleteMessage(messageId); // delete_message -> deleteMessage
            return ResponseEntity.ok().build(); // 200 OK
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("삭제 실패");
        }
    }
}