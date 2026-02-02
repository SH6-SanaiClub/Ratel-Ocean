package com.sanaiclub.chat.controller;

import com.sanaiclub.chat.model.dto.ChatMessageDTO;
import com.sanaiclub.chat.model.dto.ChatRoomDTO;
import com.sanaiclub.chat.service.ChatService;
import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.user.model.vo.UserType;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/chat")
@RequiredArgsConstructor
public class ChattingRestController {

    private final ChatService chatService;
    private final SimpMessageSendingOperations messagingTemplate; // STOMP 메시지 전송 템플릿

    @GetMapping("/room/{roomId}/info")
    public ChatRoomDTO roomInfo( @PathVariable Integer roomId) {
        return chatService.findRoomInfo(roomId, AuthContext.getCurrentUserId());
    }

    @PostMapping("/room/{roomId}/read")
    public void markAsRead(@PathVariable Integer roomId) {
        chatService.markRoomAsRead(roomId, AuthContext.getCurrentUserId());
    }

    @PostMapping("/create-or-get-room")
    public Integer createOrGetRoom(
            @RequestParam Integer projectId,
            @RequestParam(required = false) Integer freelancerId
    ) {
        Integer loginUserId = AuthContext.getCurrentUserId();
        UserType userType = AuthContext.getCurrentUserType();
        Integer targetFreelancerId;

        if (UserType.CLIENT.equals(userType)) {
            targetFreelancerId = freelancerId;
        } else {
            targetFreelancerId = loginUserId;
        }
        return chatService.createOrGetRoom(projectId, targetFreelancerId);
    }

    @GetMapping("/rooms")
     public List<ChatRoomDTO> rooms() {
        return chatService.findMyRooms(AuthContext.getCurrentUserId());
    }

    @GetMapping("/room/{roomId}/messages")
    public List<ChatMessageDTO> getMessages(@PathVariable Integer roomId) {
        return chatService.findMessages(roomId);
    }

    @PostMapping("/room/{roomId}/exit")
    public String exitRoom(@PathVariable Integer roomId, HttpSession session) {
        chatService.exitRoom(roomId, AuthContext.getCurrentUserId());
        return "ok";
    }
    // 메시지 전송
    @PostMapping("/room/{roomId}/message")
    public ResponseEntity<ChatMessageDTO> sendMessage(
            @PathVariable Integer roomId,
            @RequestParam String content,
            @RequestParam(required = false) MultipartFile file,
            HttpSession session
    ) throws IOException {
        Integer senderId = AuthContext.getCurrentUserId();
        String uploadPath = session.getServletContext().getRealPath("/") + "upload/chat";
        ChatMessageDTO message = chatService.processAndSendMessage(
                roomId,
                senderId,
                content,
                file,
                uploadPath
        );
        return ResponseEntity.ok(message);
    }

    @GetMapping("/file/{messageId}")
    public ResponseEntity<Resource> downloadFile(
            @PathVariable Integer messageId, HttpSession session
    ) throws Exception {
        ChatMessageDTO msg = chatService.findFileByMessageId(messageId);

        if (msg == null || msg.getFileUrl() == null) {
            return ResponseEntity.notFound().build();
        }
        String contextPath = session.getServletContext().getRealPath("/");
        String filePath = contextPath + msg.getFileUrl();
        File file = new File(filePath);

        if (!file.exists()) {
            return ResponseEntity.notFound().build();
        }
        Resource resource = new FileSystemResource(file);

        String encodedFileName =
                URLEncoder.encode(msg.getFileName(), "UTF-8").replaceAll("\\+", "%20");

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename=\"" + encodedFileName + "\"")
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .contentLength(file.length())
                .body(resource);
    }

    @PostMapping("/message/{messageId}/delete")
    public ResponseEntity<?> deleteMessage(@PathVariable int messageId, @RequestBody Map<String, Integer> payload) {
        try {
            Integer roomId = payload.get("roomId");
            if (roomId == null) {
                return ResponseEntity.badRequest().body("roomId is missing");
            }
            chatService.deleteMessage(messageId);
            Map<String, Object> deleteSignal = new HashMap<>();
            deleteSignal.put("type", "DELETE");
            deleteSignal.put("messageId", messageId);
            messagingTemplate.convertAndSend("/sub/chat/room/" + roomId, deleteSignal);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Fail to delete");
        }
    }
}